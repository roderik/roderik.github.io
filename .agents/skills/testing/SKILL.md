---
name: testing
description: >-
  Multi-tier testing skill for development quality gates. Four tiers: fast
  (lint+format+typecheck on affected packages), checkpoint (fast+unit tests),
  full (checkpoint+e2e on affected), and manual (delegates to evidence skill
  for browser-based verification with self-learning flows). Use during
  development for fast feedback, after implementation phases for checkpoint
  verification, before PRs for full verification, and as a command for
  manual browser-based testing. Also invoked by the verifier skill for
  functional CC-xx item verification. Do NOT use for code review (use sweep).
user-invocable: true
---

<objective>
Provide fast, targeted quality feedback at every stage of development through four testing
tiers — each progressively broader. Tiers 1-3 are automated CI checks. Tier 4 (manual)
delegates to the evidence skill, which owns the self-learning flow system for browser-based
verification and evidence capture.
</objective>

<important if="always">
## ZERO TOLERANCE POLICY

**`bun run ci` MUST exit 0 with ZERO errors, ZERO warnings across ALL packages — no exceptions.**

- There is NO SUCH THING as a "pre-existing" failure. If CI is red, fix it — period.
- If your changes cause a failure in a package you didn't touch, that is still YOUR failure to fix.
- Never push with red CI. Never dismiss errors as "not caused by me". Never skip packages.
- The CI gate blocks merges. A partially-green run is a FAILED run.
- Before pushing ANY code, run `bun run ci` and confirm ZERO failures across the entire monorepo.
- If you encounter failures you can't fix, STOP and ask the user — do not push broken code.
</important>


<tiers>
## Testing Tiers

| Tier | Command | When to use | What it runs | Target |
|------|---------|-------------|-------------|--------|
| **Fast** | `bun run ci:fast` | During development, after each edit batch | format + lint + typecheck | `--affected` packages only |
| **Checkpoint** | `bun run ci:checkpoint` | After completing a phase or feature chunk | fast + unit tests | `--affected` packages only |
| **Full** | `bun run ci` then `bun run e2e --filter=<pkg>` | Before pushing, before PR creation | checkpoint + integration tests + all CI checks + e2e | `--affected` for CI, targeted filter for e2e |
| **Manual** | `/testing` or `/evidence` | Exploratory testing, complex verification, UI-heavy CC items | evidence skill flows + recording | Specific features via flow composition |

### Tier 1: Fast

Run constantly during development — after saving a batch of edits, after generating code, after any change that might break types or lint.

```bash
bun run ci:fast
```

This runs `compile`, `codegen`, `typecheck`, `lint`, `oxlint`, and `format:check` on `--affected` packages only. Fast because it skips unit tests, knip, shellcheck, migration checks, and contract size checks.

**When the verifier or execute skill says "periodic quality checks"**, this is the command to use.

### Tier 2: Checkpoint

Run after completing a significant implementation phase — tracer bullet done, feature chunk done, before moving to the next task.

```bash
bun run ci:checkpoint
```

This runs everything in fast PLUS unit tests on `--affected` packages. Catches regressions without the overhead of full CI.

**When the execute skill completes Phase: Implement**, run checkpoint before Phase: Verify.

### Tier 3: Full

Run before pushing, before creating a PR, as the final gate.

```bash
bun run ci
```

This runs everything in checkpoint PLUS integration tests, knip, codegen freshness, migration checks, shellcheck, contract size checks — the complete CI pipeline on `--affected` packages. Integration tests (`test:integration`) are included in the ci task — most run against PGLite/testcontainers, and provider suites may call sandbox APIs when credentials are configured.

For E2E, run targeted:
```bash
bun run e2e --filter=@dalp/dapi
```

**When the verifier skill runs build health CC items**, this is the command.

### Tier 4: Manual

For exploratory testing, complex UI verification, or when automated tests aren't enough.

**This tier delegates entirely to the evidence skill.** Load the evidence skill (`/evidence`)
which owns:

- The composable flow system (browser + CLI flows)
- Self-learning protocol (flows adapt when they break)
- Video recording and screenshot capture
- Evidence upload to Linear tickets
- GitHub PR evidence comments

When `/testing` is invoked and manual verification is needed:

1. Run tiers 1-3 first (fast → checkpoint → full CI) to catch static issues
2. Invoke the evidence skill for browser-based verification
3. The evidence skill handles flow composition, execution, recording, and upload

The evidence skill maintains all flows in its `flows/` directory — read its
`flows/INDEX.md` for available flows and their dependency graph.
</tiers>

<credentials>
## Test Credentials

| Role | Email | Password | Pincode |
|------|-------|----------|---------|
| Admin | admin@settlemint.com | settlemint | 111111 |

These are the default dev credentials. Use them for all testing unless specified otherwise.
</credentials>

<gotchas>
## Gotchas

- **`--affected` requires clean git state for accuracy**: If you have uncommitted changes that span many packages, `--affected` may over-include. Commit or stash unrelated changes first.
- **Dev server not running for manual tier**: The evidence skill needs the dev server running. Check portless URLs before invoking manual testing.
- **E2E preflight is slow**: `bun run e2e` runs a preflight that deploys contracts, runs migrations, and waits for subgraph indexing (~60s). Use `PLAYWRIGHT_SKIP_ONBOARDING_SETUP=1` to skip setup when re-running specific test projects.
- **Tier 1 during implementation, not Tier 3**: Running full CI after every edit wastes time. Use `ci:fast` during development, `ci:checkpoint` at phase boundaries, full `ci` only before pushing.
</gotchas>

<integration>
## Integration with Other Skills

| Skill | How testing integrates |
|-------|----------------------|
| **evidence** | Manual tier (Tier 4) delegates to evidence for browser flows, recording, and upload |
| **execute** | Phase: Implement runs `ci:fast` periodically. Before Phase: Verify runs `ci:checkpoint`. |
| **verifier** | Build health CC items use `bun run ci`. Functional UI CC items invoke evidence via testing. |
| **planner** | Test Strategy section references the 4 tiers. |
| **sweep** | Runs after implementation, before testing. Testing validates the code sweep reviewed. |
| **tdd** | TDD cycles use `ci:fast` for quick feedback between red-green-refactor steps. |
</integration>

<success_criteria>
- Correct tier selected for the development stage (fast during dev, checkpoint at phase boundaries, full before PR)
- `--affected` used to scope checks to changed packages
- Manual testing delegates to evidence skill for flow execution and recording
- Test credentials used correctly
- Results clearly reported (which tiers passed, what evidence was captured)
</success_criteria>
