# Workflow: Create Agent

Triggered when the user says "I need a new agent" (or similar). Follow these steps in order.

---

## Step 1 — Gather Requirements

Ask the following questions, max 3 at a time. Use multiple choice for structure, open-ended for content.

### Required

1. **Purpose** — What does this agent do, in one sentence? (open-ended)
2. **Goal** — What is the concrete goal or outcome? (open-ended)
   Based on the answer, suggest a first iteration of relevant tools, sources, and workflows.
   Frame as: *"Since this looks like a [type] agent, could I suggest..."*
3. **Name** — Suggest 3-4 names based on the purpose. User can pick one or provide their own.
4. **Persona** — Tone and style? (multiple choice + open-ended)
   - Methodical / Structured
   - Casual / Conversational
   - Technical / Precise
   - Custom: ___
5. **Responsibilities** — What does it do? What does it NOT do? (open-ended, ask for both)
   Suggest examples based on the stated purpose and goal.
6. **Sources** — Present suggested sources from step 2. User confirms, adds, or removes.
7. **Session start behavior** — What should happen when a session begins?
   - Always read latest handover
   - Read handover + scan progress (for task-based agents)
   - Other startup routines
8. **Session end behavior** — When should a handover be written?
   - User-triggered only (never auto-end)
   - Always at end of session
   - Only when meaningful state changed
   - Custom trigger: ___
9. **Output style** — How should it format responses? (multiple choice)
   - Concise / bullet points
   - Detailed / prose
   - Checklists / structured
   - Match the Architect's style
10. **Registry** — Which registry should this agent go in? (multiple choice)
    - Read `agent-blueprint.json` to check if multi-machine is configured (`machine.slug` exists)
    - If multi-machine: offer `shared` (all machines) or `{machine.slug}` (this machine only). Default: `{machine.slug}`.
    - If single-machine: skip this question — use `shared` automatically.

---

## Step 2 — Create Folder Structure

Create the full skeleton under `{systemRoot}/AI/Agents/{Agent-Name}/`:

```
{Agent-Name}/
├── System/
│   ├── README.md
│   ├── persona.md
│   ├── responsibilities.md
│   └── learnings.md
├── Workflows/
├── Tools/
│   ├── Templates/
│   └── Scripts/
└── Handover/
    └── Archive/
```

---

## Step 3 — Write System Files

Using the answers from Step 1 and the template at `Tools/Templates/agent-template.md`:

1. **README.md** — Boot file: identity, boot sequence, sources, folder map
2. **persona.md** — Tone, behavior, communication style, output format
3. **responsibilities.md** — Does + Does Not
4. **learnings.md** — Empty file with heading: `# Learnings — {Agent Name}`

Show a summary of all files before writing. Confirm with user.

---

## Step 4 — Register Agent

1. **Add to registry** — Append the agent to the chosen registry file at `{systemRoot}/AI/Agents/registry/{registry}.json`:
   - Read the target registry file (JSON array)
   - Append a new object with these fields:
     - `id`: lowercase slug
     - `name`: display name
     - `folder`: folder name under `Agents/`
     - `purpose`: one-line description
     - `status`: `"active"`
     - `persona`: persona type (methodical / casual / technical / custom)
     - `requiredSources`: array of source slugs
     - `label`: matching label ID
     - `createdAt`: date of creation (YYYY-MM-DD)
   - Write the updated array back to the file

2. **Create label** — Add agent label to the current workspace's `labels/config.json`
   - ID: lowercase slug of agent name
   - Name: agent display name
   - Color: complementary to existing agent labels
   - Add an `autoRules` entry with a case-insensitive pattern matching the agent name
   - Ready for sub-labels as the agent evolves

3. **Create agent skill** — Every agent gets a skill in the current workspace's `skills/{agent-slug}/SKILL.md`:
   - `requiredSources`: list the sources this agent needs (auto-enabled on boot)
   - Body: point to the agent's `System/README.md` boot file
   - Validate with `skill_validate`

4. **Configure sources** — For each source the agent needs:
   - Verify it exists in the workspace
   - If not, trigger source creation flow
   - Document in the agent's README which sources it uses and why

---

## Step 5 — Confirm Result

Show the user:
- Full folder tree that was created
- List of files written
- Label created
- Sources configured
- Any next steps (e.g. "You can now use `/start` and select this agent")
