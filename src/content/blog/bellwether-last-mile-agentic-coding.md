---
title: 'From AI code to merged PR: closing the last mile'
description: 'AI coding agents are good at writing code and opening PRs. The part nobody talks about: what happens after. bellwether closes that loop.'
pubDate: 2026-03-29
tags: ['ai', 'agents', 'tooling', 'github', 'bellwether']
---

AI coding agents have gotten remarkably good at writing code. You describe a feature, Claude Code or Cursor writes it, opens a PR. Done, right?

Not quite.

The PR is open. CI is running. A reviewer leaves a comment. And suddenly you're back at the keyboard — refreshing GitHub, reading logs, copying error messages into a new prompt, waiting for the agent to fix things, then doing it all again.

The agent handled the hard part. You're doing the grunt work.

This is the last-mile problem in agentic coding, and it's why I built [bellwether](https://github.com/roderik/bellwether).

---

## What the loop actually looks like

Here's the typical flow when an AI agent opens a PR:

1. Agent writes code, opens PR
2. CI runs — you wait
3. CI fails — you read the logs, find the actual error buried in the noise, paste it into the agent prompt
4. Agent fixes it, pushes — you wait again
5. Reviewer leaves a comment — you read it, summarize it, paste it in
6. Repeat until green

Each step is a context switch. Each "copy error from GitHub, paste to agent" is manual plumbing that shouldn't exist.

The agent is capable of handling this loop autonomously — it just doesn't have clean access to the state it needs.

---

## What bellwether does

bellwether is a TypeScript CLI that reads your PR's current state and returns it in a structured, token-efficient format:

```bash
npx -y bellwether@latest check --watch
```

Output:

```
pr:
  state: open
  mergeable: clean
  ready: true
ci:
  sha: abc1234
  checks: "3 total, 3 passing, 0 failing, 0 pending"
  passed: "build, lint, test"
reviews:
  total: "0 unresolved, 0 unanswered"
```

When CI fails, you get the actual error — not the raw GitHub API payload, just what failed and where:

```
ci:
  FAIL build: "TypeError: Cannot find name 'fetch' at src/client.ts:12"
```

`--watch` blocks until CI completes and the PR reaches a terminal state. No polling loop in your script. No refreshing the browser.

---

## The watch loop

The mental model is simple:

```
check --watch
  → pr.ready = true?   → done ✓
  → CI failing?        → show filtered error logs
  → Unresolved review? → show comment with context
  → Merge conflict?    → sync branch needed
```

Your agent runs this, reads the output, knows exactly what to fix, pushes a commit, and runs it again. The loop is tight. The signal is clean. No browser required.

---

## Design decisions

### Token efficiency over completeness

The GitHub Checks API is verbose. A single failed check run returns megabytes of JSON containing build metadata, timestamps, step names, environment variables — and somewhere in there, the actual error.

bellwether queries Check Runs, fetches job logs, and filters down to the actionable signal: compiler errors, test failures, the lines that actually matter. Raw API responses are expensive for agents to process. Focused output isn't.

This was directly inspired by [RTK](https://github.com/rtk-ai/rtk) — a token-efficient CLI proxy that does the same thing for git and other dev tools. If you're not using RTK alongside bellwether, you should be.

### Standing on shoulders: agent-reviews

The core idea — that an AI agent should be able to read, respond to, and resolve PR review comments autonomously — comes directly from [agent-reviews](https://github.com/pbakaus/agent-reviews) by @pbakaus. That project showed the pattern works. bellwether takes it further by integrating it into a full watch loop alongside CI and merge state, but the insight is his. Worth reading if you want to understand the problem space.

### Clean signal, not automation

bellwether doesn't try to fix things. It tells you what's broken in a format your agent (or you) can act on. The agent decides what to do.

This is a deliberate choice. Automated PR fixers that also decide what to change are a different category of tool — and a much more dangerous one. bellwether is an observation layer. It composes with whatever agent or workflow you're already using.

### Works for humans too

`check --watch` is just a nicer way to monitor a PR than refreshing GitHub. The agent-first framing is the primary use case, but the tool is useful without an AI agent in the loop. No magic mode required.

### Review comment handling

bellwether surfaces unresolved review comments with file and line context. You can also reply and resolve inline:

```bash
# Show unresolved comments
npx -y bellwether@latest check --unresolved

# Reply to comment 456 and mark it resolved
npx -y bellwether@latest check --reply "456:Fixed in abc1234" --resolve
```

For agents, this means the full review cycle — read comment, understand context, fix code, reply, resolve — can happen without a human touching GitHub.

---

## Installing as a Claude Code skill

bellwether ships as a Claude Code skill. One command installs it into your local Claude Code context:

```bash
npx -y bellwether@latest skills add
```

Once installed, Claude Code knows the full bellwether loop: watch CI → fix failures → address reviews → push → repeat until `pr.ready = true`. It's available on the [Claude Code marketplace](https://github.com/roderik/bellwether/blob/main/marketplace.json) as well.

The dual-mode design (CLI for humans, skill for agents) means the same tool works in both contexts. You're not maintaining two separate integrations.

## Hooks: zero-friction PR feedback

Once you've installed the skill, bellwether adds Claude Code hooks that trigger automatically after common git operations:

- **After `git push`** — immediately checks CI and review state on your PR
- **After `gh pr create`** — checks the new PR's initial state
- **After `gh pr ready`** — confirms it's actually ready before you notify reviewers

The hook runs `npx -y bellwether@latest hook-check --format json` and feeds the result back into Claude Code's context. Your agent doesn't need to remember to check — it happens automatically every time you push.

This is the part that makes the loop feel tight. No manual `check --watch` invocation between pushes. Push → CI state appears → agent decides what to do next.

---

## Where it's headed

bellwether is early — v0.0.6, a few days old. The core watch loop works. What's next:

- **Auto-merge on ready**: once `pr.ready = true`, optionally trigger merge
- **Multi-PR mode**: watch several PRs at once, surface only the ones that need attention
- **Better log filtering**: smarter signal extraction from more CI providers

If you're working on agentic coding workflows and hitting the same last-mile friction, I'd genuinely like to know what your setup looks like. Issues and PRs welcome.

---

**GitHub:** [github.com/roderik/bellwether](https://github.com/roderik/bellwether)
**npm:** [npmjs.com/package/bellwether](https://npmjs.com/package/bellwether)

```bash
# Try it now — no install needed
npx -y bellwether@latest check
```
