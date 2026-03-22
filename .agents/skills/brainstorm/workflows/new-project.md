<required_reading>
Read before proceeding:
- `references/workspace-config.md`
- `linear-cli/references/project.md` (for `project create` flags)
- `linear-cli/references/api.md` (for GraphQL fallback to extract project ID)
</required_reading>

<process>
## New Project Workflow

### Step 1: Get project name

Ask the user:
> What should this project be called?

**Autonomous mode:** Use the project name from the calling context if provided. Otherwise, derive a short name (2-4 words) from the idea captured during brainstorm intake. The idea is always available in the conversation context at this point — the brainstorm intake captures it before routing to this workflow.

### Step 2: Select initiative

Use the pre-fetched initiative list from `references/workspace-config.md`. Present to the user:

> Which initiative does this project belong to?
> 1. Bringing digital assets to life
> 2. Customer Success
> 3. Deploy and operate at will
> 4. Letting go of the past
> 5. None — standalone project

If the list in workspace-config.md is outdated, use `linear initiative list --json` (see `linear-cli/references/initiative.md`).

**Autonomous mode:** If the calling context specifies an initiative, use it. Otherwise default to "None."

### Step 3: Create the project in Linear

Use `linear project create` with the flags documented in `linear-cli/references/project.md`:
- `--name` (required)
- `--team PRD` (required)
- `--status planned`
- `--initiative` (omit if "None")

Capture the project ID from the output. If not visible in the CLI output, extract via GraphQL (see `linear-cli/references/api.md`): query `projects` filtered by name.

**Error handling:** If `linear project create` fails:
- If auth error: suggest `linear auth` and retry once
- If transient/network error: retry once
- If it fails twice: stop and report the error. Do NOT proceed without a valid project-id — every subsequent step depends on it.

### Step 4: Confirm to user

Tell the user the project has been created and show the project identifier.

**Autonomous mode:** Log the creation, proceed without pausing.

### Step 5: Hand off to brainstorm loop

Read and follow `workflows/brainstorm-loop.md`.

Pass context:
- **project-id**: the UUID from Step 3
- **project-name**: from Step 1
- **existing-description**: empty (new project)
- **existing-content**: empty (new project)
- **existing-documents**: none
- **autonomous**: pass through from calling context
</process>

<success_criteria>
- Project exists in Linear with status "planned" and correct team (PRD)
- Initiative linked if user chose one
- Brainstorm loop entered with correct project context
</success_criteria>
