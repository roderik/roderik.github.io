<required_reading>
Read before proceeding:
- `references/workspace-config.md`
- `references/graphql-operations.md` (for project queries and active project filtering)
- `linear-cli` skill's SKILL.md (for general CLI usage)
- `linear-cli/references/document.md` (for `document list` and `document view`)
</required_reading>

<process>
## Existing Project Workflow

### Step 1: Fetch active projects

Use `linear project list --team PRD` to list projects (see `linear-cli/references/project.md`).

Note: `project list` does not support `--json`. For programmatic filtering, use the active projects query from `references/graphql-operations.md`.

If no active projects are found, tell the user and suggest starting a new project instead.

### Step 2: Select project

Present to the user:
> Which project do you want to work on?
> 1. [Project A] — status: planned
> 2. [Project B] — status: started
> ...

Include project status for context.

**Autonomous mode:** If the calling context specifies a project ID, use it directly. Otherwise stop and report an error — autonomous mode requires an explicit project ID.

### Step 3: Load project context

Fetch full details using the project content query from `references/graphql-operations.md`.

Extract: name, description (short subtitle, max 255 chars), content (full rich-text body — this is the PRD), status, lead, dates, initiative.

### Step 4: Load attached documents

Use `linear document list --project "<project-name>" --json` (see `linear-cli/references/document.md`).

For each document, read its content with `linear document view <id> --raw`.

### Step 5: Summarize existing state

Present to the user:
- Project name and status
- Current description (or "no description yet")
- Whether a full PRD exists in the content field
- Number of attached documents and their titles
- Any metadata already set (lead, dates, initiative)

**Autonomous mode:** Log the summary internally, proceed without presenting.

### Step 6: Hand off to brainstorm loop

Read and follow `workflows/brainstorm-loop.md`.

Pass context:
- **project-id**: the UUID from Step 2
- **project-name**: from the project metadata
- **existing-description**: the `description` field (short subtitle)
- **existing-content**: the `content` field (full PRD body, may be empty)
- **existing-documents**: content of all attached documents
- **autonomous**: pass through from calling context
</process>

<success_criteria>
- User selected a valid active project (or project ID provided in autonomous mode)
- Full project context (metadata + content + documents) loaded and summarized
- Brainstorm loop entered with complete context
</success_criteria>
