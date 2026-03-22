<required_reading>
Read before proceeding:
- `references/workspace-config.md`
- `references/graphql-operations.md` (exact mutations for project update, metadata, user resolution)
- `linear-cli` skill's SKILL.md (for general CLI usage)
</required_reading>

<process>
## Brainstorm Loop

Core orchestration loop. Delegates PRD content creation to prd-builder, then handles Linear storage and metadata. Should run in **plan mode** to prevent premature implementation. Enter plan mode if not already in it.

You have context from the calling workflow:
- **project-id**: Linear project UUID
- **project-name**: Human-readable name
- **existing-description**: Current project description (empty for new projects)
- **existing-content**: Current project content / full PRD body (empty for new projects)
- **existing-documents**: Content of attached Linear documents (empty for new projects)
- **autonomous**: Whether to auto-approve (from calling workflow or user context)

---

### Phase A: Delegate PRD creation to prd-builder

Write any existing PRD content to a temp file for prd-builder to work with:

```bash
# Only if existing-content is non-empty
cat > /tmp/prd-<project-id>.md <<'EOF'
<existing-content>
EOF
```

**Read the `prd-builder` skill's SKILL.md and follow its instructions.** Before starting, establish the following context so prd-builder can pick it up:

| Context to establish | Value |
|---------------------|-------|
| `idea` | For new projects: the user's raw idea (captured during brainstorm intake). For existing projects: the existing content + any documents. |
| `output-path` | `/tmp/prd-<project-id>.md` |
| `mode` | `new` if existing-content is empty, `refine` otherwise |
| `constraints` | Any constraints from the user or existing project context |
| `research-context` | Content of existing-documents (if any) |
| `autonomous` | Pass through the autonomous flag |

**Complete the full prd-builder workflow before continuing to Phase B.**

---

### Phase B: Store in Linear & fill metadata

#### 1. Store PRD as project content + description

Read the PRD from `/tmp/prd-<project-id>.md`. Extract the first 1-2 sentences of the Executive Summary as the short description (max 255 chars).

Use the `projectUpdate` mutation from `references/graphql-operations.md` to set both `description` and `content` fields. Pass the PRD file via `--variable "content=@/tmp/prd-<project-id>.md"`.

#### 2. Fill project metadata

Ask the user to confirm each metadata value. In autonomous mode, use defaults without asking.

**Lead:**
> Who should be the project lead? (Enter a username, email, or "@me" for yourself)

Autonomous default: current user ("@me"). Resolve to UUID using the queries in `references/graphql-operations.md` (viewer for @me, users filter for email).

**Dates** (if the PRD's roadmap section has timeline info):
> Based on the roadmap, should we set project dates?
> - Start date: YYYY-MM-DD (or skip)
> - Target date: YYYY-MM-DD (or skip)

Autonomous default: extract dates from the PRD if present, skip if not.

Update metadata using the `projectUpdate` mutation from `references/graphql-operations.md`. Only include fields the user confirmed or that were defaulted.

#### 3. Offer ticket breakdown

Ask the user:

> The PRD has been stored. Would you like to break it down into implementation tickets now?
> 1. **Yes** — decompose the PRD into milestones and detailed tickets in Linear
> 2. **No** — stop here, I'll break it down later

| Response | Action |
|----------|--------|
| Yes | Read and follow `workflows/ticket-breakdown.md` |
| No | Proceed to Phase C exit |

**Autonomous mode:** Default to "Yes" — always break down into tickets.

---

### Phase C: Exit

Clean up temp files:
```bash
rm -f /tmp/prd-<project-id>.md
```

Tell the user:
- The PRD is stored as the project description in Linear
- Project metadata has been updated

**If tickets were created:**
- N tickets created across M milestones
- Implementation plan document created in Linear
- To start implementing: `linear issue start PRD-xxx` on the tracer bullet ticket

**If no tickets were created:**
- Run `/brainstorm` on this project again when ready to break it down

**Exit plan mode** if in it. Return to the main agent. Do NOT begin implementation.
</process>

<success_criteria>
- PRD stored as both `description` (short summary) and `content` (full PRD) on the Linear project
- Project metadata filled (lead, dates where applicable)
- User approved the PRD (or auto-approved in autonomous mode)
- If ticket breakdown chosen: tickets, milestones, dependencies, and plan document exist in Linear
- No implementation started
- Temp files cleaned up
</success_criteria>
