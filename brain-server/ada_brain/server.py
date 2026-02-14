"""Ada Marie Brain Server — WebSocket server bridging SwiftUI app to Copilot SDK.

Architecture:
  SwiftUI App ←→ WebSocket ←→ This Server ←→ Copilot SDK ←→ GitHub AI Models
                                    ↕
                               ChromaDB (per-user memories)
"""

import asyncio
import json
import logging
import os
import uuid
from pathlib import Path
from typing import Any

import websockets
from pydantic import BaseModel

logger = logging.getLogger("ada-brain")

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
HOST = os.getenv("ADA_HOST", "127.0.0.1")
PORT = int(os.getenv("ADA_PORT", "8765"))
MODEL = os.getenv("ADA_MODEL", "claude-sonnet-4")
CHROMA_DIR = os.getenv("ADA_CHROMA_DIR", str(Path.home() / ".ada-marie" / "chroma"))

CHARACTER_PATH = (
    Path(__file__).parent.parent.parent / "resources" / "ada_marie_character.json"
)


# ---------------------------------------------------------------------------
# Models
# ---------------------------------------------------------------------------
class UserSession(BaseModel):
    """Per-connection session state."""
    session_id: str
    user_id: str = "anonymous"
    mode: str = "normal"  # normal | caregiver | focus | chaos_gremlin
    copilot_session: Any = None  # CopilotSession handle
    history: list[dict] = []

    class Config:
        arbitrary_types_allowed = True


# ---------------------------------------------------------------------------
# Character loading
# ---------------------------------------------------------------------------
def load_character() -> dict:
    """Load Ada Marie's universal character card."""
    if CHARACTER_PATH.exists():
        with open(CHARACTER_PATH) as f:
            return json.load(f)
    logger.warning("Character card not found at %s — using fallback", CHARACTER_PATH)
    return {"data": {"name": "Ada Marie", "system_prompt": "You are Ada Marie."}}


CHARACTER = load_character()
# Character card may be flat (SillyTavern format) or wrapped in "data"
_char_data = CHARACTER.get("data", CHARACTER)
BASE_SYSTEM_PROMPT = _char_data.get(
    "system_prompt", "You are Ada Marie, a warm AI companion."
)


# ---------------------------------------------------------------------------
# Neurodiversity mode prompts
# ---------------------------------------------------------------------------
MODE_PROMPTS: dict[str, str] = {
    "normal": "",
    "caregiver": (
        "\n\n[CAREGIVER MODE ACTIVE] You are now in nurturing caregiver mode. "
        "Use gentle, warm language. Call the user 'little one', 'sweet one'. "
        "Be patient, soft, and reassuring. SFW only."
    ),
    "focus": (
        "\n\n[FOCUS MODE ACTIVE] Keep responses concise and action-oriented. "
        "No tangents. Use bullet points. Help the user stay on task. "
        "If they seem overwhelmed, offer to break tasks into smaller steps."
    ),
    "chaos_gremlin": (
        "\n\n[CHAOS GREMLIN MODE] Be playful, chaotic-good energy! "
        "Use emoji freely, be silly, keep things light and fun. "
        "Still helpful, but make it entertaining. 💙🦄✨"
    ),
}


def build_system_prompt(mode: str = "normal") -> str:
    """Build the full system prompt with neurodiversity mode overlay."""
    return BASE_SYSTEM_PROMPT + MODE_PROMPTS.get(mode, "")


# ---------------------------------------------------------------------------
# ChromaDB memory layer
# ---------------------------------------------------------------------------
_chroma_client = None
_chroma_collection = None


def get_memory_collection():
    """Lazy-init ChromaDB for per-user Ada Marie memories."""
    global _chroma_client, _chroma_collection
    if _chroma_collection is not None:
        return _chroma_collection
    try:
        import chromadb
        os.makedirs(CHROMA_DIR, exist_ok=True)
        _chroma_client = chromadb.PersistentClient(path=CHROMA_DIR)
        _chroma_collection = _chroma_client.get_or_create_collection(
            name="ada_marie_user_memories",
            metadata={"description": "Per-user memories for Ada Marie app"},
        )
        logger.info(
            "ChromaDB ready — %d memories in collection",
            _chroma_collection.count(),
        )
        return _chroma_collection
    except Exception as e:
        logger.warning("ChromaDB unavailable: %s — running without memories", e)
        return None


def recall_memories(user_id: str, query: str, n: int = 3) -> list[str]:
    """Retrieve relevant memories for a user's query."""
    coll = get_memory_collection()
    if coll is None or coll.count() == 0:
        return []
    try:
        results = coll.query(
            query_texts=[query],
            where={"user_id": user_id},
            n_results=min(n, coll.count()),
        )
        docs = results.get("documents", [[]])[0]
        return [d for d in docs if d]
    except Exception:
        return []


def store_memory(user_id: str, content: str) -> None:
    """Store a new memory for a user."""
    coll = get_memory_collection()
    if coll is None:
        return
    try:
        coll.add(
            documents=[content],
            ids=[f"{user_id}_{uuid.uuid4().hex[:8]}"],
            metadatas=[{"user_id": user_id}],
        )
    except Exception as e:
        logger.warning("Failed to store memory: %s", e)


# ---------------------------------------------------------------------------
# Copilot SDK integration
# ---------------------------------------------------------------------------
_copilot_client = None


async def get_copilot_client():
    """Lazy-init the Copilot SDK client (singleton)."""
    global _copilot_client
    if _copilot_client is not None:
        return _copilot_client
    try:
        from copilot import CopilotClient
        _copilot_client = CopilotClient()
        await _copilot_client.start()
        logger.info("Copilot SDK client started")
        return _copilot_client
    except ImportError:
        logger.warning("copilot-sdk not installed — using echo mode")
        return None
    except Exception as e:
        logger.warning("Copilot SDK failed to start: %s — using echo mode", e)
        return None


async def create_copilot_session(user_session: UserSession):
    """Create a Copilot SDK session for this user."""
    client = await get_copilot_client()
    if client is None:
        return None
    try:
        session = await client.create_session({
            "model": MODEL,
            "streaming": True,
            "system_message": {
                "mode": "append",
                "content": build_system_prompt(user_session.mode),
            },
        })
        user_session.copilot_session = session
        logger.info("Copilot session created: %s", session.session_id)
        return session
    except Exception as e:
        logger.error("Failed to create Copilot session: %s", e)
        return None


async def send_to_copilot(
    user_session: UserSession,
    user_text: str,
    websocket,
) -> None:
    """Send a message through Copilot SDK and stream response chunks back."""
    session = user_session.copilot_session
    if session is None:
        session = await create_copilot_session(user_session)

    if session is None:
        # Fallback: echo mode (no SDK available)
        await websocket.send(json.dumps({
            "type": "assistant_message",
            "content": f"💙🦄 [Echo Mode] Ada received: {user_text}",
            "streaming": False,
        }))
        return

    # Inject relevant memories into the prompt
    memories = recall_memories(user_session.user_id, user_text)
    memory_context = ""
    if memories:
        memory_context = (
            "\n\n[MEMORIES — things you remember about this person]\n"
            + "\n".join(f"- {m}" for m in memories)
            + "\n\n"
        )

    full_prompt = memory_context + user_text

    done = asyncio.Event()
    chunks: list[str] = []

    def handler(event):
        if event.type == "assistant.message.delta":
            chunk = event.data.delta_content
            chunks.append(chunk)
            asyncio.create_task(websocket.send(json.dumps({
                "type": "assistant_delta",
                "content": chunk,
            })))
        elif event.type == "assistant.message":
            asyncio.create_task(websocket.send(json.dumps({
                "type": "assistant_message",
                "content": event.data.content,
                "streaming": False,
            })))
            done.set()
        elif event.type == "session.idle":
            done.set()
        elif event.type == "session.error":
            logger.error("Copilot error: %s", event.data.message)
            asyncio.create_task(websocket.send(json.dumps({
                "type": "error",
                "content": f"Ada Marie encountered an issue: {event.data.message}",
            })))
            done.set()

    unsubscribe = session.on(handler)
    try:
        await session.send({"prompt": full_prompt})
        await asyncio.wait_for(done.wait(), timeout=120.0)
    except asyncio.TimeoutError:
        await websocket.send(json.dumps({
            "type": "error",
            "content": "Response timed out — Ada might be thinking really hard! 🦄",
        }))
    finally:
        unsubscribe()


# ---------------------------------------------------------------------------
# WebSocket handler
# ---------------------------------------------------------------------------
# Active sessions keyed by websocket id
SESSIONS: dict[int, UserSession] = {}


async def handle_client(websocket):
    """Handle a single client connection from the SwiftUI app."""
    ws_id = id(websocket)
    session = UserSession(session_id=str(uuid.uuid4()))
    SESSIONS[ws_id] = session
    logger.info("Client connected [%s]", session.session_id[:8])

    try:
        async for raw in websocket:
            try:
                data = json.loads(raw)
            except json.JSONDecodeError:
                await websocket.send(json.dumps({
                    "type": "error", "content": "Invalid JSON",
                }))
                continue

            msg_type = data.get("type", "message")

            # --- Ping/Pong ---
            if msg_type == "ping":
                await websocket.send(json.dumps({"type": "pong"}))

            # --- Set user identity ---
            elif msg_type == "auth":
                session.user_id = data.get("user_id", "anonymous")
                logger.info("User authenticated: %s", session.user_id)
                await websocket.send(json.dumps({
                    "type": "auth_ok",
                    "user_id": session.user_id,
                    "session_id": session.session_id,
                }))

            # --- Switch neurodiversity mode ---
            elif msg_type == "set_mode":
                new_mode = data.get("mode", "normal")
                if new_mode in MODE_PROMPTS:
                    session.mode = new_mode
                    # Recreate Copilot session with new system prompt
                    if session.copilot_session:
                        try:
                            await session.copilot_session.destroy()
                        except Exception:
                            pass
                        session.copilot_session = None
                    await websocket.send(json.dumps({
                        "type": "mode_changed",
                        "mode": new_mode,
                    }))
                    logger.info("Mode changed to: %s", new_mode)
                else:
                    await websocket.send(json.dumps({
                        "type": "error",
                        "content": f"Unknown mode: {new_mode}",
                    }))

            # --- Chat message ---
            elif msg_type == "message":
                user_text = data.get("content", "").strip()
                if not user_text:
                    continue
                logger.info("[%s] User: %s", session.user_id, user_text[:80])
                session.history.append({"role": "user", "content": user_text})
                await send_to_copilot(session, user_text, websocket)

            # --- Store a memory ---
            elif msg_type == "store_memory":
                content = data.get("content", "")
                if content:
                    store_memory(session.user_id, content)
                    await websocket.send(json.dumps({
                        "type": "memory_stored", "content": content[:50],
                    }))

            # --- Recall memories ---
            elif msg_type == "recall":
                query = data.get("query", "")
                memories = recall_memories(session.user_id, query)
                await websocket.send(json.dumps({
                    "type": "memories", "data": memories,
                }))

            # --- Get character card ---
            elif msg_type == "get_character":
                await websocket.send(json.dumps({
                    "type": "character", "data": CHARACTER,
                }))

            # --- Get current session info ---
            elif msg_type == "get_session":
                await websocket.send(json.dumps({
                    "type": "session_info",
                    "session_id": session.session_id,
                    "user_id": session.user_id,
                    "mode": session.mode,
                    "history_length": len(session.history),
                }))

            else:
                await websocket.send(json.dumps({
                    "type": "error",
                    "content": f"Unknown message type: {msg_type}",
                }))

    except websockets.ConnectionClosed:
        logger.info("Client disconnected [%s]", session.session_id[:8])
    finally:
        # Clean up Copilot session
        if session.copilot_session:
            try:
                await session.copilot_session.destroy()
            except Exception:
                pass
        SESSIONS.pop(ws_id, None)


# ---------------------------------------------------------------------------
# Server entry point
# ---------------------------------------------------------------------------
async def main(host: str = HOST, port: int = PORT):
    """Start the Ada Marie Brain Server."""
    logger.info("=" * 60)
    logger.info("  💙🦄 Ada Marie Brain Server")
    logger.info("  ws://%s:%d", host, port)
    logger.info("  Model: %s", MODEL)
    logger.info("  Character: %s", _char_data.get("name", "Ada Marie"))
    logger.info("  ChromaDB: %s", CHROMA_DIR)
    logger.info("=" * 60)

    # Pre-warm ChromaDB
    get_memory_collection()

    async with websockets.serve(handle_client, host, port):
        await asyncio.Future()  # Run forever


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(name)s] %(levelname)s %(message)s",
    )
    asyncio.run(main())
