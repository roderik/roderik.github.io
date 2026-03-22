---
name: prd-builder
description: >-
  Build a structured PRD from a project idea through iterative brainstorming,
  research, and refinement. Outputs a complete PRD markdown document following
  the strict 6-section schema (including Agent Execution Context). Pure content
  producer — does NOT interact with Linear or any ticket system. Orchestrated
  by brainstorm, commands, or other skills. Not user-invocable. Use when a PRD
  needs to be drafted or refined from an idea, problem statement, or existing
  spec. Do NOT use for ticket decomposition (use task-builder) or Linear
  operations (use brainstorm).
user-invocable: false
---

<objective>
Turn a project idea into a structured Product Requirements Document through iterative brainstorming, research, and refinement. Output the PRD as markdown to a specified file path.

This skill is a pure content producer — it does not interact with Linear, create tickets, or manage project metadata. Orchestrating skills call prd-builder and decide where to store the result.

The PRD must read like something a senior PM at a top-tier company would write. If it reads like a template with blanks filled in, it doesn't meet the bar.
</objective>

<interface>
## Context Contract

The calling skill must establish the following context in the conversation before this skill's SKILL.md is read and followed. These are not function parameters — they are conversation context that prd-builder expects to find.

| Context | Required | Description |
|---------|----------|-------------|
| `idea` | Yes | The raw project idea, problem statement, or existing PRD to refine |
| `output-path` | Yes | File path where the final PRD markdown should be written |
| `mode` | No | `new` (default) or `refine` — draft from scratch or refine existing content |
| `constraints` | No | Additional constraints, tech stack requirements, or scope boundaries |
| `research-context` | No | Pre-gathered research findings to incorporate |
| `autonomous` | No | `true` for headless execution (ralph.sh). Auto-approves after drafting instead of waiting for user input. Defaults to `false`. |

## Output

- Writes the approved PRD as markdown to `output-path`
- The PRD follows the strict 6-section schema from `references/prd-schema.md`
- Returns control to the calling skill
</interface>

<essential_principles>

### 1. Pure content production
Produce a PRD markdown file — nothing else. No Linear API calls, no ticket creation, no project metadata, no implementation. The calling skill handles storage and orchestration.

### 2. Iterative refinement with the user
Keep brainstorming and refining until the user explicitly approves. One focused question at a time. Prefer multiple-choice options over open-ended questions — they reduce cognitive load and keep the conversation moving. In autonomous mode, skip user interaction and make best-judgment calls.

### 3. Research-backed decisions
Use every available tool to produce the best possible PRD:
- **Codebase exploration** (Explore agents) for existing patterns, constraints, and architecture that shape the technical spec
- **context7** for library documentation when specific libraries are mentioned
- **exa** for web research, competitor analysis, technical approach validation
- **codex** for second opinions and assumption challenges

When research sources disagree, present both perspectives to the user with the evidence for each. The user decides. In autonomous mode, pick the more conservative approach and note the tradeoff.

### 4. Section 6 is mandatory
Every PRD includes the Agent Execution Context section (Section 6). This is not optional because all implementation tasks are picked up by autonomous agents or agent-assisted sessions. Module Inventory, Architectural Boundaries, Global Anti-Requirements, and State Machines give agents the project-level constraints they need.

### 5. Codex has no context
Every `mcp__codex__codex` prompt must be fully self-contained — include all relevant facts, constraints, and tech stack details directly in the prompt. Codex cannot see the conversation, the codebase, or the PRD draft. Give it the information and ask a focused question. Keep prompts under 2000 words for best results.
</essential_principles>

<process>

Read `references/prd-schema.md` and `references/brainstorm-techniques.md` before proceeding. Use `templates/prd-template.md` as the structural skeleton for the output.

---

### Phase A: Understand intent

**If `mode` is `refine` and `idea` contains existing PRD content:**

Present the existing PRD briefly and ask the user:

> What would you like to do?
> 1. **Rewrite** the spec from scratch
> 2. **Adjust or extend** the current spec
> 3. **Refine a specific section** — tell me which

**If `mode` is `new` or no existing content:** Skip to Phase B.

**Autonomous mode:** If `mode` is `refine`, default to "adjust or extend." If `mode` is `new`, proceed directly to Phase B.

---

### Phase B: Discovery & research

#### Step 1: Idea dump

If `idea` is brief or high-level (under ~200 words), ask the user to expand:

> Tell me everything you have in mind — the problem, the solution, constraints, half-baked thoughts, inspirations, anything. I'll sort through it and ask targeted follow-ups.

If `idea` is already thorough, skip to Step 2.

**Autonomous mode:** Use `idea` as-is. Do not ask for expansion.

#### Step 2: Targeted follow-ups

Based on gaps in the idea, ask follow-up questions **one at a time**. Only ask what's missing:

| Gap | Question |
|-----|----------|
| Problem / motivation unclear | "What's the pain point this solves? Why now?" |
| Users / personas not mentioned | "Who are the primary users? What do they care about?" |
| Success criteria absent | "How will we know this worked? What metrics matter?" |
| Technical constraints unaddressed | "Any hard constraints on stack, performance, or security?" |
| Scope boundaries vague | "What are we explicitly NOT building?" |

Skip any question already answered. If the idea was thorough, proceed directly to Step 3.

**Autonomous mode:** Infer reasonable answers from the idea and codebase exploration. Do not ask the user. If codebase exploration returns nothing useful (e.g., entirely new domain), proceed with the information available and note gaps as "TBD — resolve during implementation" in the PRD.

#### Step 3: Research

Launch research in parallel where possible:

**Codebase exploration** (always do this):
- Launch Explore agents to understand existing architecture, patterns, and constraints relevant to the project
- Identify which packages, services, and patterns the project touches
- This directly feeds Section 4 (Technical Specifications) and Section 6 (Agent Execution Context)

**Library docs** (if specific libraries are mentioned):
- `mcp__context7__resolve-library-id` to find the library
- `mcp__context7__query-docs` for API details, patterns, and limitations

**Web research** (if the project involves external integrations, competitive features, or unfamiliar territory):
- `mcp__exa__web_search_exa` for competitor analysis, market context, or technical approaches
- `mcp__exa__deep_researcher_start` + `mcp__exa__deep_researcher_check` for complex topics needing thorough investigation

Summarize research findings to the user before proceeding. In autonomous mode, summarize findings in internal notes and proceed.

---

### Phase C: Brainstorm facilitation

Apply techniques from `references/brainstorm-techniques.md`:

**Autonomous mode for Phase C:** Skip all user interaction. Generate approaches, use codex to challenge (if available — proceed without if not), pick the approach that best balances pragmatism and the project's stated constraints, then proceed to Phase D.

**Interactive mode for Phase C:**

#### 1. Diverge
Generate 2-3 genuinely different approaches for the key architectural or product decisions. Each approach should have clear trade-offs. One approach should always be the simplest thing that could work.

Present with pros/cons in a table or bullet format.

#### 2. Challenge
Use `mcp__codex__codex` to get an independent challenge. The prompt must be self-contained:

> "I'm building [X] for [context]. The proposed approach is: [full details]. Constraints: [list]. Tech stack: [stack]. What are we missing? What could go wrong? What would you do differently?"

Share the codex response with the user. If codex is unavailable, proceed without — note which assumptions were not independently challenged.

#### 3. Converge
Ask the user which direction to pursue:

> Based on the analysis, which approach do you prefer?
> 1. [Approach A] — [one-line summary]
> 2. [Approach B] — [one-line summary]
> 3. Combine elements (tell me which)

#### 4. Deepen
Drill into the chosen approach. Fill out PRD sections incrementally, asking the user to validate key decisions along the way.

---

### Phase D: Draft PRD

Using `references/prd-schema.md` for quality standards and `templates/prd-template.md` for structure, draft the complete PRD.

**Autonomous mode for Phase D:** Draft all 6 sections in one pass without pausing for feedback. After drafting, use codex to review the complete PRD (if available). If codex is unavailable, run a self-review pass checking each section against the quality standards in `references/prd-schema.md`. Then proceed directly to Phase E.

**Interactive mode for Phase D:** Present the draft **section by section** — do NOT dump the entire document at once:

1. **Executive Summary** — Problem, solution, success criteria. Ask for feedback.
2. **User Experience & Functionality** — Personas, user stories with acceptance criteria, non-goals. Ask for feedback.
3. **AI System Requirements** — Only if the project involves AI/ML. Skip otherwise. Ask for feedback.
4. **Technical Specifications** — Architecture, integration points, security, performance. Ground this in codebase exploration findings. Ask for feedback.
5. **Risks & Roadmap** — Phased rollout, technical risks with likelihood/impact, open questions. Ask for feedback.
6. **Agent Execution Context** — Module Inventory, Architectural Boundaries, Global Anti-Requirements, State Machines. Ground this in codebase exploration. This section is always included. Ask for feedback.

**Non-Functional Requirements checklist** — Before assembling the final PRD, verify Section 4 explicitly addresses every applicable category. Do NOT leave these to the reader's imagination:

| Category | What to specify | Example |
|----------|----------------|---------|
| **Performance** | Latency (p50/p95/p99), throughput, batch sizes | "p95 < 200ms for single transfers, batch of 100 < 5s" |
| **Security** | AuthZ model, data classification, encryption at rest/in transit | "Only token admins can approve; AES-256 at rest" |
| **Scalability** | Concurrency limits, data volume projections, horizontal scaling | "Support 10k concurrent WebSocket connections" |
| **Observability** | Logging, metrics, alerting, tracing | "Structured logs for every state transition; alert on error rate > 1%" |
| **Compliance** | Regulatory requirements, audit trail, data retention | "Immutable audit log retained 7 years; GDPR data subject access" |
| **Accessibility** | WCAG level, keyboard navigation, screen reader support | "WCAG 2.1 AA; all interactive elements keyboard-accessible" |
| **Reliability** | SLA targets, failure modes, recovery | "99.9% uptime; graceful degradation when indexer is behind" |

If a category is genuinely not applicable, state so explicitly (e.g., "Accessibility: N/A — backend-only feature"). Never silently omit a category.

After all sections are reviewed, assemble and present the complete PRD for final review.

---

### Phase E: Iteration checkpoint

Ask the user:

> How would you like to proceed?
> 1. **Approve** — finalize this PRD
> 2. **Refine a section** — tell me which section to revisit
> 3. **More research** — tell me what topic to investigate further
> 4. **Different approach** — restart the brainstorm with a new direction

| Response | Action |
|----------|--------|
| Approve | Proceed to Phase F |
| Refine | Loop back to Phase D for the specified section |
| Research | Loop back to Phase B Step 3 with the specific topic |
| Different | Loop back to Phase B from scratch — **re-run codebase exploration** for the new direction since architectural assumptions may have changed. Do not reuse stale research from the previous approach. |

Keep iterating until the user approves.

**Autonomous mode:** Auto-approve. Proceed directly to Phase F.

---

### Phase F: Write output

Write the approved PRD markdown to `output-path` using the Write tool.

Return control to the calling skill. Do NOT start implementation, create tickets, or interact with any external systems.
</process>

<reference_index>
## References

All in `references/`:
- **prd-schema.md** — The strict 6-section PRD output schema with quality standards. Read before drafting.
- **brainstorm-techniques.md** — Facilitation patterns: Diverge-Converge, Five Whys, SCAMPER, Assumption Challenging, Second Opinion, Research-Backed Validation. Read before Phase C.

## Templates

All in `templates/`:
- **prd-template.md** — Markdown skeleton for the PRD with all 6 sections. Use as the structural starting point for drafting.
</reference_index>

<gotchas>
## Gotchas

- **Template-itis**: The biggest failure mode. Claude defaults to filling in template placeholders with generic text. Every section should contain project-specific content grounded in research. If a sentence could appear in any PRD, it's too generic — rewrite it with specifics.
- **Skipping codebase exploration**: Section 4 (Technical Specifications) and Section 6 (Agent Execution Context) require actual codebase findings. If you skip the Explore step, these sections will contain guesses that mislead implementing agents. Always explore before drafting Sections 4 and 6.
- **Codex context bleed**: Codex has zero shared context. If you send it "review my PRD" without pasting the PRD text, it will hallucinate or give generic feedback. Always paste the full content into the codex prompt.
- **Dumping the whole PRD at once**: Users get overwhelmed and rubber-stamp. Present section-by-section and get feedback on each before assembling the whole document.
- **Vague success criteria**: "The system should be fast" is not a criterion. Every success criterion needs a number ("p95 < 200ms") or a concrete condition ("Lighthouse Accessibility score = 100").
- **Research tool failures**: If context7, exa, or codex are unavailable, proceed with codebase exploration alone (which uses only local tools). Note in the PRD which assumptions were not externally validated. Never block on a research tool failure.
- **Autonomous mode silent failures**: In autonomous mode, there's no user to catch mistakes. The Phase D autonomous instructions handle this — codex review if available, self-review if not. The Phase E auto-approve only fires after Phase D's review pass.
- **Section 6 as afterthought**: Module Inventory and Architectural Boundaries are often written last and given the least thought. These directly shape every implementation task. Spend as much time on Section 6 as on Section 4.
</gotchas>

<success_criteria>
- PRD follows the strict 6-section schema from `references/prd-schema.md` — all sections present including Section 6 (Agent Execution Context)
- PRD written to the specified `output-path`
- Research tools used to validate at least one key assumption (codebase exploration at minimum)
- Section 4 and Section 6 grounded in actual codebase findings, not guesses
- User explicitly approved before writing (or auto-approved in autonomous mode)
- Quality standards met: concrete measurable criteria, testable acceptance criteria, no vague language
- Reads like a senior PM wrote it — not a filled-in template
- No Linear interaction, no ticket creation, no implementation started
</success_criteria>
