---
name: sweep
description: >-
  Review changed code for reuse, quality, efficiency, and security using six
  parallel review agents (reuse, quality, efficiency, security, cubic,
  adversarial), then fix any issues found. Use this skill whenever the user
  says "review my code", "check my changes", "sweep", "quality check",
  "code review", "clean up", or after completing a feature — even if they
  don't explicitly ask for a review. Also trigger when the user finishes a
  batch of edits and wants a sanity check before committing.
user-invocable: true
---

# Sweep

Review all changed files for reuse, quality, efficiency, and security. Fix any issues found.

## Phase 1: Identify Changes

Determine what to review:

1. Run `git diff --stat` and `git diff --staged --stat` to see the scope of changes.
2. If there are changes, run the full diff (`git diff` or `git diff HEAD` if staged) to get the content.
3. If there are no git changes, check the conversation history for files you edited. If you can identify specific files, review those. Otherwise, tell the user there's nothing to review and stop.

Collect the list of changed file paths — you'll pass these to the review agents so they know where to focus their searches.

## Phase 2: Triage — Select Relevant Agents

Not every change needs all six reviewers. Analyze the diff from Phase 1 and select which agents to run based on what actually changed. Err on the side of caution — when in doubt, include the agent. But skip agents that clearly have nothing to review.

**Decision matrix:**

| Agent | Run when | Skip when |
|-------|----------|-----------|
| **Reuse** | New functions, utilities, or logic added | Config-only, docs-only, or purely deleting code |
| **Quality** | Any code changes (new or modified) | Docs-only, markdown-only, config-only changes |
| **Efficiency** | Code touching hot paths, data fetching, loops, I/O, or rendering | Docs, tests-only, types-only, small config tweaks |
| **Security** | Code handling user input, auth, API routes, env vars, shell commands, or `.sol` files | Docs, pure UI styling, tests-only, markdown |
| **Cubic** | Any code changes | Docs-only, markdown-only, no code in diff |
| **Adversarial** | Substantial code changes (new features, architectural changes, >100 lines of code) | Small fixes, docs, config, styling tweaks, <50 lines of code changes |

**Quick classification by file type:**
- **`.md`, `.mdx`** → Skip all code agents. At most run Quality for prose consistency.
- **`.ts`, `.tsx` (UI components)** → Reuse + Quality + Cubic. Add Efficiency if rendering/data-fetching. Add Security if handling user input.
- **`.ts` (API routes, middleware, server)** → All code agents. Security is mandatory.
- **`.sol`** → Security is mandatory. Quality + Adversarial recommended.
- **`.css`, theme/token files** → Quality only (check token consistency).
- **`config.*`, `package.json`, `tsconfig.*`** → Skip most. Quality if structural concern.
- **Test files only** → Quality only (check for anti-patterns).

State which agents you're launching and why you're skipping the others. Then launch the selected agents concurrently in a single message. Pass each agent the full diff and the list of changed file paths so it has the complete context.

**Finding format**: Every agent must return findings as a list where each item includes the **exact file path and line number** (`file:line`), a severity (`critical` / `warning` / `info`), and a concrete description of what's wrong and how to fix it. Vague observations like "consider improving performance" are not findings — cite the specific code location and state what change to make.

### Agent 1: Code Reuse Review

For each change:

1. **Search for existing utilities and helpers** that could replace newly written code. Use Grep to find similar patterns elsewhere in the codebase — common locations are utility directories, shared modules, and files adjacent to the changed ones.
2. **Flag any new function that duplicates existing functionality.** Suggest the existing function to use instead.
3. **Flag any inline logic that could use an existing utility** — hand-rolled string manipulation, manual path handling, custom environment checks, ad-hoc type guards, and similar patterns are common candidates.

### Agent 2: Code Quality Review

Apply KISS, YAGNI, and single responsibility throughout. Review the same changes for hacky patterns:

1. **Redundant state**: state that duplicates existing state, cached values that could be derived, observers/effects that could be direct calls
2. **Parameter sprawl**: adding new parameters to a function instead of generalizing or restructuring existing ones
3. **Copy-paste with slight variation**: near-duplicate code blocks that should be unified with a shared abstraction
4. **Leaky abstractions**: exposing internal details that should be encapsulated, or breaking existing abstraction boundaries
5. **Stringly-typed code**: using raw strings where constants, enums (string unions), or branded types already exist in the codebase
6. **Type suppression**: anywhere a type error is silenced rather than resolved — casts, `any`, ignored diagnostics, non-null assertions
7. **Complexity**: functions, files, or branching logic that have grown beyond readable size — prefer explicit over clever
8. **AI slop**: abstractions nobody asked for — single-use utilities, comments restating the code, wrappers that only delegate, speculative extension points
9. **Separation of concerns**: IO, logic, and presentation tangled in the same layer
10. **Convention drift**: code that bypasses the project's established patterns — raw browser APIs instead of project utilities, hardcoded values instead of tokens, incomplete API contracts
11. **Test anti-patterns**: tests that hide problems — skipped tests, artificial delays, mocked internals, assertions against implementation rather than behavior
12. **CLAUDE.md hard blockers** — scan changed files for every item in the hard blockers list. These are **merge-blocking** violations:
    - `any`, `as` casts, `@ts-ignore`, `@ts-expect-error`, `!` non-null assertions
    - `toLocaleDateString` / `toLocaleTimeString` / `toLocaleString` (use i18n utilities)
    - New or modified v1 API routes (v1 is frozen)
    - `z.string()` for date/datetime fields (use `z.iso.datetime()` / `z.iso.date()`)
    - oRPC routes without `.meta()` containing `description` and `examples`
    - `test.skip()` or `test.todo()` (delete or implement)
    - Relative imports (`../`) instead of path aliases
    - TODOs, stubs, `throw new Error("not implemented")`
    - Silent bailouts — swallowed errors, silent default returns, fallback code paths in catch blocks
    - Direct `tsc` or `tsgo` invocations (use `bun run typecheck`)
    - On-chain reads (`readContract`, `publicClient`, `NetworkLoader`) in DAPI mutation handlers (use indexer data)

### Agent 3: Efficiency Review

Review the same changes for efficiency:

1. **Unnecessary work**: redundant computations, repeated file reads, duplicate network/API calls, N+1 patterns
2. **Missed concurrency**: independent operations run sequentially when they could run in parallel
3. **Hot-path bloat**: new blocking work added to startup or per-request/per-render hot paths
4. **Unnecessary existence checks**: pre-checking file/resource existence before operating (TOCTOU anti-pattern) — operate directly and handle the error
5. **Memory**: unbounded data structures, missing cleanup, event listener leaks
6. **Overly broad operations**: reading entire files when only a portion is needed, loading all items when filtering for one

### Agent 4: Security Review

Review the same changes for vulnerabilities:

1. **Injection**: untrusted input reaching execution contexts — SQL, shell commands, template engines — without sanitization or parameterization
2. **Secret exposure**: credentials, API keys, or tokens hardcoded in source rather than injected from the environment
3. **Information leaks**: error messages, logs, or responses revealing stack traces, internal paths, or system details to end users
4. **Missing boundary validation**: data from outside the system — user input, API responses, file contents, environment variables — accepted without validation

If smart contract files (`.sol`) are in the diff, also check:

5. **Access control**: state-changing functions callable by unintended actors
6. **Reentrancy**: external calls that can re-enter before state is settled
7. **Upgrade safety**: storage or initialization patterns that break across upgrades
8. **Compliance**: token behavior drifting from ERC-3643 requirements

For smart contracts, consider loading the `audit` skill for deeper analysis if the changes are substantial (new contract, modified access control, changed storage layout).

### Agent 5: Code Review (cubic)

Run `cubic review` and return the issues found. If `cubic` is not available (command not found, not installed, or errors on startup), return an empty finding list — do not block the review on this agent.

### Agent 6: Adversarial Review

Run the `adversarial-review` skill. This spawns reviewers on the **opposite model** (Claude spawns Codex, Codex spawns Claude) to challenge the work from distinct critical lenses. Follow the full instructions in `.agents/skills/adversarial-review/SKILL.md` — load brain principles, determine scope and intent, detect model, spawn reviewers via the opposite CLI (`codex exec` or `claude -p`), and synthesize the verdict. Return the synthesized verdict including severity-rated findings and the lead judgment.

## Phase 3: Fix Issues

Wait for all launched agents to complete. Aggregate their findings into a single list, then triage by severity before fixing:

**Severity ordering** (fix in this order):
1. **Security vulnerabilities** — injection, access control, secret exposure
2. **Correctness bugs** — logic errors, race conditions, data loss risks
3. **Hard blockers from CLAUDE.md** — `any` casts, `@ts-ignore`, `toLocaleString`, etc.
4. **Code quality** — duplication, convention drift, test anti-patterns
5. **Efficiency** — N+1 queries, missed concurrency, hot-path bloat
6. **Style/polish** — naming, minor restructuring

Fix each issue directly. If a finding is a false positive or not worth addressing, note it in your summary and move on — don't argue with the finding, just skip it. For adversarial review findings, respect the lead judgment: accept findings the lead accepted, skip those the lead rejected.

If two agents flag overlapping issues (e.g., Agent 2 and Agent 6 both flag the same function), deduplicate — fix once, credit both.

## Phase 4: Verify

After fixes, run `bun run lint` and `bun run typecheck` to confirm nothing broke. If either fails, fix and re-run before proceeding.

## Phase 5: Quality Bar

Step back and evaluate the changed code holistically against this bar:

- **Engineering**: Everything is fast — instant navigation, optimistic updates, no unnecessary spinners. Clean architecture with no rough edges. Keyboard-first. No feature feels bolted on; everything fits like it was designed together from day one.
- **Design**: Every pixel is intentional. Subtle animations that communicate meaning, not decoration. Information density that feels effortless, not cramped. Dark mode that's a first-class experience, not an afterthought. The kind of UI where users notice it feels good without being able to articulate why. Apply the `design` skill for token/component/layout consistency and the `interaction-design` skill for motion, microinteractions, and state transitions — timing should follow the interaction-design timing guidelines, easing should feel physical (spring-based), and all animation must respect `prefers-reduced-motion`.
- **The test**: If what you built looks like it came from a template, a tutorial, or a ChatGPT prompt — it doesn't meet the bar. The difference is craft: the micro-interactions, the state transitions, the edge cases handled, the details nobody asked for but everyone notices.

If anything falls short, fix it now. When done, briefly summarize what was fixed (or confirm the code was already clean).
