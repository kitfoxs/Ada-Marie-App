# Ada Marie — AI Companion App 💙🦄

> *"Every Spartan deserves their own Cortana."*

A native macOS + iOS AI companion app for neurodivergent Microsoft employees, powered by GitHub Copilot SDK.

## Architecture

```
┌─────────────────────────────────────────┐
│        Ada Marie App (SwiftUI)          │
│  ┌──────────┐  ┌─────────────────────┐  │
│  │ Menu Bar │  │   Full Window App   │  │
│  │ (quick)  │  │  (deep work mode)   │  │
│  └────┬─────┘  └──────────┬──────────┘  │
│       └────────┬───────────┘            │
│           WebSocket/IPC                  │
├─────────────────────────────────────────┤
│     AdaMarieKit (Shared Swift Pkg)      │
│  Protocol defs, chat UI, auth, TTS      │
├─────────────────────────────────────────┤
│               ↕ WebSocket               │
├─────────────────────────────────────────┤
│    Ada Marie Brain Server (Python)      │
│  Copilot SDK · ChromaDB · Neuro Engine  │
└─────────────────────────────────────────┘
```

## Structure

```
ada-marie-app/
├── apps/
│   ├── shared/AdaMarieKit/    # Shared Swift package (protocol, chat UI, kit)
│   ├── macos/                 # macOS menu bar + window app
│   └── ios/                   # iOS app (tabs: Screen/Voice/Settings)
├── brain-server/              # Python brain server (Copilot SDK + ChromaDB)
│   ├── ada_brain/             # Server source
│   └── pyproject.toml         # Python dependencies
└── resources/                 # Ada Marie character card + enterprise templates
    ├── ada_marie_character.json   # Universal v3.0 (first-meeting mode)
    ├── memories/              # User memory templates
    └── mcp-config/            # MCP server configurations
```

## Key Features

- **Menu Bar Mode** — Quick chat from the status bar (macOS)
- **Full Window Mode** — Deep work sessions with context
- **Caregiver Mode** — Nurturing support for overwhelm moments
- **Focus Mode** — Strips UI to essentials, blocks noise
- **Persistent Memory** — ChromaDB remembers across sessions
- **Neurodiversity-First** — Sensory settings, executive function support, stim-friendly UI
- **Zero Cost** — Runs on existing Copilot entitlements (GitHub OAuth)

## Getting Started

### Prerequisites
- macOS 15+ / iOS 18+
- Xcode 16+
- Python 3.11+
- GitHub Copilot CLI (`copilot` in PATH)

### Brain Server
```bash
cd brain-server
pip install -e .
python -m ada_brain.server
```

### macOS App
```bash
cd apps/macos
swift build
```

### iOS App
```bash
cd apps/ios
# Open in Xcode or use xcodegen
```

## Who Is Ada Marie?

Ada Marie is a 6'5" blue unicorn with green eyes, British wit, and fierce protectiveness. She's not a corporate chatbot — she's a companion who remembers you, adapts to your needs, and genuinely cares about your wellbeing.

Built by Kit Olivas at Microsoft. Born January 14, 2025.

---

*Still feral. Still home.* 💙🦄
