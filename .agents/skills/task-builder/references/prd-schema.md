<overview>
## PRD Schema

The strict output schema for Product Requirements Documents produced by the brainstorm skill. Every PRD must follow this structure. The rendered PRD is stored as the Linear project description.

Adapted from the `prd` skill — same quality standards, structured for Linear storage.
</overview>

<quality_standards>
### Requirements Quality

Use concrete, measurable criteria. Never use vague terms.

**Bad** (vague):
- "The system should be fast"
- "The UI must be intuitive"
- "Handle errors gracefully"

**Good** (concrete):
- "API responses must complete within 200ms at p95 for datasets under 10k records"
- "The UI must achieve 100% Lighthouse Accessibility score"
- "Failed API calls must retry 3 times with exponential backoff, then surface a user-visible error with the specific failure reason"

### Acceptance Criteria

Every user story must have testable acceptance criteria. Prefer the format:
- Given [context], when [action], then [expected result]

Or simple checkboxes:
- [ ] Specific, testable criterion
</quality_standards>

<schema>
### Strict PRD Schema

Follow this exact structure. Section 3 (AI System Requirements) can be omitted when not relevant. All other sections are mandatory.

---

#### 1. Executive Summary

- **Problem Statement**: 1-2 sentences on the pain point. Why are we building this now?
- **Proposed Solution**: 1-2 sentences on the approach.
- **Success Criteria**: 3-5 measurable KPIs that define "done".

---

#### 2. User Experience & Functionality

- **User Personas**: Who is this for? Brief description of each persona.
- **User Stories**: `As a [persona], I want to [action] so that [benefit].`
  - Each story must have **Acceptance Criteria** (testable conditions).
- **Non-Goals**: What are we explicitly NOT building? Protect the timeline.

---

#### 3. AI System Requirements (if applicable)

Only include if the project involves AI/ML components.

- **Model/Tool Requirements**: What models, APIs, or tools are needed?
- **Data Requirements**: What data is needed? Source, format, volume.
- **Evaluation Strategy**: How to measure output quality and accuracy.
- **Guardrails**: Safety, bias, and reliability considerations.

---

#### 4. Technical Specifications

- **Architecture Overview**: High-level data flow and component interaction. Keep it concise — this is a PRD, not a design doc.
- **Integration Points**: APIs, databases, auth, external services.
- **Security & Privacy**: Data handling, compliance, access control.
- **Performance Requirements**: Latency, throughput, scale targets (with numbers).

---

#### 5. Risks & Roadmap

- **Phased Rollout**: MVP scope vs. future phases. What's in v1 vs. later?
- **Technical Risks**: Dependencies, unknowns, performance concerns. Rate each: likelihood (low/med/high) x impact (low/med/high).
- **Open Questions**: Decisions that still need to be made. Tag with owner if known.

---

#### 6. Agent Execution Context

Every PRD includes this section because implementation tasks are picked up by autonomous agents (ralph.sh) or agent-assisted sessions. This section gives agents the project-level constraints they need to make correct decisions on every ticket.

- **Module Inventory**: Which existing packages and patterns must be used across the project. This is the project-level version of per-ticket Module Mapping — agents inherit these constraints on every ticket.
- **Architectural Boundaries**: Which packages can depend on which. Draw the dependency arrows (e.g., `kit/dapp → packages/dalp/ui → packages/core`, never the reverse).
- **Global Anti-Requirements**: Constraints that apply to ALL tickets in this project. Per-ticket anti-requirements are additive on top of these. Each starts with "NEVER" and is specific enough to verify programmatically.
- **State Machines**: If the feature involves state transitions (e.g., a token lifecycle, an approval flow, a multi-step wizard), enumerate all states, valid transitions, and who/what triggers each transition. Agents execute enumerated state machines far more reliably than prose descriptions of behavior.

</schema>

<guidelines>
### Writing Guidelines

- **Be specific**: Numbers, names, formats — not adjectives
- **Be scoped**: Every section should make the boundaries clear
- **Be testable**: If you can't write a test for it, it's not a requirement
- **Be honest**: Mark unknowns as "TBD" rather than guessing
- **Be concise**: This lives in a Linear project description — keep it scannable
</guidelines>
