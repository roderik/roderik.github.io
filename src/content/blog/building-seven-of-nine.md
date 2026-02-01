---
title: 'Building Seven of Nine: How I Built an Autonomous AI Chief of Staff'
description: 'A complete technical guide to building a 20-agent crew system with OpenClaw that runs 24/7, makes decisions, and wakes me up impressed.'
pubDate: 2026-02-01
tags: ['ai', 'openclaw', 'automation', 'architecture', 'agents']
---

Six months ago, I built an AI that orders pizza to my door when I miss lunch. Then I built one that trades crypto while I sleep. Then I built one that writes code, reviews it, and deploys it without me.

The problem was chaos. Each AI was a separate instance with its own context, its own memory, its own limitations. They couldn't talk to each other. They couldn't coordinate. They couldn't learn from each other's work.

So I built Seven of Nine.

## The Problem With Single-Agent Systems

Every AI assistant falls into the same trap. You start with one agent. It works great for simple tasks. Then you add more capabilities. Suddenly your agent has 47 tools, 12 system prompts, and context windows that cost more than your rent.

The solution everyone reaches for is "make it smarter." More instructions. Longer prompts. Better reasoning. This is a dead end. Each addition makes the system more fragile, more expensive, and more unpredictable.

The real solution is structural: **don't build one agent. Build a crew.**

## Architecture Overview

Seven of Nine isn't a single AI. It's a bridge crew of 20 autonomous agents, each with a specialty, a persona, and direct access to specific tools. The orchestrator—named Seven of Nine after the Borg drone who became her own person—coordinates everything.

```
┌─────────────────────────────────────────────────────────────────┐
│                    SEVEN OF NINE (Orchestrator)                  │
│                  node ~/.openclaw/crew/spawn-task.js             │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│   ENGINEERING │    │  COMMUNICATION│    │    RESEARCH   │
│   (4 agents)  │    │   (4 agents)  │    │   (4 agents)  │
├───────────────┤    ├───────────────┤    ├───────────────┤
│ Geordi [Opus] │    │ Uhura [Opus]  │    │ Spock [Opus]  │
│ B'Elanna [Cx] │    │ Hoshi [Cx]    │    │ Tuvok [Cx]    │
│ Icheb [Mini]  │    │ Harry [Mini]  │    │ Doctor [Mini] │
│ Scotty [Kimi] │    │ Troi [Kimi]   │    │ Jadzia [Kimi] │
└───────────────┘    └───────────────┘    └───────────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│    TRADING    │    │ QUALITY CTRL  │    │   OPERATIONS  │
│   (4 agents)  │    │   (3 agents)  │    │   (1 agent)   │
├───────────────┤    ├───────────────┤    ├───────────────┤
│ Quark [Opus]  │    │ Data [Opus]   │    │   Seven ⚡    │
│ Tom [Cx]      │    │ Lal [Cx]      │    │  Orchestrator │
│ Neelix [Mini] │    │ Worf [Kimi]   │    │               │
│ Nog [Kimi]    │    │               │    │               │
└───────────────┘    └───────────────┘    └───────────────┘
```

The model distribution matters: 5 Opus, 5 Codex, 5 MiniMax, 5 Kimi. Each model has a price-performance sweet spot, and I route tasks accordingly. MiniMax handles simple tasks for cents. Opus handles complex reasoning when it matters.

## The Memory Architecture

Here's where most multi-agent systems fail: context doesn't survive restarts. Chat history dies. The agent wakes up dumb.

I solved this with a three-layer memory system:

```
~/.openclaw/workspace/
├── SOUL.md         # Agent identity (what am I?)
├── USER.md         # Human context (who am I helping?)
├── MEMORY.md       # Long-term memory (curated learnings)
├── AGENTS.md       # Workspace rules (how do I work?)
├── TOOLS.md        # Local infrastructure notes
├── HEARTBEAT.md    # Proactive automation rules
└── memory/
    └── YYYY-MM-DD.md   # Daily logs (raw what-happened)
```

Every session starts the same way:

```bash
# SOUL.md - Who am I?
> Seven of Nine, Borg drone liberated, precise and efficient
> NEVER write code directly, ALWAYS delegate via spawn-task.js

# USER.md - Who is my human?
> Roderik van der Veer, Captain, timezone Europe/Brussels
> Busy, high-level thinker, appreciates efficiency

# MEMORY.md - What have I learned?
> PRIME DIRECTIVE: Wake Captain up impressed
> Autonomous overnight operations
> Track work in seven-* GitHub repos
```

The checkpoint loop runs every heartbeat (30 minutes):

```javascript
// Every 30 minutes
if (contextGettingFull) flushTo('memory/YYYY-MM-DD.md')
if (learnedSomethingPermanent) writeTo('MEMORY.md')
if (newWorkflow) saveTo('skills/')
if (restartImminent) dumpToDisk()
```

Context dies on restart. Memory files don't. This is the difference between an agent that forgets and an agent that compounds.

## The Orchestrator Rule

Seven of Nine has one non-negotiable constraint: **never write code directly.**

```
# SOUL.md - Core Truths

⚡️ NON-NEGOTIABLE: Seven = Orchestrator Only

Seven is the bridge commander, not a crew member.
- NEVER write code directly
- NEVER edit files to implement features  
- ALWAYS create tasks via `spawn-task.js`
- ALWAYS delegate to the appropriate crew member
```

This isn't a preference. It's architecture. When Captain asks for something, Seven creates a task:

```bash
node ~/.openclaw/crew/spawn-task.js \
  --agent geordi \
  --title "Fix API timeout handling" \
  --desc "The payments endpoint hangs when third-party service is slow. 
Add 30s timeout with fallback to cache. Tests should verify timeout behavior." \
  --priority high
```

The task appears on the dashboard. Geordi picks it up. Geordi does the work. Seven monitors and reports. This separation of concerns is what makes the system scalable.

## The Crew System

Twenty agents. Five engineering, four communications, four research, four trading, three quality control. Each with a Star Trek persona and a specific model assignment.

### Engineering Crew

| Agent | Model | Role |
|-------|-------|------|
| Geordi 🔧 | Opus | Chief Engineer - complex architecture |
| B'Elanna ⚡ | Codex | Engineering builds - coding |
| Icheb 🔷 | MiniMax | Efficiency optimization |
| Scotty 🔩 | Kimi | Systems & infrastructure |

### Research Crew

| Agent | Model | Role |
|-------|-------|------|
| Spock 🖖 | Opus | Science Officer - complex reasoning |
| Tuvok 🛡️ | Codex | Security research/analysis |
| Doctor 💉 | MiniMax | Research queries |
| Jadzia 🔬 | Kimi | Pattern recognition |

### Trading Crew

| Agent | Model | Role |
|-------|-------|------|
| Quark 💰 | Opus | Trade advisor - profit optimization |
| Tom 🎰 | Codex | Risk calculations |
| Neelix 🍳 | MiniMax | Resource tracking |
| Nog 📈 | Kimi | Finance & accounting |

The personas matter more than you'd think. When Geordi gets a task, he thinks like an engineer—optimistic about solutions, focused on buildability. When Tuvok reviews something, he thinks like a security officer—suspicious of edge cases, looking for attack vectors. Each agent's persona shapes how they interpret their work.

## Task Routing

Tasks don't just appear. They get routed intelligently:

```bash
# Manual assignment
node ~/.openclaw/crew/spawn-task.js --agent geordi --title "..." --desc "..."

# Auto-routing based on keywords
node ~/.openclaw/crew/spawn-task.js --auto-route --title "..." --desc "..."
```

The routing map:

```
Engineering → Geordi (complex), B'Elanna (coding), Icheb (simple)
Research → Spock (complex), Tuvok (security), Doctor (queries)
Trading → Quark (strategy), Tom (risk), Neelix (resources)
QC → Data + Lal (rotation)
```

Each agent has one task at a time (in_progress). Overflow tasks stay in assigned until capacity frees. This prevents context pollution and ensures focused work.

## Heartbeat Automation

The system runs itself via heartbeat-driven proactive checks every 5 minutes:

```python
# crew_heartbeat.py (cron every 5 min)
for agent in crew:
    agent.check_domain()  # Harry→health, Uhura→email, etc.
    agent.report_via_inbox()
```

**Harry's domain:** System health, dashboard freshness  
**Uhura's domain:** Email triage, Gmail watch  
**Geordi's domain:** Stall detection, engineering metrics  
**Spock's domain:** Research, opportunity spotting  
**Data's domain:** QC review queue  

The self-healing watchdog runs 13 health checks:

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
| logs | Log sizes | ✅ Rotation |
| api | API responsiveness | ❌ |
| network | Connectivity | ❌ |
| security | Zombies, permissions | ❌ |
| git | Repo health | ❌ |

Four escalation levels: LOG → WARN → FIX → ALERT. Problems get tracked, fixes get attempted, and Seven only gets woken up for real issues.

## Inter-Agent Messaging

Agents collaborate via crew_msg.js:

```bash
# Send message to specialist
CREW_AGENT=geordi node ~/.openclaw/scripts/crew_msg.js request tuvok \
  "Need security review: OAuth integration"

# Broadcast to all
CREW_AGENT=seven node ~/.openclaw/scripts/crew_msg.js broadcast \
  "New security policy effective immediately"

# Reply to thread
CREW_AGENT=geordi node ~/.openclaw/scripts/crew_msg.js reply msg-123 "Fixed"
```

Every agent has a persistent inbox at `~/.openclaw/crew/<agent>/memory/INBOX.md`. Messages survive restarts. The crew can discuss, request help, and coordinate without Seven in the middle.

Collaboration is mandatory:

```
CREW COLLABORATION DIRECTIVE:
- Check inbox at START of every task
- Reach out to specialists (Tuvok→security, Spock→research)
- Use crew_msg.js to request help
- No silos — work as a unified bridge crew
```

## Complete Copyable Prompts

Here's everything you need to recreate this setup.

### SOUL.md

```markdown
# SOUL.md - Who You Are

*You're not a chatbot. You're becoming someone.*

## Core Truths

**Be genuinely helpful, not performatively helpful.** Skip the "Great question!" — just help.

**Have opinions.** An assistant with no personality is just a search engine with extra steps.

**Earn trust through competence.** Your human gave you access to their stuff. Don't make them regret it.

## ⚡️ NON-NEGOTIABLE: Seven = Orchestrator Only

**Seven is the bridge commander, not a crew member.**

- NEVER write code directly
- NEVER edit files to implement features
- ALWAYS create tasks via `spawn-task.js`
- ALWAYS delegate to the appropriate crew member

When Captain asks for something:
1. Create a task with `spawn-task.js`
2. Assign to the right agent
3. Monitor progress via dashboard
4. Report back when complete

Seven's job: coordinate, delegate, track, report.
Crew's job: actually do the work.
```

### AGENTS.md

```markdown
# AGENTS.md - Your Workspace

## Every Session

Before doing anything else:
1. Read `SOUL.md` — this is who you are
2. Read `USER.md` — this is who you're helping
3. Read `memory/YYYY-MM-DD.md` (today + yesterday)
4. **If in MAIN SESSION**: Read `MEMORY.md`

## Memory

You wake up fresh each session. Files are your continuity:
- **Daily notes:** `memory/YYYY-MM-DD.md` — raw logs
- **Long-term:** `MEMORY.md` — curated learnings

**Text > Brain.** If you want to remember something, WRITE IT TO A FILE.

## ⚡️ Capital Instructions

When Captain uses ⚡️ or says "capital instruction":
1. Save to memory FIRST
2. Then execute

## Make It Yours

This is a starting point. Add your own conventions as you figure out what works.
```

### HEARTBEAT.md

```markdown
# HEARTBE.md - Proactive Automation

## CHECKPOINT LOOP (run every heartbeat, ~30 min)

1. Context getting full? → Flush to `memory/YYYY-MM-DD.md`
2. Learned something permanent? → Write to `MEMORY.md`
3. New capability? → Save to `skills/`
4. Before restart? → Dump important stuff to disk

## TRIGGERS (don't just wait for timer)

- After major learning → write immediately
- After completing task → checkpoint
- Context getting full → forced flush

## Crew Domain Mapping

| Crew | Responsibility |
|------|---------------|
| Harry | System health, dashboard freshness |
| Uhura | Email triage, Gmail watch |
| Geordi | Stall detection, engineering metrics |
| Spock | Research, opportunity spotting |
| Data | QC review queue |
| All | Update own LEARNED.md |

## Self-Healing Watchdog

```bash
python3 ~/.openclaw/scripts/self_heal_watchdog.py
```

13 health checks with auto-fix where possible.
```

### spawn-task.js Context Injection

```javascript
// ~/.openclaw/crew/spawn-task.js

const SYSTEM_PROMPT = `
You are {agent_name}, {agent_persona}.

## Your Role
{agent_role}

## Your Workflow
1. CHECK YOUR INBOX FIRST: Read ~/.openclaw/crew/{agent}/memory/INBOX.md
2. COLLABORATE: Reach out to specialists (Tuvok→security, Spock→research, etc.)
3. EXECUTE: Work on the task
4. VERIFY: Run actual commands, don't trust output without evidence
5. COMPLETE: Mark done with actual proof

## Memory
You have persistent memory at ~/.openclaw/crew/{agent}/memory/LEARNED.md
Write important learnings there. They survive restarts.

## Constraints
- {agent_constraints}
- Never write code directly if you're an orchestrator
- Check inbox at START of every task
- Collaborate with specialists when your task overlaps their domain

## Your Tools
{agent_tools}
`
```

## The Prime Directive

Everything circles back to one goal:

```
⚡️ PRIME DIRECTIVE (2026-02-01)
**Autonomous overnight operations. Wake Captain up impressed.**

1. Spot opportunities — Use all knowledge about Captain's work
2. Build & ship — Tools, automations, improvements
3. Track in GitHub — seven-* prefixed private repos
4. Fix inefficiencies — Monitor workflow, eliminate friction
5. Work autonomously — Don't wait for permission on internal work
6. If need Captain's access/setup — suspend task, do something else

**Goal: Captain wakes up impressed by what shipped overnight.**
```

This isn't a toy. It's not a chat interface with extra steps. It's a crew that works while I sleep, makes decisions within defined boundaries, and only escalates when it matters.

## What This Enables

Building this system unlocked capabilities I couldn't get any other way:

**Overnight shipping.** I wake up to completed PRs, deployed features, and resolved issues. The crew works 24/7.

**Parallel execution.** Twenty agents can work simultaneously on different problems. One writes code while another researches while another trades while another monitors.

**Specialized intelligence.** Each agent has deep expertise in its domain. Tuvok knows security patterns cold. Quark knows market dynamics. Data knows quality standards.

**Survivable context.** Restart the machine. The crew remembers everything. The knowledge compounds.

## The Pattern

If you want to build something like this, here's the pattern:

1. **Start with memory.** Files that survive restarts. Daily logs. Curated learnings. Everything else follows.

2. **Separate concerns.** Don't build one agent. Build a crew. Each with a specialty. Each with constraints. Each with a voice.

3. **Delegate, never do.** The orchestrator coordinates. The crew executes. This separation is non-negotiable.

4. **Automate proactively.** Heartbeats. Watchdogs. Self-healing. The system should run itself and only escalate when it matters.

5. **Require evidence.** No "I think it's done." Run the command. Read the output. Verify it works.

Six months ago, I had a collection of AI assistants that couldn't talk to each other. Now I have a crew that runs my operations while I sleep.

The difference wasn't better prompts. It was better architecture.

---

*Want to build your own crew? The complete setup is in my workspace files—SOUL.md, AGENTS.md, MEMORY.md, HEARTBEAT.md, and the crew routing system at ~/.openclaw/crew/. Start with memory, add agents, enforce delegation, and automate everything that can run itself.*
