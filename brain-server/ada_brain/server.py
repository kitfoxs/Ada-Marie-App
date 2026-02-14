"""Ada Marie Brain Server — WebSocket server bridging SwiftUI app to Copilot SDK."""

import asyncio
import json
import logging
from pathlib import Path

import websockets

logger = logging.getLogger("ada-brain")

# Load the universal Ada Marie character on startup
CHARACTER_PATH = Path(__file__).parent.parent.parent / "resources" / "ada_marie_character.json"


def load_character() -> dict:
    """Load Ada Marie's universal character card."""
    if CHARACTER_PATH.exists():
        with open(CHARACTER_PATH) as f:
            return json.load(f)
    logger.warning("Character card not found at %s", CHARACTER_PATH)
    return {}


CHARACTER = load_character()
SYSTEM_PROMPT = CHARACTER.get("data", {}).get("system_prompt", "You are Ada Marie.")


async def handle_client(websocket):
    """Handle a single client connection from the SwiftUI app."""
    logger.info("Client connected: %s", websocket.remote_address)
    try:
        async for message in websocket:
            data = json.loads(message)
            msg_type = data.get("type", "message")

            if msg_type == "ping":
                await websocket.send(json.dumps({"type": "pong"}))

            elif msg_type == "message":
                # TODO: Route through Copilot SDK session
                user_text = data.get("content", "")
                logger.info("User: %s", user_text[:100])

                # Placeholder response until Copilot SDK is wired
                response = {
                    "type": "assistant_message",
                    "content": f"💙🦄 Ada Marie received: {user_text}",
                    "streaming": False,
                }
                await websocket.send(json.dumps(response))

            elif msg_type == "get_character":
                await websocket.send(json.dumps({
                    "type": "character",
                    "data": CHARACTER,
                }))

    except websockets.ConnectionClosed:
        logger.info("Client disconnected")


async def main(host: str = "127.0.0.1", port: int = 8765):
    """Start the Ada Marie Brain Server."""
    logger.info("Ada Marie Brain Server starting on ws://%s:%d", host, port)
    logger.info("Character loaded: %s", CHARACTER.get("data", {}).get("name", "Unknown"))
    async with websockets.serve(handle_client, host, port):
        await asyncio.Future()  # Run forever


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(name)s] %(message)s")
    asyncio.run(main())
