---
title: 'flock: my worktree functions, now a fisher plugin'
description: 'The fish functions from my AI dev setup are now a proper, installable fisher plugin. One command to create a worktree, set up a layout, and launch an agent.'
pubDate: 2026-03-29
heroImage: /blog-images/flock-hero.jpg
tags: ['ai', 'fish', 'tooling', 'open-source', 'worktrees']
---

In [How I Stopped Babysitting Claude Code](/blog/remote-ai-development-stack/) I described a set of fish shell functions that wrap my entire worktree workflow — create a branch from a Linear ticket, set up a terminal layout, launch an AI coding agent. One command from ticket to agent working on it. Those functions lived in [my dotfiles](https://github.com/roderik/dotfiles-2026), which meant anyone who wanted to try them had to copy the right files into the right places and hope their setup was close enough to mine.

That's not really sharing something. It's "here, debug this."

I've packaged them as a proper fisher plugin: [roderik/flock](https://github.com/roderik/flock).

```fish
fisher install roderik/flock
```

## What you get

flock wraps the full git worktree lifecycle. Create a branch and worktree, set up your terminal layout, launch your agent, do your work, tear everything down when the PR merges.

```fish
flock new PRD-1234        # fetch ticket, create worktree, set up layout, launch agent
flock delete               # remove current worktree + branch + remote ref
flock orchestrator         # jump to your main project directory
```

Abbreviations ship with it — `fn` / `fd` / `fo` for the short versions, and `wtn` / `wtd` / `wto` as backward-compat aliases for anyone already on the dotfiles originals.

If you're using zellij, a layout file ships with the plugin and gets symlinked on shell start. That's what gives you the three-pane setup — main editor pane, lazygit on the right, spare terminal below. If you're not using zellij, this layer is entirely inert.

Required: `git`, `gh`, `fzf`, `worktrunk`. Optional: `zellij`, `lazygit`, `linear` CLI, `claude` or `codex`.

## Making it portable

The original functions had my machine hardcoded everywhere. The orchestrator directory was `~/Development/dalp`. The remote hostname was `daystrom`. The zellij layout assumed a file that only existed because I'd put it there by hand.

Two environment variables replace all of that:

```fish
set -U FLOCK_ORCHESTRATOR_DIR ~/Development/my-project   # default: ~/Development/dalp
set -U FLOCK_REMOTE_HOST my-server                        # default: daystrom
```

`FLOCK_ORCHESTRATOR_DIR` is the repo everything else orbits around — where `flock orchestrator` drops you. `FLOCK_REMOTE_HOST` is for the zellij helpers that manage remote sessions.

The actual work of packaging wasn't the fisher plugin structure — that's just a repo with functions in `functions/` and completions in `completions/`. It was sitting with each function and asking: what here is behavior, and what here is my specific machine? `daystrom` wasn't just a hostname. It appeared in conditional logic that assumed certain tools were installed remotely but not locally. Pulling that apart meant understanding decisions I'd made implicitly months earlier.

I'm not sure the variable names are final. `FLOCK_ORCHESTRATOR_DIR` is a mouthful. But the seam between "this is what the tool does" and "this is where I happen to run it" — that felt like the thing worth getting right.

**GitHub:** [github.com/roderik/flock](https://github.com/roderik/flock)
