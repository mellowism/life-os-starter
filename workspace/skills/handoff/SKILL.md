---
name: "Handoff"
description: "End a session — create handover and archive the previous one"
---

# Session Handoff

Identify which agent is active in this session (from labels, conversation context, or ask the user).

## 1. Determine Handover Mode

Read `agent-blueprint.json` at the workspace root to get `systemRoot`, `machine.slug`, and `machine.name`.

All paths in this skill resolve from `{systemRoot}` (the value read from `agent-blueprint.json`).

Read the agent's registry file at `{systemRoot}/AI/Agents/registry/{agent-id}.json` to get `contexts` and `folder`.

- **Cross-machine agent** (multiple values in `contexts` AND `machine.slug` exists): handover file is `latest-{machine.slug}.md`
- **Single-machine agent** (or no machine config): handover file is `latest.md`

## 2. Archive Previous Handover

Check if the handover file (from step 1) exists in `{systemRoot}/AI/Agents/{folder}/Handover/`:

- **Cross-machine:** Archive `latest-{slug}.md` → `Handover/Archive/{date}-{slug}-{session-id}.md`. Only touch this machine's file.
- **Single-machine:** Archive `latest.md` → `Handover/Archive/{date}-{session-id}.md`.
- **If file doesn't exist:** Skip — this is the first handover (on this machine).

## 3. Ask the User (MANDATORY — never skip)

**Always ask these questions, even if you think you already know the answers from the conversation.** Do not auto-generate the handover from context alone. The user may have priorities, blockers, or corrections that weren't discussed.

Ask all three questions in a **single prompt**, with your own suggestions based on the session. The user can confirm, correct, or add to your suggestions. Format:

> Here's what I have from this session — confirm, correct, or add:
>
> **1. What did you accomplish?**
> [Your bullet-point summary from the session]
>
> **2. Any blockers or issues?**
> [Your observations, or "None that I saw"]
>
> **3. What should the next session focus on?**
> [Your suggested priorities]

If the user says "perfect" or similar, use your suggestions as-is. Short answers are fine.

## 4. Learnings Reflection

Before writing the handover, review the session for reusable insights. Ask:

> **Any learnings worth saving?** Here's what I noticed:
> - [Your suggestions — patterns discovered, gotchas hit, conventions established, useful techniques]
>
> Want me to add any of these to `System/learnings.md`?

If the user confirms, append to `{systemRoot}/AI/Agents/{folder}/System/learnings.md`. Organize under a relevant heading (create one if needed). Keep entries concise — one line per learning.

If the user says "no" or "skip", move on. Don't force it.

## 5. Write Handover

Write to the handover file determined in step 1:

- **Cross-machine:** `{systemRoot}/AI/Agents/{folder}/Handover/latest-{slug}.md`
- **Single-machine:** `{systemRoot}/AI/Agents/{folder}/Handover/latest.md`

**Cross-machine template:**

```markdown
---
agent: "[[{Agent-Folder-Name}]]"
---

# Handover — {Agent Name}

**Date:** {YYYY-MM-DD}
**Session:** {session-id}
**Machine:** {machine.name}

## Completed
- [bullet points from Q1]

## Blockers
- [from Q2, or "None"]

## Next Session Focus
- [ ] [checkboxes from Q3]

**Top priority:** [highlight one item]

## Context
[Any relevant state the next session should know — files touched, decisions made, things left mid-way]
```

**Single-machine template:** Same as above but without the `**Machine:**` line.

Keep it under 300 words. Focus on WHAT and WHY, not HOW.

## 6. Confirm

> Handoff complete.
> Archived: [previous file, if any]
> Created: {filename}
> Next focus: [top priority]
