---
title: 'flock: my worktree functions, now a fisher plugin'
description: 'The fish functions from my AI dev setup are now a proper, installable fisher plugin. One command to create a worktree, set up a layout, and launch an agent.'
pubDate: 2026-03-29
heroImage: /blog-images/flock-hero.jpg
tags: ['ai', 'fish', 'tooling', 'open-source', 'worktrees']
---

Every path in my worktree functions was hardcoded to my laptop. The orchestrator directory was `~/Development/dalp`. The remote hostname was `daystrom`. The zellij layout assumed a file that only existed because I'd put it there by hand six months ago.

I knew this because three people told me. They'd read [the AI dev setup post](/blog/remote-ai-development-stack), tried copying the functions into their own fish config, and hit walls that had nothing to do with the actual logic. The functions worked. The assumptions baked into them didn't travel.

That's not really sharing something. It's "here, debug this."

So I spent a weekend extracting the configuration from the behavior. Every hardcoded path became an environment variable. The zellij layout ships with the plugin and gets symlinked on shell start. The whole thing is now a fisher plugin: [roderik/flock](https://github.com/roderik/flock).

```fish
fisher install roderik/flock
```

Two variables control the machine-specific parts:

```fish
set -U FLOCK_ORCHESTRATOR_DIR ~/Development/my-project
set -U FLOCK_REMOTE_HOST my-server
```

`FLOCK_ORCHESTRATOR_DIR` is the repo everything else orbits around — where `flock orchestrator` drops you. `FLOCK_REMOTE_HOST` is for the zellij helpers that manage remote sessions. If you're not using zellij, that entire layer is inert. The layout helpers are behind zellij checks.

The commands do what the original functions did:

```fish
flock new PRD-1234        # fetch ticket, create worktree, layout, launch agent
flock delete               # remove worktree + branch + remote ref
flock orchestrator         # jump to main project directory
```

Abbreviations ship with it — `fn` / `fd` / `fo` for the short versions, and `wtn` / `wtd` / `wto` as backward-compat aliases for anyone already on the dotfiles originals.

The part that took longest wasn't the plugin packaging. Fisher plugins are just a repo with functions in a `functions/` directory and completions in `completions/`. The actual work was sitting with each function and asking: what here is behavior, and what here is my specific machine? That distinction was surprisingly blurry. `daystrom` wasn't just a hostname — it appeared in conditional logic that assumed certain tools were installed remotely but not locally. Pulling that apart meant understanding decisions I'd made implicitly months earlier.

I'm not sure the variable names are final. `FLOCK_ORCHESTRATOR_DIR` is a mouthful. But the seam between "this is what the tool does" and "this is where I happen to run it" — that's the thing that makes the difference between shareable code and code that works on exactly one machine.

**GitHub:** [github.com/roderik/flock](https://github.com/roderik/flock)
