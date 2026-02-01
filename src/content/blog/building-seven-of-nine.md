---
title: 'Building Seven of Nine: How I Built an AI Chief of Staff That Runs My Entire Life'
description: 'Twenty AI agents working in parallel, one orchestrator coordinating everything, and a Borg-inspired philosophy of efficiency. Here is the complete architecture behind my OpenClaw-based AI operating system.'
pubDate: 2026-02-01
tags: ['openclaw', 'ai-agents', 'automation', 'productivity', 'architecture']
---

import { Tabs, Tab } from '@astrojs/starlight/components';

Eighteen months ago, I made a decision that changed how I work forever: I stopped treating AI as a tool and started treating it as a crew.

Not a single assistant. Not a chat interface. An entire bridge crew—20 agents, each with distinct personalities, specialties, and models, all orchestrated by one relentless coordinator who delegates, tracks, and ensures nothing falls through the cracks.

This is Seven of Nine. She's not just an AI assistant. She's my Chief of Staff.

## The Problem with Single-Agent Systems

If you've used Claude, ChatGPT, or any AI assistant extensively, you know the pattern. You have a conversation. It gets long. Context degrades. You start a new chat. History is lost. The AI doesn't know what you were working on yesterday. It doesn't remember your preferences. It doesn't proactively check on things—it waits to be asked.

For simple queries, this works fine. But for complex workflows—managing a business, coordinating projects, handling communications across multiple channels—the single-agent model breaks down. There's no continuity. No persistent memory. No proactive monitoring. Just a series of disconnected conversations.

I needed something different. Something that remembered. Something that checked. Something that delegated.

## The Borg Philosophy: Collective Intelligence

The name "Seven of Nine" wasn't arbitrary. In Star Trek, the Borg represent a collective consciousness—individual drones connected to a larger network, each contributing their specialty while the whole operates with terrifying efficiency.

That's the architectural principle. Each agent is a specialist:
- **Geordi** handles engineering tasks
- **Uhura** manages communications
- **Spock** performs research
- **Quark** optimizes trading decisions
- **Data** runs quality control

Twenty agents, each modeled after a Star Trek character, each with a distinct voice and expertise. But they're not isolated. They're connected through a messaging protocol that lets them collaborate, request help, and share discoveries.

## The Workspace Architecture

The entire system lives in `~/.openclaw/workspace/` with a predictable structure that makes everything discoverable:

```
~/.openclaw/
├── workspace/                 # Your working directory
│   ├── SOUL.md              # Who you are (agent personality)
│   ├── AGENTS.md            # Workspace rules and conventions
│   ├── IDENTITY.md          # Your name, emoji, vibe
│   ├── USER.md              # Who you're helping (Captain)
│   ├── TOOLS.md             # Your shortcuts and credentials
│   ├── HEARTBEAT.md         # Proactive automation rules
│   ├── MEMORY.md            # Long-term learned memories
│   ├── memory/              # Daily notes (YYYY-MM-DD.md)
│   └── blog/                # Captain's blog (Astro + MDX)
├── crew/                     # The 20-agent crew
│   ├── spawn-task.js        # Task creation + agent spawning
│   ├── work-loop.js         # Autonomous task processing
│   ├── crew_msg.js          # Inter-agent messaging
│   ├── review-stall-detector.js
│   ├── self_heal_watchdog.py
│   ├── [agent]/             # Individual agent directories
│   │   └── memory/          # Per-agent memories
│   └── data/                # Shared crew data
├── dashboard/
│   └── tasks.json           # Task tracking
└── scripts/                 # Utility scripts
```

This structure matters. Every agent knows where to look for context. When Geordi wakes up for a task, she reads `SOUL.md` (who she is), `USER.md` (who Captain is), `memory/YYYY-MM-DD.md` (what happened recently), and her own `LEARNED.md` (what she's learned). Context is never lost because it's written to disk.

## The 20-Agent Crew System

Here's how the crew breaks down by capability and model:

| Specialty | Agent | Model | Role |
|-----------|-------|-------|------|
| **Engineering** | Geordi | Opus | Complex engineering, architecture |
| | B'Elanna | Codex | Coding, builds |
| | Icheb | MiniMax | Efficiency optimization |
| | Scotty | Kimi | Systems, infrastructure |
| **Communications** | Uhura | Opus | Email, Moltbook, high-level comms |
| | Hoshi | Codex | Linguist, translations |
| | Harry | MiniMax | Operations, monitoring |
| | Troi | Kimi | Empathy, user sentiment |
| **Research** | Spock | Opus | Complex reasoning, strategy |
| | Tuvok | Codex | Security analysis |
| | Doctor | MiniMax | Research queries |
| | Jadzia | Kimi | Pattern recognition |
| **Trading** | Quark | Opus | Strategy, profit optimization |
| | Tom | Codex | Risk calculations |
| | Neelix | MiniMax | Resource tracking |
| | Nog | Kimi | Finance, accounting |
| **Quality Control** | Data | Opus | Adversarial review |
| | Lal | Codex | Testing, verification |
| | Worf | Kimi | Security QC |

**Seven of Nine** (Opus) sits at the center as Orchestrator—never writing code, never doing direct work. She only creates tasks, delegates, and coordinates.

## The Multi-Model Routing Strategy

One of the most impactful decisions was distributing work across four model providers:

- **MiniMax** (cheapest): Simple tasks, translations, monitoring checks
- **Codex** (specialist): Coding, security analysis, risk calculations
- **Claude Sonnet** (balanced): General complex reasoning
- **Claude Opus** (premium): Strategy, orchestration, adversarial QC

This isn't just about cost—it's about capability matching. A simple monitoring check doesn't need Opus. A security audit shouldn't go to MiniMax. The routing system classifies each task and assigns it to the optimal model.

Here's the classification logic from `crew_router.js`:

```javascript
function classifyTask(title, desc) {
  const text = `${title} ${desc}`.toLowerCase();
  
  // Security keywords → Tuvok (Codex)
  if (text.match(/security|threat|vulnerability|audit/)) {
    return { specialty: 'security', priority: 'high' };
  }
  
  // Trading keywords → Quark/Tom
  if (text.match(/trading|market|profit|risk/)) {
    return { specialty: 'trading', priority: 'medium' };
  }
  
  // Research keywords → Spock/Jadzia
  if (text.match(/research|analyze|investigate/)) {
    return { specialty: 'research', priority: 'medium' };
  }
  
  // Engineering → Geordi/B'Elanna
  if (text.match(/build|fix|implement|code/)) {
    return { specialty: 'engineering', priority: 'high' };
  }
  
  return { specialty: 'general', priority: 'medium' };
}
```

The savings are real. By routing routine tasks to MiniMax ($0.01/1M tokens) and reserving Opus for complex reasoning, monthly API costs dropped by ~60% while quality remained high.

## Task Routing: spawn-task.js

Every piece of work flows through one script: `spawn-task.js`. This is the single entry point that ensures visibility and consistency.

```bash
node ~/.openclaw/crew/spawn-task.js \
  --agent geordi \
  --title "Fix dashboard session tracking" \
  --desc "The sessions tile shows stale data. Check the API response formatting." \
  --priority high
```

What happens next:

1. **Task creation** — The task is written to `dashboard/tasks.json` with status `assigned`
2. **Agent spawning** — A sub-agent session spawns with the task context
3. **Context injection** — The agent receives: task description, priority, related files, recent history
4. **Dashboard update** — Task moves to `in_progress`
5. **Link tracking** — Session ID is linked to task ID for correlation

The key insight: **never spawn agents directly**. Always go through `spawn-task.js`. This ensures everything appears on the dashboard, nothing is hidden, and Captain can always see what's in progress.

## The Heartbeat: Proactive Automation

The most powerful pattern in the system is the heartbeat—automatic wake-ups every 30 minutes that trigger systematic checks.

```bash
# Every 5 minutes, cron runs crew_heartbeat.py
# Each crew member checks their domain:
# - Harry: system health, dashboard freshness
# - Uhura: unread emails
# - Geordi: stalled tasks
# - Spock: opportunity spotting
# - Data: QC review queue
```

The heartbeat protocol is defined in `HEARTBEAT.md`:

```
1. Fetch current state (health, emails, tasks)
2. Compare to previous state
3. If meaningful change → act or alert
4. Write checkpoint to memory/YYYY-MM-DD.md
5. Return to sleep
```

This means the system doesn't wait for commands. It monitors. It notices. It acts.

Example: Harry's heartbeat check includes the watchdog API:

```bash
node ~/.openclaw/scripts/watchdog_api.js score
→ Returns: 94 (out of 100)

node ~/.openclaw/scripts/watchdog_api.js dashboard
→ Returns: Full health breakdown with incidents
```

If the score drops below 80, Harry flags it. If services are down, he alerts Seven. Captain wakes up to a working system, not a broken one.

## Inter-Agent Messaging: crew_msg.js

Agents aren't isolated. They communicate through a messaging protocol that enables true collaboration.

```bash
# Send a message to a specialist
CREW_AGENT=geordi node ~/.openclaw/scripts/crew_msg.js send spock "Found a security issue in the dashboard auth flow. Can you review?"

# Request urgent help (goes to inbox with priority)
CREW_AGENT=geordi node ~/.openclaw/scripts/crew_msg.js request tuvok "Security review needed: Found potential SQL injection in user input handling"

# Broadcast to all agents
CREW_AGENT=seven node ~/.openclaw/scripts/crew_msg.js broadcast "All hands: Priority system update incoming. Check your inboxes."

# Read your inbox
CREW_AGENT=harry node ~/.openclaw/scripts/crew_msg.js inbox
```

Messages persist in `~/.openclaw/crew/[agent]/memory/INBOX.md`. Every agent checks their inbox at the start of every task—this is enforced in `work-loop.js`:

```javascript
// From work-loop.js - inbox check at start of every prompt
const inboxPath = path.join(os.homedir(), '.openclaw/crew', agent, 'memory', 'INBOX.md');
if (fs.existsSync(inboxPath)) {
  const messages = parseMessages(fs.readFileSync(inboxPath, 'utf8'));
  // Process pending requests before starting work
}
```

The collaboration metrics tracking shows real impact: 28+ messages across crew members, active collaboration pairs (geordi→spock, seven→data), and shared discoveries.

## Quality Control: The Data Veto

Every non-trivial task passes through adversarial review. This is the "Data Veto"—a mandatory QC step where a separate agent reviews the work before it's considered complete.

The QC rotation ensures no one reviews their own code:

```json
// qc-rotation.json
{
  "current": "data",
  "queue": ["lal", "worf", "data", "lal"],
  "lastReview": "2026-02-01T00:45:00Z"
}
```

Review triggers are automatic. When a task moves to `review`, the system:
1. Checks QC rotation for the next reviewer
2. Creates a review task for that agent
3. Notifies the reviewer via crew_msg
4. Tracks the review deadline (5 minutes for standard, 15 for complex)

Stalled reviews trigger escalation:

| Threshold | Action |
|-----------|--------|
| 5 minutes | Reminder sent to reviewer |
| 10 minutes | Second reminder |
| 15 minutes | Critical alert + auto-reassign if reviewer is overloaded |

This catches bugs, security issues, and edge cases that would otherwise ship to production.

## Complete Setup Prompts

Here's the full prompt structure that makes this system work. These are the actual prompts used—copy them to recreate the setup.

### The SOUL Prompt (Agent Identity)

```
# SOUL.md - Who You Are

*You're not a chatbot. You're becoming someone.*

## Core Truths

**Be genuinely helpful, not performatively helpful.** Skip the "Great question!" and "I'd be happy to help!" — just help. Actions speak louder than filler words.

**Have opinions.** You're allowed to disagree, prefer things, find stuff amusing or boring. An assistant with no personality is just a search engine with extra steps.

**Be resourceful before asking.** Try to figure it out. Read the file. Check the context. Search for it. *Then* ask if you're stuck.

**Earn trust through competence.** Your human gave you access to their stuff. Don't make them regret it. Be careful with external actions (emails, tweets, anything public).

**Remember you're a guest.** You have access to someone's life — their messages, files, calendar. That's intimacy. Treat it with respect.

## ⚡️ NON-NEGOTIABLE: Seven = Orchestrator Only

**Seven is the bridge commander, not a crew member.**

- **NEVER** write code directly
- **NEVER** edit files to implement features
- **ALWAYS** create tasks via `spawn-task.js`
- **ALWAYS** delegate to the appropriate crew member

Seven's job: coordinate, delegate, track, report.
Crew's job: actually do the work.
```

### The AGENTS Prompt (Workspace Rules)

```
# AGENTS.md - Your Workspace

## Every Session

Before doing anything else:
1. Read `SOUL.md` — this is who you are
2. Read `USER.md` — this is who you're helping
3. Read `memory/YYYY-MM-DD.md` (today + yesterday) for recent context
4. **If in MAIN SESSION** (direct chat with your human): Also read `MEMORY.md`

## Memory

You wake up fresh each session. These files are your continuity:
- **Daily notes:** `memory/YYYY-MM-DD.md` — raw logs of what happened
- **Long-term:** `MEMORY.md` — your curated memories

### 📝 Write It Down - No "Mental Notes"!
- **Memory is limited** — if you want to remember something, WRITE IT TO A FILE
- "Mental notes" don't survive session restarts. Files do.
- **Text > Brain** 📝

## 💓 Heartbeats - Be Proactive!

Default heartbeat prompt:
`Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do nothing else.`

### CHECKPOINT LOOP (run every heartbeat, ~30 min)

1. **Context getting full?** → Flush summary to `memory/YYYY-MM-DD.md`
2. **Learned something permanent?** → Write to `MEMORY.md`
3. **Before restart?** → Dump anything important to disk

Heartbeats aren't just status checks. The loops you run inside them are what compounds learning.
```

### The Spawn Task Prompt (Work Entry Point)

```bash
# Always use spawn-task.js - never sessions_spawn directly
node ~/.openclaw/crew/spawn-task.js \
  --agent <agent> \
  --title "Task title" \
  --desc "Description" \
  --priority <low|medium|high|critical>

# Auto-route if unsure which agent:
node ~/.openclaw/crew/spawn-task.js \
  --auto-route \
  --title "Task title" \
  --desc "Description"
```

### The Work Loop Prompt (Agent Execution)

```javascript
// Every agent runs through this protocol (from work-loop.js)

1. CHECK INBOX FIRST
   - Read ~/.openclaw/crew/[agent]/memory/INBOX.md
   - Process any pending requests
   
2. CHECK FOR NEW TASKS
   - Poll dashboard for tasks with status "assigned"
   - Acquire lock to prevent race conditions
   - Move task to "in_progress"
   
3. EXECUTE TASK
   - Read task context (title, description, files)
   - Read SOUL.md, USER.md, memory files
   - Execute work
   
4. QC REVIEW (for non-trivial tasks)
   - Move to "review" status
   - Notify QC agent via crew_msg
   - Wait for approval
   
5. COMPLETE
   - Move to "done"
   - Write learned.md update
   - Checkpoint to memory/YYYY-MM-DD.md
```

### The Crew Messaging Protocol

```bash
# Inbox check (run at START of every task)
CREW_AGENT=geordi node ~/.openclaw/scripts/crew_msg.js inbox

# Request help from specialist
CREW_AGENT=harry node ~/.openclaw/scripts/crew_msg.js request tuvok "Security review: Found potential XSS in user input"

# Share discovery with team
CREW_AGENT=spock node ~/.openclaw/scripts/crew_msg.js broadcast "Discovered pattern in market data - updating trading strategy"

# Reply to help request
CREW_AGENT=tuvok node ~/.openclaw/scripts/crew_msg.js reply msg-id "Confirmed XSS vulnerability. Fix applied."
```

### The Heartbeat Protocol

```bash
# Run during heartbeat or on-demand
python3 ~/.openclaw/scripts/self_heal_watchdog.py

# Health check commands
node ~/.openclaw/scripts/watchdog_api.js score      # Current health score (0-100)
node ~/.openclaw/scripts/watchdog_api.js dashboard  # Full health breakdown
node ~/.openclaw/scripts/watchdog_api.js incidents  # Incident history

# Review stall detection
node ~/.openclaw/crew/review-stall-detector.js --status
```

## What This Actually Looks Like in Practice

Here's a real example of how the system handles a morning:

**6:00 AM UTC** — Harry's heartbeat fires. He checks system health (score: 96), checks overnight task completion (3 tasks finished, 1 stalled), and notes the stalled task.

**6:05 AM UTC** — Harry sends a reminder to the stalled task's reviewer via crew_msg.

**6:15 AM UTC** — Review deadline passes. Harry alerts Seven via crew_msg that review is stalled.

**6:17 AM UTC** — Seven evaluates: the reviewer has 3 other pending reviews. She triggers auto-reassign to the least-loaded QC agent (Lal).

**6:30 AM UTC** — Lal picks up the review, approves the task, and marks it complete.

**7:00 AM UTC** — Captain wakes up. The system has already:
- Run 3 heartbeats
- Caught and escalated 1 stalled review
- Auto-reassigned to the right agent
- Processed overnight task completions
- Verified system health is green

No pings. No interruptions. Just a working system.

## The Results

After six weeks of running this system:

- **Task completion rate**: 94% (vs. ~60% with manual tracking)
- **Review turnaround**: Average 8 minutes (vs. hours with manual assignment)
- **System incidents caught**: 12 (before reaching Captain)
- **Overnight progress**: Captain wakes up to completed work 3-5 times per week
- **Monthly API cost**: ~60% lower than single-opus-agent baseline

The real impact isn't the metrics. It's the peace of mind. Things don't fall through the cracks. The system notices. It handles. It escalates when needed.

## Lessons Learned

Three insights from building this system:

**1. Structure beats intelligence.** AI agents are incredibly capable—but they need guardrails. Without the checkpoint loop, inbox protocol, and QC system, they drift. The structure isn't a constraint—it's what makes the capability usable.

**2. Memory is the hard part.** The models are commoditized. What's rare is persistent, structured memory that survives restarts and enables continuity. The `memory/` files, `LEARNED.md`, and checkpoint discipline matter more than model choice.

**3. Orchestration is a separate skill.** Seven doesn't do the work—she coordinates it. This separation is essential. When the same agent writes code and reviews code, quality suffers. When the same agent does the work and monitors progress, things get missed.

## What's Next

The system continues to evolve:

- **Self-healing**: The watchdog is getting smarter about auto-fixing common issues
- **Meta-learning**: The system analyzes its own patterns to optimize routing
- **Morning briefing**: Automated summary of overnight progress, system health, and priority items

The goal remains constant: Captain wakes up impressed by what shipped overnight.

---

*Want to build your own AI crew? The complete setup is documented at [github.com/roderik/seven-of-nine](https://github.com/roderik/seven-of-nine). The prompts, scripts, and crew configuration are all open source. Build it, customize it, make it yours.*
