---
name: task-builder
description: >-
  Decompose an approved PRD into milestones and detailed, self-contained task
  descriptions. Each task gets its own sub-PRD with implementation checklist,
  module mapping, anti-requirements, completion checklist, and verification
  protocol — detailed enough for a fresh Claude session to implement from the
  description alone. Pure content producer — does NOT interact with Linear or
  any ticket system. Orchestrated by brainstorm, commands, or other skills.
  Not user-invocable. Use when a PRD needs to be broken into implementation
  tasks. Do NOT use for PRD creation (use prd-builder) or Linear operations
  (use brainstorm).
user-invocable: false
---

<objective>
Take an approved PRD and decompose it into milestones and detailed task descriptions. Each task is a self-contained markdown file with YAML frontmatter for metadata and a full body following the strict task template — detailed enough that a fresh Claude session can implement it from the description alone.

This skill is a pure content producer — it does not interact with Linear, create issues, or manage project metadata. Orchestrating skills call task-builder and decide where to store the results.
</objective>

<interface>
## Context Contract

The calling skill must establish the following context in the conversation before this skill's SKILL.md is read and followed. These are not function parameters — they are conversation context that task-builder expects to find.

| Context | Required | Description |
|---------|----------|-------------|
| `prd-path` | Yes | File path to the approved PRD markdown |
| `output-dir` | Yes | Directory where task files and plan.md should be written |
| `project-name` | Yes | Human-readable project name (used in task context sections) |
| `constraints` | No | Additional decomposition constraints (e.g., "max 5 tasks", "focus on MVP only") |
| `autonomous` | No | `true` for headless execution (ralph.sh). Auto-approves after decomposition. Defaults to `false`. |

## Output

Writes to `output-dir`:

```
output-dir/
  plan.md                                    # Implementation plan with milestones, dependency graph, task index
  tasks/
    milestone-1-foundation/
      task-01-tracer-bullet-slug.md          # First task (always the tracer bullet)
      task-02-another-slug.md
    milestone-2-core-features/
      task-03-slug.md
      task-04-slug.md
    milestone-3-polish/
      task-05-slug.md
```

Each task file contains:
- YAML frontmatter with metadata (title, milestone, estimate, priority, labels, depends-on, blocks)
- Full body following the template from `templates/task-template.md`

Returns control to the calling skill after the user approves.
</interface>

<essential_principles>

### 1. Pure content production
Produce task markdown files and a plan — nothing else. No Linear API calls, no issue creation, no milestone management, no implementation. The calling skill handles storage and orchestration.

### 2. Self-contained tasks
A task passes the self-containment test if a fresh Claude session can:
1. Read the task description alone (no other task, no PRD)
2. Understand what to build and why
3. Know which files to touch and what patterns to follow
4. Know when it's done (completion checklist)
5. Know what to test and how

If any of these require reading another task or the PRD, the task needs more context inlined.

### 3. Vertical slices, not horizontal layers
Each task cuts through all integration layers end-to-end (DB → API → UI → tests). A completed task should be independently deployable, non-breaking, and demoable. Horizontal splits ("all the DB work", "all the API work") create integration risk and block parallel execution.

### 4. Tracer bullet first
The first task in every project is the tracer bullet — the simplest possible end-to-end slice that proves the architecture. Minimal UI (or none), minimal data, minimal logic, maximum learning. It touches all layers and exposes integration issues early.

### 5. Research-backed decomposition
Explore the codebase to identify exact file paths, existing patterns, and utilities to reuse. Every module mapping entry should point to an actual package. Every anti-requirement should reference an actual boundary. Guessing creates drift and duplication.

### 6. Codex has no context
Every `mcp__codex__codex` prompt must be fully self-contained — include the full PRD text and proposed task list directly in the prompt. Codex cannot see the conversation or codebase. Keep prompts focused and under 2000 words.
</essential_principles>

<process>

Read `references/ticket-writing.md` and `references/prd-schema.md` before proceeding. Use `templates/task-template.md` as the structural skeleton for each task.

---

### Step 1: Analyze the PRD for vertical slices

Read the PRD from `prd-path`. Identify the vertical slices by looking for:

- **Distinct user stories** from Section 2 — each story often maps to one or more slices
- **Integration points** from Section 4 — each external integration may need its own slice
- **State transitions** from Section 6 — each state machine transition can be a slice
- **Phased rollout** from Section 5 — MVP items are earlier slices, future items are later

**Decomposition rules:**
- The tracer bullet is always the first slice — simplest end-to-end path
- Each subsequent slice adds one capability (edge case, feature, polish)
- Every slice is independently deployable and non-breaking
- A completed slice should be demoable or verifiable on its own
- Prefer many thin slices (2-3 point estimates) over fewer thick ones (5+ points)

**Use research tools to inform the breakdown:**

Launch Explore agents to understand the codebase areas each slice touches. This is critical for Step 3 (module mapping, file paths, anti-requirements).

Use `mcp__codex__codex` to challenge the decomposition:
> "Here is the PRD: [paste full PRD]. Here are the slices I'm proposing: [numbered list with brief scope for each]. Are any too large? Am I missing dependencies between slices? Are there parallel paths I'm not exploiting?"

Present the proposed slices to the user for feedback before writing detailed tasks.

**Autonomous mode:** Skip user feedback. Use codex to review the decomposition if available. If codex is unavailable, validate by checking: (1) every user story from the PRD maps to at least one slice, (2) no slice exceeds 5 points, (3) the tracer bullet touches all integration layers. Proceed with the proposed slices.

---

### Step 2: Organize into milestones

Group slices into milestones. Each milestone represents a meaningful deliverable that could be shipped independently.

**Default structure** (adjust based on project size and shape):

| Milestone | Purpose | Typical contents |
|-----------|---------|-----------------|
| 1: Foundation | Prove the architecture | Tracer bullet + core infrastructure |
| 2: Core Features | Deliver the main value | Primary user stories |
| 3: Polish & Edge Cases | Harden for production | Error handling, UX refinement, performance |

Small projects (3-5 tasks) may only need 1-2 milestones. Large projects may need more. The milestone structure should feel natural, not forced.

Present the proposed milestone structure to the user for feedback.

**Autonomous mode:** Skip user feedback. Proceed with the proposed structure.

---

### Step 3: Write detailed task descriptions

For each vertical slice, write a task file using `templates/task-template.md` and `references/ticket-writing.md`.

#### YAML frontmatter

Every task file starts with YAML frontmatter:

```yaml
---
title: "Descriptive, action-oriented title"
milestone: "Milestone 1: Foundation"
estimate: 2
priority: 2
labels:
  - Enhancement
depends-on: []
blocks: []
related: []
---
```

**Estimates** (t-shirt sizes as numeric values):

| Size | Value | Scope | Signal to split? |
|------|-------|-------|-------------------|
| XS | 1 | Config change, single file | No |
| S | 2 | New component, simple endpoint | No |
| M | 3 | Cross-cutting feature, new pattern | Watch closely |
| L | 5 | New subsystem, complex integration | Consider splitting |
| XL | 8 | Multiple subsystems | Must split |

If an estimate exceeds 5, the task is too large. Find a vertical split boundary.

**Priority:**

| Value | Meaning |
|-------|---------|
| 1 | Urgent — blocks everything |
| 2 | High — critical path |
| 3 | Medium — important but not blocking |
| 4 | Low — polish, nice-to-have |

**Labels** — use vocabulary from the workspace: `Enhancement`, `Bug`, `Security`, `Tracer Bullet`, `Task : E2E`, etc. Use `Tracer Bullet` on the first task.

#### Task body sections

Each task body must include ALL of the following sections. Refer to `references/ticket-writing.md` for detailed quality standards on each.

**1. Context** (scale with complexity — short for simple tasks, longer for complex ones)
What this task delivers and why. Include enough project context that someone who hasn't read the full PRD can understand the purpose. Reference the project name but don't depend on having read the PRD.

**Self-containment rule for Context**: The Context section is the primary vehicle for self-containment. Inline the relevant domain knowledge, architectural decisions, and constraints from the PRD that this specific task needs. If the task depends on output from a prior task (e.g., "task-02 created a `collateral_ratios` table"), summarize that output in Context — never say "see task-02."

Bad (not self-contained):
> This task builds the API endpoint for the collateral dashboard. See PRD for requirements and task-01 for the database schema.

Good (self-contained):
> **Project: Collateral Ratio Dashboard** — The platform needs a real-time dashboard showing asset collateral health. This task adds the oRPC query endpoint that returns collateral ratios with status classification. The data model (from the foundation milestone) stores ratios in `idxr_collateral_snapshots` with columns: `asset_id`, `ratio`, `utilization_pct`, `snapshot_at`. Thresholds: healthy > 150%, warning 120-150%, critical < 120%. The endpoint serves the dashboard page at `/collateral` (built in a later task).

**2. Goal** (1 sentence)
The specific outcome this task achieves.

**3. Scope**
Explicit in-scope deliverables and out-of-scope exclusions. Out-of-scope items prevent creep.

**4. Implementation Checklist**
Ordered list of concrete actions. Each step is a single action, not a paragraph. Say WHAT to do and WHERE, not exact line numbers. Reference patterns ("follow the pattern in X") rather than brittle specifics.

**5. Files to Modify/Create**
Table of specific paths and what changes in each. Use directory-level references when exact file names may change.

**6. Acceptance Criteria**
Testable conditions using "Given/When/Then" or checkboxes.

**7. Test Strategy**
Which quality gates prove this works, ordered by speed: types → lint → unit → integration → e2e.

**8. Completion Checklist**
The most important section. Numbered items (CC-01, CC-02, ...) in two categories:

- **Functional verification** (at least one per deliverable): Proves the feature works. A demo of this item would convince a PM. Examples: "Navigate to /settings, change currency to EUR, verify portfolio updates." "POST /api/widgets with {name: 'test'} returns 201 with {id, name, createdAt} shape."
- **Build health** (standard): Full CI tier passes (see testing skill for commands).

Every item must be verifiable by running a command or inspecting specific output. No vague criteria.

**9. Dependencies**
Which tasks must complete first (`depends-on`), which this unblocks (`blocks`), and which share code but have no hard ordering (`related`). Reference task slugs.

**10. Module Mapping**
Table mapping EVERY capability the task needs to an existing package with its path. Be exhaustive — list every utility, pattern, schema, component, and service the implementing agent will touch. Explore the codebase during this step — don't guess. If nothing exists, note "Create new" explicitly. An incomplete module mapping causes agents to reinvent existing infrastructure.

**11. Anti-Requirements**
Deterministic "NEVER" constraints scoped to THIS task. Derived from four sources — include at least one from each applicable source:
- **PRD-level**: The PRD's Global Anti-Requirements (Section 6) — filter to those relevant to this task
- **Project-level**: Hard Blockers in CLAUDE.md (e.g., no `any`, no `as` casts, no relative imports)
- **Architectural**: Boundary constraints (e.g., "NEVER import from `@core/` in `kit/dapp`")
- **Task-specific**: Constraints discovered during codebase exploration for this task (e.g., "NEVER use `readContract` for pre-flight validation — use indexer data")

Each starts with "NEVER" and includes WHY in parentheses. Each is specific enough to grep for. Aim for 4-8 anti-requirements per task — fewer means you haven't explored enough, more means some are too generic.

**12. Verification Protocol**
Table mapping each requirement to the exact command or check that proves it. The Completion Checklist references these rather than duplicating the commands.

**13. Durability Notes**
What's stable (well-established patterns), what's volatile (concurrent work, refactors in progress), and what pattern to follow (existing code to reference).

#### Research during task writing

While writing each task:
- **Codebase exploration**: Identify exact file paths, existing patterns, utilities to reuse
- **context7**: For library-specific implementation guidance
- **codex**: To review a task for completeness (paste full task text — codex has no context)

---

### Step 4: Validate dependency graph

After writing all tasks, validate:
- The tracer bullet has no blockers
- Only direct dependencies (if A→B→C, set A→B and B→C, not A→C)
- No cycles (valid DAG)
- Tasks that touch the same file but can run in any order use `related`, not `depends-on`
- The critical path (longest dependency chain) is reasonable

---

### Step 5: Write plan.md

Write `plan.md` to `output-dir`:

```markdown
# [project-name] — Implementation Plan

## Milestones

### Milestone 1: [name]
- [ ] task-01-slug: [title] (estimate: N pts)
- [ ] task-02-slug: [title] (estimate: N pts)

### Milestone 2: [name]
- [ ] task-03-slug: [title] (estimate: N pts)

## Dependency Graph

task-01 → task-02 → task-04 (critical path)
task-03 (independent, parallel with task-02)

## Task Index

| Slug | Title | Milestone | Estimate | Priority | Depends On |
|------|-------|-----------|----------|----------|------------|
| task-01-slug | Title | 1 | 2 | High | — |
| task-02-slug | Title | 1 | 3 | High | task-01 |

## Suggested Implementation Order

1. task-01-slug — Tracer bullet (no blockers)
2. task-02-slug — Depends on task-01
3. task-03-slug — Independent, parallel with #2
```

---

### Step 6: Write task files

Write each task as a markdown file to `output-dir/tasks/milestone-N-name/task-NN-slug.md`.

**Naming conventions:**
- Milestone directories: `milestone-N-kebab-name` (e.g., `milestone-1-foundation`)
- Task files: `task-NN-kebab-slug.md` (e.g., `task-01-tracer-bullet-token-create.md`)
- NN is zero-padded sequential across all milestones (task-01, task-02, ... task-15)
- Slug is 3-5 words describing the task

Create directories as needed.

---

### Step 7: Present summary and get approval

Present the complete breakdown:

- Number of milestones and their scope
- Number of tasks with total estimate points
- Critical path (longest dependency chain) with total points
- Suggested implementation order
- Any tasks flagged as high-risk or exceeding size 3

Ask:
> Does this breakdown look right?
> 1. **Approve** — finalize
> 2. **Adjust tasks** — tell me which to split, merge, or rewrite
> 3. **Add more tasks** — I missed something
> 4. **Change ordering** — reorder milestones or dependencies

Iterate until approved. After each round of changes, rewrite affected task files and update plan.md.

**Autonomous mode:** Before auto-approving, use codex to review the tracer bullet task (task-01) for completeness — paste the full task text and ask: "Would a fresh agent be able to implement this from this description alone? What's missing?" If codex is unavailable, verify task-01 has all 13 sections populated with non-placeholder content. Then auto-approve and proceed to Step 8.

---

### Step 8: Exit

Return control to the calling skill. Do NOT start implementation.
</process>

<reference_index>
## References

All in `references/`:
- **ticket-writing.md** — Detailed quality standards for each task section: self-containment test, vertical slices, tracer bullet, durability, implementation checklists, completion checklists, estimation, module mapping, anti-requirements, verification protocol, anti-patterns. Read before Step 3.
- **prd-schema.md** — The PRD input schema. Read to understand the structure of the input PRD (especially Section 6 for project-level constraints that feed task anti-requirements).

## Templates

All in `templates/`:
- **task-template.md** — Markdown skeleton with YAML frontmatter and all 13 body sections. Use as the structural starting point for every task file.
</reference_index>

<gotchas>
## Gotchas

- **Horizontal slicing by reflex**: Claude defaults to "Step 1: set up the database, Step 2: build the API, Step 3: build the UI." This creates three tasks where nothing works until all three are done. Force vertical slices: each task delivers working end-to-end functionality.
- **Non-self-contained tasks**: The most common failure. A task that says "see PRD for details" or "builds on the schema from task-02" forces the implementing agent to read other documents. Inline the relevant context into each task.
- **Guessed module mappings**: If you write "Use `@core/cache`" without exploring the codebase, you might be pointing at a package that doesn't exist or has a different API. Always run Explore agents before writing module mappings.
- **Vague completion checklists**: "Feature works correctly" is the #1 completion checklist failure. Every CC item must name a specific action and observable outcome. If you can't run it as a command or describe exactly what you'd see, it's too vague.
- **Hollow anti-requirements**: "NEVER write bad code" is useless. Anti-requirements must be grepable: "NEVER use `as` type assertion (use type narrowing or runtime validation instead)."
- **Transitive dependencies**: If A→B→C, setting A→C as a dependency is redundant and clutters the graph. Only set direct edges.
- **Oversized tasks**: Anything over 5 points hides complexity. When you think a task is size 5, look for a split point — there almost always is one. The implementing agent's context window is finite.
- **Missing tracer bullet**: Skipping straight to "real" tasks means integration issues surface late. The tracer bullet exists to fail fast on architecture questions.
- **Codex context bleed**: Same as prd-builder — codex has zero shared context. Always paste the full PRD and task list into the prompt.
- **Research tool failures**: If exploration tools are unavailable, note which module mappings and file paths are unverified. Mark them as "VERIFY BEFORE IMPLEMENTING" in the durability notes.
</gotchas>

<success_criteria>
- Every task follows the template from `templates/task-template.md` with all 13 body sections present
- Every task has YAML frontmatter with: title, milestone, estimate, priority, labels, depends-on, blocks, related
- Every task passes the self-containment test (implementable by a fresh session from the description alone)
- Every completion checklist has at least one functional verification per deliverable plus build health gates
- No completion checklist contains vague criteria ("works correctly", "looks good", "handles edge cases")
- All criteria are concrete enough to execute without judgment calls
- Tasks are sized at 1-5 points (none exceed 5 without explicit user approval or autonomous override)
- The tracer bullet is task-01 with no blockers and the `Tracer Bullet` label
- Dependency graph is a valid DAG (no cycles)
- plan.md exists with milestone structure, dependency graph, task index, and suggested order
- Codebase explored to identify exact file paths and existing patterns for module mapping
- Module mapping entries point to actual packages, not guesses
- Anti-requirements derived from PRD Section 6 + CLAUDE.md Hard Blockers + codebase boundaries
- User explicitly approved (or auto-approved in autonomous mode)
- No Linear interaction, no implementation started
</success_criteria>
