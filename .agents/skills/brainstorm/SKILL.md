---
name: brainstorm
description: >-
  Brainstorm and define a project as a PRD stored in Linear. Use when starting
  a new project idea, refining an existing project spec, or turning a vague
  concept into a structured PRD. Triggers: "brainstorm", "new project",
  "define a project", "write a PRD", "refine the spec", "project brainstorm",
  "I have an idea", "let's scope this out", "spec this", "plan a feature",
  "break this down into tickets".
user-invocable: true
disable-model-invocation: true
---

<objective>
Turn project ideas into structured PRDs stored as Linear project descriptions, and optionally decompose them into milestones and detailed implementation tickets. This skill is the orchestrator — it owns the Linear integration and delegates content creation to two sub-skills:

- **prd-builder** — brainstorm facilitation, research, and PRD content creation (no Linear)
- **task-builder** — PRD decomposition into milestones and self-contained task descriptions (no Linear)

Brainstorm handles: project creation/selection in Linear, PRD storage, metadata, milestone creation, issue creation, dependency linking, plan documents.

**Quality bar**: Is this Linear-level engineering and design? If not, do better.
</objective>

<quick_start>
1. Run `/brainstorm`
2. Choose: new project or existing project
3. Follow the guided brainstorm loop until you approve the PRD
4. PRD is stored as the Linear project description
5. Optionally break down into implementation tickets
</quick_start>

<essential_principles>

### 1. Linear is the source of truth
The PRD lives as the Linear project description. Not a local file, not Claude's memory. Every iteration updates Linear directly. Tickets live as Linear issues.

### 2. No implementation
This skill produces a PRD, fills project metadata, and optionally creates tickets — then **stops**. No code, no scaffolding, no permanent local files. Everything lives in Linear. Implementation happens later by picking up individual tickets.

### 3. Delegate content creation
PRD drafting is delegated to the `prd-builder` skill. Task decomposition is delegated to the `task-builder` skill. Brainstorm only handles the Linear CRUD operations and orchestration flow. This separation enables prd-builder and task-builder to be reused without Linear.

### 4. Autonomous mode
When running headlessly via ralph.sh, pass `autonomous: true` to sub-skills. All user interaction points auto-resolve: prd-builder auto-approves after drafting, task-builder auto-approves after decomposition. Brainstorm auto-selects reasonable defaults for metadata (lead = current user, dates from roadmap).

### 5. Resilience
If `linear` CLI commands fail (network issues, auth expired, rate limits):
- Report the error clearly to the user
- Suggest `linear auth` if it's an auth issue
- For transient failures, retry once before escalating
- Never continue the workflow with stale or missing data — wait for resolution
</essential_principles>

<intake>
**Step 1: Capture the idea**

If the user hasn't already provided their idea in the conversation, ask:
> What's the project idea? Give me everything you have — problem, solution, constraints, half-baked thoughts.

Note the user's idea — it will be passed to prd-builder later as the `idea` context.

**Autonomous mode:** The calling context (ralph.sh) MUST include the idea. If no idea is present in the conversation context, stop and report an error: "Autonomous brainstorm requires an idea in the calling context."

**Step 2: Route**

Ask the user:
> What would you like to do?
> 1. Start a **new project** — create a fresh project in Linear and brainstorm from scratch
> 2. Work on an **existing project** — refine or extend an existing project's spec

**Wait for response before proceeding.**

**Autonomous mode:** Default to "new project" unless the calling context specifies an existing project ID.
</intake>

<routing>
| Response | Workflow |
|----------|----------|
| 1, "new", "new project", "fresh", "start" | `workflows/new-project.md` |
| 2, "existing", "refine", "extend", "update" | `workflows/existing-project.md` |

**After reading the workflow, follow it exactly.**
</routing>

<reference_index>
## References

- `references/workspace-config.md` — Pre-fetched PRD team configuration: t-shirt sizes, labels, priorities, workflow states, initiatives. **Always read this first** — it eliminates runtime API calls for static data.
- `references/graphql-operations.md` — Specific GraphQL mutations and queries used by brainstorm workflows (project update, metadata, user resolution, milestone assignment). These complement the `linear-cli` skill's general CLI docs.

## Linear CLI

For all Linear CLI operations, **read the `linear-cli` skill's SKILL.md and relevant reference docs**. The linear-cli skill has authoritative, up-to-date documentation for every command. Key references used by brainstorm workflows:

| Operation | linear-cli reference |
|-----------|---------------------|
| Create/list/view projects | `linear-cli/references/project.md` |
| Update project description & content | `linear-cli/references/api.md` (GraphQL `projectUpdate` — no CLI command exists) |
| Create/list milestones | `linear-cli/references/milestone.md` |
| Create/update/list issues | `linear-cli/references/issue.md` |
| Set issue relations (dependencies) | `linear-cli/references/issue.md` (relation subcommand) |
| Create/list documents | `linear-cli/references/document.md` |
| List initiatives | `linear-cli/references/initiative.md` |
| GraphQL API (fallback) | `linear-cli/references/api.md` |

The Linear-specific knowledge not covered by linear-cli (project update mutations, milestone assignment, user resolution) is documented in `references/graphql-operations.md`.

## Sub-Skills

Workflows delegate to these by reading their SKILL.md and following their instructions. Context is established in the conversation before the sub-skill's SKILL.md is read.

- **prd-builder** — Pure PRD content production. Called from `workflows/brainstorm-loop.md`. Context: `idea`, `output-path`, `mode`, optional `constraints`, `research-context`, `autonomous`.
- **task-builder** — Pure task decomposition. Called from `workflows/ticket-breakdown.md`. Context: `prd-path`, `output-dir`, `project-name`, optional `constraints`, `autonomous`.
</reference_index>

<workflows_index>
## Workflows

All in `workflows/`:

| Workflow | Purpose |
|----------|---------|
| new-project.md | Create a new Linear project, then enter brainstorm loop |
| existing-project.md | Load existing project context, then enter brainstorm loop |
| brainstorm-loop.md | Delegate to prd-builder, store PRD in Linear, fill metadata, offer ticket breakdown |
| ticket-breakdown.md | Delegate to task-builder, create Linear milestones/issues/dependencies/plan document |
</workflows_index>

<gotchas>
## Gotchas

- **Linear auth expiry mid-workflow**: The most disruptive failure. If a GraphQL mutation fails with an auth error after the PRD is drafted, the PRD content exists only in the temp file. Don't delete temp files until Linear storage is confirmed. Suggest `linear auth` and retry.
- **Description vs content confusion**: Linear projects have TWO text fields. `description` is the short subtitle (max 255 chars). `content` is the full rich-text body (unlimited). The PRD goes in `content`. A summary goes in `description`. If you put the full PRD in `description`, it gets truncated silently.
- **Partial ticket creation failure**: If issue creation fails after creating 5 of 10 tickets, you have orphaned tickets in Linear. Track the slug-to-identifier mapping as you go so you can resume or clean up. Never re-create tickets that already exist.
- **Milestone assignment requires UUIDs**: The CLI's `issue create` doesn't support `--milestone`. You need the issue UUID and milestone UUID for the GraphQL mutation. Collect both during creation, not after.
- **Temp file collisions**: Use `project-id` in temp file names (`/tmp/prd-<project-id>.md`) to avoid collisions when running multiple brainstorms. Never use generic names like `/tmp/prd.md`.
- **Autonomous mode still needs research**: Auto-approve doesn't mean skip research. The research phase is what separates a good PRD from a template fill-in. Always run codebase exploration even in autonomous mode.
</gotchas>

<success_criteria>
A well-executed brainstorm:
- Produces a complete PRD following the strict 6-section schema (including Agent Execution Context)
- Stores the PRD as the Linear project description (both `description` and `content` fields)
- Fills all applicable project metadata (lead, dates, initiative)
- Uses research tools to validate at least one key assumption (delegated to prd-builder)
- Gets explicit user approval before storing (or auto-approves in autonomous mode)
- If ticket breakdown chosen: milestones created, all tickets have self-contained descriptions with all 13 sections, estimates, priorities, dependencies, and a plan document exists in Linear
- Does NOT start any implementation
- Reads like something a senior PM at a top-tier company would write
</success_criteria>
