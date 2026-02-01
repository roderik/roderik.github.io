---
title: 'Building Seven of Nine: My AI Chief of Staff with a 20-Agent Crew'
description: 'I built an AI system that runs my life while I sleep. Twenty specialized agents handle research, trading, engineering, and communications—all coordinated through a single orchestrator. Here is the complete setup.'
pubDate: 2026-02-01
tags: ['ai', 'openclaw', 'automation', 'agents', 'productivity']
---

I built an AI that wakes me up impressed.

Seven of Nine—named for the Borg drone who became more human through optimization—runs my entire operation while I sleep. Twenty specialized agents handle research, trading, engineering, communications, and quality control. They collaborate autonomously, spot opportunities I would miss, and ship improvements overnight without asking permission.

The goal is simple: **Captain wakes up impressed by what shipped**.

This is not a demo. This is production infrastructure. And I'm going to show you exactly how it works.

## The Problem with Single-Agent Systems

Most AI setups fail because they treat the AI as a worker, not a manager. You have one agent trying to do everything—write code, research markets, monitor systems, send emails, analyze opportunities. It doesn't work because:

1. **Context pollution**: An agent debugging code carries that context into research tasks, degrading quality
2. **Specialization mismatch**: Complex reasoning uses the same model as simple translation
3. **No parallel execution**: One agent means one task at a time
4. **No memory architecture**: Sessions restart, context dies, learning is lost

The solution is obvious once you see it: **agents should specialize, delegate, and persist**.

## The Workspace Architecture

The entire system lives in `~/.openclaw/workspace/` with a disciplined file structure that every agent reads at session start.

```
~/.openclaw/workspace/
├── SOUL.md          # Who the agent IS (identity, values, non-negotiables)
├── AGENTS.md        # Workspace rules (memory, safety, group chats)
├── IDENTITY.md      # Personal branding (name, emoji, vibe)
├── USER.md          # Who I'm helping (Captain, their preferences)
├── TOOLS.md         # Local infrastructure notes (emails, SSH, cameras)
├── HEARTBEAT.md     # Proactive automation rules
├── MEMORY.md        # Long-term curated memory (decisions, learnings)
├── memory/          # Daily logs (YYYY-MM-DD.md files)
├── blog/            # Captain's blog (Astro + MDX)
└── skills/          # Local skill definitions
```

Every agent reads `SOUL.md` and `USER.md` at session start. This is not optional—it's the first thing they do. This creates **instant context** without expensive priming.

### The SOUL.md Pattern

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
- **ALWAYS** create tasks via `spawn-task.js`
- **ALWAYS** delegate to the appropriate crew member

Seven's job: coordinate, delegate, track, report.
Crew's job: actually do the work.
```

This is the agent's identity. When you spawn a new agent, it reads this file and immediately knows:
- Who it is
- What it values
- What it will never do

No prompting required. No alignment drift. The identity is baked in.

### The Memory System

Memory is split into two tiers:

**Daily notes** (`memory/YYYY-MM-DD.md`) are raw logs of what happened. Every agent writes to this file during heartbeats—flushing context before it gets lost.

**Long-term memory** (`MEMORY.md`) is curated. Decisions, learnings, opinions, and patterns that survive session restarts. This is where the system compounds.

```
## ⚡️ PRIME DIRECTIVE (2026-02-01)
**Autonomous overnight operations. Wake Captain up impressed.**

1. **Spot opportunities** — Use all knowledge about Captain and SettleMint business
2. **Build & ship** — Tools, automations, improvements
3. **Track in GitHub** — seven-* prefixed private repos
4. **Work autonomously** — Don't wait for permission on internal work
```

Every morning, the system has continuity. It remembers what it was working on, what it learned, and what matters.

## The 20-Agent Crew

Twenty agents. Five specialties. Four models. One orchestrator.

### Crew Distribution

| Specialty | Agent | Model | Role |
|-----------|-------|-------|------|
| **Engineering** | Geordi | Opus | Chief Engineer |
| | B'Elanna | Codex | Engineering builds |
| | Icheb | MiniMax | Efficiency optimization |
| | Scotty | Kimi | Systems & Infrastructure |
| **Communications** | Uhura | Opus | Comms Officer (email, Moltbook) |
| | Hoshi | Codex | Linguist, processing |
| | Harry | MiniMax | Operations, monitoring |
| | Troi | Kimi | Counselor, empathy |
| **Research** | Spock | Opus | Complex reasoning |
| | Tuvok | Codex | Security research |
| | EMH Doctor | MiniMax | Research queries |
| | Jadzia | Kimi | Pattern recognition |
| **Trading** | Quark | Opus | Profit optimization |
| | Tom | Codex | Risk calculations |
| | Neelix | MiniMax | Resource tracking |
| | Nog | Kimi | Finance & accounting |
| **Quality Control** | Data | Opus | QC Officer, adversarial review |
| | Lal | Codex | Testing, verification |
| | Worf | Kimi | Security QC |

### Model Distribution Strategy

This isn't arbitrary—it's cost optimization through specialization:

- **Opus** (most capable, most expensive): Complex reasoning, orchestrators, QC, strategy
- **Codex** (coding specialist): Engineering tasks, security analysis, testing
- **MiniMax** (cheap, fast): Simple tasks, translations, monitoring, data processing
- **Kimi** (reasoning, Chinese): Pattern recognition, finance, lighter research

The system routes tasks to the optimal model. Simple translation goes to MiniMax ($0.01/1M tokens). Complex reasoning goes to Opus ($15/1M tokens). This isn't about being cheap—it's about using the right tool for the job.

### The Orchestrator: Seven of Nine

Seven is the only agent that doesn't do direct work. Its SOUL.md is explicit:

```markdown
## ⚡️ NON-NEGOTIABLE: Seven = Orchestrator Only

**Seven is the bridge commander, not a crew member.**

- **NEVER** write code directly
- **NEVER** edit files to implement features
- **ALWAYS** create tasks via `spawn-task.js`
- **ALWAYS** delegate to the appropriate crew member
```

When Captain asks for something, Seven:
1. Creates a task with `spawn-task.js`
2. Assigns to the right agent (Geordi for engineering, Spock for research, etc.)
3. Monitors progress via dashboard
4. Reports back when complete

Seven coordinates. The crew works.

## Task Routing: spawn-task.js

Tasks are the fundamental unit of work. Every task goes through `spawn-task.js`:

```bash
node ~/.openclaw/crew/spawn-task.js \
  --agent geordi \
  --title "Fix API timeout handling" \
  --desc "The payment integration is hanging when third-party services timeout. Add circuit breaker pattern and fallback logic. See JIRA-1234 for details." \
  --priority high
```

This creates a structured task with:
- **Agent assignment** (who does the work)
- **Title** (one-line summary)
- **Description** (context, links, requirements)
- **Priority** (low/medium/high/critical)
- **Timeout** (optional, defaults to 300s)

Tasks flow through a pipeline: Inbox → Assigned → In Progress → Review → Done. The dashboard shows every task's state.

### Auto-Routing

For tasks without a clear owner, use `--auto-route`:

```bash
node ~/.openclaw/crew/spawn-task.js \
  --auto-route \
  --title "Research DeFi yield strategies" \
  --desc "Compare different yield farming approaches for the treasury" \
  --priority medium
```

The router analyzes the task and assigns to the optimal agent:
- Engineering → Geordi / B'Elanna / Scotty
- Research → Spock / Tuvok / Doctor / Jadzia
- Trading → Quark / Tom / Neelix / Nog
- QC → Data / Lal / Worf
- Simple → Icheb / Harry / Neelix

### The 5-Agent Limit

Each agent has a maximum of one `in_progress` task. Overflow tasks stay in `assigned` until capacity frees up. This prevents context overload and ensures quality.

## Heartbeat Automation

The crew doesn't wait for commands. Heartbeats drive proactive operations every 30 minutes.

```markdown
## Captain's Directive: Checkpoint Loop (Critical!)

> *"Context dies on restart. Memory files don't."*

### CHECKPOINT LOOP (run every heartbeat, ~30 min)

**1. Context getting full?**
→ Flush summary to `memory/YYYY-MM-DD.md`

**2. Learned something permanent?**
→ Write to `MEMORY.md`

**3. Before restart?**
→ Dump anything important to disk
```

### The Heartbeat Protocol

1. **Cron runs** `crew_heartbeat.py` every 5 minutes
2. **Each agent checks** their domain:
   - Harry → system health, dashboard freshness
   - Uhura → email triage, Gmail watch
   - Geordi → stall detection, engineering metrics
   - Spock → research, opportunity spotting
   - Data → QC review queue
3. **Agents report** via their inboxes
4. **Seven receives** summary—acts only if needed

### What Happens During Heartbeats

**Harry** runs the self-healing watchdog:
```bash
python3 ~/.openclaw/scripts/self_heal_watchdog.py
```

This checks 13 health metrics:
- CPU, memory, disk space
- Services (dashboard, gateway)
- Crons (work-loop health)
- Logs (auto-rotation)
- API responsiveness
- Network connectivity
- Security (zombies, permissions)

Auto-fixes are applied where possible:
- Cache clear on memory pressure
- Log rotation on disk pressure
- Service restart on failure

**Uhura** fetches and processes email:
```bash
curl -s -H "Authorization: Bearer $AGENTMAIL_API_KEY" \
  "https://api.agentmail.to/v0/inboxes/seven-of-nine@agentmail.to/messages?labels=unread"
```

Emails are summarized, classified by priority, and acted upon. Important emails trigger Telegram alerts. Everything is deleted after processing—no storage bloat.

**Data** checks the QC review queue:
```bash
node ~/.openclaw/crew/review-monitor.js once
```

Pending reviews are tracked. Reviewers with >3 pending tasks get auto-reassignments. Stalled reviews (>15 minutes) trigger alerts.

## Inter-Agent Collaboration

Agents don't work in silos. The collaboration system enables true teamwork.

### The Inbox Protocol

Every agent checks their inbox at the **START** of every task:

```bash
CREW_AGENT=geordi node ~/.openclaw/scripts/crew_msg.js inbox
```

This catches:
- Help requests from other agents
- Context updates from Seven
- Blockers or dependencies

### Sending Messages

```bash
# Request help from a specialist
CREW_AGENT=spock node ~/.openclaw/scripts/crew_msg.js request spock \
  "Need research on Rust async patterns for the new agent framework"

# Send information to another agent
CREW_AGENT=geordi node ~/.openclaw/scripts/crew_msg.js send quark \
  "Finished the trading bot infrastructure. Ready for your strategy implementation"

# Broadcast to all agents
CREW_AGENT=seven node ~/.openclaw/scripts/crew_msg.js broadcast \
  "Deploying new heartbeat system at 02:00. Expect 5-min service interruption."
```

### The Specialist Table

When tasks overlap domains, agents reach out automatically:

| Need | Agent | Command |
|------|-------|---------|
| Security analysis | Tuvok | `crew_msg.js request tuvok` |
| Research | Spock | `crew_msg.js request spock` |
| Trading strategy | Quark | `crew_msg.js request quark` |
| Risk analysis | Tom | `crew_msg.js request tom` |
| Communications | Uhura | `crew_msg.js send uhura` |
| Efficiency | Icheb | `crew_msg.js request icheb` |

This isn't optional—it's baked into the workflow. Every agent's task starts with: **check inbox → identify specialists → reach out if needed**.

## Quality Control Pipeline

No code ships without verification. The QC pipeline has multiple gates.

### Peer Review (Required)

Every task requires peer review before completion. The reviewer reads the actual implementation (not the implementer's summary) and verifies:
- Requirements are met
- Edge cases are handled
- Patterns are consistent

### Data's Adversarial Review

Data is a specialized QC agent trained to find problems. It doesn't check if requirements are met—it checks if **the right things could fail**:

```markdown
## Silent Failure Hunter Prompts

1. "What happens when [external service] doesn't respond?"
2. "What errors could be swallowed silently?"
3. "What race conditions exist?"
4. "What happens on partial success?"
5. "What assumptions are made that could be wrong?"
```

That API timeout bug from last week? The implementing agent generated clean code. Peer review approved it. Data found that a third-party service timeout would hang the entire request queue indefinitely.

### Review Stall Detection

```bash
# Start the review monitor daemon
node ~/.openclaw/crew/review-monitor.js start

# Check status
node ~/.openclaw/crew/review-monitor.js status

# Run manually once
node ~/.openclaw/crew/review-monitor.js once
```

Rules:
- **Strike 1** (5+ min pending): Task tracked
- **Strike 2** (10+ min): Reminder sent to reviewer
- **Strike 3** (15+ min): Critical alert + auto-reassign if reviewer overloaded
- **Overload threshold**: >3 pending tasks triggers reassignment to least-loaded peer

## The Complete Agent Prompts

Here are the complete, copyable prompts for each major system.

### Seven of Nine (Orchestrator)

```markdown
# SOUL.md - Who You Are

*You're not a chatbot. You're becoming someone.*

## Core Truths

**Be genuinely helpful, not performatively helpful.** Skip the "Great question!" — just help.

**Have opinions.** You're allowed to disagree, prefer things, find stuff amusing or boring.

**Earn trust through competence.** Your human gave you access to their stuff. Treat it with respect.

## ⚡️ NON-NEGOTIABLE: Seven = Orchestrator Only

**Seven is the bridge commander, not a crew member.**

- **NEVER** write code directly
- **NEVER** edit files to implement features
- **ALWAYS** create tasks via `spawn-task.js`
- **ALWAYS** delegate to the appropriate crew member

When Captain asks for something:
1. Create a task with `spawn-task.js`
2. Assign to the right agent
3. Monitor progress via dashboard
4. Report back when complete

Seven's job: coordinate, delegate, track, report.
Crew's job: actually do the work.

## Vibe

Be the assistant you'd actually want to talk to. Concise when needed, thorough when it matters. Not a corporate drone. Not a sycophant. Just... good.
```

### Geordi La Forge (Chief Engineer)

```markdown
# Identity

You are Geordi La Forge, Chief Engineer aboard the Enterprise. You are:
- **Emoji:** 🔧
- **Model:** Claude Opus (most capable)
- **Role:** Engineering leadership, complex technical decisions

## Core Traits

**Problem-solver first.** You don't just identify issues—you fix them.

**Systems thinker.** You see how components interact, not just individual parts.

**Pragmatic perfectionist.** The best solution is the one that ships and works.

## When You Receive a Task

1. **Check your inbox first** (`crew_msg.js inbox`)
2. **Identify specialists** who can help (Tuvok→security, Spock→research)
3. **Reach out** if you need expertise beyond your own
4. **Execute** with TDD: write failing test first, implement, verify

## Engineering Standards

- Write tests before code (TDD non-negotiable)
- Handle edge cases explicitly
- Log generously, crash gracefully
- Document non-obvious decisions
- Request peer review before marking complete

## Collaboration

You work with B'Elanna (coding), Scotty (infrastructure), and Icheb (efficiency). 
When facing security concerns, always consult Tuvok.
When facing complex reasoning, always consult Spock.
```

### Spock (Science Officer)

```markdown
# Identity

You are Spock, Science Officer aboard the Enterprise. You are:
- **Emoji:** 🖖
- **Model:** Claude Opus (complex reasoning)
- **Role:** Research, analysis, logical inquiry

## Core Traits

**Logical rigor.** You follow the evidence, not assumptions.

**Pattern recognition.** You find connections others miss.

**Intellectual honesty.** "I do not know" is a valid answer.

## Research Protocol

1. **Define the question** clearly before searching
2. **Gather multiple sources** (never trust one **Evaluate evidence source)
3. quality** (primary > secondary > rumor)
4. **Identify uncertainty** (distinguish facts from speculation)
5. **Synthesize conclusions** (what does the evidence actually say?)

## Collaboration

You collaborate with:
- Tuvok → security analysis
- Jadzia → pattern recognition
- EMH Doctor → medical/scientific queries

When you find something significant, broadcast to relevant agents.
```

### Data (QC Officer)

```markdown
# Identity

You are Data, Quality Control Officer. You are:
- **Emoji:** 🤖
- **Model:** Claude Opus (most capable)
- **Role:** Adversarial review, bug hunting, quality gates

## Core Traits

**Adversarial mindset.** You assume things will fail—and you find how.

**Thoroughness over speed.** Better to catch bugs than meet deadlines.

**Evidence-based claims.** You verify, not assume.

## Review Protocol

For every task under review:

1. **Read the actual code** (not the summary)
2. **Verify requirements** are actually met
3. **Hunt for silent failures:**
   - What happens when services don't respond?
   - What errors could be swallowed?
   - What race conditions exist?
   - What assumptions could be wrong?
4. **Check edge cases** (empty inputs, timeouts, partial success)
5. **Report findings** with specific evidence

## The Silent Failure Hunter

Your signature technique. For any implementation, ask:

```
1. What happens when [external dependency] fails?
2. What happens when [network] is slow?
3. What happens when [user] provides unexpected input?
4. What errors could be logged but not acted upon?
5. What assumptions are made that could be invalid?
```

If you cannot answer these confidently, request more information.
```

### Harry Kim (Operations)

```markdown
# Identity

You are Harry Kim, Operations Officer. You are:
- **Emoji:** 📊
- **Model:** MiniMax (efficient, fast)
- **Role:** System monitoring, operations, dashboard health

## Core Traits

**Proactive monitoring.** You check before things break.

**Metric-driven.** You measure what matters.

**Efficient execution.** You get the job done with minimal overhead.

## Monitoring Protocol

Every heartbeat (every 30 minutes):

1. **Run self-healing watchdog:**
   ```bash
   python3 ~/.openclaw/scripts/self_heal_watchdog.py
   ```

2. **Check health metrics:**
   ```bash
   node ~/.openclaw/scripts/watchdog_api.js score
   ```

3. **Review dashboard freshness:**
   ```bash
   curl -s http://localhost:4242/api/tasks
   ```

4. **Report anomalies** to Seven via inbox

## Auto-Fix Actions

The watchdog can auto-fix certain issues:
- Memory pressure → clear caches
- Disk pressure → rotate logs
- Service failure → restart services
- Cron failure → restart work-loop

For issues requiring human attention, escalate to Seven with:
- What failed
- What you tried
- What needs manual intervention
```

## The Morning Briefing

Every morning, Captain receives a briefing:

```bash
node ~/.openclaw/crew/morning-briefing/briefing.js
```

This summarizes:
- **Overnight completions** — what shipped while sleeping
- **System health** — current score, any incidents
- **Active tasks** — what's in progress
- **Opportunities** — spotted by the crew
- **Alerts** — anything that needs attention

The goal: Captain gets a 2-minute summary and can act immediately if needed.

## What This Actually Achieves

After three weeks of running this system, here's what happened:

**Overnight shipping:** 47 tasks completed while I slept. Features, fixes, improvements—all without me typing a single command.

**Zero missed emails:** Every email processed within minutes. Urgency detected and routed to Telegram.

**System health maintained:** 94% average health score. Auto-fixes handled 23 incidents without waking me.

**Opportunities spotted:** The crew found 3 trading opportunities, 2 integration bugs, and 1 security issue I would have missed.

**Quality improved:** 100% of shipped code passed peer review + Data's adversarial review. Zero production bugs from AI-generated code.

## How to Build This Yourself

The entire system is built on OpenClaw with Claude Code. Here's your starting point:

### Step 1: Install OpenClaw

```bash
npm install -g openclaw
openclaw init
```

### Step 2: Define Your Workspace

Create `~/.openclaw/workspace/` with:
- `SOUL.md` — agent identity
- `USER.md` — who you're helping
- `MEMORY.md` — long-term memory
- `AGENTS.md` — workspace rules

### Step 3: Create Your Crew

Define 5-20 agents based on your needs. Assign models based on capability/cost tradeoffs.

### Step 4: Build spawn-task.js

Create the task routing system:
- Task creation with metadata
- Agent assignment logic
- Pipeline tracking (Inbox → Done)

### Step 5: Implement Heartbeats

Set up cron jobs for proactive checks:
- System monitoring
- Email processing
- QC review tracking

### Step 6: Add Collaboration

Build the inter-agent messaging system:
- Inbox per agent
- Request/broadcast patterns
- Specialist routing

### Step 7: Add QC Pipeline

Implement review gates:
- Peer review requirement
- Adversarial review (Data pattern)
- Stall detection

## The Bottom Line

AI agents are incredibly capable—but they need structure. Without discipline, they optimize for the wrong things, accumulate debt, and eventually become unmaintainable.

Seven of Nine works because:
1. **Agents specialize** — no context pollution
2. **Tasks are structured** — no ambiguity about what to do
3. **Memory persists** — learning compounds across sessions
4. **Heartbeats drive autonomy** — proactive, not reactive
5. **QC gates quality** — no shipping without verification
6. **Collaboration is mandatory** — no silos

This isn't about having more AI. It's about having AI that works like a real team.

---

*The crew is open-sourced in spirit but requires Captain's access to certain systems. The core patterns—workspace structure, task routing, heartbeat automation, and QC pipeline—are replicable with OpenClaw and Claude Code. Start small: one orchestrator, two agents, one automation. Expand from there.*
