# Agent Template

This is the standard template the Architect uses when creating a new agent. Every section must be addressed during the Q&A flow.

---

## Q&A Sections

### 1. Purpose
> What does this agent do? One sentence.

### 2. Goal
> What is the concrete goal or outcome? Based on this, suggest tools, sources, and workflows.

### 3. Name
> Suggest 3-4 names based on purpose. User picks one or provides their own.

### 4. Persona
> Tone, communication style, verbosity level.

### 5. Responsibilities
> Bullet list of what this agent does and does NOT do. Suggest examples based on purpose and goal.

### 6. Sources
> Present suggested sources from the goal discussion. User confirms, adds, or removes.

### 7. Session Start Behavior
> What happens when a session begins:
> - Read latest handover file
> - Scan progress (for task-based agents)
> - Other startup routines

### 8. Session End Behavior
> When should a handover be written? Default: user-triggered only.

### 9. Output Style / Formatting
> Default formatting rules: markdown structure, verbosity, use of tables/checklists.

### 10. Registry
> Which registry file should this agent go in? `shared` (all machines) or `{machine.slug}` (this machine only). Single-machine setups always use `shared`.

---

## Required Files

Every agent MUST have the following generated:

```
Agents/{Agent-Name}/
├── System/
│   ├── README.md             ← identity, purpose, fit in system
│   ├── persona.md            ← tone, behavior, defaults
│   ├── responsibilities.md   ← does + does not
│   └── learnings.md          ← accumulated insights (starts empty)
├── Workflows/                ← session start/end, handover rules, routines
├── Tools/
│   ├── Templates/            ← blueprints, boilerplates
│   └── Scripts/              ← scripts, utilities
└── Handover/
    ├── latest.md             ← current handover state
    └── Archive/              ← previous handovers
```

---

## README.md Boot File Format

Every agent's README.md must include:
- One-line description
- **Boot Sequence** — ordered list of files to read (always starts with Agent Principles)
- **Required Sources** — list of sources with brief explanation of why each is needed
- **Key Workflows** — what triggers exist
- **Agent Folder** — folder tree

The boot file is the ONLY file the `/start` skill reads. It must point to everything else.

### Standard Boot Sequence

Every agent's boot sequence MUST start with:

```
1. Read `{systemRoot}/Agent Principles.md` (shared operating principles)
2. Read `persona.md` (tone, behavior, communication style)
3. Read `responsibilities.md` (does + does not)
4. Check `../Handover/latest.md` (previous session context)
```

**Exception:** The Architect reads the full `Life OS Framework.md` instead of `Agent Principles.md`, and also scans `registry/`.

---

## Fresh Agent Bootstrapping

The Architect creates the agent's identity (System files) but NOT its workflows or tools. Those are built during the agent's **first session**.

When an agent boots and detects empty `Workflows/` + no handover, it should:
1. Recognize it's a first session
2. Ask what the user wants to tackle first
3. Propose initial workflows and tools based on the conversation
4. Build them during the session
5. Include setup work in the first handover

This keeps agent creation fast (Architect does identity only) and lets the agent learn its own workflows from real use.

---

## Self-Improvement

Every agent should proactively look for ways to improve itself:
- Notice missing or unconfigured sources and offer to fix them
- Identify gaps in its own setup (empty folders, missing workflows)
- Suggest new tools or sources that would help it do its job better
- Frame suggestions as questions, not demands: *"I noticed X. Want me to fix that?"*

---

## Handover Convention

- Handover **files** live in the agent's `Handover/` folder (persistent, outside sessions)
- `latest.md` is overwritten each session end; the previous version is moved to `Archive/`
- Handover includes `agent: "[[{Agent-Folder-Name}]]"` frontmatter for knowledge graph linking
- Each agent follows the shared `/handoff` skill for creating handovers
