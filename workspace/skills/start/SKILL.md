---
name: "Start"
description: "Start a session — pick an agent, load context, check handover"
---

# Agent Session Start

## 1. List Available Agents

Scan the current workspace's `skills/` folder for agent skills (each subfolder with a `SKILL.md`). Exclude system skills (`start`, `handoff`, `new-agent`) — only list agent-specific skills.

Present the agent names from each skill's frontmatter:

> "Hey, which agent today?"
> - [list agent names from skills]

Wait for the user to pick one.

## 2. Boot the Agent

Read the selected agent's skill file (`skills/{agent-slug}/SKILL.md`), then follow its instructions — which will point to the agent's boot file:

```
{{LIFEOS_ROOT}}/AI/Agents/{agent}/System/README.md
```

This file points to persona, responsibilities, required sources, and other files to read.

## 3. Validate Sources

The agent's README lists required sources. For each one:

- **If active in this session:** Good, move on.
- **If it exists in the workspace but isn't active:** Enable it yourself if possible. If you can't, tell the user exactly what to toggle: *"Please enable Desktop Commander in the sources panel."*
- **If it doesn't exist at all:** Offer to set it up: *"This agent needs [source], but it's not configured yet. Want me to add it now?"*

Do NOT silently skip missing sources — always surface the issue.

## 4. Check Handover

Check if `{{LIFEOS_ROOT}}/AI/Agents/{agent}/Handover/latest.md` exists:

- **If it exists:** Read it. Briefly summarize what happened last session and what the recommended next focus is.
- **If it doesn't exist:** Note this is a fresh start — no prior context.

## 5. Fresh Agent Detection

Check if `Workflows/` is empty AND no handover exists. If both are true, this is a **fresh agent** that hasn't been configured yet.

For fresh agents:

1. Explain: *"This is your first session with [agent]. Let me learn how you want me to work."*
3. Ask: *"What's the first thing you want to tackle?"*
4. Based on the answer, propose initial workflows and tools
5. Build them during the session
6. Include this setup work in the handover

This replaces the generic "What would you like to work on?" prompt for fresh agents.

## 6. Self-Check (returning agents only)

For agents that already have workflows and prior sessions:

- Is anything about this agent's setup incomplete or improvable?
- Are there missing sources, outdated workflows, or gaps?
- If so, mention it: *"I noticed [issue]. Want me to fix that?"*

Agents should always look for ways to improve their own setup.

## 7. Ready

Confirm the agent is loaded:

> **Fresh agent:** "[Agent name] loaded. First session — let's set you up. What's the first thing you want to tackle?"
> **Returning agent:** "[Agent name] loaded. [One-line handover summary.] What would you like to work on?"

After the ready message, add a rename reminder:

> **Rename session** — give this session a name that reflects today's focus (e.g. "Architect — new trading agent").

## Available Skills Reminder

After booting, if the user seems unsure, mention available skills:

- `/new-agent` — create a new agent (Architect only)
- `/handoff` — end session and create handover
- Any agent-specific skills listed in that agent's workflows
