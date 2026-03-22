# [Project Name]

## 1. Executive Summary

**Problem Statement:**
<!-- 1-2 sentences: what pain point does this address? Why now? -->

**Proposed Solution:**
<!-- 1-2 sentences: what are we building? -->

**Success Criteria:**
- <!-- Measurable KPI 1 -->
- <!-- Measurable KPI 2 -->
- <!-- Measurable KPI 3 -->

---

## 2. User Experience & Functionality

### Personas

<!-- Brief description of each user type -->

| Persona | Description | Primary Goal |
|---------|-------------|--------------|
| <!-- e.g., Platform Admin --> | <!-- who they are --> | <!-- what they need --> |

### User Stories

**Story 1:** As a [persona], I want to [action] so that [benefit].
- [ ] <!-- Acceptance criterion -->
- [ ] <!-- Acceptance criterion -->

**Story 2:** As a [persona], I want to [action] so that [benefit].
- [ ] <!-- Acceptance criterion -->
- [ ] <!-- Acceptance criterion -->

### Non-Goals

- <!-- What we are explicitly NOT building in this project -->
- <!-- Boundaries to protect the timeline -->

---

## 3. AI System Requirements

<!-- Remove this section entirely if no AI/ML components are involved -->

**Model/Tool Requirements:**
- <!-- What models, APIs, or tools are needed -->

**Data Requirements:**
- <!-- Source, format, volume -->

**Evaluation Strategy:**
- <!-- How to measure quality and accuracy -->

**Guardrails:**
- <!-- Safety, bias, reliability considerations -->

---

## 4. Technical Specifications

**Architecture Overview:**
<!-- High-level data flow and component interaction — keep concise -->

**Integration Points:**
| System | Purpose | Protocol |
|--------|---------|----------|
| <!-- e.g., Auth service --> | <!-- what it does --> | <!-- REST/gRPC/etc --> |

**Security & Privacy:**
- <!-- Data handling, compliance, access control -->

**Performance Requirements:**
- <!-- Latency: e.g., p95 < 200ms -->
- <!-- Throughput: e.g., 1000 req/s -->
- <!-- Scale: e.g., 100k users -->

---

## 5. Risks & Roadmap

### Phased Rollout

**MVP (v1.0):**
- <!-- Core scope — minimum to deliver value -->

**v1.1:**
- <!-- Follow-up improvements -->

**Future:**
- <!-- Longer-term vision items -->

### Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| <!-- e.g., API rate limits --> | Med | High | <!-- strategy --> |

### Open Questions

- [ ] <!-- Decision needed — owner: @someone -->
- [ ] <!-- Unknown to resolve before implementation -->

---

## 6. Agent Execution Context

<!-- Every PRD includes this section. Implementation tasks are picked up by agents. -->

### Module Inventory

<!-- Which existing packages and patterns must be used across the project. Agents inherit these constraints on every ticket. Ground this in codebase exploration — list actual packages with paths. -->

| Need | Package | Path |
|------|---------|------|
| <!-- e.g., Database access --> | <!-- e.g., Drizzle via @dalp/database --> | <!-- `packages/dalp/database/` --> |

### Architectural Boundaries

<!-- Which packages can depend on which. Draw the dependency arrows. -->

- <!-- e.g., `kit/dapp` -> `packages/dalp/ui` -> `packages/core` (never the reverse) -->

### Global Anti-Requirements

<!-- Constraints that apply to ALL tickets. Per-ticket anti-requirements are additive. Each starts with "NEVER" and is verifiable programmatically. -->

- NEVER <!-- e.g., "import from `@core/` in `kit/dapp` — go through `@dalp/ui` (architectural boundary)" -->

### State Machines

<!-- If the feature involves state transitions, enumerate all states, valid transitions, and triggers. Agents execute state machines more reliably than prose. -->

<!-- Remove this subsection if no state transitions are involved -->

| State | Valid Transitions | Trigger |
|-------|------------------|---------|
| <!-- e.g., Draft --> | <!-- Published, Archived --> | <!-- User action / API call --> |
