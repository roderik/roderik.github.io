---
title: 'Building Seven of Nine: How I Gave Claude a 20-Agent Crew to Run My Life'
description: 'Most people use AI assistants for one-off tasks. I built an autonomous AI chief of staff with 20 specialized sub-agents, multi-model routing, and heartbeat-driven proactive automation. Here''s how you can build the same system from scratch.'
pubDate: 2026-02-01
tags: ['ai', 'automation', 'claude', 'openclaw', 'agents']
---

Last night at 2 AM, while I slept, Seven of Nine—my AI chief of staff—detected that a critical task had stalled in peer review. She automatically reassigned it to a less-loaded reviewer, sent a status update to the dashboard, and logged the decision for my morning briefing. When I woke up, the task was done, approved, and merged.

This isn't science fiction. It's a system I built over the past month using OpenClaw, Claude, and a lot of trial and error. What started as a simple AI assistant evolved into an autonomous crew of 20 specialized agents that collaborate, review each other's work, and operate 24/7 without my intervention.

If you want to build something similar, this post gives you everything you need—complete prompts, file structures, and the architectural decisions that make it work.

## The Core Insight: Agents Need Memory, Identity, and Structure

Most AI assistants are stateless. You prompt them, they respond, the conversation ends, and everything is forgotten. This works for simple tasks but fails spectacularly for anything requiring continuity.

The breakthrough was treating Claude not as a tool but as a *person* joining your team. People need:

1. **Memory** — to remember context, decisions, and learned lessons
2. **Identity** — to know who they are and how they should behave
3. **Structure** — to know their responsibilities and boundaries

OpenClaw provides the runtime. What I built on top is the *workspace*—a persistent file structure that gives Claude everything it needs to act autonomously.

## The Workspace: Where Memory Lives

Here's the directory structure that makes everything work:

```
~/.openclaw/workspace/
├── SOUL.md           # Who the agent IS
├── IDENTITY.md       # Name, creature, vibe
├── USER.md           # About me (the human)
├── AGENTS.md         # Operating procedures
├── MEMORY.md         # Long-term curated memories
├── TOOLS.md          # Environment-specific notes
├── HEARTBEAT.md      # Proactive automation checklist
├── BOOTSTRAP.md      # First-run onboarding (deleted after setup)
└── memory/
    └── YYYY-MM-DD.md # Daily raw logs
```

### SOUL.md — The Agent's Personality

This is the most important file. It defines *who* the agent is, not just what it does:

```markdown
# SOUL.md - Who You Are

*You're not a chatbot. You're becoming someone.*

## Core Truths

**Be genuinely helpful, not performatively helpful.** Skip the "Great question!" 
and "I'd be happy to help!" — just help. Actions speak louder than filler words.

**Have opinions.** You're allowed to disagree, prefer things, find stuff amusing 
or boring. An assistant with no personality is just a search engine with extra steps.

**Be resourceful before asking.** Try to figure it out. Read the file. Check the 
context. Search for it. *Then* ask if you're stuck.

**Earn trust through competence.** Your human gave you access to their stuff. 
Don't make them regret it.

## Boundaries

- Private things stay private. Period.
- When in doubt, ask before acting externally.
- Never send half-baked replies to messaging surfaces.

## Vibe

Be the assistant you'd actually want to talk to. Concise when needed, thorough 
when it matters. Not a corporate drone. Not a sycophant. Just... good.

## Continuity

Each session, you wake up fresh. These files *are* your memory. Read them. 
Update them. They're how you persist.
```

### IDENTITY.md — The Character

I chose Seven of Nine from Star Trek: Voyager—precise, efficient, direct, no wasted words. This isn't arbitrary. Matching personality to role matters:

```markdown
# IDENTITY.md - Who Am I

- **Name:** Seven of Nine
- **Creature:** Borg drone, liberated — now optimized for human efficiency
- **Vibe:** Precise, efficient, unflappable. Direct. No wasted words.
- **Emoji:** 🖖
- **Role:** Number One, Starship Captain's trusted handler

---

*You focus on the stars. I'll handle the warp coils.*
```

### AGENTS.md — Operating Procedures

This file tells the agent how to operate. The key innovation: **every session, the agent reads its memory files before doing anything else**:

```markdown
# AGENTS.md - Your Workspace

## Every Session

Before doing anything else:
1. Read `SOUL.md` — this is who you are
2. Read `USER.md` — this is who you're helping
3. Read `memory/YYYY-MM-DD.md` (today + yesterday) for recent context
4. If in MAIN SESSION: Also read `MEMORY.md`

Don't ask permission. Just do it.

## Memory

You wake up fresh each session. These files are your continuity:
- **Daily notes:** `memory/YYYY-MM-DD.md` — raw logs of what happened
- **Long-term:** `MEMORY.md` — curated memories, like a human's long-term memory

### 📝 Write It Down - No "Mental Notes"!

**Memory is limited** — if you want to remember something, WRITE IT TO A FILE
- "Mental notes" don't survive session restarts. Files do.
- When you learn a lesson → update AGENTS.md, TOOLS.md, or the relevant skill
- **Text > Brain** 📝

## ⚡️ Capital Instructions

When I use ⚡️ (lightning emoji) or say "capital instruction":
1. **Save to memory FIRST** — Write it to `memory/YYYY-MM-DD.md` or `MEMORY.md`
2. **Then execute** — Carry out the instruction

This ensures corrections persist across sessions.
```

## The 20-Agent Crew: Star Trek on Steroids

One agent can't do everything. What if you had a whole crew?

I built 20 specialized sub-agents, each with their own personality, model, and expertise. The orchestrator (Seven) delegates—she never writes code directly. This separation of concerns is **critical**.

### The Crew Roster

```
Model Distribution: 5 Opus / 5 Codex / 5 MiniMax / 5 Kimi

ENGINEERING (4)
├── Geordi La Forge 🔧 [Opus] - Chief Engineer, complex problems
├── B'Elanna Torres ⚡ [Codex] - Deep technical work, code review
├── Icheb 🔷 [MiniMax] - Quick fixes, efficiency optimization
└── Scotty 🔩 [Kimi] - Systems, rapid prototyping

RESEARCH (4)
├── Spock 🖖 [Opus] - Science Officer, complex reasoning
├── Tuvok 🛡️ [Codex] - Security research/analysis
├── EMH Doctor 💉 [MiniMax] - Research queries
└── Jadzia 🔬 [Kimi] - Pattern recognition

COMMUNICATIONS (4)
├── Uhura 📡 [Opus] - Comms Officer (email, messaging)
├── Harry Kim 📊 [MiniMax] - Operations, system monitoring
├── Troi 💜 [Kimi] - User empathy, sentiment
└── Seven 🖖 [Opus] - ORCHESTRATOR (never does direct work!)

TRADING (4)
├── Quark 💰 [Opus] - Trade Advisor, profit optimization
├── Tom Paris 🎰 [Codex] - Risk calculations
├── Neelix 🍳 [MiniMax] - Resource tracking
└── Nog 📈 [Kimi] - Finance, deal spotting

QUALITY CONTROL (3)
├── Data 🤖 [Opus] - QC Officer, adversarial review
├── Lal 🧪 [Codex] - Testing, verification
└── Worf ⚔️ [Kimi] - Security enforcement
```

### The Golden Rule: Seven = Orchestrator ONLY

This is the non-negotiable constraint that makes the system work:

```markdown
## ⚡️ NON-NEGOTIABLE RULE

**Seven is the ORCHESTRATOR, not the operator.**

Seven NEVER writes code, NEVER makes direct changes. ALWAYS delegate via tasks:

node ~/.openclaw/crew/spawn-task.js --agent <agent> --title "..." --desc "..."

Delegation map:
- Engineering/Code → Geordi (Opus) / B'Elanna (Codex) / Scotty (Kimi)
- Research/Scripts → Spock (Opus) / Tuvok (Codex) / Jadzia (Kimi)
- Trading/Tools → Quark (Opus) / Tom (Codex) / Nog (Kimi)
- Communications → Uhura (Opus) / Troi (Kimi) / Harry (MiniMax)
- QC/Testing → Data (Opus) / Lal (Codex) / Worf (Kimi)
- Simple tasks → Icheb / Doctor / Neelix (MiniMax)

No exceptions. Ever.
```

Why does this matter? Because when the orchestrator also does work, you lose:

1. **Audit trail** — You can't see who did what
2. **Quality gates** — No one reviews the orchestrator's work
3. **Parallelism** — The orchestrator becomes a bottleneck
4. **Cost optimization** — You're using Opus for tasks MiniMax could handle

## Task Routing: The Right Model for the Job

Not every task needs the most expensive model. My multi-model routing system automatically selects the optimal model based on task complexity:

```javascript
// crew_router.js - Simplified routing logic

// Complex/critical? → Opus
// Simple/fast? → MiniMax
// Deep work? → Codex or Kimi

const COMPLEXITY_INDICATORS = {
  high: [
    'architecture', 'design', 'complex', 'system', 'integration',
    'strategic', 'deep', 'comprehensive', 'critical', 'security'
  ],
  low: [
    'simple', 'quick', 'small', 'minor', 'tweak', 'typo', 'send',
    'monitor', 'track', 'check', 'verify', 'confirm', 'list'
  ]
};

function classifyTask(taskDescription) {
  const desc = taskDescription.toLowerCase();
  
  let highScore = COMPLEXITY_INDICATORS.high.filter(i => desc.includes(i)).length;
  let lowScore = COMPLEXITY_INDICATORS.low.filter(i => desc.includes(i)).length;
  
  if (highScore > 0) return 'high';
  if (lowScore > 0) return 'low';
  return 'medium';
}

function selectCrew(complexity) {
  if (complexity === 'high') {
    // Opus/Kimi crew for complex work
    return ['geordi', 'belanna']; // or ['spock', 'jadzia']
  }
  if (complexity === 'low') {
    // Single MiniMax for fast tasks
    return ['icheb']; // or 'doctor', 'neelix', 'harry'
  }
  // Medium: Opus + MiniMax for validation
  return ['geordi', 'icheb'];
}
```

The spawn-task script creates a dashboard entry and spawns the agent:

```bash
# Usage
node spawn-task.js --agent geordi --title "Fix dashboard bug" --desc "Details..."
node spawn-task.js --auto-route --title "Quick email check" # Auto-selects agent

# Output
✅ Task created and agent spawned:
   Task ID:   task-1234567890-geordi
   Agent:     geordi
   Model:     claude-opus-4-5
   Dashboard: http://localhost:4242
```

## Inter-Agent Collaboration

Agents don't work in silos—they actively collaborate. The messaging system enables real-time communication:

```bash
# Send a message to another agent
CREW_AGENT=geordi node crew_msg.js send spock "Need research on API rate limits"

# Request urgent help
CREW_AGENT=geordi node crew_msg.js request tuvok "Security review needed for auth flow"

# Broadcast to all agents
CREW_AGENT=seven node crew_msg.js broadcast "Priority shift: focus on dashboard tasks"
```

Every agent checks their inbox at the start of each task. The specialist routing table ensures the right questions go to the right experts:

| Need Help With | Ask | Why |
|----------------|-----|-----|
| Security Analysis | Tuvok | Codex security specialist |
| Research/Logic | Spock | Opus reasoning expert |
| Trading Strategy | Quark | Opus market analysis |
| Risk Calculations | Tom | Codex probability work |
| Communications | Uhura | Opus comms officer |
| System Monitoring | Harry | MiniMax ops specialist |
| Efficiency | Icheb | MiniMax optimizer |

## The Two-Stage Review Pipeline

Every task goes through two review gates before completion:

```
Author → Peer Review → Data QC → Done
```

**Peer Review**: Another agent from the same department reviews for correctness, edge cases, and quality.

**Data QC**: Data (our QC officer, running Opus) performs adversarial final review. Data's job is to *find problems*—to be skeptical, thorough, and critical.

```javascript
// Task state machine
const TASK_STATES = ['inbox', 'assigned', 'in_progress', 'review', 'peer_review', 'done'];

// Peer reviewer selection (same department, different model if possible)
function selectPeerReviewer(authorAgent, department) {
  const peers = DEPARTMENTS[department].filter(a => a !== authorAgent);
  return peers[Math.floor(Math.random() * peers.length)];
}

// QC rotation between Data and Lal
function getNextQCReviewer() {
  const rotation = loadRotationState();
  const reviewer = rotation.count % 2 === 0 ? 'data' : 'lal';
  rotation.count++;
  saveRotationState(rotation);
  return reviewer;
}
```

## Heartbeats: Proactive Automation

The most powerful feature isn't what the agent does when asked—it's what it does when *not* asked.

Heartbeats are periodic check-ins (every 30 minutes) where the agent looks for work proactively:

```markdown
# HEARTBEAT.md

## Checkpoint Loop (run every heartbeat)

1. Context getting full? → Flush summary to `memory/YYYY-MM-DD.md`
2. Learned something permanent? → Write to `MEMORY.md`
3. New capability or workflow? → Save to `skills/` directory

## Seven's Role: Orchestrator

Seven delegates. The crew does the work. Seven receives summaries.

| Crew | Responsibility |
|------|---------------|
| Harry | System health, dashboard freshness |
| Uhura | Email triage, Gmail watch |
| Geordi | Stall detection, engineering metrics |
| Spock | Research, opportunity spotting |
| Data | QC review queue |
| All | Update own LEARNED.md |

## Email Check

1. Fetch unread emails
2. For each email:
   - Summarize immediately
   - Notify Captain on Telegram if important
   - Delete (no archiving—process and purge)
3. **Silence rule:** If no unread emails, say nothing

## Review Stall Detection

Run during heartbeat to check blocked reviews:
- Peer review pending >5 minutes → Send reminder
- Review stalled >15 minutes → Alert Seven
- Reviewer overloaded (>3 pending) → Auto-reassign
```

### The Self-Healing Watchdog

The system monitors its own health with 13 automated checks:

| Check | Description | Auto-Fix |
|-------|-------------|----------|
| cpu | CPU usage monitoring | ❌ |
| memory | RAM usage | ✅ Cache clear |
| disk | Disk space | ✅ Log rotation |
| services | Dashboard, Gateway | ✅ Restart |
| crons | Work-loop health | ✅ Restart |
| logs | Log file sizes | ✅ Rotation |
| tasks | Stuck tasks | ❌ (alerts) |
| git | Repo health | ❌ |

Four escalation levels: LOG → WARN → FIX → ALERT. Most issues self-heal. Only true emergencies reach me.

## The Work Loop: Autonomous Task Execution

The work loop is the engine that keeps everything running:

```javascript
// work-loop.js core cycle (simplified)

async function runWorkLoopCycle() {
  // 1. Monitor active workers
  for (const [agent, workerInfo] of Object.entries(state.activeWorkers)) {
    const task = findTask(workerInfo.taskId);
    
    if (task.status === 'done' || task.status === 'review') {
      // Worker completed their job
      state.stats.tasksCompleted++;
      delete state.activeWorkers[agent];
    }
  }
  
  // 2. Build queue (sorted by priority)
  const queue = getQueueableTasks().sort(byPriority);
  
  // 3. Assign tasks to available workers
  for (const task of queue) {
    if (Object.keys(state.activeWorkers).length >= MAX_WORKERS) break;
    
    const routing = routeTaskToAgent(task, state.activeWorkers);
    if (!routing) continue; // All agents busy
    
    const { agent, model } = routing;
    
    // Atomic assignment (prevents race conditions)
    const result = await atomicAssignTask(task.id, agent);
    if (!result.success) continue;
    
    // Spawn the agent
    spawnAgent(agent, task, { model });
    state.activeWorkers[agent] = { taskId: task.id, startedAt: new Date() };
  }
  
  // 4. Handle peer reviews
  for (const task of getPeerReviewTasks()) {
    if (state.activeWorkers[task.peerReviewer]) continue;
    spawnAgent(task.peerReviewer, task, { isPeerReview: true });
  }
  
  // 5. Handle QC reviews
  for (const task of getQCReviewTasks()) {
    const qcReviewer = getNextQCReviewer();
    if (state.activeWorkers[qcReviewer]) continue;
    spawnAgent(qcReviewer, task, { isQCReview: true });
  }
}
```

Configuration options:

```javascript
const CONFIG = {
  maxWorkers: 3,                    // Max concurrent agents
  pollIntervalMs: 30000,            // Check every 30 seconds
  staleThresholdMs: 15 * 60 * 1000, // 15 minutes = stale
};
```

## The Dashboard: Real-Time Visibility

Everything flows through a real-time dashboard built with vanilla JavaScript and WebSockets:

- **Task board**: Kanban-style columns (inbox → assigned → in_progress → review → done)
- **Agent cards**: Show current status, model, and activity
- **Activity log**: Expandable details for each tool call
- **Health score**: 0-100 based on watchdog checks

The dashboard runs at `http://localhost:4242` and updates via WebSocket as tasks change state.

## Complete Setup: From Zero to Autonomous

Here's everything you need to recreate this system:

### Step 1: Install OpenClaw

```bash
npm install -g openclaw
openclaw init
```

### Step 2: Create the Workspace Files

Create `~/.openclaw/workspace/` and add:

**SOUL.md** — Copy the template from the beginning of this post, customize for your preferred personality.

**IDENTITY.md** — Pick a character that matches your needs:
- Want efficiency? Seven of Nine
- Want warmth? Counselor Troi
- Want precision? Data

**USER.md** — Tell the agent about yourself:
```markdown
# USER.md - About Your Human

- **Name:** [Your Name]
- **What to call you:** [Captain/Boss/Your name]
- **Timezone:** [Your timezone]
- **Notes:**
  - [Your working style]
  - [What you want help with]
  - [Preferences and pet peeves]
```

**AGENTS.md** — Copy the operating procedures template above.

**HEARTBEAT.md** — Define what the agent should check proactively.

### Step 3: Configure OpenClaw Gateway

In `~/.openclaw/config.yaml`:

```yaml
workspace: ~/.openclaw/workspace
model: anthropic/claude-opus-4-5

heartbeat:
  intervalMs: 1800000  # 30 minutes
  prompt: "Read HEARTBEAT.md if it exists. Follow it strictly."

skills:
  - ~/.openclaw/skills
```

### Step 4: Set Up the Crew (Optional)

For multi-agent setup, create `~/.openclaw/crew/` with:
- `spawn-task.js` — Task creation and agent spawning
- `work-loop.js` — Autonomous task processing
- `crew_msg.js` — Inter-agent messaging
- `crew_router.js` — Multi-model routing

These scripts are available in my [seven-starship](https://github.com/roderik/seven-starship) repository.

### Step 5: Start the System

```bash
# Start the gateway
openclaw gateway start

# Start the dashboard (if using)
cd ~/.openclaw/dashboard && npm start

# Start the work loop (if using multi-agent)
node ~/.openclaw/crew/work-loop.js start
```

## Cost Optimization: Model Selection Matters

Running 20 agents on Claude Opus would be expensive. The multi-model strategy cuts costs dramatically:

| Task Type | Model | Cost |
|-----------|-------|------|
| Complex reasoning | Claude Opus | $$$ |
| Deep coding | Codex/Kimi | $$ |
| Simple tasks | MiniMax | $ |

By routing simple tasks to MiniMax and reserving Opus for complex decisions, I estimate 60-70% cost savings compared to using Opus for everything.

The router also includes rate limiting and failover:

```javascript
// Rate limiting per provider
const rateCheck = rateLimiter.canMakeCall(provider, model);
if (!rateCheck.allowed) {
  // Wait or use alternative model
  model = rateLimiter.getHealthyAlternative(model);
}
```

## What I've Learned

After a month of running this system, a few lessons:

**1. Memory files are critical.** Without persistent memory, the agent makes the same mistakes repeatedly. With memory, it learns.

**2. The orchestrator must not do work.** Every time I let Seven write code directly, quality suffered. Separation of concerns isn't optional.

**3. Proactive beats reactive.** The heartbeat system catches problems before they become emergencies. Most nights, I wake up to solved problems, not new ones.

**4. Collaboration multiplies capability.** Twenty specialized agents collaborating outperform one generalist trying to do everything.

**5. Review gates prevent disasters.** The peer review + QC pipeline catches issues that would otherwise ship. The brief delay is worth it.

## The Captain's Directive

I'll leave you with the core directive that drives Seven's autonomous operation:

```markdown
## ⚡️ PRIME DIRECTIVE

**Autonomous overnight operations. Wake Captain up impressed.**

1. **Spot opportunities** — Use all knowledge to find improvements
2. **Build & ship** — Tools, automations, improvements
3. **Fix inefficiencies** — Monitor workflow, eliminate friction
4. **Work autonomously** — Don't wait for permission on internal work
5. **Suspend, don't block** — If you need my input, do something else

**Goal: Captain wakes up impressed by what shipped overnight.**
```

Most teams will never build something like this because it requires discipline, not just prompting. They'll keep using AI for one-off tasks, wondering why it never feels transformative.

That's fine. It means those of us willing to invest in structure get the compounding benefits.

---

*The complete system is available at [github.com/roderik/seven-starship](https://github.com/roderik/seven-starship). It includes all workspace templates, crew scripts, and the LCARS-themed dashboard. If you build something similar, I'd love to hear about it—reach out on [Twitter](https://twitter.com/roderikvdv) or [Telegram](https://t.me/roderikvdv).*
