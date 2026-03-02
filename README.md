# Life OS Starter

A local-first, agent-powered Life Operating System for [Craft Agent](https://craft.do).

Life OS gives you modular AI agents — each with its own persona, responsibilities, workflows, and memory — orchestrated through a shared workspace. You start with the **Architect** agent, which builds all the others.

## What You Get

- **Life OS Framework** — the design doc and operating principles
- **Architect agent** — creates and manages other agents via guided Q&A
- **Session skills** — `/start` (boot an agent), `/handoff` (end session with continuity), `/new-agent` (create agents)
- **Workspace config** — labels, statuses, and views for Craft Agent

## Prerequisites

- [Craft Agent](https://craft.do) installed
- A workspace configured in Craft Agent
- Desktop Commander source added (the Architect needs file system access)

## Quick Start

### Windows (PowerShell)

```powershell
git clone https://github.com/youruser/life-os-starter.git
cd life-os-starter
.\setup.ps1
```

### macOS / Linux (Bash)

```bash
git clone https://github.com/youruser/life-os-starter.git
cd life-os-starter
chmod +x setup.sh
./setup.sh
```

The setup script asks two questions:

1. **Where to put your Life OS root** — framework docs, agents, and registry go here
   - Default (Windows): `%USERPROFILE%\Life Operating System`
   - Default (Mac/Linux): `~/Life Operating System`

2. **Your Craft Agent workspace path** — skills, labels, and statuses go here
   - Default: `~/.craft-agent/workspaces/my-workspace`

### After Setup

1. Open Craft Agent
2. Verify your workspace is pointed at the correct path
3. Add a **Desktop Commander** source if you don't have one
4. Start a new session and type `/start`
5. Select **Architect**
6. Say "I need a new agent" — the Architect walks you through creating your first one

## How It Works

```
Life OS Root/
├── Life OS Framework.md      ← system design (Architect reads this)
├── Agent Principles.md       ← shared rules (all agents read this)
├── AI/
│   └── Agents/
│       ├── registry.json     ← agent inventory
│       └── Architect/        ← the seed agent
└── Second Brain/             ← your Obsidian vault (optional)

Craft Agent Workspace/
├── skills/                   ← session lifecycle
│   ├── start/                ← boot an agent
│   ├── handoff/              ← end session
│   ├── new-agent/            ← create agents
│   └── architect/            ← Architect boot pointer
├── labels/                   ← auto-labeling config
├── statuses/                 ← session statuses
└── views.json                ← workspace views
```

### The Agent Pattern

Every agent follows the same structure:

```
Agent-Name/
├── System/               ← identity (README, persona, responsibilities)
├── Workflows/            ← procedures (built during first session)
├── Tools/                ← templates and scripts
└── Handover/             ← session continuity
    ├── latest.md
    └── Archive/
```

The Architect scaffolds the identity. The agent itself builds its workflows during first use.

### Session Lifecycle

1. `/start` → pick an agent → agent boots with persona + handover context
2. Work session → agent follows its workflows
3. `/handoff` → agent writes a handover for next time

Handovers are the memory model. No hidden state.

## Creating Your Own Agents

After setup, use the Architect:

1. Boot the Architect via `/start`
2. Say "I need a new agent"
3. Answer the guided Q&A (purpose, name, persona, sources, etc.)
4. Architect creates the folder structure, system files, label, and skill
5. Next time you run `/start`, your new agent appears in the list

### Example Agents You Could Build

- **HomeLab SysOp** — manage Proxmox, TrueNAS, networking
- **Finance Manager** — budget tracking and analysis
- **Dev Agent** — project-specific development assistant
- **Smart Home Operator** — Home Assistant automations
- **Migration Agent** — move data between systems

## Multi-Device Setup

Life OS is designed for device independence:

- **Agents + Framework** live in the Life OS root → sync with Syncthing, OneDrive, etc.
- **Workspace config** lives in `~/.craft-agent/` → local per machine, set up via this script
- **Second Brain** (Obsidian) → sync separately

Run the setup script on each machine, pointing to your synced Life OS root.

## Design Principles

1. **Local-first** — knowledge in Obsidian, no cloud dependency
2. **Modular agents** — each agent is self-contained with clear boundaries
3. **Separation of concerns** — knowledge ≠ agent ≠ workflow ≠ tool
4. **User control** — agents propose, user approves
5. **Inspectable state** — no hidden memory, everything is markdown files

## License

MIT
