---
name: planner
description: >-
  Research-first implementation planning with parallel expert review. Takes a
  task description (ticket, ad-hoc request, or PRD), runs codebase exploration,
  library/web research, codex second opinion, constitution check, and parallel
  expert review (feasibility, scope, security, architecture, devil's advocate,
  design, interaction). Produces a structured implementation plan with module
  mapping, anti-requirements, completion checklist, and verification protocol.
  Pure content producer — does NOT interact with Linear or any ticket system.
  Orchestrated by execute, commands, or other skills. Not user-invocable.
  Do NOT use for PRD creation (use prd-builder) or ticket decomposition
  (use task-builder) or verification (use verifier).
user-invocable: false
---

<objective>
Take a task description and produce a structured, research-backed implementation plan that has been validated by parallel expert reviewers. The plan is detailed enough for a fresh agent session to implement from it alone.

This skill handles the full planning workflow: research → plan → expert review → deepen → approve.

Pure content producer — no Linear, no workpad, no implementation. The calling skill handles storage and orchestration.
</objective>

<interface>
## Context Contract

The calling skill must establish the following context before this skill's SKILL.md is read and followed.

| Context | Required | Description |
|---------|----------|-------------|
| `task-description` | Yes | The full task description — ticket body, ad-hoc request, or PRD section to implement |
| `output-path` | Yes | File path where the final plan should be written |
| `project-context` | No | Parent project PRD content for broader context |
| `existing-plan` | No | A prior plan to refine (for rework scenarios) |
| `constraints` | No | Additional constraints or decisions already made |
| `autonomous` | No | `true` for headless execution. Auto-approves after review. Defaults to `false`. |

## Output

- Writes the approved plan as markdown to `output-path`
- The plan contains all 8 ticket-ready sections (see Phase 3)
- Returns control to the calling skill
</interface>

<essential_principles>

### 1. Pure content production
Produce a plan markdown file — nothing else. No Linear API calls, no workpad management, no implementation, no code. The calling skill handles storage and orchestration.

### 2. Research before everything
Never draft a plan from assumptions. Every claim about existing code, available utilities, or architectural patterns must be grounded in actual codebase exploration. Library usage must be validated against current docs. Approaches must be validated against current best practices.

### 3. Constitution check is non-negotiable
The plan must not violate: Hard Blockers from CLAUDE.md, the task's Module Mapping (use specified packages), the task's Anti-Requirements (NEVER constraints), or architectural boundaries from the project PRD's Agent Execution Context.

### 4. Parallel expert review catches blind spots
7 specialized reviewers challenge the plan from different angles. A plan that passes all reviewers is far more robust than one reviewed by a single generalist. The cost is tokens; the benefit is catching issues before implementation.

### 5. Codex has no context
Every `mcp__codex__codex` prompt must be fully self-contained. Include all relevant facts, constraints, and tech stack. Codex cannot see the conversation or codebase.

### 6. Plans must be implementable by a fresh session
The plan should contain enough detail that an agent reading only this plan (not the ticket, not the PRD) can understand what to build, which files to touch, what patterns to follow, and when it's done.
</essential_principles>

<invocation_modes>
## Invocation Modes

This skill can be invoked in two ways:

**Full invocation (default):** The calling skill says "read planner's SKILL.md and follow its instructions." Run all phases 1-8 in order.

**Partial invocation (review-only):** The ExitPlanMode hook invokes planner for review only — "run Phase 4 through Phase 6 on this plan file." In this case:
- Skip Phases 1-3 (the plan already exists)
- Read the plan from the file path provided by the hook
- Run Phase 4 (Parallel expert review), Phase 5 (Research & deepen), Phase 6 (Final quality check)
- Skip Phases 7-8 (the hook handles approval and marker creation)
- After Phase 6, create the review marker file as instructed by the hook: `touch <marker-path>`

The calling context makes it clear which mode applies.
</invocation_modes>

<process>

---

### Phase 1: Research

#### Step 1: Parse the task

Read `task-description` and identify:
- **Goal**: What needs to be built and why
- **Acceptance criteria**: How to know it's done
- **Module mapping**: Which packages to use (if specified)
- **Anti-requirements**: What to never do (if specified)
- **Completion checklist**: CC-xx items (if specified)

If `project-context` is provided, read it for broader architectural context (especially Section 6: Agent Execution Context).

#### Step 2: Codebase exploration (always do this)

Launch Explore agents in parallel to:
- Find files the task will touch
- Understand existing patterns in those areas
- Identify utilities to reuse (feeds Module Mapping)
- Map architectural boundaries (feeds Anti-Requirements)
- Find tests to extend or follow patterns from

This directly feeds Phases 2 and 3.

#### Step 3: Library and web research (as needed)

In parallel with codebase exploration:

- **Library docs**: Use `mcp__context7__resolve-library-id` + `mcp__context7__query-docs` for every library/framework mentioned in the task
- **Web research**: Use `mcp__exa__web_search_exa` for technical approaches, patterns, pitfalls
- **Code examples**: Use `mcp__exa__get_code_context_exa` for implementation patterns

#### Step 4: Second opinion

Use `mcp__codex__codex` with a self-contained prompt:

> "I'm implementing [task summary]. Tech stack: [stack]. Existing patterns: [from exploration]. The approach I'm considering: [brief approach]. Constraints: [from task]. What am I missing? What could go wrong?"

If codex is unavailable, proceed without — note which assumptions were not independently challenged.

Summarize all research findings before proceeding.

**Autonomous mode:** Summarize internally and proceed.

---

### Phase 2: Draft plan

Using research findings, draft the implementation plan.

#### Constitution check

Before finalizing, verify the plan does not violate:
- **Hard Blockers** from CLAUDE.md (no `any`, no `as` casts, no relative imports, etc.)
- **Module Mapping** from the task (use specified packages, not alternatives)
- **Anti-Requirements** from the task (every NEVER constraint respected)
- **Architectural boundaries** from the project PRD's Agent Execution Context (if present)

Flag any violations and adjust the plan.

#### Surface decisions

Identify architectural choices that have trade-offs. In interactive mode, present each to the user via `AskUserQuestion` with concrete options and pros/cons. In autonomous mode, pick the pragmatic choice and document the rationale.

**Autonomous mode:** Document all decisions with rationale directly in the plan. Do not ask the user.

---

### Phase 3: Ensure ticket-ready structure

The plan must contain ALL 8 sections. Add any that are missing. Ground each in codebase exploration findings.

Read `references/ticket-writing.md` for detailed quality standards on each section — especially Completion Checklists (functional verification + build health, CC-xx numbering, no vague criteria), Module Mapping (codebase-grounded, not guesses), and Anti-Requirements (NEVER + grepable + WHY).

**1. Acceptance Criteria**
Testable Given/When/Then conditions for every deliverable. Not "works correctly" — concrete, executable checks.

**2. Completion Checklist**
Numbered CC-01, CC-02, etc. Two sections:
- **Functional verification**: proves each deliverable works (navigate to X, call Y, verify Z)
- **Build health**: Full CI tier passes (see testing skill for commands)

**3. Module Mapping**
Table of Need → Use This → Location. Every entry grounded in codebase exploration — not guesses.

**4. Anti-Requirements**
Each starts with "NEVER", is specific enough to grep for, includes WHY in parentheses. Derived from: CLAUDE.md Hard Blockers, task constraints, architectural boundaries.

**5. Verification Protocol**
Table mapping each requirement to a concrete verification command. The Completion Checklist references these.

**6. Files to Modify/Create**
Table of Path → Action → What Changes. Use directory-level references when exact files may change.

**7. Test Strategy**
Quality gates mapped to testing tiers: `ci:fast` (types + lint) → `ci:checkpoint` (fast + unit) → `ci` (full) → `e2e` → manual flows (agent-browser). Reference the `testing` skill for tier details.

**8. Vertical Slices**
If the plan has multiple deliverables, structure them as vertical slices (each cutting all layers end-to-end). The first slice is the tracer bullet.

---

### Phase 4: Parallel expert review

Launch ALL applicable reviewers as subagents **in parallel** (single message, multiple Agent tool calls). Each subagent reads the draft plan and returns: **PASS**, **CONCERNS** (with list), or **REWORK** (with reasons).

#### Reviewer 1: Feasibility
Can this be built? Validate assumptions against actual code. Check that referenced files, modules, patterns, and APIs actually exist. **Required**: codebase exploration.

#### Reviewer 2: Scope & Completeness
Everything needed, nothing more? Missing edge cases, migration gaps, missing tests? Scope creep, YAGNI? **Required**: codebase exploration.

#### Reviewer 3: Security & Safety
Auth gaps, injection risks, data leaks, breaking changes, unsafe state transitions, race conditions?

#### Reviewer 4: Architecture
Fits the system? Layering violations, coupling, inconsistency? Performance, observability, deployment? **Required**: context7 docs, web search for best practices.

#### Reviewer 5: Devil's Advocate
Strongest case AGAINST this plan. Challenge core assumptions. Propose at least one concrete alternative. **Required**: web search for alternatives and failure cases.

#### Reviewer 6: Design & UX (skip if no UI)
Visual hierarchy, animation, dark mode, keyboard-first, craft vs template? **Required**: check existing components, web search and context7 for UI patterns.

#### Reviewer 7: Interaction & Motion (skip if no UI)
Loading states, optimistic updates, error recovery, transitions, feedback on every action, `prefers-reduced-motion`? **Required**: web search for interaction patterns.

#### Resolution

- **Any REWORK**: Update the plan to address concerns, then re-run only the reviewers that flagged REWORK
- **Only CONCERNS**: In interactive mode, present to user and ask whether to address. In autonomous mode, address all concerns.
- **All PASS**: Proceed to Phase 5

**Autonomous mode:** Address all REWORK and CONCERNS without asking. Use best judgment.

---

### Phase 5: Research & deepen

Enrich the plan with per-section research.

#### Step 1: Discover applicable skills

Check which project skills are relevant to the plan:

```bash
ls .agents/skills/*/SKILL.md
```

Read descriptions. For skills whose domain overlaps (design, shadcn, rest-route-conventions, better-auth-best-practices, etc.), spawn subagents that apply each skill's lens to the plan and return recommendations.

#### Step 2: Per-section research

For each major plan section, spawn a research subagent that:
1. Explores the codebase for existing patterns the section should reference
2. Queries context7 for up-to-date docs on referenced technologies
3. Searches the web (exa) for recent best practices and pitfalls
4. Returns concrete, actionable recommendations

#### Step 3: Enhance plan sections

Merge research findings into each section as "Research Insights" subsections. Preserve all original content — research enhances, not replaces.

---

### Phase 6: Final quality check

Before writing output:

- [ ] All original task intent preserved
- [ ] Every library validated against up-to-date docs
- [ ] Code examples syntactically correct and follow project conventions
- [ ] No contradictions between sections
- [ ] All 8 ticket-ready sections present and concrete
- [ ] No vague criteria ("works correctly", "looks good")
- [ ] Acceptance criteria are executable
- [ ] Constitution check passed (no Hard Blocker violations)

**Autonomous mode:** Run this check internally. If codex is available, use it for a final review of the complete plan.

---

### Phase 7: Approval

Present the complete plan to the user. Ask:

> How would you like to proceed?
> 1. **Approve** — finalize this plan
> 2. **Refine a section** — tell me which
> 3. **More research** — tell me what topic
> 4. **Different approach** — restart from Phase 2

Iterate until approved.

**Autonomous mode:** Auto-approve after Phase 6 quality check passes.

---

### Phase 8: Write output

Write the approved plan to `output-path` using the Write tool. Return control to the calling skill.
</process>

<gotchas>
## Gotchas

- **Skipping codebase exploration**: The most common failure. Module Mapping, Anti-Requirements, and Files to Modify all require actual codebase findings. A plan based on assumptions will mislead the implementing agent.
- **Research tool failures**: If context7/exa/codex are unavailable, proceed with codebase exploration alone. Note unvalidated assumptions in the plan. Never block on a research tool failure.
- **Constitution check as afterthought**: Run it BEFORE expert review, not after. A plan that violates Hard Blockers will waste reviewer tokens.
- **Reviewer parallelism**: Launch ALL reviewers in a single message. Sequential review is 7x slower. Each reviewer is independent.
- **REWORK loops**: If a reviewer flags REWORK, only re-run that specific reviewer after fixing — not all 7. Otherwise you burn tokens.
- **Template-itis in completion checklists**: "Feature works correctly" is not a CC item. Every CC item must name a specific action and observable outcome.
- **Codex context bleed**: Codex has zero shared context. Always paste full task and plan text into prompts.
- **Autonomous mode still needs review**: Auto-approve doesn't mean skip expert review. The 7 reviewers catch issues that self-review misses.
- **Over-planning trivial tasks**: If the task is < 10 lines of obvious changes, the calling skill should skip planner entirely. Planner is for non-trivial work.
</gotchas>

<reference_index>
## References

All in `references/`:
- **ticket-writing.md** — Quality standards for all 8 ticket-ready sections: self-containment test, vertical slices, completion checklists, estimation, module mapping, anti-requirements, verification protocol, anti-patterns. Read before Phase 3.
</reference_index>

<success_criteria>
- Plan written to `output-path`
- Codebase explored to ground Module Mapping, Files to Modify, Anti-Requirements in actual code
- At least one research tool used beyond codebase exploration
- Constitution check passed (no Hard Blocker violations)
- All 7 reviewers ran (skipping Design/Interaction only if no UI)
- All REWORK items resolved
- All 8 ticket-ready sections present and concrete
- No vague criteria in Completion Checklist or Acceptance Criteria
- User approved (or auto-approved in autonomous mode)
- No Linear interaction, no workpad management, no implementation started
</success_criteria>
