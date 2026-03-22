---
name: shepherd
description: >-
  Shepherd a PR to merge — resolve review comments and keep CI green
  until the PR is merge-ready. Use this skill whenever the user mentions PR issues,
  failing CI, red checks, review comments to address, "make CI green", "fix the
  build", "get this merged", or any variation of babysitting a pull request through
  to completion.
user-invocable: true
---

# Shepherd

Drive a PR to merge-ready state: all checks green, no unaddressed reviews, mergeable.

## PR

!`gh pr view --json number,url,headRefName,state 2>/dev/null || echo "NO_PR"`

If no PR exists, notify the user and stop.
If the PR is merged or closed, notify the user and stop.

## Convergence Loop

Reviews and CI are interdependent: review fixes trigger new CI runs, CI fixes trigger new bot reviews. Loop until both stabilize.

Repeat the following steps **directly** (not via subagents — execute each step yourself in this conversation):

### Step 1: Resolve reviews

Run `bunx agent-reviews --unanswered --expanded` to fetch all unanswered comments.

- If zero comments: skip to Step 2.
- If comments exist: for each comment, evaluate (TRUE POSITIVE → fix, FALSE POSITIVE → won't fix, UNCERTAIN → ask user). After evaluating all:
  - Fix all true positives
  - Run `bunx turbo ci test:integration --affected` to verify fixes
  - Stage files by name (never `git add -A`), commit and push: `git add <files> && git commit -m "fix: address PR review findings" && git push`
  - Reply to every comment using `bunx agent-reviews --reply <id> "<message>" --resolve`
  - When dismissing repeated bot comments across review rounds, batch-reply with a short reference to the prior dismissal reason
  - Record: `reviewsPushed = true`

### Step 2: Wait for review bots

After any push (from Step 1 or previous iteration), review bots need time to analyze.

1. Check bot status: `gh pr view --json statusCheckRollup --jq '[.statusCheckRollup[] | select(.status != "COMPLETED") | select(.workflowName == "") | .name] | join(", ")'`
2. If bots are still running: wait 60 seconds, then re-check. Repeat until all bots complete.
3. After bots complete, run `bunx agent-reviews --unanswered --expanded` one more time.
   - If new comments from bots: process them (same as Step 1), set `reviewsPushed = true`.
   - If no new comments: proceed to Step 3.

### Step 3: Check CI + merge state

Check PR state:

```bash
gh pr view --json mergeable,mergeStateStatus,statusCheckRollup --jq '{
  mergeable: .mergeable,
  mergeState: .mergeStateStatus,
  failing: [.statusCheckRollup[] | select(.conclusion == "FAILURE") | .name],
  pending: [.statusCheckRollup[] | select(.status != "COMPLETED") | .name]
}'
```

- If CI checks are **pending**: wait 60 seconds, re-check. Repeat until all complete.
- If CI checks **failed**: diagnose the failure, fix it, commit and push. Set `ciPushed = true`.
- If merge state is **BEHIND**: run `git fetch origin main && git rebase origin/main && git push --force-with-lease`. Set `ciPushed = true`.
- If merge state is **DIRTY** (conflicts): run `/sync`, resolve conflicts, push. Set `ciPushed = true`.

### Step 4: Convergence check

- If `reviewsPushed` or `ciPushed` → bots will re-analyze. **Go back to Step 1.**
- If neither pushed AND all checks pass AND PR is mergeable → **PR has converged.** Go to Summary.
- If neither pushed but checks still pending → wait 60s, **go back to Step 3.**

## Stop condition

Stop when ALL of:
- Zero unanswered review comments
- All review bot checks completed
- All CI checks green
- PR is mergeable
- No commits pushed in the last iteration

If a blocker requires user help (ambiguous reviewer request, unresolvable conflict, permissions issue), stop and report what needs attention.

## Summary

Report:
- Review findings: fixed, dismissed, skipped (with counts)
- CI failures resolved
- Final PR status + URL
