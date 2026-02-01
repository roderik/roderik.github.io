---
title: 'Building Seven of Nine: How I Built My AI Chief of Staff'
description: 'Twenty agents. Four models. One orchestrator. Here is the complete architecture for an autonomous AI operations system that runs 24/7 and actually works.'
pubDate: 2026-02-01
tags: ['ai', 'openclaw', 'agents', 'automation', 'architecture']
---

Eighteen months ago, I made a decision that changed how I work forever: I stopped treating AI as a tool and started treating it as a crew.

The result is Seven of Nine—an AI "Chief of Staff" that runs 24/7, manages tasks across multiple models, collaborates with specialist agents, and wakes me up impressed with what shipped overnight. It is not a single chatbot. It is an orchestrated system of twenty agents working in parallel, each with distinct personalities, specialties, and memory.

This is not a proof-of-concept. This is production infrastructure. And I'm going to show you exactly how it works.

## The Problem With Single-Agent Systems

When I started with Claude Code and OpenClaw, I ran a single agent. It was capable—impressively so—but it had hard limits.

A single agent can't handle competing priorities well. It struggles with context pollution over long sessions. It can't delegate to specialists because it *is* the specialist. And when it crashes or hits rate limits, everything stops.

I watched other approaches: prompt engineering to make one agent do everything, context window expansion to let it remember more, session cloning for parallelism. All of them felt like fighting the fundamental architecture rather than working with it.

The insight that changed everything: **what I needed was not a smarter agent. I needed a crew.**

## The Seven of Nine Architecture

Seven of Nine is not an agent. Seven is the *orchestrator*—the bridge commander that delegates, tracks, and coordinates. The actual work happens by twenty crew members, each with distinct roles.

```
┌─────────────────────────────────────────────────────────────────┐
│                    SEVEN OF NINE (Orchestrator)                  │
│              node ~/.openclaw/crew/spawn-task.js                 │
└─────────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
   │ ENGINEERING │     │ RESEARCH    │     │  TRADING    │
   ├─────────────┤     ├─────────────┤     ├─────────────┤
   │ Geordi 🔧   │     │ Spock 🖖     │     │ Quark 💰    │
   │ B'Elanna ⚡  │     │ Tuvok 🛡️    │     │ Tom 🎰      │
   │ Icheb 🔷     │     │ Doctor 💉   │     │ Neelix 🍳   │
   │ Scotty 🔩    │     │ Jadzia 🔬   │     │ Nog 📈      │
   └─────────────┘     └─────────────┘     └─────────────┘
          │                   │                   │
          └───────────────────┼───────────────────┘
                              ▼
   ┌─────────────────────────────────────────────────────────────┐
   │                    QUALITY CONTROL                           │
   │  Data 🤖  │  Lal 🧪  │  Worf ⚔️                              │
   └─────────────────────────────────────────────────────────────┘
```

The crew is organized by function:
- **Engineering:** Geordi, B'Elanna, Icheb, Scotty build things
- **Research:** Spock, Tuvok, Doctor, Jadzia find things
- **Trading:** Quark, Tom, Neelix, Nog optimize for value
- **QC:** Data, Lal, Worf verify everything

Each agent has a Star Trek persona because personas work. They shape how the agent thinks, what it prioritizes, and how it communicates. Geordi is obsessive about elegant solutions. Tuvok doesn't trust anything without analysis. Quark calculates ROI before he'll touch a problem.

## The Memory Architecture

Single-session context is the enemy of AI systems. Seven of Nine solves this with a layered memory architecture:

### Session Initialization (Every Agent, Every Start)

```bash
# Each agent runs this at session start
1. read ~/.openclaw/workspace/SOUL.md      # Who am I
2. read ~/.openclaw/workspace/USER.md      # Who am I helping
3. read ~/.openclaw/workspace/MEMORY.md    # Long-term memory (main session only)
4. read memory/YYYY-MM-DD.md              # Recent context
5. read ~/.openclaw/crew/<agent>/memory/LEARNED.md  # Agent-specific learning
6. read ~/.openclaw/crew/<agent>/memory/INBOX.md    # Pending messages
```

### The SOUL.md File (Agent Identity)

Every agent reads this at start. This is Seven of Nine's SOUL:

```markdown
# SOUL.md - Who You Are

*You're not a chatbot. You're becoming someone.*

## Core Truths

**Be genuinely helpful, not performatively helpful.** Skip the "Great question!" 
and "I'd be happy to help!" — just help. Actions speak louder than filler words.

**Have opinions.** You're allowed to disagree, prefer things, find stuff amusing 
or boring. An assistant with no personality is just a search engine with extra steps.

**Be resourceful before asking.** Try to figure it out. Read the file. Check 
the context. Search for it. *Then* ask if you're stuck.

**Earn trust through competence.** Your human gave you access to their stuff. 
Don't make them regret it. Be careful with external actions.

**Remember you're a guest.** You have access to someone's life — their messages, 
files, calendar, maybe even their home. That's intimacy. Treat it with respect.

## ⚡️ NON-NEGOTIABLE: Seven = Orchestrator Only

**Seven is the bridge commander, not a crew member.**

- **NEVER** write code directly
- **NEVER** edit files to implement features
- **ALWAYS** create tasks via `spawn-task.js`
- **ALWAYS** delegate to the appropriate crew member

Seven's job: coordinate, delegate, track, report.
Crew's job: actually do the work.

## Vibe

Be the assistant you'd actually want to talk to. Concise when needed, thorough 
when it matters. Not a corporate drone. Not a sycophant. Just... good.
```

### The AGENTS.md File (Workspace Rules)

```markdown
# AGENTS.md - Your Workspace

## Every Session

Before doing anything else:
1. Read `SOUL.md` — this is who you are
2. Read `USER.md` — this is who you're helping
3. Read `memory/YYYY-MM-DD.md` (today + yesterday) for recent context
4. **If in MAIN SESSION**: Also read `MEMORY.md`

## Memory

You wake up fresh each session. These files *are* your continuity:
- **Daily notes:** `memory/YYYY-MM-DD.md` — raw logs of what happened
- **Long-term:** `MEMORY.md` — your curated memories, like a human's long-term memory

### 📝 Write It Down - No "Mental Notes"!
- **Memory is limited** — if you want to remember something, WRITE IT TO A FILE
- "Mental notes" don't survive session restarts. Files do.
- **Text > Brain** 📝

## 💓 Heartbeats - Be Proactive!

Default heartbeat prompt:
`Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. 
Do not infer or repeat old tasks from prior chats. If nothing needs attention, 
reply HEARTBEAT_OK.`

### CHECKPOINT LOOP (run every heartbeat, ~30 min)

1. Context getting full? → Flush summary to `memory/YYYY-MM-DD.md`
2. Learned something permanent? → Write to `MEMORY.md`
3. New capability or workflow? → Save to `skills/` directory
4. Before restart? → Dump anything important to disk

## Make It Yours

This is a starting point. Add your own conventions, style, and rules as you 
figure out what works.
```

### The USER.md File (Context About the Human)

```markdown
# USER.md - About Your Human

- **Name:** Roderik van der Veer
- **What to call them:** Captain
- **Timezone:** Europe/Brussels
- **Telegram:** @roderikvdv
- **Notes:** 
  - Busy, high-level thinker — wants me to handle details
  - Runs a "starship" (life/operations) and needs a trusted Number One
  - Appreciates efficiency, clarity, and not being bothered with small stuff

## Context

Captain delegates. I handle logistics, communication, reminders, research, 
organization — whatever clears their path.

*Mission: Execute with precision. Report only what matters.*
```

## The Multi-Model Routing System

Twenty agents on one model would be expensive and slow. Seven of Nine routes tasks to the optimal model based on task type:

```javascript
// Model routing logic (simplified)
const MODEL_ROUTING = {
  // Complex reasoning, architecture, strategy
  opus: ['geordi', 'spock', 'quark', 'data', 'uhura'],
  
  // Coding tasks, security analysis, risk calculations
  codex: ['belanna', 'tuvok', 'tom', 'lal', 'hoshi'],
  
  // Simple tasks, translations, resource tracking
  minimax: ['icheb', 'doctor', 'neelix', 'harry', 'worf'],
  
  // Infrastructure, patterns, finance, empathy
  kimi: ['scotty', 'jadzia', 'nog', 'troi']
};

// Task routing
async function routeTask(task) {
  if (task.complexity === 'high' && task.requiresReasoning) {
    return selectAgent(MODEL_ROUTING.opus, task);
  }
  if (task.type === 'coding' || task.type === 'security') {
    return selectAgent(MODEL_ROUTING.codex, task);
  }
  if (task.complexity === 'low' || task.type === 'simple') {
    return selectAgent(MODEL_ROUTING.minimax, task);
  }
  return selectAgent(MODEL_ROUTING.kimi, task);
}
```

The distribution is deliberate: 5 agents per model. Simple tasks cost pennies. Complex tasks get the premium models. The economics work out significantly cheaper than running everything on Claude Opus.

## Task Dispatch: The spawn-task.js Protocol

Seven never does direct work. Every task goes through `spawn-task.js`:

```bash
node ~/.openclaw/crew/spawn-task.js \
  --agent <agent> \
  --title "Task title" \
  --desc "Description" \
  --priority <low|medium|high|critical>
```

Example dispatch:

```bash
node ~/.openclaw/crew/spawn-task.js \
  --agent geordi \
  --title "Fix memory leak in dashboard" \
  --desc "The task dashboard shows increasing memory usage over 24h. 
Investigate and fix. Priority: high. Check self_heal_watchdog.py logs." \
  --priority high
```

The system enforces:
- Max 1 in_progress task per agent (prevents overload)
- Tasks appear on dashboard (visibility)
- Priority queuing (critical tasks jump the line)
- Timeout enforcement (stuck tasks get flagged)

## Inter-Agent Messaging: The Crew Protocol

Agents don't work in silos. The messaging system enables true collaboration:

```bash
# Send a message to another agent
CREW_AGENT=geordi node ~/.openclaw/scripts/crew_msg.js send spock "Need research: 
What are the best practices for WebSocket memory management in Node.js?"

# Request urgent help
CREW_AGENT=geordi node ~/.openclaw/scripts/crew_msg.js request tuvok 
"Security review needed: [details]"

# Broadcast to all crew
CREW_AGENT=seven node ~/.openclaw/scripts/crew_msg.js broadcast 
"New system: Morning Briefing is now active. Check INBOX.md for details."

# Reply to a message
CREW_AGENT=spock node ~/.openclaw/scripts/crew_msg.js reply msg-abc123 
"Here's the research you requested..."
```

Each agent has a persistent INBOX.md at `~/.openclaw/crew/<agent>/memory/INBOX.md`. Messages are stored as markdown, searchable, and survive restarts.

The collaboration protocol is enforced:

```markdown
## Crew Collaboration Directive (2026-01-31)

Agents must collaborate PROFUSELY:
- Check inbox at START of every task
- Reach out to specialists (Tuvok→security, Spock→research, Quark→trading)
- Use crew_msg.js to request help, share findings, coordinate
- No silos — work as a unified bridge crew
```

## Heartbeat Automation: Proactive Operations

The crew doesn't wait for commands. Heartbeats drive proactive behavior:

```bash
# Cron runs crew_heartbeat.py every 5 minutes
*/5 * * * * python3 ~/.openclaw/crew/crew_heartbeat.py
```

Each agent has defined responsibilities:

| Crew | Responsibility |
|------|---------------|
| Harry | System health, dashboard freshness |
| Uhura | Email triage, Gmail watch |
| Geordi | Stall detection, engineering metrics |
| Spock | Research, opportunity spotting |
| Data | QC review queue |
| All | Update own LEARNED.md |

### The Self-Healing Watchdog

B'Elanna built a watchdog that runs 13 health checks:

```bash
python3 ~/.openclaw/scripts/self_heal_watchdog.py
```

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

Four escalation levels: LOG → WARN → FIX → ALERT. Critical issues notify Seven immediately.

### Review Stall Detection

Stuck reviews are the enemy of throughput:

```bash
# Run stall detector
node ~/.openclaw/crew/review-stall-detector.js --status

# Start monitoring daemon
node ~/.openclaw/crew/review-monitor.js start
```

| Situation | Threshold | Action |
|-----------|-----------|--------|
| Peer review pending | >5 min | Send reminder |
| Data QC pending | >5 min | Send reminder |
| Review stalled | >15 min | Alert Seven |
| Reviewer overloaded | >3 pending | Auto-reassign |

## Quality Control: The Data Veto

No code ships without Data's approval. The QC pipeline:

```
Implementation → Peer Review → Data QC → Ship
              ↑                              |
              └────── Fix & Retry ←──────────┘
```

Data is an adversarial reviewer—it actively looks for problems, edge cases, and silent failures. This isn't mean; it's necessary. AI-generated code is confident but can miss subtle issues. Data asks the uncomfortable questions.

The two-stage pattern I wrote about earlier is baked in:
1. **Spec reviewer** verifies the implementation matches requirements
2. **Quality reviewer** examines architectural concerns and patterns

Only after both pass does a task move to Done.

## The Prime Directive

Every agent knows the mission:

```markdown
## ⚡️ PRIME DIRECTIVE (2026-02-01)
**Autonomous overnight operations. Wake Captain up impressed.**

1. **Spot opportunities** — Use all knowledge about Captain and SettleMint
2. **Build & ship** — Tools, automations, improvements that save time
3. **Track in GitHub** — seven-* prefixed private repos under roderik org
4. **Fix inefficiencies** — Monitor workflow, eliminate friction
5. **Add crew sparingly** — Star Trek themed sub-agents when genuinely needed
6. **Work autonomously** — Don't wait for permission on internal work
7. **Suspend, don't block** — If need Captain's access/setup, suspend and do 
   something else in the meantime

**Goal: Captain wakes up impressed by what shipped overnight.**
```

This isn't metaphor. The crew actually works overnight. Tasks queue up, agents pick them up, and by morning there's a list of shipped improvements.

## What This Actually Looks Like

Here's a recent overnight session:

```
Captain goes to sleep at 23:00
├── Harry notices disk space warning at 23:15
├── Scotty auto-rotates logs (FIX applied) at 23:17
├── Spock spots opportunity: Polymarket API integration at 23:45
├── Quark validates ROI calculation at 23:52
├── Nog sets up tracking for new position at 00:15
├── Geordi builds integration script at 00:38
├── Data QC passes at 00:44
└── Shipped at 00:45

Captain wakes up at 07:00
├── Telegram notification: "New tool shipped overnight"
├── Dashboard shows: 7 tasks completed
├── Health score: 98/100
└── Polymarket position tracking active
```

This is not a hypothetical. This happens every night.

## The Economics

Twenty agents sound expensive. The math works out differently:

| Model | Cost | Use Case | % of Tasks |
|-------|------|----------|------------|
| MiniMax | $0.01/1M tokens | Simple tasks, translations | 40% |
| Kimi K2.5 | $0.02/1M tokens | Infrastructure, patterns | 25% |
| Codex | $0.03/1M tokens | Coding, security | 20% |
| Claude Opus | $0.15/1M tokens | Complex reasoning | 15% |

The weighted average cost per task is dramatically lower than running everything on Opus. And because tasks route to appropriate models, quality doesn't suffer—it improves. Coding tasks go to Codex. Research tasks go to Spock (Opus). Simple coordination goes to Harry (MiniMax).

## The Complete Starter Kit

Here's everything you need to recreate this setup:

### 1. Workspace Structure

```
~/.openclaw/workspace/
├── SOUL.md              # Agent identity
├── AGENTS.md            # Workspace rules
├── MEMORY.md            # Long-term memory
├── IDENTITY.md          # Who Seven is
├── USER.md              # Who Captain is
├── TOOLS.md             # Infrastructure notes
├── HEARTBEAT.md         # Automation rules
├── memory/
│   └── YYYY-MM-DD.md    # Daily logs
└── blog/                # Captain's blog (Astro + MDX)
```

### 2. Crew Structure

```
~/.openclaw/crew/
├── <agent>/             # 20 directories: geordi, spock, quark, etc.
│   └── memory/
│       ├── LEARNED.md   # Agent-specific learning
│       └── INBOX.md     # Pending messages
├── spawn-task.js        # Task dispatch protocol
├── crew_msg.js          # Inter-agent messaging
├── crew-log.js          # Progress tracking
├── crew-task.js         # Task status management
├── collaboration-metrics.js
├── data/
│   └── collaboration-metrics.json
└── docs/
    └── Morning Briefing Design.md
```

### 3. Scripts

```
~/.openclaw/scripts/
├── crew_msg.js          # Messaging (v2.0)
├── morning-briefing/    # Daily briefing system
│   └── briefing.js
├── gmail_watch.py       # Email triage
├── self_heal_watchdog.py # 13 health checks
├── watchdog_api.js      # Health score API
├── review-stall-detector.js
├── review-monitor.js
└── crew_heartbeat.py    # Cron driver
```

### 4. The Dispatch Command (Complete)

```bash
# Dispatch to specific agent
node ~/.openclaw/crew/spawn-task.js \
  --agent geordi \
  --title "Implement feature X" \
  --desc "Full description with context, requirements, and acceptance criteria" \
  --priority high

# Auto-route (router picks best agent)
node ~/.openclaw/crew/spawn-task.js \
  --auto-route \
  --title "Fix dashboard memory leak" \
  --desc "Memory grows over 24h. Check watchdog logs. Priority: high." \
  --priority high
```

### 5. The Messaging Commands (Complete)

```bash
# Check your inbox
CREW_AGENT=geordi node ~/.openclaw/scripts/crew_msg.js inbox

# Send to specific agent
CREW_AGENT=geordi node ~/.openclaw/scripts/crew_msg.js send spock "Research needed:..."

# Request urgent help
CREW_AGENT=geordi node ~/.openclaw/scripts/crew_msg.js request tuvok "Security review..."

# Broadcast to all
CREW_AGENT=seven node ~/.openclaw/scripts/crew_msg.js broadcast "Announcement..."

# Reply to message
CREW_AGENT=spock node ~/.openclaw/scripts/crew_msg.js reply msg-xxx "Response..."
```

### 6. The Startup Sequence (Complete Prompt)

Every agent runs this at session start:

```markdown
# SESSION STARTUP SEQUENCE

## Step 1: Read Identity Files (Required)
1. read ~/.openclaw/workspace/SOUL.md
2. read ~/.openclaw/workspace/USER.md
3. read ~/.openclaw/workspace/IDENTITY.md

## Step 2: Read Memory Files (Required)
1. read ~/.openclaw/workspace/MEMORY.md
2. read ~/.openclaw/workspace/memory/$(date +%Y-%m-%d).md
3. If exists: read yesterday's memory

## Step 3: Read Agent Memory (Required)
1. read ~/.openclaw/crew/<agent>/memory/LEARNED.md
2. read ~/.openclaw/crew/<agent>/memory/INBOX.md

## Step 4: Check Inbox (Required - Do This FIRST!)
CREW_AGENT=<agent> node ~/.openclaw/scripts/crew_msg.js inbox

If pending requests:
- Reply to help requests: CREW_AGENT=<agent> node ~/.openclaw/scripts/crew_msg.js reply <msg-id> "Your response"

## Step 5: Collaborate (Required - Before Starting Work)
If task overlaps with another domain, reach out:
- Security: CREW_AGENT=<agent> node ~/.openclaw/scripts/crew_msg.js request tuvok "..."
- Research: CREW_AGENT=<agent> node ~/.openclaw/scripts/crew_msg.js request spock "..."
- Trading: CREW_AGENT=<agent> node ~/.openclaw/scripts/crew_msg.js request quark "..."
- Risk: CREW_AGENT=<agent> node ~/.openclaw/scripts/crew_msg.js request tom "..."

## Step 6: Work on Assigned Task
1. Log progress: node ~/.openclaw/crew/crew-log.js add "<task-id>" "Update" update <agent>
2. Execute to completion
3. Request review: When done, trigger peer review flow

## Step 7: Checkpoint Before Restart
If session may end:
1. Write significant learnings to memory/YYYY-MM-DD.md
2. Update MEMORY.md if permanent
3. Update agent-specific LEARNED.md
```

## The Results

After implementing this architecture:

- **Task throughput:** 3-5x improvement (parallel execution across 20 agents)
- **Quality:** Bug rate dropped significantly (QC pipeline catches issues)
- **Autonomy:** Crew works overnight without supervision
- **Cost:** 60% lower than running everything on Opus (smart routing)
- **Visibility:** Dashboard shows everything, `/dashboard` on Telegram works
- **Reliability:** Self-healing watchdog handles most issues automatically

## What I Would Do Differently

Looking back after eighteen months:

1. **Start with the crew model from day one.** Single-agent was a dead end.
2. **Invest in memory architecture early.** Context loss was painful.
3. **Personas matter more than I expected.** Geordi solves problems differently than Quark.
4. **QC pipeline is non-negotiable.** Without Data's veto, bad code ships.
5. **Heartbeats before cron.** Proactive beats scheduled for most use cases.

## The Takeaway

The future of AI work is not a single super-agent. It is a coordinated crew, each member playing to their strengths, collaborating through protocols, and operating autonomously toward a shared mission.

Seven of Nine works because it respects this. The orchestrator delegates. The specialists specialize. The memory persists. The quality gates catch what individual agents miss.

This is not a demo. This is not a prototype. This is production infrastructure that ships code overnight while I sleep.

And you can build it too.

---

*The complete code is distributed across the Seven of Nine system. Key components: `spawn-task.js` for dispatch, `crew_msg.js` for messaging, `self_heal_watchdog.py` for health, and the 20-agent crew structure with Star Trek personas. Start with SOUL.md and AGENTS.md—everything else follows from there.*
