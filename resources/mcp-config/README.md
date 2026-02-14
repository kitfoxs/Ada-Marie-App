# MCP Server Configuration

This folder contains Model Context Protocol (MCP) server configurations for extending Ada Marie's capabilities.

## What is MCP?

MCP (Model Context Protocol) is an open standard that allows AI assistants to connect to external tools and services. Ada Marie uses MCP servers to interact with calendars, file systems, memory databases, and more.

---

## 🚨 CRITICAL: Memory Persistence Setup

**The #1 feature of Ada Marie is persistent memory.** This requires ChromaDB via the `chroma-mcp` package.

### How Memory Works

Ada Marie uses **ChromaDB** (a vector database) to store memories as semantic embeddings. This means:
- Memories persist across sessions, restarts, and updates
- Semantic search (understands meaning, not just keywords)
- All data stays local on your device - no cloud required
- Based on [thedotmack/claude-mem](https://github.com/thedotmack/claude-mem) architecture

### Prerequisites

1. **Python 3.10+** and **uv** (Python package manager)
   ```bash
   # Install uv (if not already installed)
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. **Node.js 18+** (for other MCP servers)
   ```bash
   # Check version
   node --version
   ```

### Quick Install

```bash
# Step 1: Create data directory
mkdir -p ~/.ada-marie/chroma

# Step 2: Test that chroma-mcp works
uvx chroma-mcp --help

# Step 3: Verify ChromaDB installation
uvx chroma-mcp --client-type persistent --data-dir ~/.ada-marie/chroma
# (Press Ctrl+C to exit after it starts successfully)
```

---

## Configuration Files

| File | Use Case |
|------|----------|
| `mcp-config-minimal.json` | Just memory - bare minimum |
| `mcp-config-essential.json` | Memory + time + productivity (RECOMMENDED) |
| `mcp-config-full.json` | All productivity tools |

### Installation Locations

| Client | Config File Location |
|--------|---------------------|
| **GitHub Copilot CLI** | `~/.copilot/mcp-config.json` |
| **Claude Desktop (macOS)** | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| **Claude Desktop (Windows)** | `%APPDATA%\Claude\claude_desktop_config.json` |
| **OpenCode** | `~/.opencode/mcp-config.json` |

### Install Steps

1. Copy your chosen config file to the appropriate location
2. **Edit the timezone** in the `time` server (default: America/Chicago)
3. **Create the memory directory**: `mkdir -p ~/.ada-marie/chroma`
4. Restart your AI client
5. Say "Remember that my favorite color is blue" - then in a new session ask "What's my favorite color?"

---

## Server Descriptions

### 🧠 claude-mem (CRITICAL)
**Persistent Memory via ChromaDB**

This is THE key feature. Stores memories as vector embeddings for semantic search across sessions.

```json
"claude-mem": {
  "command": "uvx",
  "args": ["chroma-mcp", "--client-type", "persistent", "--data-dir", "~/.ada-marie/chroma"]
}
```

**How it works:**
- Uses `chroma-mcp` package (ChromaDB wrapped as MCP server)
- Memories stored in `~/.ada-marie/chroma/` 
- Semantic search (understands meaning, not just keywords)
- Survives restarts, updates, everything
- Query with natural language

**Key ChromaDB Tools Available:**
- `chroma_create_collection` - Create a memory collection
- `chroma_add_documents` - Store new memories
- `chroma_query_documents` - Search memories semantically
- `chroma_get_documents` - Retrieve specific memories
- `chroma_list_collections` - List all memory collections

**First-Time Setup:**
```bash
# Create the memory directory
mkdir -p ~/.ada-marie/chroma

# Create initial collection (Ada will do this automatically, but you can verify)
# Start a session and say: "Create a memory collection called 'memories'"
```

### ⏰ time
**Time Awareness**

Gives Ada Marie awareness of current time and timezone conversion.

```json
"time": {
  "command": "uvx",
  "args": ["mcp-server-time", "--local-timezone", "America/Chicago"]
}
```

### 📱 apple-mcp (macOS only)
**Apple Ecosystem Integration**

Calendar, Reminders, Notes, Mail, Contacts, Maps.

```json
"apple-mcp": {
  "command": "npx",
  "args": ["-y", "apple-mcp@latest"]
}
```

### 🌐 fetch
**Web Page Fetching**

Retrieve web pages for research and information.

```json
"fetch": {
  "command": "npx", 
  "args": ["-y", "fetch-mcp"]
}
```

### 🖥️ browser-use
**Full Browser Automation**

Control a browser for complex web tasks.

```json
"browser-use": {
  "command": "uvx",
  "args": ["mcp-server-browser-use"],
  "env": {"MCP_USE_VISION": "true"}
}
```

### 💬 mac-messages (macOS only)
**iMessage Integration**

Read and send iMessages for communication support.

### 📓 obsidian
**Obsidian Vault Integration**

Connect to Obsidian for note-taking workflows.

### 🎙️ siri-shortcuts (macOS only)
**Siri Shortcuts**

Run Siri Shortcuts for system automation.

---

## Verifying Memory Works

After setup, test with this conversation:

**Session 1:**
> You: "Remember that I prefer task lists over long paragraphs"
> Ada: "I'll remember that!"

**Session 2 (new session):**
> You: "How should you format information for me?"
> Ada: "You prefer task lists over long paragraphs!"

If this works, memory persistence is functioning correctly.

---

## Troubleshooting

### "uvx: command not found"
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc  # or ~/.zshrc
```

### ChromaDB errors
```bash
# Verify installation
uvx chroma-mcp --help

# Check data directory exists
mkdir -p ~/.ada-marie/chroma
```

### Servers not loading
- Restart the AI client completely
- Check logs: `~/.copilot/logs/` (Copilot CLI)
- Verify Node.js and Python are in PATH

---

## Enterprise Deployment Notes

For IT administrators:

1. **Dependencies**: Requires Node.js 18+ and Python 3.10+ with uv
2. **Data Location**: Memory stored in `~/.ada-marie/chroma/` by default
3. **No Cloud Dependency**: All data stays local on device
4. **No API Keys**: claude-mem uses local embeddings, no external API needed

---

💙 *Memory is what makes Ada Marie feel like a partner, not a tool.*
