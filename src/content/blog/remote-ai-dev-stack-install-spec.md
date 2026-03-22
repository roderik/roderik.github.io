---
title: 'Installation Spec: The Remote AI Development Stack'
description: 'Everything you need to reproduce the AI development setup from the blog post. Agent-executable on a fresh macOS machine.'
pubDate: 2026-03-22
tags: ['ai', 'engineering', 'tooling', 'setup']
draft: true
---

> Companion to [My AI Dev Setup](/blog/remote-ai-development-stack). Only covers what's needed for the stack described there.

## Prerequisites

- macOS 14+ (Apple Silicon)
- Homebrew installed
- GitHub CLI authenticated (`gh auth login`)
- Claude Code installed (`npm install -g @anthropic-ai/claude-code`)

---

## 1. Core tools

```bash
brew install fish git gh lazygit rtk worktrunk yadm fzf zoxide bat eza ripgrep schpet/tap/linear
```

- **fish** — shell
- **lazygit** — git TUI (runs in the right pane)
- **[rtk](https://github.com/reachingforthejack/rtk)** — token optimizer for Claude Code
- **[worktrunk](https://github.com/max-sixty/worktrunk)** — git worktree manager with cmux integration
- **[linear](https://github.com/schpet/linear-cli)** — Linear CLI for ticket fetching (used by `wtn`)
- **yadm** — dotfile manager

Set fish as default shell:

```bash
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

---

## 2. cmux

Install from [cmux.dev](https://cmux.dev). Native macOS app, built on libghostty.

Verify: `cmux --version`

---

## 3. OpenClaw

Install from [openclaw.ai](https://openclaw.ai) — both the macOS app and the CLI.

```bash
openclaw onboard --install-daemon
```

The app runs as a LaunchAgent (boots on login, stays alive). The CLI handles onboarding, skill management, and gateway configuration. Skills directory: `~/.agents/skills/`.

---

## 4. Fish shell setup

Clone the [dotfiles repo](https://github.com/roderik/dotfiles-2026/tree/main) or grab the relevant files:

- [`config.fish`](https://github.com/roderik/dotfiles-2026/blob/main/.config/fish/config.fish) — abbreviations, PATH, worktrunk init, cmux shortcuts
- [`__wt_cmux_setup.fish`](https://github.com/roderik/dotfiles-2026/blob/main/.config/fish/functions/__wt_cmux_setup.fish) — auto-provisions the three-pane layout when entering a project
- [`__wt_cmux_rename.fish`](https://github.com/roderik/dotfiles-2026/blob/main/.config/fish/functions/__wt_cmux_rename.fish) — renames workspace tabs

Install fish plugins:

```bash
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
```

Save to `~/.config/fish/fish_plugins`:

```
jorgebucaran/fisher
ilancosman/tide@v6
jorgebucaran/autopair.fish
meaningful-ooo/sponge
nickeb96/puffer-fish
```

Then: `fish -c "fisher update"`

---

## 5. Claude Code plugins

```bash
claude plugin install context-mode@context-mode      # Context window virtualization
claude plugin install claude-hud@claude-hud          # Status line
claude plugin install plannotator@plannotator        # Plan annotation & code review UI
claude plugin install impeccable@impeccable          # Design fluency skills
claude plugin install worktrunk@worktrunk            # Worktree integration
claude plugin install telegram@claude-plugins-official  # Telegram notifications
```

RTK is installed via homebrew (step 1) and works transparently through Claude Code hooks.

---

## 6. Workflow skills

```bash
npx skills add roderik/roderik.github.io
```

This installs the full workflow skill set:

| Skill | What it does |
|-------|-------------|
| [`brainstorm`](https://github.com/roderik/roderik.github.io/tree/main/.agents/skills/brainstorm) | Idea → PRD → Linear project + tickets |
| [`execute`](https://github.com/roderik/roderik.github.io/tree/main/.agents/skills/execute) | Linear ticket → plan → build → verify → PR |
| [`shepherd`](https://github.com/roderik/roderik.github.io/tree/main/.agents/skills/shepherd) | PR babysitting until merge-ready |
| [`planner`](https://github.com/roderik/roderik.github.io/tree/main/.agents/skills/planner) | Research-first planning with 7 parallel reviewers |
| [`verifier`](https://github.com/roderik/roderik.github.io/tree/main/.agents/skills/verifier) | Completion checklists + full CI verification |
| [`agent-reviews`](https://github.com/pbakaus/agent-reviews) | PR review resolution (bot + human) — installed separately |
| [`prd-builder`](https://github.com/roderik/roderik.github.io/tree/main/.agents/skills/prd-builder) | PRD drafting through iterative brainstorm |
| [`task-builder`](https://github.com/roderik/roderik.github.io/tree/main/.agents/skills/task-builder) | PRD decomposition into tickets |
| [`tdd`](https://github.com/roderik/roderik.github.io/tree/main/.agents/skills/tdd) | Test-driven development enforcement |
| [`testing`](https://github.com/roderik/roderik.github.io/tree/main/.agents/skills/testing) | CI tier management (fast/checkpoint/full) |
| [`sweep`](https://github.com/roderik/roderik.github.io/tree/main/.agents/skills/sweep) | Code quality review |
| [`adversarial-review`](https://github.com/roderik/roderik.github.io/tree/main/.agents/skills/adversarial-review) | 7-lens review framework |

---

## 7. Verify

```bash
fish --version
cmux --version
claude --version
rtk --version
rtk gain
wt --version
launchctl list | grep openclaw
```

---

## Quick start

The fish wrapper functions ([in the dotfiles](https://github.com/roderik/dotfiles-2026/tree/main/.config/fish/functions)) handle worktree creation, cmux layout, and agent launch in one command:

```bash
# Start work on a Linear ticket — creates worktree, sets up cmux, launches Claude via ACP
wtn PRD-1234

# Create a plain worktree with a branch name
wtc my-feature

# Pick an open PR (fzf picker) and check it out as a worktree
wtg

# Done — remove worktree, clean up branch, close cmux workspace
wtr
```

Each command calls `__wt_cmux_setup` automatically: Claude/Codex in the main pane, lazygit on the right, terminal at the bottom. `wtn` goes further — it fetches the ticket from Linear, names the workspace after it, and launches Claude Code with `/execute` via ACP so you can follow along from Telegram.

---

*Companion to [My AI Dev Setup](/blog/remote-ai-development-stack). Last updated: 2026-03-22.*
