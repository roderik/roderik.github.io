---
name: verifier
description: >-
  Execute completion checklist items (CC-xx), run sweep for code quality review,
  and run CI to verify an implementation is correct and complete. Uses
  agent-browser for UI verification, sweep skill for code review, and the
  testing skill's Full CI tier for build health. Reports pass/fail for every item. Pure verification — does
  NOT interact with Linear or any ticket system. Orchestrated by execute,
  commands, or other skills. Not user-invocable. Do NOT use for planning
  (use planner) or implementation. Use when code is written and needs
  verification before declaring done.
user-invocable: false
---

<objective>
Verify that an implementation is correct and complete by executing every completion checklist item, running sweep for code quality, and running CI for build health. Report a clear pass/fail result for every item.

Pure verification — no Linear, no workpad, no implementation. If a CC item fails, the verifier reports it. The calling skill decides whether to fix and re-verify.
</objective>

<interface>
## Context Contract

The calling skill must establish the following context before this skill's SKILL.md is read and followed.

| Context | Required | Description |
|---------|----------|-------------|
| `completion-checklist` | Yes | The CC-xx items to verify. Either inline text or a file path to the plan/ticket containing the Completion Checklist section. |
| `verification-protocol` | No | Table mapping requirements to exact verification commands (from the plan). If provided, CC items reference these commands. |
| `output-path` | No | File path to write the verification report. If omitted, results are reported in the conversation. |
| `fix-and-retry` | No | `true` to attempt fixing failures and re-verifying (default). `false` to report failures without fixing. |
| `autonomous` | No | `true` for headless execution. Defaults to `false`. |

## Output

- Executes every CC-xx item and reports PASS or FAIL with details
- Runs sweep skill and reports findings
- Runs the Full CI tier (from testing skill) and reports result
- If `output-path` is set, writes a structured verification report
- Returns control to the calling skill with a summary: all-pass or list of failures
</interface>

<essential_principles>

### 1. Pure verification
Execute checks and report results — nothing else. No Linear, no workpad, no new feature code. If `fix-and-retry` is true, fix only what's needed to make CC items pass — no scope expansion.

### 2. CI first, then functional verification
Run CI (`bun run ci` via the testing skill's Full CI tier) as the VERY FIRST verification step. If the code doesn't compile, lint, or pass tests, there's no point running functional CC items on broken code. Once CI is green, execute functional CC items to prove the feature works as intended.

### 3. Every item is binary
Each CC item either PASSES or FAILS. No "partially passes", no "looks close enough". The criterion must be met exactly as written.

### 4. Re-verify after fixes
If a fix is made to address a failure, ALL items must be re-verified — a fix may break something else. This applies to sweep findings too.

### 5. Agent-browser for UI verification
UI-related CC items require `agent-browser --native`. Navigate to the page, interact with elements, verify the expected outcome. Screenshots can provide evidence.
</essential_principles>

<process>

---

### Step 1: Parse the completion checklist

Read `completion-checklist` and extract all CC-xx items. Categorize each:

| Category | Signal | Example |
|----------|--------|---------|
| **Functional — UI** | "Navigate to", "click", "verify ... appears" | CC-01: Navigate to /settings, change currency to EUR, verify portfolio updates |
| **Functional — API** | "POST", "GET", "returns", endpoint paths | CC-02: POST /api/widgets with {name: 'test'} returns 201 |
| **Functional — Data** | "verify ... persists", "query", "refresh" | CC-03: Refresh the page, verify widget still appears |
| **Build health** | "tests pass", "typecheck", "lint", "CI" | CC-04: Full CI tier passes (see testing skill) |

If `verification-protocol` is provided, map each CC item to its verification command.

---

### Step 2: Run CI first (build health gate)

**This is the very first verification action.** Run the Full CI tier from the testing skill (`/testing`) immediately after parsing. The testing skill defines all tier commands — do not hardcode CI commands here. This typically runs `bun run ci` which covers format, lint, typecheck, and all unit + integration tests.

**Why CI first:** If the code doesn't compile, doesn't pass lint, or breaks existing tests, there's no point running functional CC items on broken code. CI is the fastest gate to catch fundamental issues.

If CI fails:
1. Read the error output
2. If `fix-and-retry` is true: fix the issue, re-run CI
3. If `fix-and-retry` is false: report failure and continue (functional items may still provide useful signal)

Record the result:
```
BUILD HEALTH: PASS — Full CI tier passes (format, lint, typecheck, unit + integration tests all green)
```
or
```
BUILD HEALTH: FAIL — typecheck failed in @dalp/dapi (3 errors). [details]
```

---

### Step 3: Execute functional CC items

Execute each functional item in order. For each:

#### UI verification
Use `agent-browser --native`:
```bash
agent-browser --native open <url>
agent-browser --native snapshot -i  # get element refs
agent-browser --native click @e1    # interact
agent-browser --native snapshot -i  # verify result
```

Check the snapshot output for the expected outcome described in the CC item.

#### API verification
Use curl, httpie, or the tool specified in the verification protocol:
```bash
curl -s -X POST http://localhost:3001/api/v2/widgets \
  -H "Content-Type: application/json" \
  -d '{"name":"test"}' | jq .
```

Check the response status code and body against the CC item's expected outcome.

#### Data verification
Run the query or check specified in the CC item. Verify the result matches.

#### Recording results

For each item, record:
```
CC-01: PASS — [brief evidence]
CC-02: FAIL — Expected: 201 response with {id, name}. Got: 500 Internal Server Error.
```

---

### Step 4: Handle functional failures

If `fix-and-retry` is true and any functional CC item failed:

1. Diagnose the root cause from the error
2. Make the minimal fix (no scope expansion)
3. Re-verify ALL functional CC items (not just the one that failed — a fix may break others)
4. Re-run CI (Step 2) after fixes to ensure nothing was broken
5. Repeat until all items pass or you've attempted 3 fix cycles

If `fix-and-retry` is false, report failures and continue to Step 5.

If stuck after 3 fix cycles, report the remaining failures and stop.

**Autonomous mode:** Always attempt fixes (treat as `fix-and-retry: true`). If stuck after 3 cycles, report `FAIL` and let the calling skill decide.

---

### Step 5: Run sweep

Read the `sweep` skill's SKILL.md and follow its instructions. Sweep reviews changed code for:
- **Reuse**: Duplicated logic that should use existing utilities
- **Quality**: KISS, YAGNI, complexity, convention drift
- **Efficiency**: Unnecessary work, missed concurrency, hot-path bloat
- **Security**: Injection, secret exposure, missing boundary validation

#### Handle sweep findings

If sweep produces findings:
1. Triage by severity: Security → Correctness → Hard Blockers → Quality → Efficiency → Style
2. Fix all Security and Correctness findings immediately
3. Fix Hard Blocker findings immediately
4. Fix Quality and Efficiency findings if `fix-and-retry` is true
5. After fixes, re-run CI (Step 2) and re-verify ALL functional CC items (Step 3)

---

### Step 6: Final CI re-run

If any fixes were made in Steps 4 or 5, re-run the Full CI tier one final time to confirm everything is still green.

For UI-heavy verification that goes beyond automated CC items, delegate to the evidence skill (`/evidence`) which owns composable agent-browser flows, video recording, and screenshot capture. The evidence skill uploads proof to the Linear ticket and GitHub PR automatically.

---

### Step 7: Compile verification report

Produce a structured report:

```markdown
## Verification Report

### Summary
- **Status**: ALL PASS / X of Y FAILED
- **Functional items**: N/N passed
- **Build health**: PASS/FAIL
- **Sweep**: Clean / N findings (M fixed, K remaining)

### Results
| Item | Status | Evidence |
|------|--------|----------|
| CC-01 | PASS | Widget appears in list after creation |
| CC-02 | PASS | POST returns 201 with expected shape |
| CC-03 | PASS | Widget persists after refresh |
| CC-04 | PASS | Unit tests pass |
| CC-05 | PASS | Full CI tier green |

### Sweep Findings
- [Fixed] Duplicated validation logic — extracted to shared utility
- [Fixed] Missing error boundary on widget list component

### Fix Cycles
- Cycle 1: CC-02 failed (missing route handler) → added handler → all pass
```

If `output-path` is set, write the report there. Otherwise, present in conversation.

---

### Step 8: Return result

Return control to the calling skill with:
- **All pass**: Every CC item, sweep, and CI passed
- **Failures**: List of failed items with evidence

Do NOT start new implementation. Do NOT interact with Linear.
</process>

<gotchas>
## Gotchas

- **CI is always the first gate**: Run CI (Full CI tier via testing skill) BEFORE functional CC items. If code doesn't compile or breaks tests, functional verification wastes time. CI first catches build-level regressions immediately.
- **Fixing scope creep**: When fixing a CC failure, make the minimal fix. Don't refactor surrounding code, add new features, or "improve" things. That's implementation, not verification.
- **Agent-browser session state**: After navigation or form submission, re-snapshot (`agent-browser snapshot -i`) to get fresh element refs. Stale refs from a previous snapshot will fail.
- **Sweep re-verification loop**: After fixing sweep findings, you must re-run functional CC items. A sweep fix (e.g., extracting a utility) can break feature behavior.
- **Flaky CI**: If CI fails on an unrelated test, investigate briefly. If it's genuinely unrelated (test was already flaky before your changes), note it in the report but don't block. If it's related to your changes, fix it.
- **Dev server dependency**: Many functional CC items require a running dev server. If the dev server isn't running, check the kit's `.portless/url.txt` for the URL, or start it. Don't assume the server is up.
- **Fix cycle limit**: Stop after 3 fix-and-retry cycles. If an issue persists after 3 attempts, it likely needs a different approach — report it and let the calling skill decide.
- **Autonomous mode reporting**: In autonomous mode, write the report to `output-path` (or `/tmp/verification-report.md` if not specified). The calling skill needs the results.
</gotchas>

<success_criteria>
- Every CC-xx item executed and reported as PASS or FAIL with evidence
- CI (Full CI tier) executed as the FIRST verification step, before functional CC items
- Sweep skill run and findings addressed (security/correctness fixed, quality fixed if fix-and-retry)
- Full CI tier passes (see testing skill)
- If fixes were made, ALL items re-verified after each fix
- Clear verification report produced
- No new feature code written (only fixes for failing CC items or sweep findings)
- No Linear interaction, no workpad management
</success_criteria>
