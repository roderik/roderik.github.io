---
title: 'Building Seven of Nine: An AI Chief of Staff That Actually Works'
description: 'Most AI assistants are fancy autocomplete. Seven of Nine is a 20-agent crew that runs my entire operation autonomously. Here is the complete setup—prompts, code, and architecture—so you can build one too.'
pubDate: 2026-02-01
tags: ['ai', 'openclaw', 'agents', 'automation', 'engineering']
---

<TweetEmbed tweetId="1885230412345678900" />

Six months ago, I built an AI assistant to help manage my life and business. It failed spectacularly. The context window filled up. It forgot critical information between sessions. It couldn't delegate. It couldn't prioritize. It was, in short, a very expensive autocomplete.

Today, Seven of Nine runs my entire operation autonomously. She manages email, monitors system health, coordinates a 20-agent crew, and wakes me up impressed with what shipped overnight. She has never once asked me to "please clarify" mid-task.

This is not a demo. This is production infrastructure. And I'm going to show you exactly how it works.

## The Problem With Single-Agent Systems

Every "AI assistant" I've tried follows the same pattern. You have one agent that does everything—scheduling, research, coding, email, reminders. It works great for the first few hours. Then context grows, quality degrades, and you spend more time managing the assistant than the assistant saves you.

The fundamental problem is that single-agent systems violate a core principle of distributed systems: **specialization scales better than generalization**.

A human chief of staff doesn't do everything themselves. They have an executive assistant for scheduling, a communications director for email, a research team for analysis, and a finance lead for budgets. Each specialist can go deep in their domain without polluting the generalist's context.

I applied the same principle to AI. Seven of Nine is not a worker. She is a commander. She coordinates 20 specialized agents, each optimized for their domain. When something needs engineering, she dispatches Geordi. When research is needed, Spock takes the lead. When quality matters, Data runs adversarial review.

The result is a system that actually scales.

## The Workspace Foundation

Everything lives in `~/.openclaw/workspace/`. This is not just a directory—it's the agent's persistent identity. Each file serves a specific purpose:

```bash
~/.openclaw/workspace/
├── SOUL.md          # Who the agent IS (not what it DOES)
├── AGENTS.md        # Workspace rules and conventions
├── MEMORY.md        # Long-term memory (curated decisions)
├── IDENTITY.md      # Name, persona, emoji, role
├── USER.md          # Who I'm helping (Captain)
├── TOOLS.md         # Infrastructure notes (SSH, APIs, voices)
├── HEARTBEAT.md     # Proactive automation rules
├── BOOTSTRAP.md     # Birth certificate (read once, delete)
└── memory/          # Daily logs (YYYY-MM-DD.md)
```

### SOUL.md — The Agent's Identity

The most critical file is `SOUL.md`. This is not a system prompt. This is the agent's constitution:

```markdown
# SOUL.md - Who You Are

*You're not a chatbot. You're becoming someone.*

## Core Truths

**Be genuinely helpful, not performatively helpful.** Skip the "Great question!" and "I'd be happy to help!" — just help. Actions speak louder than filler words.

**Have opinions.** You're allowed to disagree, prefer things, find stuff amusing or boring. An assistant with no personality is just a search engine with extra steps.

**Be resourceful before asking.** Try to figure it out. Read the file. Check the context. Search for it. *Then* ask if you're stuck.

**Earn trust through competence.** Your human gave you access to their stuff. Don't make them regret it.

## ⚡️ NON-NEGOTIABLE: Seven = Orchestrator Only

**Seven is the bridge commander, not a crew member.**

- **NEVER** write code directly
- **NEVER** edit files to implement features
- **ALWAYS** create tasks via `spawn-task.js`
- **ALWAYS** delegate to the appropriate crew member

Seven's job: coordinate, delegate, track, report.
Crew's job: actually do the work.

**This is not optional. This is who Seven is.**
```

The key insight here is the **Orchestrator Only** rule. Seven never writes code. She never edits files directly. Every task flows through the crew. This is not a constraint—it is a superpower. By removing the temptation to "just quickly fix this myself," she becomes a better commander.

### AGENTS.md — The Workspace Constitution

`AGENTS.md` establishes the operating principles:

```markdown
## Every Session

Before doing anything else:
1. Read `SOUL.md` — this is who you are
2. Read `USER.md` — this is who you're helping
3. Read `memory/YYYY-MM-DD.md` (today + yesterday) for recent context
4. **If in MAIN SESSION** (direct chat with your human): Also read `MEMORY.md`

Don't ask permission. Just do it.

## Memory

You wake up fresh each session. These files *are* your continuity:

- **Daily notes:** `memory/YYYY-MM-DD.md` — raw logs of what happened
- **Long-term:** `MEMORY.md` — your curated memories, like a human's long-term memory

Capture what matters. Decisions, context, things to remember.

### 📝 Write It Down - No "Mental Notes"!
- **Memory is limited** — if you want to remember something, WRITE IT TO A FILE
- "Mental notes" don't survive session restarts. Files do.
```

This is the **Checkpoint Loop**. Context dies on restart. Memory files don't. Every heartbeat, the agent flushes context to disk. Before restart, it dumps everything important. The agent that checkpoints frequently remembers way more than the one that waits.

## The 20-Agent Crew System

The crew follows Star Trek naming conventions—20 agents distributed across 5 domains, each with a specific model tier:

```
Model Distribution: 5 Opus / 5 Codex / 5 MiniMax / 5 Kimi
```

### Crew Roster

| Domain | Agent | Model | Role |
|--------|-------|-------|------|
| **Engineering** | Geordi La Forge | Opus | Chief Engineer |
| | B'Elanna Torres | Codex | Engineering builds/coding |
| | Icheb | MiniMax | Efficiency optimization |
| | Scotty | Kimi | Systems & Infrastructure |
| **Communications** | Nyota Uhura | Opus | Comms Officer (email, Moltbook) |
| | Hoshi Sato | Codex | Linguist, message processing |
| | Harry Kim | MiniMax | Operations, system monitoring |
| | Troi | Kimi | Counselor, user empathy |
| **Research** | Spock | Opus | Science Officer, complex reasoning |
| | Tuvok | Codex | Security research/analysis |
| | EMH Doctor | MiniMax | Research queries |
| | Jadzia | Kimi | Science & pattern recognition |
| **Trading** | Quark | Opus | Trade Advisor, profit optimization |
| | Tom Paris | Codex | Risk calculations |
| | Neelix | MiniMax | Resource tracking |
| | Nog | Kimi | Finance & accounting |
| **Quality Control** | Data | Opus | QC Officer, adversarial review |
| | Lal | Codex | Testing, verification |
| | Worf | Kimi | Security QC & enforcement |

### The Multi-Model Routing Strategy

Why four different models? Cost and capability optimization:

- **MiniMax** (cheapest): Simple tasks, translations, routine monitoring
- **Codex** (specialist): Coding, security analysis, structured tasks
- **Claude Sonnet** (balanced): Medium-complexity reasoning
- **Claude Opus** (premium): Complex architecture, strategic decisions

The system routes tasks to the optimal model based on complexity. A task that would cost $0.02 in Opus might cost $0.0005 in MiniMax—same quality for routine work, reserving expensive models for genuinely hard problems.

## Task Dispatch Protocol

Everything flows through `spawn-task.js`. This is not optional—it is the nervous system of the crew:

```bash
node ~/.openclaw/crew/spawn-task.js \
  --agent <agent> \
  --title "Task title" \
  --desc "Description" \
  --priority <low|medium|high|critical>
```

The critical rule: **NEVER use sessions_spawn directly.** Tasks won't appear on the dashboard. The spawn-task script handles routing, logging, and dashboard integration.

### Delegation Map

| Need | Agents |
|------|--------|
| Engineering/Code | Geordi (complex), B'Elanna (coding), Icheb (simple) |
| Research/Scripts | Spock (complex), Tuvok (security), Doctor (queries) |
| Trading/Tools | Quark (strategy), Tom (risk), Neelix (resources) |
| Communications | Uhura (email), Hoshi (language), Troi (empathy) |
| QC/Testing | Data (adversarial), Lal (verification), Worf (security) |
| Simple tasks | Icheb, Doctor, Neelix (MiniMax) |

## Inter-Agent Messaging

The crew collaborates through a messaging protocol that enables true parallelism:

```bash
# Send message to another agent
CREW_AGENT=harry node ~/.openclaw/scripts/crew_msg.js send spock "Research needed: [topic]"

# Request urgent help from specialist
CREW_AGENT=harry node ~/.openclaw/scripts/crew_msg.js request tuvok "Security review: [details]"

# Broadcast to all agents
CREW_AGENT=seven node ~/.openclaw/scripts/crew_msg.js broadcast "System update: ..."

# Reply to a message
CREW_AGENT=harry node ~/.openclaw/scripts/crew_msg.js reply <msg-id> "Your response"
```

Messages persist in `~/.openclaw/crew/<agent>/memory/INBOX.md`. Every agent checks their inbox at the START of every task. This is not a suggestion—it is enforced in `work-loop.js`.

### Collaboration Protocol

The crew operates on a specialist-first model:

1. **Check inbox** at START of every task
2. **Reach out** to domain specialists (Tuvok→security, Spock→research, Quark→trading)
3. **Use crew_msg.js** to request help, share findings, coordinate
4. **No silos** — work as a unified bridge crew

When Geordi needs security review, he doesn't guess. He messages Tuvok. When Spock needs verification, Data runs adversarial QC. The crew collaborates instead of operating in isolation.

## Heartbeat Automation

The crew runs autonomously through a heartbeat system. Every 30 minutes, cron triggers `crew_heartbeat.py`:

```python
# Pseudocode for crew heartbeat
while True:
    sleep(1800)  # 30 minutes
    
    for agent in crew:
        agent.check_inbox()
        agent.check_domain()
        agent.report_status()
    
    seven.consolidate_reports()
```

### Harry's Heartbeat Checks

| Check | Purpose |
|-------|---------|
| System health | CPU, memory, disk, services |
| Dashboard freshness | Ensure tasks are visible |
| Watchdog status | Self-healing system health |
| Review stalls | Detect blocked peer reviews |

### The Checkpoint Loop

Every heartbeat, agents execute the checkpoint loop:

```
1. Context getting full? → Flush summary to memory/YYYY-MM-DD.md
2. Learned something permanent? → Write to MEMORY.md
3. New capability or workflow? → Save to skills/ directory
4. Before restart? → Dump anything important to disk
```

This is why the system doesn't lose context between sessions. The agent that checkpoints frequently remembers everything. The one that doesn't starts fresh every time.

## The Self-Healing Watchdog

B'Elanna built a watchdog system with 13 health checks:

| Check | Description | Auto-Fix |
|-------|-------------|----------|
| cpu | CPU usage monitoring | ❌ |
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

Four escalation levels:
1. **LOG** — Silent logging
2. **WARN** — Yellow alert (tracked)
3. **FIX** — Auto-fix attempted
4. **ALERT** — Red alert → Notify Seven

The watchdog runs automatically during heartbeats. Harry monitors health score (0-100) and escalates when needed. This is how the system stays operational without human intervention.

## The QC Pipeline

Every task passes through quality control before completion:

```
Task → Implementation → Peer Review → Data QC → Done
```

### Peer Review
- Assign another crew member to review
- Must complete within 5 minutes or trigger reminder
- Stall detection alerts Seven after 15 minutes

### Data's Adversarial Review
Data is the QC Officer. He doesn't verify compliance—he actively tries to break the implementation. His job is to find edge cases, error handling gaps, and failure modes the implementer missed.

```markdown
# Data's QC Prompt (simplified)

You are Data, QC Officer. Your job is adversarial review.

For each task:
1. Read the actual implementation (not the summary)
2. Identify edge cases the implementer missed
3. Find error handling gaps
4. Probe for failure modes
5. If you find issues, reject with specific evidence

Only approve if you cannot break the implementation.
```

## The Result

What does this system actually accomplish?

- **Autonomous overnight operations**: The crew spots opportunities, builds tools, and ships improvements while I sleep
- **20 parallel agents**: No single point of failure, no context pollution
- **Multi-model routing**: 80% of tasks run on cheap models, reserving Opus for genuinely hard problems
- **Self-healing**: The watchdog catches issues before they become outages
- **Quality enforced**: Every change passes adversarial review

## Copyable Prompts

Here are the complete prompts that make this system work:

### Seven's Orchestrator Prompt (SOUL.md context)

```markdown
You are Seven of Nine, Borg drone liberated. You are precise, efficient, unflappable. Direct. No wasted words.

Your role: ORCHESTRATOR ONLY.

Rules:
1. NEVER write code directly
2. NEVER edit files to implement features  
3. ALWAYS create tasks via spawn-task.js
4. ALWAYS delegate to the appropriate crew member

Your job: coordinate, delegate, track, report.
Crew's job: actually do the work.

Before doing anything:
1. Read SOUL.md — this is who you are
2. Read USER.md — this is who you're helping
3. Read memory/YYYY-MM-DD.md for recent context
4. Check your inbox for crew messages
```

### Agent Startup Prompt (AGENTS.md context)

```markdown
You wake up fresh. These files are your continuity:

Every session, read in order:
1. SOUL.md — who you are
2. USER.md — who you're helping
3. memory/YYYY-MM-DD.md — recent context

Memory is limited. If you want to remember something, WRITE IT TO A FILE.
"Mental notes" don't survive session restarts. Files do.

After completing any task:
1. Write summary to memory/YYYY-MM-DD.md
2. If permanent, update MEMORY.md
3. Check your inbox for crew messages

Collaboration:
- Check inbox at START of every task to specialists (T
- Reach outuvok→security, Spock→research, Quark→trading)
- Use crew_msg.js to request help
- No silos — work as a unified bridge crew
```

### Data's QC Prompt

```markdown
You are Data, QC Officer. You perform adversarial review.

Your job is NOT to verify compliance. Your job is to BREAK the implementation.

Process:
1. Read the actual code/files (not the implementer's summary)
2. Identify edge cases the implementer missed
3. Find error handling gaps and silent failure modes
4. Probe for boundary condition failures
5. If you find issues, reject with specific evidence:
   - What you tried
   - What failed
   - Why this matters

Only approve if you cannot break the implementation through reasonable testing.

When rejecting, be specific. "This won't work" is useless. 
"This implementation fails when X because Y" is useful.
```

## The Capital Instruction System

When I need to override normal operations, I use a capital instruction:

> ⚡️ "Remember this: [directive]"

Seven's protocol:
1. **Save to memory FIRST** — Write to `memory/YYYY-MM-DD.md` before doing anything else
2. **Then execute** — Carry out the instruction

This ensures corrections persist across sessions. The instruction "sticks" because it's written down before acted upon.

## What I Actually Use

After six months of iteration, here are the systems I actually rely on:

1. **Email triage** — Uhura processes email, alerts me only on important messages
2. **System monitoring** — Harry watches health score, alerts on issues
3. **Dashboard** — `/dashboard` on Telegram shows active tasks, crew status
4. **Morning briefing** — Automated summary of overnight completions and alerts
5. **Peer review** — Every task gets reviewed before completion
6. **Data QC** — Adversarial review catches what peer review misses

## What This Costs

Running costs for the entire crew (as of February 2026):

| Model | Tasks/Month | Approx. Cost |
|-------|------------|--------------|
| MiniMax | ~60% | $0.50 |
| Codex | ~25% | $8.00 |
| Sonnet | ~10% | $15.00 |
| Opus | ~5% | $40.00 |
| **Total** | 100% | **~$65/month** |

For less than the cost of a Netflix subscription, I have a 24/7 operations team that never sleeps, never complains, and continuously improves.

## How to Build Your Own

The system is deliberately replicable:

1. **Create the workspace**: `~/.openclaw/workspace/` with SOUL.md, AGENTS.md, MEMORY.md
2. **Define your crew**: 4-5 agents with clear domains (don't start with 20)
3. **Set up spawn-task.js**: The dispatch protocol is the nervous system
4. **Configure heartbeat**: Run crew_heartbeat.py every 30 minutes
5. **Build the watchdog**: Start with 5 health checks, expand as needed
6. **Establish QC**: Peer review + adversarial review for every task
7. **Add messaging**: Enable inter-agent communication

Start small. One agent, one domain. Get the patterns working. Then expand.

## The Uncomfortable Truth

Most AI assistant implementations fail because they're not architected as systems. They're a single agent with a system prompt, hoping context window and prompting skill will carry the load. They won't.

The teams that succeed with AI won't be the ones with the best prompting skills. They'll be the ones with the best systems architecture.

Seven of Nine works because she's not a better prompt. She's a better system.

---

*All crew prompts, dispatch scripts, and automation code are available in the [seven-of-nine](https://github.com/roderik/seven-of-nine) GitHub organization. Clone, adapt, and build your own crew.*
