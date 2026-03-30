---
title: 'flock: my worktree functions, now a fisher plugin'
description: 'The fish functions from my AI dev setup are now a proper, installable fisher plugin. One command to create a worktree, set up a layout, and launch an agent.'
pubDate: 2026-03-29
heroImage: /blog-images/flock-hero.jpg
tags: ['ai', 'fish', 'tooling', 'open-source', 'worktrees']
---

The fish functions I wrote about in [my AI dev setup post](/blog/remote-ai-development-stack) — the ones that create a worktree, set up a terminal layout, and launch an AI coding agent in one command — have been living in my dotfiles. Which means anyone who wanted to try them had to copy the right files into the right places and hope their setup was close enough to mine.

That's not really sharing something. It's "here, debug this."

I've packaged them as a proper fisher plugin: [roderik/flock](https://github.com/roderik/flock).

---

## What it does

flock is a fish shell plugin that wraps the full worktree lifecycle. Create a branch and worktree, set up your terminal layout, run your work, clean everything up when the PR merges.

The main commands:

```fish
flock new PRD-1234        # fetch ticket, create worktree, set up layout, launch agent
flock delete               # remove current worktree + branch + remote ref
flock orchestrator         # jump to your main project directory
flock tab-setup            # set up pane layout in current directory (runs internally)
```

Abbreviations ship with it — `fn` / `fd` / `fo` / `fs` for the short versions, and `wtn` / `wtd` / `wto` / `wts` as backward-compat aliases for anyone already muscle-memoried into the dotfiles originals.

---

## Install

```fish
fisher install roderik/flock
```

Required: `git`, `gh`, `fzf`, `worktrunk`. Optional but used if present: `zellij` (terminal layout), `lazygit` (git TUI), `linear` CLI (ticket fetching), `claude` or `codex` (agent launch).

---

## Configuration

Two environment variables control the machine-specific parts:

```fish
set -U FLOCK_ORCHESTRATOR_DIR ~/Development/my-project   # default: ~/Development/dalp
set -U FLOCK_REMOTE_HOST my-server                        # default: daystrom
```

`FLOCK_ORCHESTRATOR_DIR` is where `flock orchestrator` drops you — the repo everything else orbits around. `FLOCK_REMOTE_HOST` is used by the zellij helpers for remote sessions.

---

## The zellij layout

A zellij layout (`zellij/flock.kdl`) ships with the plugin. On shell start, flock symlinks it to `~/.config/zellij/layouts/flock.kdl`. This is what `flock tab-setup` uses to configure your panes — main editor pane, lazygit on the right, spare terminal below.

If you're not using zellij, this part is entirely inert. The layout helpers are isolated behind zellij checks.

---

## Why it took this long to package

Mostly because the original functions were full of hardcoded assumptions. The orchestrator directory. The remote hostname. The `wt_new` function assumed a specific zellij layout that only existed on my laptop. Making them actually portable — configurable without editing source — required separating what the functions do from where I personally run them.

That's what `$FLOCK_ORCHESTRATOR_DIR` and `$FLOCK_REMOTE_HOST` are: the seams between "this behavior" and "my specific setup." It's not a novel pattern. It just required doing the work of identifying what was actually configuration.

---

If you've been running the [AI dev setup](/blog/remote-ai-development-stack) and copying these functions by hand, this replaces that. Everything else in that setup still stands — flock is just the worktree and layout layer, now installable.

**GitHub:** [github.com/roderik/flock](https://github.com/roderik/flock)

```fish
fisher install roderik/flock
```
