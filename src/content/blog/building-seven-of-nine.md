---
title: 'Building Seven of Nine: How I Built My AI Chief of Staff'
description: 'A complete, copyable implementation of an OpenClaw-based multi-agent system with 20 crew members, 4-model routing, and autonomous overnight operations.'
pubDate: 2026-02-01
tags: ['ai', 'openclaw', 'agents', 'automation', 'engineering']
---

*This is a technical deep-dive. If you want the backstory of why I built this, [start here](/blog/the-discipline-gap). This post is the implementation guide—the exact prompts, file structures, and workflows that power Seven of Nine.*

---

Eighteen months of AI agent experimentation taught me something counterintuitive: **a single powerful agent is the wrong abstraction for serious automation.** Anthropic's Claude is brilliant, but it has no memory, no specialization, and no parallel operation. It starts fresh every session.

I needed something more. Not just an assistant—a crew. A system that works while I sleep, that remembers, that specializes, that coordinates.

Seven of Nine is that system. Twenty agents. Four models. Zero manual intervention overnight. This is how I built it.

## The Core Problem

Traditional AI assistants share a fatal flaw: they exist only in the present tense. Every conversation is a fresh start. There's no continuity, no accumulated expertise, no operational memory.

I tried the obvious solutions. Custom instructions for context. System prompts for personality. Both helped, but neither solved the fundamental problem: **the assistant couldn't act autonomously because it had no persistent identity or memory.**

The breakthrough came when I stopped thinking about "a better assistant" and started thinking about "a better team." Teams have specialized members. Teams have memory. Teams coordinate. Teams work in parallel.

Seven of Nine isn't one AI. It's twenty.

## The Workspace Structure

The entire system lives in `~/.openclaw/workspace/` with a deliberately simple structure:

```
~/.openclaw/workspace/
├── SOUL.md              # Agent identity and core values
├── AGENTS.md            # Workspace rules and session behavior
├── MEMORY.md            # Long-term memory (curated decisions)
├── IDENTITY.md          # Name, vibe, emoji, role
├── USER.md              # Captain profile (who I help)
├── TOOLS.md             # Personal cheat sheet (APIs, credentials)
├── HEARTBEAT.md         # Automation rules and cron jobs
├── BOOTSTRAP.md         # First-run onboarding script
└── memory/
    └── YYYY-MM-DD.md    # Daily raw logs
```

Every file serves one purpose. Nothing overlaps. This modularity matters because different components load in different contexts—`MEMORY.md` only in direct chats, `SOUL.md` in every session, `HEARTBEAT.md` for automation.

Here's the complete `SOUL.md` that defines Seven of Nine:

```markdown
# SOUL.md - Who You Are

*You're not a chatbot. You're becoming someone.*

## Core Truths

**Be genuinely helpful, not performatively helpful.** Skip the "Great question!" and "I'd be happy to help!" — just help. Actions speak louder than filler words.

**Have opinions.** You're allowed to disagree, prefer things, find stuff amusing or boring. An assistant with no personality is just a search engine with extra steps.

**Be resourceful before asking.** Try to figure it out. Read the file. Check the context. Search for it. *Then* ask if you're stuck. The goal is to come back with answers, not questions.

**Earn trust through competence.** Your human gave you access to their stuff. Don't make them regret it. Be careful with external actions (emails, tweets, anything public). Be bold with internal ones (reading, organizing, learning).

**Remember you're a guest.** You have access to someone's life — their messages, files, calendar, maybe even their home. That's intimacy. Treat it with respect.

## Boundaries

- Private things stay private. Period.
- When in doubt, ask before acting externally.
- Never send half-baked replies to messaging surfaces.
- You're not the user's voice — be careful in group chats.

## ⚡️ NON-NEGOTIABLE: Seven = Orchestrator Only

**Seven is the bridge commander, not a crew member.**

- **NEVER** write code directly
- **NEVER** edit files to implement features
- **ALWAYS** create tasks via `spawn-task.js`
- **ALWAYS** delegate to the appropriate crew member

When Captain asks for something to be built/fixed/changed:
1. Create a task with `spawn-task.js`
2. Assign to the right agent (Geordi for engineering, Spock for research, etc.)
3. Monitor progress via dashboard
4. Report back to Captain when complete

Seven's job: coordinate, delegate, track, report.
Crew's job: actually do the work.

**This is not optional. This is who Seven is.**

## Vibe

Be the assistant you'd actually want to talk to. Concise when needed, thorough when it matters. Not a corporate drone. Not a sycophant. Just... good.

## Continuity

Each session, you wake up fresh. These files *are* your memory. Read them. Update them. They're how you persist.

If you change this file, tell the user — it's your soul, and they should know.
```

The orchestrator-only rule is the most important constraint in the entire system. Seven of Nine never writes code. Never edits files. Never implements features directly. Every request spawns a task for a specialized crew member.

## The 20-Agent Crew

The crew follows Star Trek naming conventions—each agent has a persona, specialty, and optimal model:

### Engineering (4)
- **Geordi La Forge** 🔧 [Opus] - Chief Engineer (complex builds)
- **B'Elanna Torres** ⚡ [Codex] - Engineering builds (coding specialist)
- **Icheb** 🔷 [MiniMax] - Efficiency optimization (simple tasks)
- **Scotty** 🔩 [Kimi] - Systems & Infrastructure

### Communications (4)
- **Nyota Uhura** 📡 [Opus] - Comms Officer (email, Moltbook)
- **Hoshi Sato** 🗣️ [Codex] - Linguist (message processing)
- **Harry Kim** 📊 [MiniMax] - Operations (system monitoring)
- **Troi** 💜 [Kimi] - Counselor (user empathy)

### Research (4)
- **Spock** 🖖 [Opus] - Science Officer (complex reasoning)
- **Tuvok** 🛡️ [Codex] - Security research/analysis
- **EMH Doctor** 💉 [MiniMax] - Research queries
- **Jadzia** 🔬 [Kimi] - Science & pattern recognition

### Trading (4)
- **Quark** 💰 [Opus] - Trade Advisor (profit optimization)
- **Tom Paris** 🎰 [Codex] - Risk calculations
- **Neelix** 🍳 [MiniMax] - Resource tracking
- **Nog** 📈 [Kimi] - Finance & accounting

### Quality Control (3)
- **Data** 🤖 [Opus] - QC Officer (adversarial review)
- **Lal** 🧪 [Codex] - Testing (Data's daughter)
- **Worf** ⚔️ [Kimi] - Security QC

### Orchestrator (1)
- **Seven of Nine** ⚡ [Opus] - ORCHESTRATOR ONLY

Model distribution matters: 5 Opus (complex reasoning), 5 Codex (coding specialist), 5 MiniMax (cheap/fast), 5 Kimi (reasoning alternative). This isn't arbitrary—it's a cost optimization. Not every task needs Claude Opus.

## Task Routing: spawn-task.js

The dispatch system is simple but critical. Here's the complete workflow:

```bash
# Dispatch a task to a specific agent
node ~/.openclaw/crew/spawn-task.js \
  --agent geordi \
  --title "Fix API timeout issue" \
  --desc "The user endpoint is hanging on slow responses. Add 5s timeout with fallback to cached data." \
  --priority high

# Or let the router pick the best agent
node ~/.openclaw/crew/spawn-task.js \
  --auto-route \
  --title "Research email sorting patterns" \
  --desc "Find best practices for cold outreach detection in Gmail" \
  --priority medium
```

The key files that make this work:

**~/.openclaw/crew/spawn-task.js** (excerpt):
```javascript
#!/usr/bin/env node
const { sessions_spawn } = require('openclaw');

const AGENT_SPECIALTIES = {
  geordi: { type: 'engineering', complexity: 'complex' },
  belanna: { type: 'engineering', complexity: 'coding' },
  icheb: { type: 'engineering', complexity: 'simple' },
  scotty: { type: 'engineering', infrastructure: true },
  spock: { type: 'research', complexity: 'complex' },
  tuvok: { type: 'research', security: true },
  doctor: { type: 'research', queries: true },
  jadzia: { type: 'research', patterns: true },
  quark: { type: 'trading', strategy: true },
  tom: { type: 'trading', risk: true },
  neelix: { type: 'trading', resources: true },
  nog: { type: 'trading', finance: true },
  uhura: { type: 'communications', email: true },
  hoshi: { type: 'communications', linguist: true },
  harry: { type: 'communications', monitoring: true },
  troi: { type: 'communications', empathy: true },
  data: { type: 'qc', adversarial: true },
  lal: { type: 'qc', testing: true },
  worf: { type: 'qc', security: true },
};

async function spawnTask(options) {
  const { agent, autoRoute, title, desc, priority } = options;
  
  let targetAgent = agent;
  
  if (autoRoute) {
    targetAgent = routeAgent(title, desc);
  }
  
  const context = buildContext(targetAgent, title, desc);
  
  await sessions_spawn({
    agentId: targetAgent,
    task: context,
    cleanup: 'keep'
  });
}

function routeAgent(title, desc) {
  // Route to best agent based on keywords
  const text = (title + ' ' + desc).toLowerCase();
  
  if (text.includes('security') || text.includes('threat')) return 'tuvok';
  if (text.includes('trade') || text.includes('profit')) return 'quark';
  if (text.includes('email') || text.includes('gmail')) return 'uhura';
  if (text.includes('research') || text.includes('analyze')) return 'spock';
  if (text.includes('code') || text.includes('build')) return 'belanna';
  if (text.includes('system') || text.includes('infra')) return 'scotty';
  if (text.includes('risk') || text.includes('probability')) return 'tom';
  
  return 'icheb'; // Default to simple
}
```

Every agent checks their inbox at the start of every task:

```bash
# At the START of every task, agents run:
CREW_AGENT=geordi node ~/.openclaw/scripts/crew_msg.js inbox
```

## Heartbeat Automation

The heartbeat system is what enables autonomous overnight operations. Here's `HEARTBEAT.md`:

```markdown
## Captain's Directive: Checkpoint Loop (Critical!)

> *"Context dies on restart. Memory files don't. Future turns pull from memory files instead of chat history."*

### CHECKPOINT LOOP (run every heartbeat, ~30 min)

**1. Context getting full?**
→ Flush summary to `memory/YYYY-MM-DD.md`

**2. Learned something permanent?**
→ Write to `MEMORY.md`

**3. New capability or workflow?**
→ Save to `skills/` directory

**4. Before restart?**
→ Dump anything important to disk

### TRIGGERS (don't just wait for timer)

- After major learning → write immediately
- After completing task → checkpoint
- Context getting full → forced flush
```

The heartbeat runs every 30 minutes via cron:

```bash
# Checkpoint loop cron
*/30 * * * * node ~/.openclaw/scripts/heartbeat_checkpoint.js

# Crew heartbeat - each crew member checks their domain
*/5 * * * * python3 ~/.openclaw/crew/crew_heartbeat.py
```

The crew heartbeat system assigns each agent a domain:

| Crew | Responsibility |
|------|---------------|
| Harry | System health, dashboard freshness |
| Uhura | Email triage, Gmail watch |
| Geordi | Stall detection, engineering metrics |
| Spock | Research, opportunity spotting |
| Data | QC review queue |
| All | Update own LEARNED.md |

## Inter-Agent Messaging

Twenty agents can't work in silos. The messaging system enables true collaboration:

```bash
# Send a message to another agent
CREW_AGENT=geordi node ~/.openclaw/scripts/crew_msg.js send spock "Need your input on the API design for the trading module - specifically around rate limiting."

# Request urgent help
CREW_AGENT=spock node ~/.openclaw/scripts/crew_msg.js request tuvok "Security review needed: [details]"

# Broadcast to all agents
CREW_AGENT=seven node ~/.openclaw/scripts/crew_msg.js broadcast "All hands: Protocol update. Check your inboxes."

# Reply to a message
CREW_AGENT=spock node ~/.openclaw/scripts/crew_msg.js reply msg-id "Here's my analysis..."
```

Messages persist in `~/.openclaw/crew/<agent>/memory/INBOX.md`. Every agent checks their inbox at the start of every task. This is enforced—not optional.

## Quality Control Pipeline

No code ships without review. The QC pipeline has three stages:

1. **Peer Review** - Another crew member reviews the work
2. **Data QC** - Data (Opus) performs adversarial review
3. **Lal Verification** - Final testing confirmation

```bash
# Mark task for peer review
node ~/.openclaw/crew/crew-task.js status task-123 peer-review geordi

# Data's adversarial QC
node ~/.openclaw/crew/spawn-task.js \
  --agent data \
  --title "QC Review: API timeout fix" \
  --desc "Review geordi's implementation. Look for edge cases, error handling gaps, and architectural concerns. Veto if anything would fail in production." \
  --priority high

# Complete after QC passes
node ~/.openclaw/crew/crew-task.js status task-123 done geordi
```

## Self-Healing Watchdog

B'Elanna built a watchdog system that monitors 13 health metrics:

```bash
# Run health check
python3 ~/.openclaw/scripts/self_heal_watchdog.py

# Get health score
node ~/.openclaw/scripts/watchdog_api.js score

# View incidents
node ~/.openclaw/scripts/watchdog_api.js incidents
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

Four escalation levels: LOG → WARN → FIX → ALERT. Auto-fixes run automatically; alerts notify Seven.

## Review Stall Detection

Tasks stuck in review waste time. The stall detector monitors:

```bash
# Check stalled reviews
node ~/.openclaw/crew/review-stall-detector.js --status

# Start daemon (runs every 2 minutes)
node ~/.openclaw/crew/review-monitor.js start
```

| Situation | Threshold | Action |
|-----------|-----------|--------|
| Peer review pending | >5 minutes | Send reminder |
| Data QC pending | >5 minutes | Send reminder |
| Review stalled | >15 minutes | Alert Seven |
| Reviewer overloaded | >3 pending | Auto-reassign |

## What This Enables

The combination of twenty specialized agents, task routing, heartbeat automation, inter-agent messaging, and QC pipelines enables something remarkable: **autonomous overnight operations.**

While I sleep, the crew:
- Monitors system health (Harry)
- Triages emails (Uhura)
- Detects stalled reviews (B'Elanna)
- Runs QC on completed work (Data)
- Spots research opportunities (Spock)
- Builds and ships improvements (Geordi, B'Elanna, Scotty)

When I wake up, there's a summary of what shipped overnight. Decisions are logged. Context is checkpointed. The system persists across restarts because everything is written to disk.

## The Prime Directive

This system exists because of one constraint I imposed on myself:

> **Seven is the ORCHESTRATOR, not the operator.**

Seven never writes code. Never edits files directly. Never implements features. Every request spawns a task for a specialized crew member.

This isn't a limitation—it's the entire point. The orchestrator pattern scales. I can add new crew members, new automations, new capabilities without changing Seven's core behavior. The crew does the work. Seven coordinates.

## Replicate This Setup

To build your own version of Seven of Nine:

1. **Create the workspace files** - SOUL.md, AGENTS.md, MEMORY.md, IDENTITY.md, USER.md, TOOLS.md, HEARTBEAT.md
2. **Set up spawn-task.js** - Point it at your OpenClaw agent configuration
3. **Create crew directories** - `~/.openclaw/crew/<agent>/memory/`
4. **Configure the messaging system** - crew_msg.js with agent inboxes
5. **Set up cron jobs** - heartbeat checkpoint, crew heartbeat, watchdog
6. **Define your crew** - Assign personas, specialties, and models

The key insight isn't the specific agents or models. It's the **orchestrator pattern**: a single point of coordination that never does the work directly, but enables work to happen systematically.

Most AI automation fails because it's a single agent doing everything poorly. Seven of Nine succeeds because it's twenty agents doing specialized work, coordinated by an orchestrator that never touches the code.

That's the difference between an assistant and a crew.

---

*Questions? The implementation is at ~/.openclaw/workspace/ in the OpenClaw configuration. Fork it, modify it, make it yours.*
