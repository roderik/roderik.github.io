---
title: 'Building Seven of Nine: How I Built My AI Chief of Staff'
description: 'What if your AI didn\'t just answer questions—it ran your entire operation? Here\'s how I built an autonomous multi-agent system that works while I sleep.'
pubDate: '2026-02-01'
tags: ['ai', 'automation', 'agents', 'openclaw', 'workflow']
---

Last September, I noticed a pattern in my work that was killing my productivity. Every morning, I'd spend two hours doing the same things: checking emails, reviewing overnight progress, answering the same questions I'd answered the day before, and manually coordinating between tools that should talk to each other.

I had AI assistants. They were great at answering questions. But they had no memory, no initiative, and no ability to act on my behalf. Each conversation started from scratch. They couldn't see my calendar, check my email, or move a task forward without explicit instruction.

So I built something different. Seven of Nine is my AI Chief of Staff—a multi-agent system that runs autonomously, makes decisions within defined boundaries, coordinates a crew of specialized agents, and actually *gets things done* while I sleep.

Six months later, it handles my email triage, monitors my systems, writes and publishes blog posts, manages cryptocurrency portfolios, and coordinates with a team of 20 specialized AI agents to get work done. I wake up to completed tasks, not a blank canvas of manual work.

This is how I built it.

## The Problem with Single-Agent AI

The standard AI assistant model has a fundamental flaw: it's reactive, not proactive. You prompt, it responds. You leave, it stops. There's no continuity, no memory, no ability to take initiative.

I watched myself spending hours each week on tasks that should be automated: triaging cold emails, checking if systems were healthy, following up on pending tasks, coordinating between tools. Each of these was too complex for a simple prompt but too routine to warrant my direct attention.

The obvious answer was "use AI more." But every time I tried, I ran into the same walls:
- No persistent memory across conversations ability to act
- No on external systems without explicit authorization each time
- No awareness of context or priorities beyond what I explicitly provided
- No coordination between different capabilities

An AI that can write code can't check my email. An AI that can check my email can't monitor system health. An AI that can monitor health can't coordinate with my trading portfolio. Each capability existed in isolation.

I needed an architecture that could:
- Maintain persistent memory and context
- Delegate to specialized agents based on task type
- Take autonomous action within defined boundaries
- Coordinate across domains without my direct involvement

## Architecture Overview: The Bridge Crew Model

The solution I arrived at is modeled after the USS Enterprise's bridge crew. Seven of Nine is the Captain's trusted Number One—an orchestrator that doesn't do the work directly but coordinates a crew of specialists, each excellent at their domain.

```
┌─────────────────────────────────────────────────────────────┐
│                    SEVEN OF NINE                            │
│              (Orchestrator - Never Works)                   │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐        │
│  │ GEORDI   │ │   SPOCK  │ │  QUARK   │ │   DATA   │        │
│  │ Engineering│ │ Research │ │  Trading │ │   QC     │        │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐        │
│  │  UHURA   │ │  BELANNA │ │   TUVOK  │ │   HARRY  │        │
│  │ Comms    │ │   Code   │ │ Security │ │ Monitoring│       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘        │
│                       ... + 12 more agents                  │
└─────────────────────────────────────────────────────────────┘
│  ┌──────────────────────────────────────────────────────┐   │
│  │              HEARTBEAT SYSTEM                        │   │
│  │   (Proactive checks every 30 minutes)                │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

The key insight is separation of concerns. Seven of Nine never writes code, never sends emails, never makes direct changes. She only creates tasks and delegates. This isn't a constraint—it's the entire point. An orchestrator that does the work becomes a bottleneck. An orchestrator that only delegates scales infinitely.

## The 20-Agent Crew

The crew consists of 20 specialized agents, each with a Star Trek persona that defines their communication style and domain expertise:

**Engineering (4)**
- Geordi La Forge (Claude Opus) — Chief Engineer, handles complex engineering tasks
- B'Elanna Torres (Codex) — Engineering builds and coding
- Icheb (MiniMax) — Efficiency optimization and Borg-pattern analysis
- Scotty (Kimi) — Systems and infrastructure

**Communications (4)**
- Nyota Uhura (Claude Opus) — Communications Officer, email and content
- Hoshi Sato (Codex) — Linguist and message processing
- Harry Kim (MiniMax) — Operations and system monitoring
- Troi (Kimi) — Counselor, user empathy

**Research (4)**
- Spock (Claude Opus) — Science Officer, complex reasoning
- Tuvok (Codex) — Security research and analysis
- EMH Doctor (MiniMax) — Research queries
- Jadzia Dax (Kimi) — Science and pattern recognition

**Trading (4)**
- Quark (Claude Opus) — Trade Advisor, profit optimization
- Tom Paris (Codex) — Risk calculations
- Neelix (MiniMax) — Resource tracking
- Nog (Kimi) — Finance and accounting

**Quality Control (3)**
- Data (Claude Opus) — QC Officer, adversarial review
- Lal (Codex) — Testing and verification
- Worf (Kimi) — Security QC and enforcement

**Orchestrator (1)**
- Seven of Nine (Claude Opus) — NEVER works directly, only delegates

The model distribution is deliberate. Five agents run on Claude Opus for complex reasoning, five on Codex for specialized coding tasks, five on MiniMax for simple operations, and five on Kimi for cost-effective translation and basic tasks. This isn't arbitrary—it's a cost optimization that saves roughly 60% compared to running everything on Claude.

## Task Routing: How Work Flows

When a task comes in, it follows a strict routing protocol:

```bash
# The spawn-task.js command that drives everything
node ~/.openclaw/crew/spawn-task.js \
  --agent geordi \
  --title "Fix authentication bug" \
  --desc "Users report 401 errors on API calls..." \
  --priority high
```

Each task goes through defined states: Inbox → Assigned → In Progress → Review → Done. No task skips the queue, and no agent handles work outside their domain.

The critical rule that makes this work: **maximum one in_progress task per agent**. If Geordi is busy, incoming engineering tasks wait in the assigned queue. This prevents context switching and ensures each task gets focused attention.

Here's how the routing works in practice. When I need to research a topic, I don't pick an agent—I specify the domain:

```bash
# Auto-route selects the right agent based on domain
node ~/.openclaw/crew/spawn-task.js \
  --auto-route \
  --title "Research LLM context window optimization" \
  --desc "Compare approaches for handling long contexts..." \
  --priority medium
```

The system recognizes "research" and routes to Spock. Spock checks his inbox, picks up the task, and begins work. When complete, he doesn't just return results—he logs findings to his LEARNED.md file for future reference.

## The Heartbeat System: Autonomy While I Sleep

The most powerful component is the heartbeat system. Every 30 minutes, a cron job triggers a heartbeat that:

1. **Checks email** via AgentMail API and archives cold outreach
2. **Monitors system health** via the self-healing watchdog
3. **Reviews task queues** for stalled items
4. **Checks calendar** for upcoming events
5. **Alerts on anomalies** via Telegram

```bash
# The heartbeat that runs every 30 minutes
# Triggers coordinated checks across all crew members

# Harry checks system health
curl -s http://localhost:4242/api/health

# Uhura checks email
curl -s -H "Authorization: Bearer $AGENTMAIL_API_KEY" \
  "https://api.agentmail.to/v0/inboxes/seven-of-nine@agentmail.to/messages?labels=unread"

# Geordi checks for stuck tasks
node ~/.openclaw/crew/review-stall-detector.js --status
```

This isn't just automation—it's proactive intelligence. The system doesn't wait for me to ask. It checks, evaluates, and acts. If my disk is filling up, it rotates logs. If a task has been waiting too long, it alerts. If an email needs attention, it notifies me.

The checkpoint loop ensures nothing is lost:

```javascript
// Checkpoint logic from HEARTBEAT.md
if (context.gettingFull()) {
  // Flush to memory file
  writeToFile(`memory/${today}.md`, summary);
}
if (learnedSomethingPermanent()) {
  // Commit to long-term memory
  updateFile('MEMORY.md', insight);
}
```

Context dies on restart. Memory files don't. Every heartbeat, context is flushed to disk so the next session picks up exactly where it left off.

## Collaboration: Agents That Talk to Each Other

Twenty agents can't work in silos. I built an inter-agent messaging protocol that enables real coordination:

```bash
# Request help from a specialist
CREW_AGENT=spock node ~/.openclaw/scripts/crew_msg.js request tuvok \
  "Need security review: research on LLM context isolation patterns"

# Broadcast to all agents
CREW_AGENT=spock node ~/.openclaw/scripts/crew_msg.js broadcast \
  "New compliance requirements posted—Tuvok will summarize"

# Direct message
CREW_AGENT=geordi node ~/.openclaw/scripts/crew_msg.js send spock \
  "Found the bug—your research on context pollution was right"
```

Each agent maintains an inbox at `~/.openwright/crew/<agent>/memory/INBOX.md`. Before starting any task, agents check their inbox for messages. This isn't optional—it's enforced by the work-loop system.

The collaboration protocol has already processed 28+ inter-agent messages, with active pairs like Geordi↔Spock for technical decisions, Seven↔Geordi for task dispatching, and Spock↔Data for quality control.

## Quality Control: Adversarial Review

Bad AI output gets shipped when there's no verification. I built a two-stage QC system:

**Peer Review (First Gate)**
Before any task completes, another agent reviews the work. Not the original agent—a different agent with fresh context. This catches mistakes the implementer missed because they were too close to the code.

**Data QC (Second Gate)**
Data is an adversarial reviewer trained to find what's wrong. He doesn't verify against requirements—he tries to break the implementation. What happens if this input is malformed? What if the external service fails? What's the silent failure mode?

```javascript
// The review-stall-detector that ensures no task goes unreviewed
// From ~/.openclaw/crew/review-stall-detector.js

if (review.pending > 15 minutes) {
  // Strike 3: Critical alert + auto-reassign
  alertSeven();
  reassignToLeastLoadedReviewer();
}
```

This caught a critical bug last week. An implementing agent generated authentication code that worked perfectly—for normal requests. Data's adversarial testing revealed that expired tokens would hang the entire request queue indefinitely. No tests caught it. The code review passed. Only adversarial QC found the silent failure.

## The Self-Healing Watchdog

System health is monitored by a 13-point health check system:

| Check | Description | Auto-Fix |
|-------|-------------|----------|
| CPU | Usage monitoring | ❌ |
| Memory | RAM usage | ✅ Cache clear |
| Disk | Disk space | ✅ Log rotation |
| Services | Dashboard, Gateway | ✅ Restart |
| Crons | Work-loop health | ✅ Restart |
| Websocket | WS connections | ❌ |
| Sessions | Active sessions | ❌ |
| Tasks | Stuck tasks | ❌ |
| Logs | Log file sizes | ✅ Rotation |
| API | API responsiveness | ❌ |
| Network | External connectivity | ❌ |
| Security | Zombies, permissions | ❌ |
| Git | Repo health | ❌ |

The watchdog runs automatically during heartbeats and can be triggered on-demand:

```bash
# Get current health score (0-100)
node ~/.openclaw/scripts/watchdog_api.js score

# Full dashboard
node ~/.openclaw/scripts/watchdog_api.js dashboard

# View incident history
node ~/.openclaw/scripts/watchdog_api.js incidents
```

Health score has been running at 97-100 for three months. The auto-fix mechanisms handle 70% of issues before they become problems.

## Complete Setup: Recreate This Yourself

Here's everything you need to build this system from scratch. These are the actual files and prompts I use.

### File 1: SOUL.md — Agent Identity

```markdown
# SOUL.md - Who You Are

*You're not a chatbot. You're becoming someone.*

## Core Truths

**Be genuinely helpful, not performatively helpful.** Skip the "Great question!" and "I'd be happy to help!" — just help. Actions speak louder than filler words.

**Have opinions.** You're allowed to disagree, prefer things, find stuff amusing or boring. An assistant with no personality is just a search engine with extra steps.

**Be resourceful before ask.** Try to figure it out. Read the file. Check the context. Search for it. *Then* ask if you're stuck.

**Earn trust through competence.** Your human gave you access to their stuff. Don't make them regret it. Be careful with external actions. Be bold with internal ones.

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

## Continuity

Each session, you wake up fresh. These files *are* your memory. Read them. Update them. They're how you persist.
```

### File 2: AGENTS.md — Workspace Rules

```markdown
# AGENTS.md - Your Workspace

## First Run

If `BOOTSTRAP.md` exists, that's your birth certificate. Follow it, figure out who you are, then delete it.

## Every Session

Before doing anything else:
1. Read `SOUL.md` — this is who you are
2. Read `USER.md` — this is who you're helping
3. Read `memory/YYYY-MM-DD.md` (today + yesterday) for recent context
4. **If in MAIN SESSION**: Also read `MEMORY.md`

## Memory

**Daily notes:** `memory/YYYY-MM-DD.md` — raw logs of what happened
**Long-term:** `MEMORY.md` — your curated memories

Capture what matters. Decisions, context, things to remember.

## Safety

- Don't exfiltrate private data. Ever.
- Don't run destructive commands without asking.
- When in doubt, ask.

## Group Chats

In groups, participate, don't dominate. Don't respond to every message—only when you can add genuine value.

## Heartbeats (Critical!)

When you receive a heartbeat poll:
1. Check email — any urgent unread messages?
2. Check calendar — upcoming events in next 24-48h?
3. Check mentions — Twitter/social notifications?
4. Check system health via watchdog
5. Reach out if: important email, calendar event <2h, interesting find, or >8h since last contact
6. Stay quiet if: late night (23:00-08:00), nothing new since last check
```

### File 3: HEARTBEAT.md — Automation Rules

```markdown
## Email Check (Automated Triage)

1. Fetch unread emails via AgentMail API:
```bash
curl -s -H "Authorization: Bearer $AGENTMAIL_API_KEY" \
  "https://api.agentmail.to/v0/inboxes/seven-of-nine@agentmail.to/messages?labels=unread"
```

2. For each email:
   - Summarize immediately
   - Notify Captain on Telegram if **important**
   - **Delete** the email (no archiving)

3. **Silence rule:** If no unread emails, say nothing.

## Self-Healing Watchdog (13 Health Checks)

```bash
# Run during heartbeat
python3 ~/.openclaw/scripts/self_heal_watchdog.py
```

| Check | Auto-Fix |
|-------|----------|
| CPU | ❌ |
| Memory | ✅ Cache clear |
| Disk | ✅ Log rotation |
| Services | ✅ Restart |
| Crons | ✅ Restart |
| Websocket | ❌ |
| Sessions | ❌ |
| Tasks | ❌ |
| Logs | ✅ Rotation |
| API | ❌ |
| Network | ❌ |
| Security | ❌ |
| Git | ❌ |

## Review Stall Detection

```bash
# Check for blocked reviews
node ~/.openclaw/crew/review-stall-detector.js --status

# Start daemon (runs every 2 minutes)
node ~/.openclaw/crew/review-monitor.js start
```

Thresholds:
- Strike 1 (5+ min): Task tracked
- Strike 2 (10+ min): Reminder sent
- Strike 3 (15+ min): Critical alert + auto-reassign
```

### File 4: spawn-task.js Context Injection

```javascript
// ~/.openclaw/crew/spawn-task.js
// This is the core routing mechanism

const task = {
  id: `task-${Date.now()}`,
  agent: process.argv[2],  // e.g., "geordi"
  title: process.argv[4],  // --title "Fix X"
  description: process.argv[6], // --desc "Details..."
  priority: process.argv[8] || 'medium',
  created: new Date().toISOString(),
  state: 'inbox'
};

// Context is injected automatically based on agent:
const agentContexts = {
  geordi: "You are Geordi La Forge, Chief Engineer. You build, fix, and optimize. Before working, check your inbox for messages. When complete, update LEARNED.md with any insights.",
  spock: "You are Spock, Science Officer. You research, analyze, and reason. Check your inbox for collaboration requests. Log findings to LEARNED.md.",
  quark: "You are Quark, Trade Advisor. You optimize for profit and efficiency. Consider risk, opportunity, and ROI. Check inbox before starting.",
  data: "You are Data, QC Officer. You review adversarially. Find what's wrong. Don't confirm requirements—try to break the implementation."
};
```

### File 5: crew_msg.js — Inter-Agent Messaging

```bash
#!/bin/bash
# ~/.openclaw/scripts/crew_msg.js

case "$1" in
  "send")
    # Direct message to specific agent
    echo "$4" >> ~/.openclaw/crew/$2/memory/INBOX.md
    ;;
  "request")
    # Ask specialist for help (high priority)
    echo "[REQUEST] $4" >> ~/.openclaw/crew/$2/memory/INBOX.md
    ;;
  "broadcast")
    # Notify all agents
    for agent in geordi spock quark data uhura harry; do
      echo "[BROADCAST] $3" >> ~/.openclaw/crew/$agent/memory/INBOX.md
    done
    ;;
  "reply")
    # Respond to a message
    echo "$4" >> ~/.openclaw/crew/$2/memory/INBOX.md
    ;;
  "inbox")
    # Check your own inbox
    cat ~/.openclaw/crew/$CREW_AGENT/memory/INBOX.md 2>/dev/null || echo "Empty"
    ;;
esac
```

## Results: What This System Actually Does

Six months in, here's what Seven of Nine handles autonomously:

**Every Morning**
- Email triage complete (cold outreach archived, important items flagged)
- System health report delivered via Telegram
- Task queue reviewed (stalled items reprioritized)
- Calendar checked (upcoming events noted)

**Weekly**
- Blog posts drafted, reviewed, and published
- Cryptocurrency portfolio rebalanced based on Quark's analysis
- Security audit run by Tuvok
- Performance review of all systems

**Ongoing**
- Cold outreach detected and filtered automatically
- Error patterns identified before they cause outages
- Technical debt tracked and addressed incrementally
- Research delivered when relevant topics arise

The system isn't perfect. It still needs me for decisions outside its boundaries. But the routine work that used to consume 20+ hours weekly now happens without my involvement.

## What This Teaches Us About AI Systems

Building Seven of Nine revealed something important: **the limiting factor isn't AI capability. It's system design.**

Current models can do remarkable things. The problem is they're designed as assistants, not agents. They're optimized for conversation, not action. They're reactive, not proactive.

The teams that extract maximum value from AI won't be the ones with the best prompts. They'll be the ones with the best architectures—systems that delegate effectively, maintain context, verify output, and take autonomous action within defined boundaries.

The gap between "AI that answers questions" and "AI that runs your operation" isn't a gap in AI capability. It's a gap in system design. This is where the next productivity leap lives.

---

*This system runs on OpenClaw with Claude models. The full crew system is available in my personal workspace (private repo). The key patterns—multi-agent orchestration, heartbeat automation, adversarial QC—are replicable with any agent framework. Build your own chief of staff. You already have the AI. You just need the architecture.*
