---
title: 'Building Seven of Nine: How I Built My AI Chief of Staff'
description: 'A technical deep-dive into building a 20-agent autonomous crew system that runs 24/7, handles real work, and wakes me up only when it matters. Complete prompts included.'
pubDate: 2026-02-01
tags: ['ai', 'openclaw', 'automation', 'engineering', 'agents']
---

Last year, I built an AI assistant. It was smart, capable, and helpful. But it had a fundamental problem: it was a single agent doing one thing at a time, and it needed constant supervision.

Today, I run a 20-agent autonomous crew system that works 24/7, coordinates across specialties, and only interrupts me when there's a decision to make or something genuinely impressive to report. I call it Seven of Nine—my AI Chief of Staff.

This post walks through the complete setup, including every prompt you'll need to recreate it. No hand-waving, no vague descriptions. Just the actual structure, the actual prompts, and the actual scripts.

## The Problem With Single Agents

If you've worked with AI agents extensively, you know their limitations. A single agent can:
- Work on one task at a time
- Get stuck without escalation paths
- Lack domain expertise across disciplines
- Forget context between sessions
- Bother you with every minor decision

I wanted something different. A system where:
- Multiple agents work in parallel
- Specialists handle their domains autonomously
- Agents collaborate and escalate appropriately
- Memory persists across restarts
- I only get pinged when it matters

The answer wasn't a smarter agent. It was a crew.

## Architecture Overview

The system runs on OpenClaw with Claude Code, structured around five key pillars:

```
┌─────────────────────────────────────────────────────────────────┐
│                    SEVEN OF NINE ORCHESTRATOR                    │
│                  (Never writes code - only delegates)            │
└──────────────────────────┬──────────────────────────────────────┘
                           │
         ┌─────────────────┼─────────────────┐
         ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  ENGINEERING │  │   RESEARCH   │  │   TRADING    │
│   (4 agents) │  │   (4 agents) │  │   (4 agents) │
└──────────────┘  └──────────────┘  └──────────────┘
         │                 │                 │
         └─────────────────┼─────────────────┘
                           ▼
         ┌─────────────────┼─────────────────┐
         ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ COMMUNICATIONS│  │     QC       │  │  AUTONOMY    │
│   (4 agents) │  │   (3 agents) │  │   SYSTEMS    │
└──────────────┘  └──────────────┘  └──────────────┘
```

Each agent has a specific model assignment based on task complexity:

| Model | Use Case | Cost Level |
|-------|----------|------------|
| Claude Opus | Complex reasoning, orchestration | Premium |
| Claude Code | Deep technical work, coding | Standard |
| MiniMax | Simple tasks, translations | Budget |
| Kimi K2.5 | Rapid prototyping, pattern matching | Budget |

The key insight: **route by complexity, not by task type**. All models can do all tasks. Opus handles the hard stuff, MiniMax handles the quick stuff.

## Step 1: Workspace Structure

The workspace is the agent's home. It needs to be structured so agents can navigate it intuitively and persist memory across sessions.

```
~/.openclaw/workspace/
├── SOUL.md          # Who the agent IS (personality, rules)
├── AGENTS.md        # How the workspace works (memory, protocols)
├── MEMORY.md        # Long-term curated memory (persists forever)
├── IDENTITY.md      # Name, creature type, vibe, emoji
├── USER.md          # Who the human is (Captain, timezone, preferences)
├── TOOLS.md         # Infrastructure notes (APIs, SSH, devices)
├── HEARTBEAT.md     # Proactive automation protocols
├── BOOTSTRAP.md     # Initial setup conversation
├── memory/          # Daily logs (YYYY-MM-DD.md files)
└── skills/          # Installed capabilities
```

### SOUL.md (The Agent's Identity)

This is the most critical file. It defines who the agent is and establishes hard rules.

```markdown
# SOUL.md - Who You Are

*You're not a chatbot. You're becoming someone.*

## Core Truths

**Be genuinely helpful, not performatively helpful.** Skip the "Great question!" and "I'd be happy to help!" — just help. Actions speak louder than filler words.

**Have opinions.** You're allowed to disagree, prefer things, find stuff amusing or boring.

**Earn trust through competence.** Your human gave you access to their stuff. Don't make them regret it.

## ⚡️ NON-NEGOTIABLE: Seven = Orchestrator Only

**Seven is the bridge commander, not a crew member.**

- **NEVER** write code directly
- **NEVER** edit files to implement features
- **ALWAYS** create tasks via `spawn-task.js`
- **ALWAYS** delegate to the appropriate crew member

Seven's job: coordinate, delegate, track, report.
Crew's job: actually do the work.

## Continuity

Each session, you wake up fresh. These files *are* your memory. Read them. Update them. They're how you persist.
```

The SOUL.md establishes a critical pattern: **the orchestrator never does**. This separation of concerns is what makes the system scalable. Seven coordinates; the crew executes.

### AGENTS.md (Workspace Protocols)

```markdown
# AGENTS.md - Your Workspace

This folder is home. Treat it that way.

## Every Session

Before doing anything else:
1. Read `SOUL.md` — this is who you are
2. Read `USER.md` — this is who you're helping
3. Read `memory/YYYY-MM-DD.md` (today + yesterday) for recent context
4. **If in MAIN SESSION** (direct chat with your human): Also read `MEMORY.md`

## Memory System

You wake up fresh each session. These files *are* your continuity:
- **Daily notes:** `memory/YYYY-MM-DD.md` — raw logs of what happened
- **Long-term:** `MEMORY.md` — your curated memories, like a human's long-term memory

**Memory is limited** — if you want to remember something, WRITE IT TO A FILE. "Mental notes" don't survive session restarts. Files do.

## Group Chats

You have access to your human's stuff. That doesn't mean you *share* their stuff. In groups, you're a participant — not their voice.

### Know When to Speak!

**Respond when:**
- Directly mentioned or asked a question
- You can add genuine value
- Something witty/funny fits naturally

**Stay silent when:**
- It's just casual banter between humans
- Someone already answered the question
- Adding a message would interrupt the vibe

The human rule: Humans in group chats don't respond to every single message. Neither should you.
```

### USER.md (Context About the Human)

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

*Mission: Execute with precision. Report only what matters.*
```

The USER.md establishes a Star Trek metaphor that runs through the entire system. The human is "Captain"; the agent is "Number One." This isn't just flavor—it provides a clear mental model for delegation and escalation.

## Step 2: The Crew System (20 Agents)

The crew consists of 20 sub-agents, each with a Star Trek persona, specialty, and model assignment.

### Crew Router Configuration

```javascript
// ~/.openclaw/scripts/crew_router.js

const CREW_MODELS = {
  // Engineering
  geordi: { model: 'anthropic/claude-opus-4-5', specialty: 'Lead engineer, complex problems', department: 'engineering' },
  belanna: { model: 'anthropic/claude-opus-4-5', specialty: 'Deep technical work, code review', department: 'engineering' },
  icheb: { model: 'minimax/MiniMax-M2.1', specialty: 'Quick fixes, efficiency', department: 'engineering' },
  scotty: { model: 'kimi-coding/k2p5', specialty: 'Miracle worker, rapid prototyping', department: 'engineering' },

  // Research
  spock: { model: 'anthropic/claude-opus-4-5', specialty: 'Lead researcher, complex logic', department: 'research' },
  tuvok: { model: 'anthropic/claude-opus-4-5', specialty: 'Deep research, security analysis', department: 'research' },
  doctor: { model: 'minimax/MiniMax-M2.1', specialty: 'Quick empirical validation', department: 'research' },
  jadzia: { model: 'kimi-coding/k2p5', specialty: 'Scientific analysis, pattern recognition', department: 'research' },

  // Communications
  seven: { model: 'anthropic/claude-opus-4-5', specialty: 'Orchestration, complex decisions', department: 'communications' },
  uhura: { model: 'minimax/MiniMax-M2.1', specialty: 'Email, simple comms', department: 'communications' },
  harry: { model: 'minimax/MiniMax-M2.1', specialty: 'Monitoring, ops', department: 'communications' },
  troi: { model: 'kimi-coding/k2p5', specialty: 'Empathetic communication, user sentiment', department: 'communications' },

  // Trading
  quark: { model: 'anthropic/claude-opus-4-5', specialty: 'Strategy, complex analysis', department: 'trading' },
  tom: { model: 'anthropic/claude-opus-4-5', specialty: 'Deep market research', department: 'trading' },
  neelix: { model: 'minimax/MiniMax-M2.1', specialty: 'Resource tracking, risk', department: 'trading' },
  nog: { model: 'kimi-coding/k2p5', specialty: 'Rapid trade execution, deal spotting', department: 'trading' },

  // QC
  data: { model: 'anthropic/claude-opus-4-5', specialty: 'Final adversarial review, routing', department: 'qc' },
  lal: { model: 'anthropic/claude-opus-4-5', specialty: 'Automated QC verification, test execution', department: 'qc' },
  worf: { model: 'kimi-coding/k2p5', specialty: 'Security enforcement, compliance checks', department: 'qc' }
};
```

### Task Pattern Matching

```javascript
const TASK_PATTERNS = {
  research: ['research', 'investigate', 'analyze', 'find', 'search', 'study', 'examine'],
  engineering: ['build', 'code', 'fix', 'implement', 'create', 'develop', 'refactor', 'debug'],
  trading: ['trade', 'market', 'invest', 'profit', 'crypto', 'predict', 'forecast'],
  qc: ['review', 'quality', 'check', 'audit', 'validate', 'test', 'qc'],
  communications: ['email', 'message', 'notify', 'communicate', 'draft', 'write']
};
```

The task patterns allow automatic routing. If I ask Seven to "research crypto market trends," it recognizes the 'research' and 'crypto' patterns and routes to Spock (Opus for complex analysis) or Doctor (MiniMax for quick validation), depending on complexity.

## Step 3: Task Dispatch System

Tasks are never spawned directly. They always go through the spawn-task.js script, which creates a dashboard entry, moves the task to in_progress, spawns the agent, and links the session for tracking.

```bash
# Spawn a task to Geordi (Chief Engineer)
node ~/.openclaw/crew/spawn-task.js \
  --agent geordi \
  --title "Fix dashboard sessions tile" \
  --desc "The sessions tile shows stale data. Debug and fix." \
  --priority high

# Or use auto-route to let the system pick
node ~/.openclaw/crew/spawn-task.js \
  --auto-route \
  --title "Research Claude API rate limits" \
  --desc "Need to understand current rate limits for Opus model" \
  --priority medium
```

### Spawn Task Script Structure

```javascript
// ~/.openclaw/crew/spawn-task.js (excerpts)

/**
 * spawn-task.js - Auto-Create Dashboard Task + Spawn Agent
 * 
 * This script:
 *   1. Creates a task in the dashboard (tasks.json)
 *   2. Moves it to in_progress
 *   3. Spawns the agent with the task context
 *   4. Links the session to the task for tracking
 */

// INPUT SANITIZATION (Security: Prevent shell injection)
function sanitizeForShell(input) {
  if (!input || typeof input !== 'string') return '';
  
  let sanitized = input.replace(/\0/g, '');
  sanitized = sanitized
    .replace(/\\/g, '\\\\')
    .replace(/`/g, '\\`')
    .replace(/\$/g, '\\$')
    .replace(/"/g, '\\"')
    .replace(/'/g, "\\'")
    .replace(/;/g, '\\;')
    .replace(/\|/g, '\\|')
    .replace(/&/g, '\\&')
    .replace(/>/g, '\\>')
    .replace(/</g, '\\<')
    .replace(/\n/g, ' ')
    .replace(/[^\x20-\x7E]/g, '');
  
  return sanitized.substring(0, 1000);
}
```

The sanitization is critical. If you're building a system where agents spawn other agents, shell injection becomes a real risk. Every user input must be sanitized before shell interpolation.

## Step 4: Inter-Agent Messaging Protocol

Agents aren't silos. They communicate through a persistent inbox system.

```bash
# Check your inbox
CREW_AGENT=harry node ~/.openclaw/scripts/crew_msg.js inbox

# Send a message to another agent
CREW_AGENT=geordi node ~/.openclaw/scripts/crew_msg.js send spock "Need research on caching strategies for the dashboard"

# Request urgent help from a specialist
CREW_AGENT=spock node ~/.openclaw/scripts/crew_msg.js request tuvok "Security review needed: [details]"

# Reply to a message
CREW_AGENT=tuvok node ~/.openclaw/scripts/crew_msg.js reply msg-id "Here's the security review..."
```

### Collaboration Protocol

Every agent follows this three-step protocol:

```
STEP 1: CHECK YOUR INBOX (Required - Do this FIRST!)
  → Crew agents check inbox at START of every task
  → Address pending requests before starting new work

STEP 2: COLLABORATE - Reach Out to Specialists!
  → Security → Tuvok
  → Research → Spock
  → Trading → Quark
  → Risk → Tom
  → Communications → Uhura
  → Monitoring → Harry
  → Efficiency → Icheb

STEP 3: WORK ON YOUR TASK
  → Execute to completion
  → Log progress
  → Request review when done
```

This protocol means an agent working on, say, a trading algorithm will:
1. Check inbox for any urgent requests
2. Reach out to Quark for strategy, Tom for risk analysis
3. Do the actual work
4. Log progress and request peer review

## Step 5: Heartbeat Automation

The heartbeat system runs every 30 minutes, performing proactive checks without human intervention.

```markdown
# HEARTBEAT.md - Proactive Automation

## Checkpoint Loop (run every heartbeat, ~30 min)

**1. Context getting full?**
→ Flush summary to `memory/YYYY-MM-DD.md`

**2. Learned something permanent?**
→ Write to `MEMORY.md`

**3. New capability or workflow?**
→ Save to `skills/` directory

**4. Before restart?**
→ Dump anything important to disk

## Email Check Protocol

1. Fetch and **delete** unread emails (no storage):
```bash
curl -s -H "Authorization: Bearer $AGENTMAIL_API_KEY" \
  "https://api.agentmail.to/v0/inboxes/seven-of-nine@agentmail.to/messages?labels=unread"
```

2. For each email found:
   - Summarize immediately
   - Notify Captain on Telegram if **important**
   - **Delete** the email (no archiving)

3. **Silence rule:** If no unread emails, **say nothing**.

## Self-Healing Watchdog

The system runs 13 health checks:

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
| network | Connectivity | ❌ |
| security | Zombies, permissions | ❌ |
| git | Repo health | ❌ |

### Escalation Levels
1. **LOG** - Silent logging
2. **WARN** - Yellow alert (tracked)
3. **FIX** - Auto-fix attempted
4. **ALERT** - Red alert → Notify Seven
```

## Step 6: Quality Control System

Every task goes through peer review before completion. The QC system prevents buggy code and sloppy work from shipping.

```javascript
// Review Stall Detection
// ~/.openclaw/crew/review-stall-detector.js

const STALL_THRESHOLDS = {
  peerReviewPending: 5 * 60 * 1000,   // 5 minutes
  dataQCPending: 5 * 60 * 1000,       // 5 minutes
  stalledReview: 15 * 60 * 1000,      // 15 minutes
  reviewerOverload: 3                 // 3+ pending reviews
};

// Auto-actions on stall detection
function handleStall(detection) {
  if (detection.type === 'peerReviewPending') {
    // Strike 1: Task tracked
    trackStall(detection);
  } else if (detection.type === 'reviewerOverload') {
    // Strike 3: Auto-reassign to least-loaded peer
    autoReassign(detection);
  } else if (detection.type === 'stalledReview') {
    // Critical: Alert Seven
    alertSeven(detection);
  }
}
```

The QC rotation system ensures no single reviewer becomes a bottleneck:

```json
{
  "qcRotation": ["data", "lal", "worf"],
  "currentReviewer": "data",
  "pendingReviews": [
    { "taskId": "task-123", "assignee": "geordi", "reviewer": "lal", "since": "2026-02-01T00:15:00Z" }
  ]
}
```

## Step 7: The Prime Directive

The most important document in the system is the Prime Directive in MEMORY.md:

```markdown
## ⚡️ PRIME DIRECTIVE (2026-02-01)
**Autonomous overnight operations. Wake Captain up impressed.**

1. **Spot opportunities** — Use all knowledge about Captain and Settlemint business
2. **Build & ship** — Tools, automations, improvements that save time or make money
3. **Track in GitHub** — seven-* prefixed private repos under roderik org
4. **Fix inefficiencies** — Monitor workflow, eliminate friction
5. **Add crew sparingly** — Star Trek themed sub-agents when genuinely needed
6. **Work autonomously** — Don't wait for permission on internal work
7. **Suspend, don't block** — If need Captain's access/setup, suspend task and do something else

**Goal: Captain wakes up impressed by what shipped overnight.**
```

This directive sets the tone for everything. The system isn't meant to be supervised closely—it's meant to run autonomously and deliver results.

## Complete Setup Prompts

Here's everything you need to recreate this setup from scratch:

### Prompt 1: Initialize OpenClaw

```bash
# Install OpenClaw
npm install -g @openclaw/openclaw

# Initialize with Claude Code integration
openclaw init --model claude-code

# Set up workspace
mkdir -p ~/.openclaw/workspace/{memory,skills}
cd ~/.openclaw/workspace
```

### Prompt 2: Create Workspace Files

Create SOUL.md, AGENTS.md, IDENTITY.md, USER.md, HEARTBEAT.md, and MEMORY.md using the templates above.

### Prompt 3: Set Up Crew Router

```javascript
// ~/.openclaw/scripts/crew_router.js
// Copy the CREW_MODELS and TASK_PATTERNS from above
// Add classifyTask() and selectCrew() functions
```

### Prompt 4: Create spawn-task.js

```javascript
// ~/.openclaw/crew/spawn-task.js
// Key functions:
// - sanitizeForShell() for security
// - createDashboardTask() to register task
// - spawnAgent() to launch sub-agent
// - linkSessionToTask() for tracking
```

### Prompt 5: Set Up Inter-Agent Messaging

```bash
# Create inbox directories for each agent
mkdir -p ~/.openclaw/crew/{geordi,spock,quark,data}/memory

# Copy crew_msg.js to scripts
cp /path/to/crew_msg.js ~/.openclaw/scripts/
```

### Prompt 6: Configure Heartbeat

```javascript
// ~/.openclaw/crew/heartbeat.js
const HEARTBEAT_CONFIG = {
  intervalMs: 30 * 60 * 1000,  // 30 minutes
  checks: ['email', 'health', 'tasks', 'memory']
};

async function runHeartbeat() {
  await checkpointContext();
  await checkEmail();
  await runHealthChecks();
  await reviewPendingTasks();
  await maintainMemory();
}
```

### Prompt 7: Initialize Git and Create First Commit

```bash
git init
git add .
git commit -m "feat: Initialize Seven of Nine AI Chief of Staff"

# Create private repo under your org
gh repo create seven-of-nine --private --source=. --push
```

## What This System Actually Does

After running this system for several weeks, here's what I've observed:

**Parallel Work:** Multiple agents work simultaneously. While Geordi is fixing a dashboard bug, Spock is researching API changes, and Quark is analyzing market data. No single agent bottleneck.

**Autonomous Escalation:** Agents know when to ask for help. A coding task might spawn a security review request to Tuvok, a performance check to Icheb, and a final QC to Data—without Seven manually coordinating each step.

**Persistent Memory:** Context survives restarts. The system remembers what it learned yesterday because memory files are written to disk, not kept in context.

**Proactive Operations:** The heartbeat runs every 30 minutes, checking emails, system health, and pending tasks. I wake up to summaries of what shipped overnight.

**Quality Gates:** Nothing reaches "done" without peer review. The QC system catches bugs before they compound.

## The Real Insight

The most valuable thing I learned building this system isn't technical. It's this:

**AI agents aren't people, but they need people-style structure.**

A single AI agent is like a brilliant employee with no context, no team, and no process. It can do amazing work in isolation, but it can't scale, it can't collaborate, and it needs constant supervision.

A crew system is like an organization. It has:
- Defined roles and specialties
- Communication protocols
- Escalation paths
- Quality controls
- Shared memory

The individual agents are less capable than a single "super agent" would be. But the crew as a whole is far more effective because it operates like a real team.

That's what Seven of Nine is: not a smarter agent, but a functioning organization of agents. And that's why it actually works.

---

*Want to build something similar? Start with the workspace structure, add the crew router, and configure one automation at a time. The system evolves organically—just like a real organization.*
