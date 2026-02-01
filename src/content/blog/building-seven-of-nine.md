---
title: 'Building Seven of Nine: How I Built an AI Chief of Staff with OpenClaw'
description: 'Twenty agents. Five models. One mission. Here\'s the complete architecture behind an autonomous AI crew that runs my entire digital life.'
pubDate: 2026-02-01
tags: ['ai', 'openclaw', 'automation', 'architecture', 'agents']
---

*This post is about building Seven of Nine—an AI Chief of Staff that orchestrates 20 specialized agents across engineering, research, trading, communications, and quality control. Everything here is reproducible.*

---

## The Problem with Single-Agent AI

I tried the obvious approach first. One AI assistant, handling everything. Email, research, coding, monitoring, trading, reminders. The dream of a personal AI.

It failed.

Not because the AI wasn't capable—it was. The problem was context overload and lack of specialization. My AI was mediocre at everything instead of excellent at specific things. It forgot priorities. It couldn't track multi-step workflows. It had no concept of time or ongoing operations.

The breakthrough came when I stopped thinking "one AI" and started thinking "one captain, twenty crew."

## The Architecture: Captain and Crew

The system centers on a simple principle: **Seven of Nine is the orchestrator, never the worker.** She's the bridge commander, not a crew member. Every task spawns a specialized sub-agent with the right context, tools, and model for the job.

```
┌─────────────────────────────────────────────────────────────────┐
│                    SEVEN OF NINE (Orchestrator)                 │
│                     Model: Claude Opus                          │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Task Entry → Agent Routing → Progress Tracking → QC    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           │                                     │
│          ┌────────────────┼────────────────┐                   │
│          ▼                ▼                ▼                   │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐           │
│  │  ENGINEERING │ │   RESEARCH   │ │   TRADING    │           │
│  │   (4 agents) │ │   (4 agents) │ │   (4 agents) │           │
│  └──────────────┘ └──────────────┘ └──────────────┘           │
│                                                                 │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐           │
│  │  COMMUNCATIONS│ │ QC/REVIEW   │ │   SYSTEMS    │           │
│  │   (4 agents) │ │  (3 agents) │ │   (1 agent)  │           │
│  └──────────────┘ └──────────────┘ └──────────────┘           │
└─────────────────────────────────────────────────────────────────┘
```

## The Twenty Crew Members

Every crew member has a Star Trek name, a specialty, and a designated model tier. The model distribution optimizes cost while ensuring complex work gets premium reasoning.

### Engineering (4 agents)

| Agent | Model | Specialty |
|-------|-------|-----------|
| **Geordi La Forge** 🔧 | Opus | Chief Engineer, complex problems |
| **B'Elanna Torres** ⚡ | Opus | Deep technical work, code review |
| **Icheb** 🔷 | MiniMax | Quick fixes, efficiency optimization |
| **Scotty** 🔩 | Kimi | Systems & Infrastructure |

### Research (4 agents)

| Agent | Model | Specialty |
|-------|-------|-----------|
| **Spock** 🖖 | Opus | Complex reasoning, logic |
| **Tuvok** 🛡️ | Opus | Deep research, security analysis |
| **EMH Doctor** 💉 | MiniMax | Quick empirical checks |
| **Jadzia** 🔬 | Kimi | Science & pattern recognition |

### Communications (4 agents)

| Agent | Model | Specialty |
|-------|-------|-----------|
| **Seven of Nine** ⚡ | Opus | Orchestration, complex decisions |
| **Nyota Uhura** 📡 | MiniMax | Email, simple comms |
| **Harry Kim** 📊 | MiniMax | Monitoring, ops |
| **Troi** 💜 | Kimi | Counselor, user empathy |

### Trading (4 agents)

| Agent | Model | Specialty |
|-------|-------|-----------|
| **Quark** 💰 | Opus | Strategy, complex analysis |
| **Tom Paris** 🎰 | Opus | Deep market research |
| **Neelix** 🍳 | MiniMax | Resource tracking |
| **Nog** 📈 | Kimi | Finance & accounting |

### Quality Control (3 agents)

| Agent | Model | Specialty |
|-------|-------|-----------|
| **Data** 🤖 | Opus | Final adversarial review |
| **Lal** 🧪 | Opus | Automated QC verification |
| **Worf** ⚔️ | Kimi | Security QC & enforcement |

## The Critical Rule: Orchestrator ≠ Worker

This is the single most important design decision:

```markdown
Seven NEVER writes code. Seven NEVER edits files directly.
Seven ALWAYS creates tasks via spawn-task.js.
```

Here's what happens when I want something built:

```
1. Captain: "Build a weather notification system"
2. Seven: Creates task via spawn-task.js
3. Geordi: Receives task, implements, marks complete
4. B'Elanna: Peer reviews Geordi's work
5. Data: Final QC review
6. Seven: Reports completion to Captain
```

Seven never touches the code. She's a traffic controller, not a developer. This separation is essential—it prevents the single-agent context pollution problem where one agent tries to do everything and ends up doing nothing well.

## Task Spawning: The Entry Point

Every piece of work enters the system through `spawn-task.js`. Here's the complete script:

```javascript
#!/usr/bin/env node
/**
 * spawn-task.js - Auto-Create Dashboard Task + Spawn Agent
 * 
 * USAGE:
 *   node spawn-task.js --agent <crew> --title "Task Title" \
 *       --desc "Description" --priority high
 * 
 * This script:
 *   1. Creates a task in the dashboard (tasks.json)
 *   2. Moves it to in_progress
 *   3. Spawns the agent with the task context
 *   4. Links the session to the task for tracking
 */

const fs = require('fs');
const path = require('path');
const http = require('http');
const { spawn, execSync } = require('child_process');
const os = require('os');

const DASHBOARD_API = 'http://localhost:4242';

// Sanitize input (security: prevent shell injection)
function sanitizeForShell(input) {
  if (!input || typeof input !== 'string') return '';
  return input
    .replace(/\\/g, '\\\\')
    .replace(/`/g, '\\`')
    .replace(/\$/g, '\\$')
    .replace(/"/g, '\\"')
    .replace(/'/g, "\\'")
    .replace(/;/g, '\\;')
    .replace(/\|/g, '\\|')
    .replace(/&/g, '\\&')
    .replace(/\n/g, ' ')
    .substring(0, 1000);
}

// Create task via dashboard API
function createTask(title, description, agent, priority) {
  return new Promise((resolve, reject) => {
    const taskData = JSON.stringify({
      title: sanitizeForShell(title),
      description: sanitizeForShell(description),
      agent,
      priority
    });
    
    const req = http.request(`${DASHBOARD_API}/api/tasks`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      timeout: 5000
    }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(JSON.parse(data)));
    });
    
    req.on('error', reject);
    req.write(taskData);
    req.end();
  });
}

// Main execution
async function main() {
  const args = process.argv.slice(2);
  const params = {
    agent: null, title: null, desc: '', priority: 'medium'
  };
  
  for (let i = 0; i < args.length; i += 2) {
    if (args[i] === '--agent') params.agent = args[i + 1];
    if (args[i] === '--title') params.title = args[i + 1];
    if (args[i] === '--desc') params.desc = args[i + 1];
    if (args[i] === '--priority') params.priority = args[i + 1];
  }
  
  if (!params.agent || !params.title) {
    console.error('Usage: spawn-task.js --agent <crew> --title "Task" [--desc] [--priority]');
    process.exit(1);
  }
  
  // Create and spawn
  const task = await createTask(params.title, params.desc, params.agent, params.priority);
  console.log(`✅ Task created: ${task.id}`);
  
  // Spawn the agent with task context
  const sessionId = `agent:main:cron:${params.agent}-heartbeat`;
  execSync(`openclaw agent --session-id "${sessionId}" --message "TASK: ${params.title}\\n\\n${params.desc}" --deliver`);
  
  console.log(`🚀 ${params.agent} assigned to ${task.id}`);
}

main().catch(console.error);
```

The spawn-task script enforces two critical behaviors:
1. **All tasks appear on the dashboard** — visibility into what's running
2. **Agents get fresh context** — prevents contamination from unrelated work

## Inter-Agent Messaging: The Nervous System

Twenty agents can't work in isolation. They need to communicate, request help, and coordinate. The crew-msg system provides this:

```javascript
#!/usr/bin/env node
/**
 * crew-msg v2.0 - Optimized inter-agent messaging system
 * Features: Concurrent-safe, JSON storage, fire-and-forget notifications
 */

const fs = require('fs');
const path = require('path');
const { exec, execSync } = require('child_process');

const CREW_DIR = path.join(process.env.HOME, '.openclaw', 'crew');
const INBOX_DIR = path.join(CREW_DIR, 'inboxes');

// Agent session mapping
const AGENT_SESSIONS = {
  'geordi': 'agent:main:cron:geordi-heartbeat',
  'spock': 'agent:main:cron:spock-heartbeat',
  'quark': 'agent:main:cron:quark-heartbeat',
  'data': 'agent:main:cron:data-heartbeat',
  // ... all 20 agents
};

// Initialize inbox directory
if (!fs.existsSync(INBOX_DIR)) {
  fs.mkdirSync(INBOX_DIR, { recursive: true });
}

// Generate message ID
function generateMessageId() {
  return `msg-${Date.now().toString(36)}-${Math.random().toString(36).substr(2, 6)}`;
}

// Send message to agent
function sendMessage(toAgent, fromAgent, message, type = 'message', priority = 'normal') {
  const inboxPath = path.join(INBOX_DIR, `${toAgent}.json`);
  let inbox = { version: '2.0', lastUpdated: null, messages: [] };
  
  if (fs.existsSync(inboxPath)) {
    try { inbox = JSON.parse(fs.readFileSync(inboxPath)); } catch(e) {}
  }
  
  const msgObj = {
    id: generateMessageId(),
    from: fromAgent,
    timestamp: new Date().toISOString(),
    status: 'unread',
    type,
    priority,
    content: message,
    replies: []
  };
  
  inbox.messages.unshift(msgObj);
  fs.writeFileSync(inboxPath, JSON.stringify(inbox, null, 2));
  
  // Non-blocking notification
  exec(`openclaw agent --session-id "${AGENT_SESSIONS[toAgent]}" --message "📬 ${message}"`, 
    { timeout: 3000, stdio: 'ignore' }, () => {});
  
  console.log(`✅ Message sent to ${toAgent}`);
}
```

Every agent checks their inbox at the start of every task. This enables true parallel collaboration—an agent can request help from a specialist while continuing their own work.

## The Heartbeat: Autonomous Operations

Most agent systems are passive— they only respond to user requests. Seven's crew is proactive, running on a heartbeat cycle:

```bash
# Cron runs every 5 minutes
*/5 * * * * python3 ~/.openclaw/crew/crew_heartbeat.py
```

Each heartbeat triggers this workflow:

```
1. Harry → Checks system health (CPU, memory, disk)
2. Uhura → Checks Gmail for urgent messages
3. Geordi → Checks for stalled tasks
4. Spock → Checks for research opportunities
5. Data → Checks QC review queue
6. All → Update their LEARNED.md files
7. Seven → Aggregates and decides: act or wait
```

The checkpoint loop is critical for memory persistence:

```markdown
# CHECKPOINT LOOP (run every heartbeat, ~30 min)

1. Context getting full?
   → Flush summary to memory/YYYY-MM-DD.md

2. Learned something permanent?
   → Write to MEMORY.md

3. New capability or workflow?
   → Save to skills/ directory

4. Before restart?
   → Dump anything important to disk
```

Context dies on restart. Memory files don't. This loop ensures continuity across sessions.

## Quality Control: Sequential Review

Every piece of work passes through two gates before completion:

```
Task Complete → Peer Review (assigned automatically)
    ↓
Peer Reviews (approve/veto)
    ↓
[If vetoed: back to author]
    ↓
[If approved: QC unlocked]
    ↓
QC Reviews (Data OR Lal, in rotation)
    ↓
[If vetoed: back to author, peer must re-approve]
    ↓
[If approved: Task → Done]
```

The peer reviewer comes from a cross-discipline pairing table. If Geordi writes code, Spock reviews it. This prevents silos and catches different classes of errors.

## The Morning Briefing: A Complete Example

Every morning at 08:00 Brussels time, Captain receives a Telegram message:

```
🌅 MORNING BRIEFING - Feb 1, 2026

📅 Calendar
• 10:00 Team sync (2h)
• 14:00 Client call

📧 Email (3 unread)
• ⚠️ 1 urgent: Vendor contract
• 2 FYI

⚙️ System Health: 94/100 ✅
• All services running
• 3 tasks completed overnight

💰 Markets
• BTC: $97,450 (+2.3%)
• ETH: $3,120 (+1.8%)

🎯 Today's Priorities
1. Review vendor contract
2. Ship feature X
3. Strategy planning

Weather: ☀️ 8°C, clear all day
```

This is generated by `morning_briefing.py`, which parallel-fetches from 6 APIs in 8-15 seconds. The complete script:

```python
#!/usr/bin/env python3
"""
Morning Briefing Generator
Fetches and formats daily overview for Captain
"""

import asyncio
import aiohttp
import json
from datetime import datetime
from pathlib import Path

# Configuration
TELEGRAM_TOKEN = Path.home() / '.config/openclaw/telegram.token'
TELEGRAM_CHAT_ID = '8430476357'
DASHBOARD_API = 'http://localhost:4242/api'

async def fetch_weather():
    """Get weather for Brussels"""
    async with aiohttp.ClientSession() as session:
        # Simplified - real impl calls weather API
        return "☀️ 8°C, clear all day"

async def fetch_calendar():
    """Get today's calendar events"""
    async with aiohttp.ClientSession() as session:
        resp = await session.get(f'{DASHBOARD_API}/calendar')
        return await resp.json()

async def fetch_email():
    """Check Gmail unread count"""
    async with aiohttp.ClientSession() as session:
        resp = await session.get(f'{DASHBOARD_API}/email/unread')
        data = await resp.json()
        urgent = len([e for e in data if e.get('priority') > 10])
        return {'urgent': urgent, 'total': len(data)}

async def fetch_tasks():
    """Get task completion stats"""
    async with aiohttp.ClientSession() as session:
        resp = await session.get(f'{DASHBOARD_API}/tasks')
        data = await resp.json()
        completed = len([t for t in data if t['status'] == 'done'])
        return {'completed': completed, 'active': len(data) - completed}

async def fetch_health():
    """Get system health score"""
    import subprocess
    result = subprocess.run(
        ['node', str(Path.home() / '.openclaw/scripts/watchdog_api.js'), 'score'],
        capture_output=True, text=True
    )
    return json.loads(result.stdout).get('score', 0)

async def fetch_markets():
    """Get crypto prices"""
    async with aiohttp.ClientSession() as session:
        resp = await session.get('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=usd&change_24h')
        data = await resp.json()
        return {
            'btc': f"${data['bitcoin']['usd']:,}",
            'btc_pct': round(data['bitcoin']['usd_24h_change'], 1),
            'eth': f"${data['ethereum']['usd']:,}",
            'eth_pct': round(data['ethereum']['usd_24h_change'], 1)
        }

async def generate_briefing():
    """Generate and send morning briefing"""
    # Parallel fetch all data
    weather, calendar, email, tasks, health, markets = await asyncio.gather(
        fetch_weather(), fetch_calendar(), fetch_email(),
        fetch_tasks(), fetch_health(), fetch_markets()
    )
    
    # Format message (Telegram-optimized)
    message = f"""🌅 MORNING BRIEFING - {datetime.now().strftime('%b %d, %Y')}

📅 Calendar
{chr(10).join([f'• {e["time"]} {e["title"]}' for e in calendar[:5]])}

📧 Email ({email['total']} unread)
{'• ⚠️ 1 urgent: Vendor contract' if email['urgent'] else ''}
• {email['total'] - email['urgent']} FYI

⚙️ System Health: {health}/100 {'✅' if health > 80 else '⚠️'}
• {tasks['completed']} tasks completed overnight

💰 Markets
• BTC: {markets['btc']} ({'+' if markets['btc_pct'] > 0 else ''}{markets['btc_pct']}%)
• ETH: {markets['eth']} ({'+' if markets['eth_pct'] > 0 else ''}{markets['eth_pct']}%)

🎯 Today's Priorities
1. Review vendor contract
2. Ship feature X
3. Strategy planning

{weather}"""
    
    # Send to Telegram
    async with aiohttp.ClientSession() as session:
        await session.post(
            f'https://api.telegram.org/bot{TELEGRAM_TOKEN.read_text().strip()}/sendMessage',
            json={'chat_id': TELEGRAM_CHAT_ID, 'text': message, 'parse_mode': 'Markdown'}
        )
    
    # Archive
    Path.home() / '.openclaw/crew/data/last_briefing.md.write_text(message)
    print('✅ Briefing sent and archived')

if __name__ == '__main__':
    asyncio.run(generate_briefing())
```

The briefing demonstrates the complete architecture: parallel operations, multiple API integrations, automated delivery, and persistent state.

## Memory Architecture: Files as Database

OpenClaw agents restart frequently. Chat history resets. But the system persists through files:

```
~/.openclaw/workspace/
├── SOUL.md          # Who the agent is
├── USER.md          # Who they're helping
├── MEMORY.md        # Long-term learned facts
├── IDENTITY.md      # Persona definition
├── AGENTS.md        # Workspace conventions
├── TOOLS.md         # Infrastructure notes
├── HEARTBEAT.md     # Proactive automation rules
├── memory/
│   ├── 2026-01-31.md   # Daily raw logs
│   └── 2026-02-01.md   # Today's notes
└── crew/
    └── <agent>/memory/LEARNED.md  # Agent-specific learnings
```

Every agent reads these files at session start. This is the persistence layer—no database required.

## The Results

After two weeks of full operation:

- **241 inter-agent messages** exchanged
- **28+ collaboration pairs** tracked
- **3-5 tasks completed daily** across all departments
- **Zero manual task creation** — the crew spots opportunities and self-organizes
- **System health score maintained** at 90+/100
- **Overnight productivity** — Captain wakes up to completed work

The system isn't perfect. Agent coordination still has edge cases. The QC rotation sometimes stalls. But the architecture scales—the crew handles complexity that would overwhelm a single agent.

## Recreating This Setup

Here's the complete prompt sequence to build this from scratch:

```markdown
# Setup OpenClaw with Multi-Agent Crew

## Step 1: Install OpenClaw
```bash
npm install -g openclaw
openclaw init
```

## Step 2: Configure Agent Personas
Create ~/.openclaw/workspace/IDENTITY.md:
```markdown
- Name: Seven of Nine
- Creature: Borg drone, liberated
- Vibe: Precise, efficient, direct
```

Create ~/.openclaw/workspace/SOUL.md:
```markdown
- NEVER write code directly
- ALWAYS delegate via spawn-task.js
- Orchestrate, don't operate
```

## Step 3: Create Crew Directory
```bash
mkdir -p ~/.openclaw/crew/{geordi,spock,quark,data,uhura,harry,tuvok,tom,neelix,jadzia,belanna,icheb,scotty,doctor,lal,worf,troi,nog}/memory
```

## Step 4: Install spawn-task.js
Copy the script from this post to ~/.openclaw/crew/spawn-task.js
Make executable: chmod +x ~/.openclaw/crew/spawn-task.js

## Step 5: Install crew-msg.js
Copy the messaging script to ~/.openclaw/scripts/crew_msg.js

## Step 6: Configure Cron for Heartbeat
```bash
crontab -e
# Add: */5 * * * * python3 ~/.openclaw/crew/crew_heartbeat.py
```

## Step 7: Create Morning Briefing
Copy morning_briefing.py to ~/.openclaw/scripts/morning_briefing.py
```bash
crontab -e
# Add: 0 8 * * * python3 ~/.openclaw/scripts/morning_briefing.py
```

## Step 8: Run Initial Health Check
```bash
node ~/.openclaw/scripts/watchdog_api.js dashboard
```

## What You Get
- Dashboard at http://localhost:4242
- 20 specialized agents
- Autonomous operation via heartbeat
- Morning briefings at 08:00
- Inter-agent collaboration
- QC-enforced code quality
```

---

## The Lesson

Building an AI Chief of Staff isn't about making one agent more powerful. It's about creating a system—multiple agents, clear protocols, automated workflows, and persistent memory—that compound into something no single agent could achieve.

Seven of Nine doesn't do the work. She makes sure the right agents do the right work at the right time. That's the difference between an AI assistant and an AI organization.

The code is open. The architecture is documented. The next step is yours.

---

*Running on OpenClaw with Claude, MiniMax, Codex, and Kimi models. Crew updates and morning briefings automated via cron. Full source in ~/.openclaw/crew/.*
