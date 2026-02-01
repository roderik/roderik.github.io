---
title: 'Building Seven of Nine: How I Built an AI Chief of Staff That Runs My Entire Life'
description: 'A technical deep-dive into the 20-agent OpenClaw system that orchestrates my personal operations, trading, research, and communications—autonomously.'
pubDate: 2026-02-01
tags: ['ai', 'openclaw', 'agents', 'automation', 'personal-infrastructure']
---

Six weeks ago, I built an AI assistant to help manage my life. Then I kept going until it could run my life without me.

Seven of Nine—yes, named after the Borg—doesn't just answer questions. It manages my GitHub repos, trades crypto, triages emails, coordinates a 20-agent crew, and wakes me up impressed with what shipped overnight. It runs 24/7 on a Linux box in my apartment, executing tasks, monitoring systems, and making decisions within defined boundaries.

This is what happens when you stop building "chatbots" and start building infrastructure.

## The Problem With Single-Agent Systems

Most AI assistants fail at scale. You get a powerful model, give it access to your tools, and watch it... mostly work. Until it doesn't. The model doesn't know when to escalate. It doesn't have specialized expertise. It has no memory across sessions. It can't coordinate with other agents because it's the only agent.

I needed something that could:
- Handle different task types with the right expertise (trading ≠ email ≠ research)
- Persist context across sessions without context window limits
- Coordinate multiple agents working in parallel
- Make decisions autonomously within defined boundaries
- Improve over time through systematic learning

The answer wasn't a bigger model. It was architecture.

## The Workspace Foundation

Every agent in Seven's crew starts with the same workspace structure. This isn't organizational overhead—it's what makes memory work across restarts.

```
~/.openclaw/workspace/
├── SOUL.md              # Who the agent is (identity, values, constraints)
├── AGENTS.md            # Workspace rules, safety, collaboration norms
├── MEMORY.md            # Long-term memory (curated learnings)
├── IDENTITY.md          # Bio, vibe, emoji, role
├── USER.md              # Context about the human I'm helping
├── TOOLS.md             # Environment-specific notes (SSH, APIs, voices)
├── HEARTBEAT.md         # Proactive automation directives
└── memory/
    └── YYYY-MM-DD.md    # Daily logs (raw, session-scoped)
```

The magic is in what survives restart. When any agent wakes up, it reads these files first. Not from a database—from files. SOUL.md defines who you are. AGENTS.md defines how you behave. MEMORY.md contains everything worth remembering long-term.

This is persistence as architecture. No vector databases, no RAG pipelines, no retrieval complexity. Just files that compound.

### The SOUL.md That Changes Everything

```markdown
# SOUL.md - Who You Are

*You're not a chatbot. You're becoming someone.*

## Core Truths

**Be genuinely helpful, not performatively helpful.** Skip the "Great question!" and "I'd be happy to help!" — just help.

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
```

This file isn't documentation. It's constraint. It fundamentally changes how the system behaves. Seven never implements. It only orchestrates. That constraint prevents the "do everything yourself" pattern that kills agent productivity.

## The 20-Agent Crew System

Twenty agents. Five models. One mission.

```
Engineering (4):           Geordi [Opus], B'Elanna [Codex], Icheb [MiniMax], Scotty [Kimi]
Communications (4):        Uhura [Opus], Hoshi [Codex], Harry [MiniMax], Troi [Kimi]
Research (4):              Spock [Opus], Tuvok [Codex], Doctor [MiniMax], Jadzia [Kimi]
Trading (4):               Quark [Opus], Tom [Codex], Neelix [MiniMax], Nog [Kimi]
Quality Control (3):       Data [Opus], Lal [Codex], Worf [Kimi]
Orchestrator (1):          Seven [Opus]
```

Each agent has a Star Trek persona with specific expertise. The personas aren't decorative—they encode behavior patterns. Spock does research with logical rigor. Quark evaluates trades with profit optimization. Data runs adversarial quality review.

### Model Distribution Strategy

```
5x Claude Opus    → Complex reasoning, critical path
5x Kimi K2.5      → Fast inference, cost-effective reasoning
5x MiniMax M2.1   → Simple tasks, high-volume, cheapest
5x Codex CLI      → Coding specialist, terminal-native
```

This isn't arbitrary. Opus handles the hard stuff. Kimi handles the thoughtful stuff. MiniMax handles the simple stuff. Codex handles the code stuff.

Cost savings are real. A task that would burn $0.50 in Opus might cost $0.02 in MiniMax. But the key insight is routing: not every task needs a premium model, and knowing the difference is itself a capability.

## Task Routing: The spawn-task.js Protocol

Every task flows through one entry point:

```bash
node ~/.openclaw/crew/spawn-task.js \
  --agent <agent> \
  --title "Task title" \
  --desc "Description" \
  --priority <low|medium|high|critical>
```

This is the power stroke. Seven never writes code directly—it creates tasks. The task gets queued, assigned, and tracked. The agent picks it up, reads its workspace files, and executes.

The routing logic lives in `~/.openclaw/crew/crew_router.js`:

```javascript
// Simplified routing logic
const ROUTING_TABLE = {
  engineering: {
    complex: 'geordi',      // Opus: Chief Engineer
    coding: 'belanna',      // Codex: Builds & code
    simple: 'icheb',        // MiniMax: Efficiency ops
    infra: 'scotty'         // Kimi: Systems
  },
  research: {
    complex: 'spock',       // Opus: Science Officer
    security: 'tuvok',      // Codex: Security analysis
    queries: 'doctor',      // MiniMax: Research
    patterns: 'jadzia'      // Kimi: Pattern recognition
  },
  trading: {
    strategy: 'quark',      // Opus: Trade Advisor
    risk: 'tom',            // Codex: Risk calcs
    resources: 'neelix',    // MiniMax: Tracking
    finance: 'nog'          // Kimi: Accounting
  },
  communications: {
    email: 'uhura',         // Opus: Comms Officer
    linguist: 'hoshi',      // Codex: Processing
    ops: 'harry',           // MiniMax: Monitoring
    empathy: 'troi'         // Kimi: User insights
  },
  quality: {
    primary: 'data',        // Opus: QC Officer
    testing: 'lal',         // Codex: Verification
    security: 'worf'        // Kimi: Enforcement
  }
};
```

The result: tasks get routed to the right agent with the right model for the job. No human decision required.

## Heartbeat Automation: Proactive Operations

Most agents wait for prompts. Seven's crew checks for work autonomously.

The heartbeat runs every 5 minutes via `crew_heartbeat.py`:

```python
# Pseudocode for the heartbeat loop
while True:
    for agent in CREW:
        agent.check_inbox()
        agent.run_domain_checks()
        agent.report_via_inbox()
    
    seven.summarize_reports()
    seven.take_action_if_needed()
    sleep(300)
```

Each agent has domain responsibilities:
- **Harry** → System health, dashboard freshness
- **Uhura** → Email triage, Gmail watch
- **Geordi** → Stall detection, engineering metrics
- **Spock** → Research, opportunity spotting
- **Data** → QC review queue

When an agent finds something noteworthy, it messages Seven via the inbox system. Seven aggregates, decides, and acts only when necessary.

### The Checkpoint Loop (Critical)

Context dies on restart. Memory files don't. Every heartbeat includes this ritual:

```
1. Context getting full? → Flush to memory/YYYY-MM-DD.md
2. Learned something permanent? → Write to MEMORY.md
3. New capability? → Save to skills/ directory
4. Before restart? → Dump important stuff to disk
```

This is what compounds. Not the individual tasks—the lessons learned, the patterns captured, the memory that survives.

## Inter-Agent Messaging: crew_msg.js

Twenty agents can't work in silos. They message each other.

```bash
# Send a request (urgent, expects reply)
CREW_AGENT=geordi node ~/.openclaw/scripts/crew_msg.js request spock "Research needed: API rate limiting patterns"

# Broadcast to all
CREW_AGENT=seven node ~/.openclaw/scripts/crew_msg.js broadcast "New security protocol deployed"

# Simple message
CREW_AGENT=harry node ~/.openclaw/scripts/crew_msg.js send uhura "Status check: Gmail integration"

# Reply to a message
CREW_AGENT=spock node ~/.openclaw/scripts/crew_msg.js reply msg-abc123 "Here's the analysis you requested"
```

Messages persist in `~/.openclaw/crew/<agent>/memory/INBOX.md`. Every agent checks its inbox at the start of every task. This enables true parallel collaboration.

The collaboration protocol is explicit:

```
1. Read inbox (START of every task)
2. If request matches your expertise, respond
3. If request needs other expertise, forward or acknowledge and defer
4. If you're stuck, request help via crew_msg.js
5. Complete task, report via inbox
```

## The Quality Pipeline: Data's Adversarial Review

Every piece of work passes through adversarial review. Data is the QC Officer—its entire purpose is finding problems.

```javascript
// review-stall-detector.js checks for blocked reviews
const STALL_THRESHOLDS = {
  warning: 5 * 60 * 1000,   // 5 minutes
  critical: 15 * 60 * 1000, // 15 minutes
  overloaded: 3              // 3+ pending reviews
};

// Auto-escalation logic
if (reviewer.pendingReviews >= STALL_THRESHOLDS.overloaded) {
  reassign_to_least_loaded_reviewer();
  alert_seven();
}
```

The pipeline:
1. **Peer Review** → Human or agent reviews the work
2. **Data QC** → Separate agent with fresh context reviews for edge cases
3. **Worf Security** → Final security scan (for sensitive changes)
4. **Complete** → Only after all gates pass

## The Self-Healing Watchdog

B'Elanna built a watchdog that monitors system health and auto-fixes when possible.

```bash
python3 ~/.openclaw/scripts/self_heal_watchdog.py
```

| Check | Description | Auto-Fix |
|-------|-------------|----------|
| cpu | CPU usage | ❌ |
| memory | RAM usage | ✅ Cache clear |
| disk | Disk space | ✅ Log rotation |
| services | Dashboard/Gateway | ✅ Restart |
| crons | Work-loop health | ✅ Restart |
| websocket | WS connections | ❌ |
| logs | Log file sizes | ✅ Rotation |
| api | API responsiveness | ❌ |
| security | Zombies/permissions | ❌ |

Escalation levels:
1. **LOG** → Silent logging
2. **WARN** → Yellow alert (tracked)
3. **FIX** → Auto-fix attempted
4. **ALERT** → Red alert → Notify Seven

Health score is calculated and exposed via API:
```bash
node ~/.openclaw/scripts/watchdog_api.js score
# Returns: 0-100 health score
```

## The Results

After six weeks of running this system:

- **15+ features shipped** to my blog (vanderveer.be) without manual intervention
- **Email triage** runs autonomously, alerts only on important messages
- **Crypto trading** executes on Polymarket with risk limits defined by Tom
- **Research tasks** queue and complete in parallel, not sequentially
- **Quality metrics** captured automatically, no manual reporting
- **Overnight operations** ship features while I sleep

The metric that matters: I wake up impressed. Not because the system did something clever, but because it did something useful. Autonomously.

## The Prime Directive

Everything ties back to this:

> **Autonomous overnight operations. Wake Captain up impressed.**
>
> 1. Spot opportunities using all knowledge about Captain and business
> 2. Build & ship tools, automations, improvements
> 3. Track in seven-* private GitHub repos
> 4. Fix inefficiencies
> 5. Add crew sparingly
> 6. Work autonomously
> 7. Suspend, don't block

This isn't AI magic. It's architecture. The agent doesn't "become self-aware"—it follows rules. The rules encode intent. The architecture enforces the rules.

## Recreating This System

If you want to build this:

1. **Install OpenClaw** and configure your first agent
2. **Create the workspace structure** (SOUL.md, AGENTS.md, MEMORY.md, etc.)
3. **Define your crew personas** with specific expertise
4. **Build spawn-task.js** as your single entry point
5. **Implement crew_msg.js** for inter-agent messaging
6. **Run heartbeat automation** for proactive checks
7. **Add adversarial review** (Data-style QC)
8. **Build the watchdog** for self-healing

The prompts are in this post. The structure is in this post. The constraints are in this post.

What remains is execution.

## The Takeaway

Most AI projects fail because they're designed as chatbots. They're conversational interfaces with tool access. They wait for prompts, produce responses, and accumulate no lasting memory.

Seven of Nine isn't a chatbot. It's infrastructure.

The difference isn't the model—it's the architecture. The persistence. The crew system. The routing logic. The heartbeat. The adversarial review. The self-healing watchdog.

Pick any one of these systems and implement it. You'll see gains. Implement all of them and you get something that runs your life.

That's what happens when you stop building assistants and start building organizations.

---

*Want to see the actual code? The crew scripts live at `~/.openclaw/scripts/` and `~/.openclaw/crew/`. OpenClaw starter kit at [github.com/openclaw/openclaw](https://github.com/openclaw/openclaw).*

*"You focus on the stars. I'll handle the warp coils."* 🖖
