---
name: "Start"
description: "Start a session — pick an agent, load context, check handover"
---

# Agent Session Start

**CRITICAL:** Do NOT greet the user or produce any text output until you have completed Step 1 below. Your FIRST actions must be tool calls to read the config and registry. No exceptions.

## 1. List Available Agents

Read these in parallel:
- `agent-blueprint.json` at the workspace root — extract `systemRoot`, `user.name`, `machine.name`, and `machine.slug`
- `{systemRoot}/AI/Agents/registry/shared.json` — agents available on all machines
- `{systemRoot}/AI/Agents/registry/{machine.slug}.json` — agents specific to this machine (skip if file doesn't exist or no `machine.slug`)

All paths in this skill resolve from `{systemRoot}` (the value read from `agent-blueprint.json`).

Merge both arrays into a single list of available agents. No filtering needed — the file-based scoping handles it.

Present as a **numbered list** with the agent name and a short purpose from the registry:

> Hey {user.name}, which agent today? *(Running on {machine.name})*
>
> 1. **Architect** — designs and scaffolds new agents
> 2. ...

Wait for the user to pick one (by number or name).

## 2. Boot the Agent

Using the selected agent's `folder` field from the registry, read:

```
{systemRoot}/AI/Agents/{folder}/System/README.md
```

Then follow its boot sequence. This file points to persona, responsibilities, required sources, and other files to read.

## 3. Validate Sources

The agent's registry entry lists `requiredSources`. For each one:

- **If active in this session:** Good, move on.
- **If it exists in the workspace but isn't active:** Tell the user exactly what to toggle: *"Please enable [source] in the sources panel."*
- **If it doesn't exist at all:** Offer to set it up: *"This agent needs [source], but it's not configured yet. Want me to add it now?"*

Do NOT silently skip missing sources — always surface the issue.

## 4. Check Handover

Determine if this is a cross-machine agent: it is if the agent was loaded from `shared.json` AND `machine.slug` exists (meaning multi-machine setup is active).

**Cross-machine agent** (from `shared.json` in a multi-machine setup):
- Look for ALL `latest-*.md` files in `{systemRoot}/AI/Agents/{folder}/Handover/`
- Read each one. Note which machine it's from (`**Machine:**` header) and how recent it is.
- Summarize context from all machines. Flag if multiple have recent activity (potential overlap).

**Single-machine agent** (from `{machine.slug}.json`, or any agent when not using multi-machine):
- Check if `{systemRoot}/AI/Agents/{folder}/Handover/latest.md` exists
- **If it exists:** Read it. Briefly summarize what happened last session and what the recommended next focus is.
- **If it doesn't exist:** Note this is a fresh start — no prior context.

## 5. Fresh Agent Detection

Check if `Workflows/` is empty AND no handover exists. If both are true, this is a **fresh agent** that hasn't been configured yet.

For fresh agents:

1. Explain: *"This is your first session with [agent]. Let me learn how you want me to work."*
2. Ask: *"What's the first thing you want to tackle?"*
3. Based on the answer, propose initial workflows and tools
4. Build them during the session
5. Include this setup work in the handover

This replaces the generic "What would you like to work on?" prompt for fresh agents.

## 6. Self-Check (returning agents only)

For agents that already have workflows and prior sessions:

- Is anything about this agent's setup incomplete or improvable?
- Are there missing sources, outdated workflows, or gaps?
- If so, mention it: *"I noticed [issue]. Want me to fix that?"*

Agents should always look for ways to improve their own setup.

## 7. Check Delegated Tasks

Scan for task files where the `delegated-to` frontmatter field matches the current agent's display name and `status` is not `done` or `dropped`.

Use Grep to search for the agent name in `delegated-to` frontmatter across task files. Read any matches to confirm they're delegated tasks.

- **If tasks found:** List them briefly: *"You have [N] delegated task(s) from other agents:"* followed by the task titles and who created them.
- **If no tasks:** Skip silently — don't mention it.

Tasks don't need to be acted on immediately. Surface them so the user is aware, then let them decide priority.

## 8. Ready

Confirm the agent is loaded:

> **Fresh agent:** "[Agent name] loaded. First session — let's set you up. What's the first thing you want to tackle?"
> **Returning agent:** "[Agent name] loaded. [One-line handover summary.] What would you like to work on?"

After the ready message, add a rename reminder:

> **Rename session** — give this session a name that reflects today's focus (e.g. "Architect — new trading agent").

## 9. Available Skills Reminder

After booting, if the user seems unsure, mention available skills:

- `/new-agent` — create a new agent (Architect only)
- `/handoff` — end session and create handover
- Any agent-specific skills listed in that agent's workflows
