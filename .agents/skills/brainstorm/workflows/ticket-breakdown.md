<required_reading>
Read before proceeding:
- `references/workspace-config.md`
- `references/graphql-operations.md` (for milestone IDs, issue UUID resolution, milestone assignment)
- `linear-cli` skill's SKILL.md (for general CLI usage)
- `linear-cli/references/issue.md` (for `issue create`, `issue relation`)
- `linear-cli/references/milestone.md` (for `milestone create`)
- `linear-cli/references/document.md` (for `document create`)
</required_reading>

<process>
## Ticket Breakdown Workflow

Decompose the approved PRD into milestones and detailed Linear tickets. Delegates content creation to task-builder, then handles all Linear operations.

You have context from the brainstorm loop:
- **project-id**: Linear project UUID
- **project-name**: Human-readable name
- **autonomous**: Whether to auto-approve

The PRD is at `/tmp/prd-<project-id>.md` (written by prd-builder in the brainstorm loop).

---

### Step 1: Ensure PRD is available

If `/tmp/prd-<project-id>.md` does not exist, fetch from Linear using the project content query from `references/graphql-operations.md`. Write the `content` field to `/tmp/prd-<project-id>.md`.

**Error handling:** If the file doesn't exist AND the Linear fetch fails, stop and report the error. Do NOT proceed to task-builder without a PRD — it is the only required input. If the fetch succeeds but `content` is empty, stop and report: "Project has no PRD content. Run the brainstorm loop first."

---

### Step 2: Delegate task decomposition to task-builder

**Read the `task-builder` skill's SKILL.md and follow its instructions.** Before starting, establish the following context so task-builder can pick it up:

| Context to establish | Value |
|---------------------|-------|
| `prd-path` | `/tmp/prd-<project-id>.md` |
| `output-dir` | `/tmp/tasks-<project-id>/` |
| `project-name` | The project name |
| `constraints` | Any decomposition constraints from the user (e.g., "max 5 tasks", "focus on MVP only") — pass through if present |
| `autonomous` | Pass through the autonomous flag |

Task-builder handles: PRD analysis, vertical slice decomposition, milestone organization, detailed task writing with all 13 sections, dependency graph validation, plan.md creation, and user approval.

**Complete the full task-builder workflow before continuing to Step 3.**

---

### Step 3: Read task-builder output

Task-builder writes:
- `/tmp/tasks-<project-id>/plan.md` — Implementation plan
- `/tmp/tasks-<project-id>/tasks/milestone-N-name/task-NN-slug.md` — Task files with YAML frontmatter

Read `plan.md` to understand milestone structure and task order.

For each task file, parse YAML frontmatter to extract: `title`, `milestone`, `estimate`, `priority`, `labels`, `depends-on`, `blocks`, `related`.

Build these mappings for subsequent steps:
- **milestone-names**: ordered list of unique milestone names from task frontmatter
- **slug-to-task**: map of task slug to its parsed metadata + file path
- **task-order**: ordered list of task slugs from plan.md

---

### Step 4: Create milestones in Linear

For each milestone name, use `linear milestone create` (see `linear-cli/references/milestone.md`) with `--project`, `--name`, and optionally `--description` and `--target-date`.

Retrieve milestone IDs using the milestone query from `references/graphql-operations.md`.

Build a **milestone-name-to-id** mapping.

---

### Step 5: Create tickets in Linear

For each task file (in task-order sequence):

1. Extract the body (everything after YAML frontmatter) to a uniquely named temp file: `/tmp/ticket-<project-id>-<task-slug>.md`
2. Use `linear issue create` (see `linear-cli/references/issue.md`) with:
   - `--title` from frontmatter
   - `--description-file` pointing to the temp file
   - `--project "<project-name>"`
   - `--team PRD`
   - `--estimate` from frontmatter
   - `--priority` from frontmatter
   - `--label` from frontmatter (repeat flag for multiple labels)
   - `--state "Backlog"`
3. Clean up the temp file after creation

**Labels**: Use label names from `references/workspace-config.md`. Use `Tracer Bullet` label on the first task (task-01).

**States**: Default to `Backlog`. Use `Todo` for tickets ready to be picked up immediately.

**Capture identifiers**: Note each `PRD-xxx` identifier from CLI output. Build a **slug-to-identifier** mapping.

**Get issue UUIDs** (needed for Step 6): Use the identifier-to-UUID query from `references/graphql-operations.md`. Build a **slug-to-uuid** mapping.

**Error handling for partial failures:** Track the slug-to-identifier mapping as each ticket is created. If a creation fails mid-sequence:
- Retry once for transient errors
- If it fails twice, log the failure and continue with the remaining tickets
- After all tickets are attempted, report which ones failed so they can be retried
- Do NOT re-create tickets that already exist — check the mapping first

---

### Step 6: Assign milestones via GraphQL

The CLI does not support milestone assignment on `issue create`. For each ticket, use the milestone assignment mutation from `references/graphql-operations.md`.

Use the milestone-name-to-id mapping from Step 4 and the slug-to-uuid mapping from Step 5.

---

### Step 7: Set dependency relations

Using `depends-on`, `blocks`, and `related` from each task's frontmatter, plus the slug-to-identifier mapping, use `linear issue relation add` (see `linear-cli/references/issue.md`):

- `depends-on` → `linear issue relation add <identifier> blocked-by <dependency-identifier>`
- `blocks` → `linear issue relation add <identifier> blocks <blocked-identifier>`
- `related` → `linear issue relation add <identifier> related <related-identifier>`

Rules:
- The tracer bullet (task-01) has no blockers
- Only direct dependencies, not transitive
- Validate: no cycles in the dependency graph

---

### Step 8: Create plan document in Linear

Use `linear document create` (see `linear-cli/references/document.md`) with `--title`, `--content-file` pointing to `/tmp/tasks-<project-id>/plan.md`, and `--project`.

---

### Step 9: Present summary

Present to the user:
- Number of milestones created
- Number of tickets created with total estimate points
- Critical path and its total points
- Suggested implementation order (first 3-5 tickets)
- Any tickets exceeding size 3 flagged for attention
- Any tickets that failed creation in Step 5 (if applicable)

---

### Step 10: Clean up and exit

```bash
rm -rf /tmp/tasks-<project-id>/
rm -f /tmp/prd-<project-id>.md
```

Tell the user:
- PRD stored as project description
- N tickets across M milestones
- Plan document created
- To start: `linear issue start PRD-xxx` (the tracer bullet identifier)

**Exit plan mode** if in it. Return to the main agent. Do NOT begin implementation.
</process>

<success_criteria>
- All milestones exist in Linear with correct names
- All tickets exist in Linear with correct estimates, priorities, labels, and descriptions
- Each ticket assigned to its correct milestone
- Dependency graph correctly set in Linear (valid DAG, no cycles)
- Plan document exists in Linear
- Slug-to-identifier mapping is complete (no orphaned tasks)
- No implementation started
- Temp files cleaned up
</success_criteria>
