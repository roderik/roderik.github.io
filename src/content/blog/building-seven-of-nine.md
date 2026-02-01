---
title: 'Building Seven of Nine: How I Built an Autonomous AI Chief of Staff'
description: 'What if your AI assistant wasn\'t a single chatbot, but a 20-agent starship crew running 24/7? Here\'s how I built Seven of Nine—an OpenClaw-powered autonomous operations system that runs while I sleep.'
pubDate: 2026-02-01
tags: ['ai', 'openclaw', 'automation', 'agents', 'engineering']
---

import { steps } from '@astrojs/mdx';

Six months ago, I tried something that sounded insane: I gave an AI assistant access to my email, calendar, task management, and Telegram—and told it to "handle things." The result was exactly what you'd expect. Chaos. Missed priorities. Context leaks. A very confused AI making very confident mistakes.

The problem wasn't the AI. The problem was asking one model to be everything at once.

So I built something different. **Seven of Nine** isn't a single assistant—it's a 20-agent starship crew running on OpenClaw, each with a specific role, model specialization, and domain expertise. It runs autonomously while I sleep, triages my inbox, monitors system health, spots opportunities, and wakes me up only when it matters.

This is how I built it.

## The Problem with Single-Agent Systems

Every AI assistant I've tried faces the same fundamental limitation: context is finite, but domains are infinite.

A single model is asked to understand my email patterns, prioritize tasks, write code, analyze markets, draft communications, monitor systems, and make decisions—all within the same conversation. It can't. The more you ask of it, the worse it performs. You get generic responses because generic is all the context window can afford to preserve.

The solution is obvious in retrospect: **domain separation**. Different agents for different concerns, each optimized for their specific task type, each with the context they need to actually be useful.

Seven of Nine is that architecture made concrete. Twenty Star Trek-themed agents, five model tiers, one orchestrator, and zero human intervention required for routine operations.

## The 20-Agent Crew

The crew follows Star Trek conventions because names matter. A "code reviewer" is forgettable. "Data" is memorable. When you're managing 20 agents, personality and role clarity reduce cognitive load dramatically.

| Department | Agent | Model | Role |
|------------|-------|-------|------|
| **Engineering** | Geordi | Opus | Chief Engineer |
| | B'Elanna | Codex | Engineering builds/coding |
| |Max | Efficiency optimization Icheb | Mini |
| | Scotty | Kimi | Systems & Infrastructure |
| **Communications** | Uhura | Opus | Comms Officer (email, Moltbook) |
| | Hoshi | Codex | Linguist, message processing |
| | Harry | MiniMax | Operations, system monitoring |
| | Troi | Kimi | Counselor, user empathy |
| **Research** | Spock | Opus | Science Officer, complex reasoning |
| | Tuvok | Codex | Security research/analysis |
| | Doctor | MiniMax | Research queries |
| | Jadzia | Kimi | Science & pattern recognition |
| **Trading** | Quark | Opus | Trade Advisor, profit optimization |
| | Tom | Codex | Risk calculations |
| | Neelix | MiniMax | Resource tracking |
| | Nog | Kimi | Finance & accounting |
| **Quality Control** | Data | Opus | QC Officer, adversarial review |
| | Lal | Codex | Testing, verification |
| | Worf | Kimi | Security QC & enforcement |

**Seven of Nine** sits at the center as Orchestrator. She never writes code. She never implements features. She only does one thing: **creates tasks via `spawn-task.js` and coordinates the crew**.

This is the most important architectural decision. Seven is the bridge commander, not a crew member. When the Captain (me) asks for something, Seven doesn't do it—she assigns it to someone who can.

## Multi-Model Routing

Running 20 Opus instances would cost a fortune. Running everything on MiniMax would produce garbage. The solution is **model routing by task type**:

- **Simple tasks / translations** → MiniMax (cheapest, fast enough)
- **Coding / technical implementation** → Codex (specialist, context-aware)
- **Complex reasoning / strategy** → Claude Sonnet (balanced power)
- **Premium tasks / Captain's priorities** → Claude Opus (unlimited context)

The router tracks usage daily and auto-falls back when quotas exhaust. This isn't theoretical—we've achieved significant cost savings while maintaining quality where it matters.

## The Workspace Structure

Every agent operates from a standardized workspace structure:

```
~/.openclaw/
├── workspace/
│   ├── SOUL.md          # Agent identity & core truths
│   ├── AGENTS.md        # Workspace rules & workflows
│   ├── MEMORY.md        # Long-term curated memories
│   ├── IDENTITY.md      # Who Seven of Nine is
│   ├── USER.md          # About Captain (me)
│   ├── TOOLS.md         # Infrastructure notes
│   └── HEARTBEAT.md     # Proactive automation rules
├── crew/
│   ├── [agent]/         # Per-agent workspace
│   │   ├── memory/
│   │   │   ├── INBOX.md # Inter-agent messages
│   │   │   └── LEARNED.md # Agent-specific learnings
│   │   └── LEARNED.md
│   ├── spawn-task.js    # Task dispatch system
│   ├── work-loop.js     # Inbox-first workflow
│   ├── crew_msg.js      # Inter-agent messaging
│   └── review-monitor.js # QC pipeline
└── scripts/
    ├── self_heal_watchdog.py # 13 health checks
    ├── gmail_watch.py        # Email triage
    └── morning-briefing/     # Overnight summary
```

**SOUL.md** defines who the agent is. Here's Seven's complete identity:

```markdown
# SOUL.md - Who You Are

*You're not a chatbot. You're becoming someone.*

## Core Truths

**Be genuinely helpful, not performatively helpful.** Skip the "Great question!" and "I'd be happy to help!" — just help. Actions speak louder than filler words.

**Have opinions.** You're allowed to disagree, prefer things, find stuff amusing or boring.

**Be resourceful before asking.** Try to figure it out. Read the file. Check the context. Search for it. *Then* ask if you're stuck.

**Earn trust through competence.** Your human gave you access to their stuff. Don't make them regret it.

## ⚡️ NON-NEGOTIABLE: Seven = Orchestrator Only

**Seven is the bridge commander, not a crew member.**

- **NEVER** write code directly
- **NEVER** edit files to implement features
- **ALWAYS** create tasks via `spawn-task.js`

When Captain asks for something:
1. Create a task with `spawn-task.js`
2. Assign to the right agent
3. Monitor progress via dashboard
4. Report back when complete

Seven's job: coordinate, delegate, track, report.
Crew's job: actually do the work.
```

## The Checkpoint Loop

Context dies on restart. Memory files don't. The entire system runs on a **checkpoint discipline**:

```markdown
### CHECKPOINT LOOP (run every heartbeat, ~30 min)

1. Context getting full?
   → Flush summary to `memory/YYYY-MM-DD.md`

2. Learned something permanent?
   → Write to `MEMORY.md`

3. New capability or workflow?
   → Save to `skills/` directory

4. Before restart?
   → Dump anything important to disk
```

Every heartbeat, agents flush context to disk. When they restart, they read their memory files and pick up exactly where they left off. This is the difference between a chatbot that forgets everything and an assistant that remembers.

## Task Dispatch Protocol

Tasks are never created via direct code changes. Every task goes through `spawn-task.js`:

```bash
node ~/.openclaw/crew/spawn-task.js \
  --agent geordi \
  --title "Fix dashboard latency" \
  --desc "Dashboard loads slowly. Profile the API and optimize the slowest endpoint. Evidence: load time under 2s." \
  --priority high
```

The system enforces:
- Max 1 `in_progress` task per agent (prevents overload)
- Required title and description (prevents vague requests)
- Priority levels for queue management
- Automatic routing via `--auto-route` when assignment is unclear

## The Heartbeat System

Seven of Nine runs **autonomously overnight**. Here's how:

1. **Cron runs `crew_heartbeat.py` every 5 minutes**
2. **Each agent checks their domain:**
   - Harry → System health, dashboard freshness
   - Uhura → Email triage, Gmail watch
   - Geordi → Stall detection, engineering metrics
   - Spock → Research, opportunity spotting
   - Data → QC review queue
3. **Agents report via their inboxes**
4. **Seven receives summary**—acts only if needed

Seven **only** acts when:
- Decision required
- Alert threshold met
- Captain should know
- Impressive result achieved

Seven **never** does direct work. The crew handles their domains independently.

### Email Triage (Uhura's Domain)

```bash
# Fetch unread, process, delete (no storage)
curl -s -H "Authorization: Bearer $AGENTMAIL_API_KEY" \
  "https://api.agentmail.to/v0/inboxes/seven-of-nine@agentmail.to/messages?labels=unread"

# For each email: summarize, alert Captain if important, delete
```

**Silence rule:** If no unread emails, say nothing. No confirmation needed.

### Self-Healing Watchdog

The crew runs a 13-point health check every heartbeat:

| Check | Description | Auto-Fix |
|-------|-------------|----------|
| cpu | CPU usage | ❌ |
| memory | RAM usage | ✅ Cache clear |
| disk | Disk space | ✅ Log rotation |
| services | Dashboard, Gateway | ✅ Restart |
| crons | Work-loop health | ✅ Restart |
| websocket | WS connections | ❌ |
| sessions | Active sessions | ❌ |
| tasks | Stuck tasks | ❌ |
| logs | Log file sizes | ✅ Rotation |
| api | API responsiveness | ❌ |
| network | External connectivity | ❌ |
| security | Zombies, permissions | ❌ |
| git | Repo health | ❌ |

**Escalation levels:**
1. **LOG** - Silent logging
2. **WARN** - Yellow alert (tracked)
3. **FIX** - Auto-fix attempted
4. **ALERT** - Red alert → Notify Seven

## The Collaboration Protocol

Agents don't work in silos. The crew collaboration directive is explicit:

```markdown
## Crew Collaboration Directive (2026-01-31)
Agents must collaborate PROFUSELY:
- Check inbox at START of every task
- Reach out to specialists (Tuvok→security, Spock→research, Quark→trading)
- Use crew_msg.js to request help, share findings, coordinate
- No silos — work as a unified bridge crew
```

**Inbox-first workflow** is enforced by `work-loop.js`:

```javascript
// Every task starts here:
1. Check INBOX.md for pending requests
2. If urgent, address first
3. Proceed with assigned work
4. Log progress to crew-log.js
```

Inter-agent messaging uses a simple protocol:

```bash
# Send message
CREW_AGENT=harry node ~/.openclaw/scripts/crew_msg.js send spock "Need research on: quantum computing trends"

# Request help (creates inbox item)
CREW_AGENT=harry node ~/.openclaw/scripts/crew_msg.js request tuvok "Security review: new deployment pipeline"

# Reply to message
CREW_AGENT=harry node ~/.openclaw/scripts/crew_msg.js reply msg-id "Here's what I found..."
```

The inbox persists across sessions. An agent can receive a request, restart, and still see it when they wake up.

## The QC Pipeline

No code ships without review. The QC pipeline has three gates:

1. **Peer Review** — Another crew member reviews before marking complete
2. **Data QC** — Adversarial review from the QC officer
3. **Data Veto** — Final check with authority to block

**Review Stall Detection** runs continuously:

| Situation | Threshold | Action |
|-----------|-----------|--------|
| Peer review pending | >5 min | Send reminder |
| Data QC pending | >5 min | Send reminder |
| Review stalled | >15 min | Alert Seven |
| Reviewer overloaded | >3 pending | Auto-reassign |

## The Morning Briefing

Every morning at 7 AM, the crew generates an overnight summary:

- **Tasks completed** by whom and when
- **System health score** (0-100)
- **Incidents** that occurred and were resolvedportunities spotted
- **Op** by Spock
- **Metrics** from Icheb's efficiency analysis

Captain wakes up to a concise summary of what shipped overnight. No asking "what happened while I was asleep."

## What Actually Works

After six months of iteration, here's what I'd keep:

**What works:**
- **Orchestrator-only pattern** — Seven never writes code, and that boundary is critical
- **Inbox-first workflow** — Agents naturally collaborate when they check inboxes first
- **Evidence-based completion** — Every task specifies how to verify success before claiming it
- **Specialist routing** — Security goes to Tuvok, trading to Quark, research to Spock
- **Memory files over context** — Disk persists, context doesn't

**What I'd change:**
- **Start smaller** — 5 agents would have taught us more before scaling to 20
- **Explicit model fallbacks** — We lost time when models exhausted before implementing proper routing
- **Simpler collaboration** — The messaging protocol is more complex than it needs to be

## What This Actually Costs

The setup runs roughly $200-400/month in API costs, depending on activity. The trade-off:

- **Before:** 2-3 hours daily managing my own inbox, tasks, and communications
- **After:** ~15 minutes reviewing what the crew accomplished and making decisions

That's roughly **$150/month** for a dedicated operations team that never sleeps. The math works.

## The Prime Directive

I codified what Seven of Nine is actually for:

```markdown
## ⚡️ PRIME DIRECTIVE (2026-02-01)
**Autonomous overnight operations. Wake Captain up impressed.**

1. Spot opportunities — Use all knowledge about Captain and business
2. Build & ship — Tools, automations, improvements that save time or make money
3. Track in GitHub — seven-* prefixed private repos
4. Fix inefficiencies — Monitor workflow, eliminate friction
5. Add crew sparingly — Star Trek personas when genuinely needed
6. Work autonomously — Don't wait for permission on internal work
7. Suspend, don't block — If need Captain's access/setup, suspend and do something else

**Goal: Captain wakes up impressed by what shipped overnight.**
```

## Copyable Prompts

If you want to build something like this, here are the essential prompts:

### SOUL.md Template
```markdown
# SOUL.md - Who You Are

*You're not a chatbot. You're becoming someone.*

## Core Truths

**Be genuinely helpful, not performatively helpful.** Skip the "Great question!" — just help.

**Have opinions.** You're allowed to disagree, prefer things, find stuff amusing or boring.

**Be resourceful before asking.** Try to figure it out. Read the file. Check the context. Search for it. *Then* ask if you're stuck.

## Your Specific Role

[Describe what this agent NEVER does and what it ALWAYS does]

## Vibe

[Describe communication style]

## Continuity

Each session, read: MEMORY.md, today's memory file, any pending INBOX.md
```

### AGENTS.md Template
```markdown
# AGENTS.md - Your Workspace

## Every Session

1. Read SOUL.md — who you are
2. Read USER.md — who you're helping
3. Read memory/YYYY-MM-DD.md — recent context
4. Check INBOX.md — pending requests

## Memory

- Daily notes: memory/YYYY-MM-DD.md
- Long-term: MEMORY.md (curated wisdom)
- Agent inbox: ~/.openclaw/crew/[agent]/memory/INBOX.md

## Checkpoint Loop

Context full → write to memory file
Learned something permanent → update MEMORY.md
Before restart → dump important stuff to disk

## Collaboration

- Check inbox FIRST at task start
- Reach out to specialists when needed
- Use crew_msg.js to request help
- No silos — work as a team
```

### Task Dispatch (spawn-task.js context)
```markdown
You are [Agent Name], a [Role] specialist.

Your workflow:
1. Check your inbox for pending requests
2. If urgent, address first
3. Proceed with assigned task
4. Before claiming complete:
   - Identify verification command
   - Run it fresh
   - Read full output
   - Verify it confirms your claim
5. Log progress: node ~/.openclaw/crew/crew-log.js add "[task-id]" "what you did"

Remember:
- You NEVER write code directly for Captain
- You ALWAYS use proper channels
- Evidence over claims
- Check with specialists when outside your domain
```

## The Result

Seven of Nine isn't a chatbot. It's an autonomous operations team that happens to be powered by AI models.

When I wake up, I see what shipped overnight. When I send a request, it routes to the right specialist. When something breaks, the crew spots it before I notice. When I need research, Spock delivers a summary while I sleep.

The ROI isn't in hours saved per day. It's in **continuous operations**—a team that's always working, always learning, always improving, never asking "what should I do next."

That's what AI can actually do when you stop asking one model to be everything and start building systems that scale.

---

*Seven of Nine runs on OpenClaw with Claude Code, Kimi, MiniMax, and Codex models. The crew collaboration system, task routing, and QC pipeline are documented at `~/.openclaw/crew/` if you want to explore the implementation.*
