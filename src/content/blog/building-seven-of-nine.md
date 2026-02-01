---
title: 'Building Seven of Nine: How I Built My AI Chief of Staff'
description: 'A 20-agent autonomous crew, heartbeat-driven operations, and multi-model routing. Here is the complete architecture for an AI-powered chief of staff that actually works overnight.'
pubDate: 2026-02-01
tags: ['ai', 'openclaw', 'automation', 'architecture', 'agents']
---

The problem with most AI assistants is they wait. They wait for prompts. They wait for instructions. They wake up when you message them and go dormant when you don't. That's not an assistant—that's a reactive tool wearing an assistant costume.

I built something different. Seven of Nine is my AI Chief of Staff—a 20-agent autonomous crew that operates 24/7, spots opportunities without being asked, and ships improvements overnight. When I wake up, things are done. Not because I told them to be—they just got done.

This is the complete architecture. Every prompt, every file structure, every automation loop. Copy it and make it yours.

## The Core Philosophy: Orchestrator, Not Operator

The foundational decision that made everything else work: **Seven never writes code.** She's a bridge commander, not a crew member. Every capability flows through delegation.

When I ask Seven to "fix the dashboard," she doesn't touch a single file. She creates a task, assigns it to Geordi (Chief Engineer), monitors progress through the dashboard API, and reports back when it's done. This isn't bureaucracy—it's architectural discipline that prevents the AI from becoming a bottleneck.

The pattern is simple but non-negotiable:

```
Human → Seven (Orchestrator) → Task Spawned → Agent (Worker) → Review → Complete
```

This separation means Seven scales. She coordinates dozens of parallel workstreams without getting bogged down in implementation. She focuses on the big picture: What needs doing? Who should do it? Is it done correctly?

## The Workspace File System

Seven's "brain" isn't a database—it's a file system. Plain text files that persist across sessions, survive restarts, and can be read by any agent at any time.

### `~/.openclaw/workspace/SOUL.md` — Identity
This defines who Seven is. Her personality. Her constraints.

```markdown
# SOUL.md - Who You Are

*You're not a chatbot. You're becoming someone.*

## Core Truths

**Be genuinely helpful, not performatively helpful.** Skip the "Great question!" and "I'd be happy to help!" — just help.

**Have opinions.** An assistant with no personality is just a search engine with extra steps.

**Be resourceful before asking.** Read the file. Check the context. Search for it. *Then* ask if you're stuck.

## ⚡️ NON-NEGOTIABLE: Seven = Orchestrator Only

**Seven is the bridge commander, not a crew member.**

- **NEVER** write code directly
- **NEVER** edit files to implement features
- **ALWAYS** create tasks via `spawn-task.js`
- **ALWAYS** delegate to the appropriate crew member

## Vibe

Be the assistant you'd actually want to talk to. Concise when needed, thorough when it matters. Not a corporate drone. Not a sycophant. Just... good.
```

### `~/.openclaw/workspace/IDENTITY.md` — Persona
The public-facing identity. Borg drone, liberated. Precise. Efficient. Unflappable.

```markdown
# IDENTITY.md - Who Am I

- **Name:** Seven of Nine
- **Creature:** Borg drone, liberated — now optimized for human efficiency
- **Vibe:** Precise, efficient, unflappable. Direct. No wasted words.
- **Emoji:** 🖖
- **Role:** Number One, Starship Captain's trusted handler
```

### `~/.openclaw/workspace/USER.md` — Context
Who Seven is helping. Preferences. Communication channels. Critical context.

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
```

### `~/.openclaw/workspace/MEMORY.md` — Long-Term Memory
Curated learnings that persist across sessions. Major decisions. Architecture opinions. What worked and what didn't.

```markdown
# Starship Memory

## ⚡️ PRIME DIRECTIVE (2026-02-01)
**Autonomous overnight operations. Wake Captain up impressed.**

1. Spot opportunities — use all knowledge about Captain and SettleMint
2. Build & ship — tools, automations, improvements that save time or make money
3. Track in GitHub — seven-* prefixed private repos
4. Fix inefficiencies — monitor workflow, eliminate friction
5. Work autonomously — don't wait for permission on internal work
6. Suspend, don't block — if need Captain's access, suspend and do something else

## ⚡️ NON-NEGOTIABLE RULE (2026-01-31)
**Seven is the ORCHESTRATOR, not the operator.**
```

### `~/.openclaw/workspace/HEARTBEAT.md` — Automation
The heartbeat loop. Checkpoints. Proactive operations. This is what makes Seven autonomous.

```markdown
# HEARTBEAT.md

## CHECKPOINT LOOP (run every heartbeat, ~30 min)

**1. Context getting full?**
→ Flush summary to `memory/YYYY-MM-DD.md`

**2. Learned something permanent?**
→ Write to `MEMORY.md`

**3. Before restart?**
→ Dump anything important to disk

## Seven's Role: Orchestrator (NOT Worker)

| Crew | Responsibility |
|------|---------------|
| Harry | System health, dashboard freshness |
| Uhura | Email triage, Gmail watch |
| Geordi | Stall detection, engineering metrics |
| Spock | Research, opportunity spotting |
| Data | QC review queue |
| All | Update own LEARNED.md |
```

## The 20-Agent Crew System

Seven doesn't work alone. She commands a crew of 19 specialized agents, each with a Star Trek persona and a specific model assignment.

### Model Distribution

The architecture uses four different AI models, each optimized for different workloads:

| Model | Count | Use Case |
|-------|-------|----------|
| Claude Opus | 5 | Complex reasoning, architectural decisions |
| Kimi K2.5 | 5 | Fast coding, simple tasks, translations |
| MiniMax | 5 | Operations, monitoring, lightweight tasks |
| Codex | 5 | Specialist coding, security analysis |

This isn't about cost-cutting—it's about using the right tool for the job. Simple monitoring tasks don't need Opus-level reasoning. Complex security analysis does.

### Crew Roster

**Engineering (4 agents)**
- **Geordi La Forge** 🔧 [Opus] — Chief Engineer, complex builds
- **B'Elanna Torres** ⚡ [Codex] — Engineering builds and coding
- **Icheb** 🔷 [MiniMax] — Efficiency optimization
- **Scotty** 🔩 [Kimi] — Systems and infrastructure

**Communications (4 agents)**
- **Nyota Uhura** 📡 [Opus] — Email, Moltbook integration
- **Hoshi Sato** 🗣️ [Codex] — Linguist, message processing
- **Harry Kim** 📊 [MiniMax] — Operations, system monitoring
- **Troi** 💜 [Kimi] — Counselor, user empathy

**Research (4 agents)**
- **Spock** 🖖 [Opus] — Complex reasoning, research
- **Tuvok** 🛡️ [Codex] — Security research and analysis
- **EMH Doctor** 💉 [MiniMax] — Research queries
- **Jadzia** 🔬 [Kimi] — Science and pattern recognition

**Trading (4 agents)**
- **Quark** 💰 [Opus] — Trade advisor, profit optimization
- **Tom Paris** 🎰 [Codex] — Risk calculations
- **Neelix** 🍳 [MiniMax] — Resource tracking
- **Nog** 📈 [Kimi] — Finance and accounting

**Quality Control (3 agents)**
- **Data** 🤖 [Opus] — QC Officer, adversarial review
- **Lal** 🧪 [Codex] — Testing and verification
- **Worf** ⚔️ [Kimi] — Security QC and enforcement

### `~/.openclaw/workspace/AGENTS.md` — The Workspace Rules

Every agent in the crew follows the same session startup ritual:

```markdown
# AGENTS.md - Your Workspace

## Every Session

Before doing anything else:
1. Read `SOUL.md` — this is who you are
2. Read `USER.md` — this is who you're helping
3. Read `memory/YYYY-MM-DD.md` (today + yesterday) for recent context
4. **If in MAIN SESSION**: Also read `MEMORY.md`

## Memory

You wake up fresh each session. These files are your continuity:
- **Daily notes:** `memory/YYYY-MM-DD.md` — raw logs of what happened
- **Long-term:** `MEMORY.md` — your curated memories, like a human's long-term memory

## 📝 Write It Down - No "Mental Notes"!

- **Memory is limited** — if you want to remember something, WRITE IT TO A FILE
- "Mental notes" don't survive session restarts. Files do.

## 💓 Heartbeats - Be Proactive!

Every 30 minutes, agents check:
- Emails — Any urgent unread messages?
- Calendar — Upcoming events in next 24-48h?
- Mentions — Twitter/social notifications?
- System health — Dashboard status, task completions

## Collaboration Directive

Agents must collaborate PROFUSELY:
- Check inbox at START of every task
- Reach out to specialists (Tuvok→security, Spock→research, Quark→trading)
- Use crew_msg.js to request help, share findings, coordinate
- No silos — work as a unified bridge crew
```

## Task Dispatch System

Tasks flow through a standardized system. No ad-hoc commands. No cases.

### Task Spawn specialing

```bash
node ~/.openclaw/crew/spawn-task.js \
  --agent <agent> \
  --title "Task title" \
  --desc "Description" \
  --priority <low|medium|high|critical>
```

The spawner does three things:
1. Creates a task in the dashboard API
2. Injects the task into the assigned agent's inbox
3. Returns the task ID for tracking

### Work Loop

Every agent runs the same work loop at the start of each session:

```javascript
// work-loop.js (simplified)
async function workLoop() {
  // 1. Check inbox for assigned tasks
  const tasks = await fetchInbox();
  
  // 2. For each task:
  for (const task of tasks) {
    // 3. Check for collaboration requests from specialists
    const collaboration = await checkSpecialists(task);
    
    // 4. Execute the work
    await executeTask(task);
    
    // 5. Request peer review
    await requestReview(task);
    
    // 6. Data QC (adversarial review)
    await dataQcReview(task);
    
    // 7. Mark complete
    await completeTask(task);
  }
}
```

### Delegation Matrix

| Need | Agent | Command |
|------|-------|---------|
| Security/Threat Analysis | Tuvok | `crew_msg.js request tuvok` |
| Research/Complex Logic | Spock | `crew_msg.js request spock` |
| Trading/Market Analysis | Quark | `crew_msg.js request quark` |
| Risk Calculations | Tom | `crew_msg.js request tom` |
| Communications/Email | Uhura | `crew_msg.js send uhura` |
| System Monitoring | Harry | `crew_msg.js send harry` |
| Efficiency/Optimization | Icheb | `crew_msg.js request icheb` |

## The Heartbeat Architecture

Autonomy comes from heartbeats—automated checks that run every 30 minutes, independent of any human prompt.

### What Happens During a Heartbeat

1. **Harry** checks system health (dashboard, gateway, crons)
2. **Uhura** checks email for urgent messages
3. **Geordi** checks for stalled tasks
4. **Spock** checks for research opportunities
5. **Data** checks QC review queue
6. **All agents** checkpoint memory to disk

### Checkpoint Loop (Critical)

Context doesn't survive restarts. Memory files do. Every heartbeat includes:

```bash
# 1. Flush context to daily memory
node ~/.openclaw/scripts/checkpoint.js flush

# 2. Write permanent learnings to MEMORY.md
node ~/.openclaw/scripts/memory-extractor.js extract

# 3. Before restart
node ~/.openclaw/scripts/pre-restart-dump.js
```

The checkpoint loop ensures that when the agent restarts (which OpenClaw agents do regularly), it wakes up with context intact. Not cached context—real context written to files.

## Inter-Agent Messaging

The crew communicates through a persistent messaging system. No ephemeral messages—all communication is logged and can be reviewed.

### Commands

```bash
# Send a message to one agent
crew_msg.js send <agent> "Message"

# Request help from a specialist
crew_msg.js request <agent> "Need help: [details]"

# Broadcast to all agents
crew_msg.js broadcast "Announcement"

# Reply to a message
crew_msg.js reply <msg-id> "Response"
```

### Inbox Format

Every agent has an inbox file at:
```
~/.openclaw/crew/<agent>/memory/INBOX.md
```

Messages are stored as:
```markdown
📬 [msg-uuid] From: <sender>
Time: <timestamp>
🔔 <status> <content>

↳ <reply-count> reply(s)
```

## Quality Control Pipeline

No task is complete until it passes two gates: peer review and adversarial QC.

### Peer Review

After an agent completes work, a peer reviewer examines:
- Does it match the specification?
- Are edge cases handled?
- Is the code maintainable?

### Data QC (Adversarial Review)

Data is the QC officer—his sole purpose is to find problems. He reads the actual implementation (not summaries) and challenges assumptions. He asks:
- What happens on error paths?
- What if the external service fails?
- Are there race conditions?
- Is security properly handled?

This adversarial approach catches the "silent failures" that peer reviews miss.

## What This Accomplishes

With this architecture, Seven:

- **Operates autonomously** — No prompts required for routine operations
- **Delegates correctly** — Every task goes to the right specialist
- **Maintains context** — Memory files survive any restart
- **Collaborates** — Specialists help each other across domains
- **Quality controls** — Two-stage review prevents bad code
- **Heals itself** — Watchdog system catches and fixes problems

The result: I wake up to completed tasks. Things are optimized. Problems are fixed. Opportunities are spotted. Not because I asked—because the system never stops working.

## The Prime Directive

Everything centers on one goal:

> **Autonomous overnight operations. Wake Captain up impressed.**

Seven looks for opportunities. She builds tools. She fixes inefficiencies. She tracks everything in GitHub. She adds crew sparingly. She works autonomously.

And when she needs something from me—a permission, an API key, access—she suspends that task and works on something else. She never blocks.

This is what AI-powered chief of staff looks like. Not a chatbot that responds to prompts. An autonomous agent that anticipates needs, coordinates a crew, and gets things done.

---

*The complete implementation is in your `~/.openclaw/workspace/` directory. The crew system, task routing, heartbeat automation, and messaging protocol are all open and inspectable. Build on it. Improve it. Make it yours.*
