---
name: execute
description: >-
  Execute implementation work end-to-end — from a Linear ticket or an ad-hoc
  task. Handles the full lifecycle: status routing, workpad persistence,
  research-first planning, tracer-bullet implementation, TDD, self-verification,
  and state transitions. Triggers: "execute", "implement", "work on", "pick up
  ticket", "start PRD-xxx", or any non-trivial implementation task.
user-invocable: true
disable-model-invocation: false
---

<objective>
Execute implementation work autonomously from current state to completion. For Linear tickets: route by state, maintain a persistent workpad, and advance the ticket through the workflow. For ad-hoc tasks: follow the same disciplined phases without Linear integration.

This skill is the orchestrator — it owns the Linear integration, workpad management, and implementation flow. It delegates to two sub-skills:

- **planner** — research-first planning with parallel expert review (no Linear)
- **verifier** — completion checklist execution, sweep, CI verification (no Linear)

Execute handles: state detection, workpad CRUD, implementation orchestration (TDD + tracer bullet), PR creation, state transitions, and autonomous mode signals.
</objective>

<essential_principles>

### 1. Status-aware routing
When working from a Linear ticket, the ticket's current state determines what to do — not assumptions. Always fetch the state first and route accordingly.

### 2. Workpad for multi-session continuity
Every Linear ticket gets a persistent workpad comment. If a session ends mid-work, the next session reads the workpad and picks up where it left off. The workpad is the single source of truth for progress.

### 3. Delegate planning and verification
Planning (research, constitution check, expert review) is delegated to the `planner` skill. Verification (CC-xx execution, sweep, CI) is delegated to the `verifier` skill. Execute only handles the Linear orchestration and implementation phases.

### 4. Tracer bullet first
Start with the simplest end-to-end vertical slice that proves the architecture. Then expand with breadth.

### 5. Autonomous mode
When running headlessly via ralph.sh: no user interaction, workpad is the ONLY persistent state, document every decision with rationale, signal completion with `RALPH_COMPLETE: PRD-xxx` or `RALPH_BLOCKED: PRD-xxx: <reason>`.
</essential_principles>

<required_reading>
Read before proceeding:
- `references/workpad-protocol.md`
- `linear-cli` skill's SKILL.md (for Linear CLI operations)
</required_reading>

<intake>
Determine which path to follow:

**Path A — Linear ticket:** The user provided a ticket identifier (e.g., `PRD-xxx`), or you're running autonomously via ralph.sh with a ticket in the prompt. Proceed to the **Linear Ticket Process** below.

**Path B — Ad-hoc task:** No ticket identifier. The user described a task directly. Proceed to the **Ad-hoc Task Process** below.
</intake>

<!-- ═══════════════════════════════════════════════════════════════════════ -->

<linear_ticket_process>
## Path A: Linear Ticket Execution

### Step 1: Fetch ticket and determine state

```bash
linear issue view PRD-xxx --json --no-pager
```

Extract: `title`, `description`, `state.name`, `state.type`, `url`, `labels`, `comments`.

Search comments for an existing workpad (comment body starting with `## Workpad`). See `references/workpad-protocol.md` for CLI commands.

### Step 2: Route by state

| State | Type | Action |
|-------|------|--------|
| Triage | `triage` | → Phase: Plan (do NOT implement) |
| Backlog | `backlog` | → Phase: Plan (do NOT implement) |
| Todo | `unstarted` | If workpad with plan exists → Phase: Implement. Otherwise → Phase: Plan, then Implement. |
| In Progress | `started` | If workpad exists → read Progress, continue from last checkpoint (Phase: Implement). Otherwise → Phase: Plan, then Implement. |
| In Review | `started` | → Phase: Review (do NOT start new work) |
| Done | `completed` | Nothing to do. Tell the user. |
| Canceled / Duplicate | `canceled` | Nothing to do. Tell the user. |

**Rework detection:** If the ticket was recently moved from In Review back to In Progress (check session log or state history), treat as rework:
1. Read PR review comments first
2. Understand what the reviewer asked for
3. If fundamentally different approach → pass `existing-plan` to planner for a fresh plan, new branch
4. If incremental fixes → update existing plan on workpad, continue on same branch

### Step 3: Transition to In Progress

If the ticket is in Todo (and you're about to implement):

```bash
linear issue update PRD-xxx --state "In Progress" --assignee self
```

---

### Phase: Plan

**When:** Ticket is in Backlog, Triage, or Todo without a workpad plan.

#### 1. Fetch parent project context

```bash
PROJECT_ID=$(linear issue view PRD-xxx --json --no-pager | jq -r '.project.id // empty')

if [ -n "${PROJECT_ID}" ]; then
  linear api --variable "projectId=${PROJECT_ID}" <<'GRAPHQL'
query($projectId: String!) {
  project(id: $projectId) { id name content }
}
GRAPHQL
fi
```

#### 2. Delegate to planner

**Read the `planner` skill's SKILL.md and follow its instructions.** Establish context:

| Context to establish | Value |
|---------------------|-------|
| `task-description` | The full ticket description |
| `output-path` | `/tmp/plan-PRD-xxx.md` |
| `project-context` | The project content from step 1 (if available) |
| `existing-plan` | Existing workpad plan (for rework scenarios) |
| `constraints` | Any constraints from labels, prior decisions |
| `autonomous` | Pass through autonomous flag |

**Complete the full planner workflow before continuing.**

#### 3. Store plan on workpad

Read the plan from `/tmp/plan-PRD-xxx.md`. Create (or update) the workpad comment on the ticket with the plan, initial decisions, progress checklist, and first session log entry. See `references/workpad-protocol.md` for format and CLI commands.

```bash
rm -f /tmp/plan-PRD-xxx.md
```

#### 4. If state is Backlog or Triage: STOP

The plan is written and stored on the workpad. Do NOT implement. The ticket needs to be moved to Todo before implementation begins.

---

### Phase: Implement

**When:** Ticket is in Todo (with plan) or In Progress.

1. **Read the workpad.** Check Progress for what's done and what remains. Read Session Log for context from prior sessions.

2. **Create a task list using TaskCreate with dependencies.** Based on the workpad's plan and the ticket's Implementation Checklist. If continuing from a prior session, mark already-completed items.

   **CRITICAL: You MUST use TaskCreate to register every implementation step. The stop hook (completion.sh) checks for incomplete tasks and blocks premature stopping. If you skip TaskCreate, the hook cannot enforce completion and you WILL stop mid-work.**

   Rules for task creation:
   - Use TaskUpdate to mark tasks `in_progress` when starting and `completed` when done
   - Set dependencies between tasks using `addBlockedBy`/`addBlocks` — e.g., "Fix typecheck" is blocked by all implementation tasks
   - Every implementation task implicitly includes TDD: write failing test → implement → verify test passes. Include test tasks explicitly (e.g., "Write tests for user.events.indexer" → "Implement user.events.indexer")
   - Include verification tasks: "Run Full CI" (`bun run ci` + `bun run e2e`), "Run sweep", "Create PR"
   - Identify tasks that can run in parallel (no dependencies between them) and launch them as concurrent subagents when possible

3. **Tracer bullet.** If this is the first implementation session, start with the simplest end-to-end vertical slice.

4. **Implement with TDD.** Every new file, every modified function, every touched code path gets tests. For each task:
   - Write the test first (red) — read the `tdd` skill for methodology
   - Implement until the test passes (green)
   - Refactor if needed
   - Run the Fast tier (`bun run ci:fast`) periodically (format + lint + typecheck on affected packages)

5. **Update workpad progress.** After completing significant steps, update the workpad's Progress section. This is your checkpoint.

6. **Run checkpoint before verification.** Run the Checkpoint tier (`bun run ci:checkpoint`) — fast + unit tests on affected packages.

7. **When checkpoint passes** → proceed to Phase: Verify. Verification includes the **Full tier**: `bun run ci` (all CI checks) PLUS `bun run e2e --filter=<pkg>` (e2e tests). Both commands are required — `bun run ci` alone is NOT the Full tier.

---

### Phase: Verify

**When:** All implementation tasks are complete.

#### 1. Delegate to verifier

**Read the `verifier` skill's SKILL.md and follow its instructions.** Establish context:

| Context to establish | Value |
|---------------------|-------|
| `completion-checklist` | The Completion Checklist section from the ticket description |
| `verification-protocol` | The Verification Protocol section from the ticket description (if present) |
| `output-path` | `/tmp/verify-PRD-xxx.md` |
| `fix-and-retry` | `true` |
| `autonomous` | Pass through autonomous flag |

**Complete the full verifier workflow before continuing.**

#### 2. Check results

Read the verification report from `/tmp/verify-PRD-xxx.md`.

- **All pass:** Proceed to Phase: PR.
- **Failures remain:** If verifier exhausted its fix cycles and still has failures, assess:
  - Is the failure in the implementation? → Go back to Phase: Implement to address it, then re-verify.
  - Is the failure in the ticket's CC items (unrealistic criterion)? → Flag to the user.

#### 3. Update workpad

Mark all Progress items as checked. Log verification results in the Session Log.

```bash
rm -f /tmp/verify-PRD-xxx.md
```

---

### Phase: PR and State Transition

**When:** Verification is complete — all CC-xx items pass.

1. **Commit.** Create a conventional commit: `type(scope): description`. The commit body MUST include the ticket identifier (e.g., `PRD-xxx`) so Linear auto-links it.

2. **Push and create PR.** Use the commit-push or pr skill.

3. **Transition the issue:**
   ```bash
   linear issue update PRD-xxx --state "In Review"
   ```

4. **Update workpad** with PR URL and final session log entry.

**Autonomous mode:** Commit with ticket ID but do NOT push or create PRs. The orchestrator (ralph.sh) handles that. Output `RALPH_COMPLETE: PRD-xxx`.

---

### Phase: Review

**When:** Ticket is in In Review state.

1. **Do NOT start new implementation work.**

2. **Check for an open PR:**
   ```bash
   gh pr list --head "$(git branch --show-current)" --json number,title,url
   ```

3. **Check for review comments and CI status.** Use the shepherd skill to read and address reviewer comments, fix CI failures, push fixes, and monitor.

4. **If the ticket is moved back to In Progress** (rework signal):
   - Read ALL PR review comments
   - Pass existing plan + review feedback to Phase: Plan as a rework
   - Continue with Phase: Implement after plan update

</linear_ticket_process>

<!-- ═══════════════════════════════════════════════════════════════════════ -->

<adhoc_task_process>
## Path B: Ad-hoc Task Execution

For tasks without a Linear ticket — direct user requests, refactoring, exploratory work.

### Step 1: Assess complexity

If the task is trivial (single file, obvious change, <10 lines): just do it. No ceremony needed. Skip planner and verifier.

If non-trivial: follow Steps 2-5.

### Step 2: Plan

**Read the `planner` skill's SKILL.md and follow its instructions.** Establish context:

| Context to establish | Value |
|---------------------|-------|
| `task-description` | The user's task description |
| `output-path` | `/tmp/plan-adhoc.md` |
| `constraints` | Any constraints the user mentioned (if applicable) |
| `autonomous` | Pass through if applicable |

**Complete the full planner workflow.** The plan is in `/tmp/plan-adhoc.md`.

### Step 3: Implement

1. Read the plan from `/tmp/plan-adhoc.md`
2. Create a task list with dependencies. Start with the tracer bullet.
3. Implement with TDD (read the `tdd` skill for methodology)
4. Periodic quality checks: run the Fast tier from the testing skill (lint + format + typecheck on affected packages)

### Step 4: Verify

**Read the `verifier` skill's SKILL.md and follow its instructions.** Establish context:

| Context to establish | Value |
|---------------------|-------|
| `completion-checklist` | The Completion Checklist from the plan |
| `verification-protocol` | The Verification Protocol from the plan (if present) |
| `output-path` | `/tmp/verify-adhoc.md` |
| `fix-and-retry` | `true` |
| `autonomous` | Pass through if applicable |

### Step 5: Final

Commit when all checks pass. Push/PR if requested.

```bash
rm -f /tmp/plan-adhoc.md /tmp/verify-adhoc.md
```

</adhoc_task_process>

<!-- ═══════════════════════════════════════════════════════════════════════ -->

<autonomous_mode>
## Autonomous Mode (ralph.sh)

When running headlessly via ralph.sh:

- **No user interaction.** Do NOT use `AskUserQuestion`/`request_user_input` or EnterPlanMode. Pass `autonomous: true` to planner and verifier.
- **Workpad is critical.** It is the ONLY persistent state between retries. Update it frequently.
- **Decisions go on the workpad.** Planner documents every architectural choice with rationale. Copy key decisions to the workpad.
- **Completion signals.** After all verification passes, output `RALPH_COMPLETE: PRD-xxx`. If blocked, output `RALPH_BLOCKED: PRD-xxx: <reason>`.
- **Do NOT push or create PRs.** The orchestrator handles that.
- **Commit with ticket ID.** The commit body must include the ticket identifier.
</autonomous_mode>

<gotchas>
## Gotchas

- **State detection before action**: Always fetch the ticket state first. Never assume it's still in the state from a prior session. Another agent or human may have moved it.
- **Workpad loss on comment update**: If the workpad comment ID is wrong, you'll create a second comment instead of updating. Always re-fetch the comment ID before updating.
- **Plan-then-stop for Backlog/Triage**: These states mean "plan only, don't implement." If you implement on a Backlog ticket, you're doing work nobody asked for.
- **Rework vs fresh start**: When a ticket comes back from Review, read the review comments FIRST. If the reviewer wants a fundamentally different approach, start fresh. If they want tweaks, amend.
- **Temp file cleanup**: Clean up `/tmp/plan-PRD-xxx.md` and `/tmp/verify-PRD-xxx.md` after use. Use ticket ID in filenames to avoid collisions.
- **Autonomous mode commit but no push**: ralph.sh handles pushing. If you push, you might conflict with the orchestrator's branch management.
- **Verifier fix loops**: The verifier attempts 3 fix cycles. If it still fails, the issue comes back to execute. Don't just re-delegate to verifier — assess whether the plan or implementation needs rework.
</gotchas>

<reference_index>
## References

- `references/workpad-protocol.md` — Workpad format, section mutability rules, CLI commands for create/update/read.

## Sub-Skills

Workflows delegate to these by reading their SKILL.md and following their instructions. Context is established in the conversation before the sub-skill's SKILL.md is read.

- **planner** — Research-first planning with parallel expert review. Called in Phase: Plan with `task-description`, `output-path`, `project-context`, optional `existing-plan`, `constraints`, `autonomous`.
- **verifier** — Completion checklist execution, sweep, CI. Called in Phase: Verify with `completion-checklist`, `verification-protocol`, `output-path`, `fix-and-retry`, `autonomous`.
- **tdd** — TDD methodology (red-green-refactor). Read during Phase: Implement for methodology guidance.
- **sweep** — Code quality review. Called by verifier, not directly by execute.
- **agent-browser** — Browser automation for UI verification. Used by verifier for UI CC items.
</reference_index>

<success_criteria>
## Success Criteria

A well-executed ticket:
- Has a workpad with plan, decisions, progress (all checked), and session log
- Every CC-xx item in the Completion Checklist passes (verified by verifier)
- Module Mapping was respected (validated by planner)
- Anti-Requirements were respected (validated by planner)
- Full CI tier passes (verified by verifier via testing skill)
- Sweep is clean (run by verifier)
- Commit references the ticket ID
- Ticket is in In Review with a linked PR (or committed without push in autonomous mode)
- The workpad's final session log entry records the PR URL and verification results
</success_criteria>
