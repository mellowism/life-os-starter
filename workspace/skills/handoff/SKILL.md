---
name: "Handoff"
description: "End a session — create handover and archive the previous one"
---

# Session Handoff

Identify which agent is active in this session (from labels, conversation context, or ask the user).

## 1. Archive Previous Handover

Check if `{{LIFEOS_ROOT}}/AI/Agents/{agent}/Handover/latest.md` exists:

- **If it exists:** Read it to get the session ID and date. Move it to `Handover/Archive/{date}-{session-id}.md`. Confirm archive done.
- **If it doesn't exist:** Skip — this is the first handover.

## 2. Ask the User (one at a time)

1. "What did you accomplish this session?"
2. "Any blockers or issues?"
3. "What should the next session focus on?"

Keep it brief. Don't over-prompt — if the user gives short answers, that's fine.

## 3. Write Handover

Write to `{{LIFEOS_ROOT}}/AI/Agents/{agent}/Handover/latest.md`:

```markdown
# Handover — {Agent Name}

**Date:** {YYYY-MM-DD}
**Session:** {session-id}

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

Keep it under 300 words. Focus on WHAT and WHY, not HOW.

## 4. Confirm

> Handoff complete.
> Archived: [previous file, if any]
> Created: latest.md
> Next focus: [top priority]
