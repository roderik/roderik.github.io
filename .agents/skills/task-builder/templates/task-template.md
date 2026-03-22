---
title: "[Action-oriented title]"
milestone: "[Milestone Name]"
estimate: 2
priority: 2
labels:
  - Enhancement
depends-on: []
blocks: []
related: []
---

## Context

<!-- Scale with complexity: short for simple tasks, longer for complex ones. Include enough project context, domain knowledge, and prior-task outputs that a fresh Claude session can implement this task from this description alone. NEVER reference other tasks or the PRD — inline all needed context here. -->

**Project:** [Project Name]
**Milestone:** [Milestone Name]

## Goal

<!-- 1 sentence: The specific outcome this task achieves. -->

## Scope

**In scope:**
- <!-- Specific deliverable -->

**Out of scope:**
- <!-- Explicitly excluded to prevent creep -->

## Implementation Checklist

<!-- Ordered list of concrete actions. Detailed enough to follow step-by-step, but flexible enough to survive codebase changes. Focus on WHAT to do and WHERE, not exact line numbers (those change). -->

- [ ] <!-- Step 1: e.g., "Add the new database schema field in packages/db/schema/..." -->
- [ ] <!-- Step 2: e.g., "Create the API endpoint handler in packages/api/routes/..." -->
- [ ] <!-- Step 3: e.g., "Add the UI component following the pattern in packages/dapp/components/..." -->
- [ ] <!-- Step 4: e.g., "Write unit tests covering the new logic" -->
- [ ] <!-- Step 5: e.g., "Verify types, lint, and existing tests pass" -->

## Files to Modify/Create

<!-- Specific paths and what changes in each. Use directory-level references when exact file names may change. -->

| Path | Action | What Changes |
|------|--------|-------------|
| <!-- `packages/db/schema/foo.ts` --> | Modify | <!-- Add new field --> |
| <!-- `packages/api/routes/bar.ts` --> | Create | <!-- New endpoint handler --> |

## Acceptance Criteria

<!-- Testable conditions. Use Given/When/Then or simple checkboxes. -->

- [ ] <!-- Given [context], when [action], then [expected result] -->
- [ ] <!-- Given [context], when [action], then [expected result] -->
- [ ] All existing tests pass
- [ ] No regressions in related functionality
- [ ] Types check passes (`bun run typecheck`)

## Test Strategy

<!-- Which quality gates prove this works? Prefer fastest: types > lint > unit > integration > e2e -->

- [ ] Type check passes
- [ ] Lint passes
- [ ] Unit tests for new/changed logic
- [ ] <!-- Additional: integration test, e2e test, manual verification -->

## Completion Checklist

<!-- The implementing agent MUST pass every item below BEFORE signaling completion.
     Two categories: functional verification (does the feature work?) and build health (does nothing break?).

     Rules:
     - Number each item (CC-01, CC-02, ...) for traceability
     - Every item must be verifiable by running a command or inspecting a specific output
     - Include at least one functional check per deliverable
     - Always include the standard build health checks at the end
     - Never use vague criteria like "works correctly", "looks good", or "handles edge cases"
     - All ambiguity was resolved during brainstorm — every criterion here must be concrete -->

**Functional verification:**
- [ ] CC-01: <!-- e.g., "Navigate to /widgets, click 'Create', fill name='Test', submit — verify widget appears in list" -->
- [ ] CC-02: <!-- e.g., "POST /api/widgets with {name: 'test'} returns 201 with {id, name, createdAt} shape" -->

**Build health:**
- [ ] CC-03: <!-- e.g., "All new/changed logic has unit tests that pass" -->
- [ ] CC-04: <!-- e.g., "Full CI tier passes (see testing skill)" -->

## Dependencies

- **Depends on:** <!-- task-slug — what must be done first and why -->
- **Blocks:** <!-- task-slug — what this unblocks -->
- **Related:** <!-- task-slug — touches similar code but no hard dependency -->

## Module Mapping

<!-- Exhaustively map EVERY capability this task needs to an existing package. List every utility, pattern, schema, component, and service the implementing agent will touch. An incomplete mapping causes agents to reinvent existing infrastructure. -->

| Need | Use This | Location |
|------|----------|----------|
| <!-- e.g., Database queries --> | <!-- e.g., Drizzle schema + existing query patterns --> | <!-- `packages/dalp/database/` --> |
| <!-- e.g., API endpoint --> | <!-- e.g., oRPC route with .meta() --> | <!-- `kit/dapi/src/routes/` --> |

## Anti-Requirements

<!-- Deterministic constraints scoped to THIS task. Derive from: PRD anti-requirements, CLAUDE.md Hard Blockers, architectural boundaries, and task-specific constraints found during exploration. Aim for 4-8 items. Include WHY in parentheses. -->

- NEVER <!-- e.g., "add a new npm dependency for functionality already in @core/validation (prevents duplication)" -->
- NEVER <!-- e.g., "use raw SQL — always use the Drizzle query builder (consistency + type safety)" -->

## Verification Protocol

<!-- Maps requirements to specific commands or checks. The Completion Checklist references these. -->

| Requirement | Verification Command / Check |
|-------------|------------------------------|
| <!-- e.g., "New endpoint returns 201" --> | <!-- `curl -X POST localhost:3001/api/v2/widgets -d '{"name":"test"}' \| jq .status` --> |

## Durability Notes

<!-- What parts are resilient to main branch changes? What might need adjustment? -->

- **Stable:** <!-- e.g., "The database schema pattern is well-established" -->
- **Volatile:** <!-- e.g., "The auth middleware is being refactored — check current implementation" -->
- **Pattern to follow:** <!-- e.g., "Follow the existing pattern in packages/api/routes/existing-endpoint.ts" -->
