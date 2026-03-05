# Agent Blueprint

A modular AI agent framework for [Craft Agent](https://craft.do).

Agent Blueprint gives you a system of modular AI agents — each with its own persona, responsibilities, workflows, and memory — orchestrated through a shared workspace. You start with the **Architect** agent, which designs and scaffolds all the others.

## What You Get

- **Framework docs** — system design and shared operating principles for all agents
- **Architect agent** — creates and manages other agents via guided Q&A
- **Session skills** — `/start` (boot an agent), `/handoff` (end session with continuity), `/new-agent` (create agents)
- **Workspace config** — labels, statuses, and views for Craft Agent

## Prerequisites

- [Craft Agent](https://craft.do) installed
- A workspace configured in Craft Agent

## Quick Start

### Windows (PowerShell)

```powershell
git clone https://github.com/mellowism/agent-blueprint.git
cd agent-blueprint
.\setup.ps1
```

### macOS / Linux (Bash)

```bash
git clone https://github.com/mellowism/agent-blueprint.git
cd agent-blueprint
chmod +x setup.sh
./setup.sh
```

The setup script asks:

1. **Your name** — how agents should address you
2. **System root folder** — where framework docs, agents, and registry live
3. **Craft Agent workspace path** — where skills, labels, and statuses go
4. **Multi-machine setup** *(optional)* — if you use multiple machines, each gets a name and context

### After Setup

1. Open Craft Agent
2. Verify your workspace points to the correct path
3. Start a new session and type `/start`
4. Select **Architect**
5. Say "I need a new agent" — the Architect walks you through creating your first one

## How It Works

```
System Root/
├── Life OS Framework.md          ← system design
├── Agent Principles.md           ← shared rules all agents follow
├── AI/
│   └── Agents/
│       ├── registry/
│       │   ├── shared.json       ← agents available on all machines
│       │   └── {machine}.json    ← machine-specific agents (multi-machine only)
│       └── Architect/            ← the seed agent
└── Knowledge/                    ← optional knowledge base

Craft Agent Workspace/
├── agent-blueprint.json          ← links workspace to system root
├── skills/
│   ├── start/                    ← boot an agent
│   ├── handoff/                  ← end session with continuity
│   ├── new-agent/                ← create agents
│   └── architect/                ← Architect boot pointer
├── labels/                       ← auto-labeling config
├── statuses/                     ← session statuses
└── views.json                    ← workspace views
```

### The Agent Pattern

Every agent follows the same structure:

```
Agent-Name/
├── System/               ← identity (README, persona, responsibilities, learnings)
├── Workflows/            ← procedures (built during first session)
├── Tools/                ← templates and scripts
└── Handover/             ← session continuity
    ├── latest.md         ← most recent handover
    └── Archive/          ← previous handovers
```

The Architect scaffolds the identity. The agent itself builds its workflows during first use.

### Session Lifecycle

1. `/start` → pick an agent → agent boots with persona + handover context
2. Work session → agent follows its workflows
3. `/handoff` → agent writes a handover for next time, reflects on learnings

Handovers are the memory model. No hidden state — everything is inspectable markdown.

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
- **Personal Assistant** — daily planning and task management
- **Smart Home Operator** — Home Assistant automations

## Multi-Machine Setup

Agent Blueprint supports running across multiple machines:

- **Agents + Framework** live in the system root → sync with your preferred tool (Syncthing, OneDrive, etc.)
- **Workspace config** lives in `~/.craft-agent/` → local per machine, set up via the setup script
- Each machine gets a **name** and **context** (e.g. "home", "office") during setup
- Agents live in **per-scope registry files** — `shared.json` (all machines) + `{machine}.json` (machine-specific). A work agent in `work-laptop.json` won't appear on your home machine.
- Handovers are per-machine (`latest-{machine}.md`) so sessions don't collide

Run the setup script on each machine, pointing to your synced system root. Choose "yes" for multi-machine setup and give each machine a unique name.

## Design Principles

1. **Local-first** — all state is local files, no cloud dependency
2. **Modular agents** — each agent is self-contained with clear boundaries
3. **Separation of concerns** — knowledge ≠ agent ≠ workflow ≠ tool
4. **User control** — agents propose, user approves
5. **Inspectable state** — no hidden memory, everything is markdown files
6. **Agents stay in their lane** — agents don't modify shared infrastructure

## License

MIT
