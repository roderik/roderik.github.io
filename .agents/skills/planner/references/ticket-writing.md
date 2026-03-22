<overview>
## Ticket Writing Guidelines

How to write tickets that are detailed enough for a fresh Claude session to implement, yet durable enough to survive a fast-moving main branch.
</overview>

<principles>

### The Self-Contained Ticket Test

A task passes if a fresh Claude session can:
1. Read the task description alone
2. Understand what to build and why without reading any other task or the project PRD
3. Know which files to touch and what patterns to follow
4. Know when it's done (acceptance criteria)
5. Know what to test and how

If any of these require reading another task or external document, the task needs more context inlined.

### Vertical Slices, Not Horizontal Layers

Each ticket should cut through all integration layers end-to-end:

```
BAD (horizontal):                   GOOD (vertical):
┌─────────────────┐                ┌───┐ ┌───┐ ┌───┐
│   All UI         │                │ U │ │ U │ │ U │
├─────────────────┤                │ I │ │ I │ │ I │
│   All API        │                ├───┤ ├───┤ ├───┤
├─────────────────┤                │ A │ │ A │ │ A │
│   All DB         │                │ P │ │ P │ │ P │
└─────────────────┘                │ I │ │ I │ │ I │
                                   ├───┤ ├───┤ ├───┤
3 huge tickets, nothing             │ D │ │ D │ │ D │
works until all 3 done             │ B │ │ B │ │ B │
                                   └───┘ └───┘ └───┘
                                   Each ticket works
                                   independently
```

### The Tracer Bullet

The first ticket in every project should be the **tracer bullet** — the simplest possible end-to-end slice that proves the architecture:
- Minimal UI (or none — CLI/API is fine)
- Minimal data (hardcoded or single record)
- Minimal logic (happy path only)
- Maximum learning (touches all layers, exposes integration issues)

### Durability vs. Specificity Balance

Tickets must balance two competing needs:

**Too specific** (fragile):
> "On line 47 of `packages/api/routes/users.ts`, add a new handler after the `getUser` function..."

**Too vague** (useless):
> "Add a new API endpoint for the feature"

**Just right** (durable):
> "Add a new endpoint in `packages/api/routes/` following the pattern established by `users.ts`. The endpoint should handle POST requests for creating widgets. See the existing `createUser` handler for the middleware chain pattern."

Key durability techniques:
- Reference **patterns** ("follow the pattern in X") not line numbers
- Reference **directories** when exact files may be created/renamed
- Flag **volatile areas** where concurrent work may change things
- Include **the why** so the implementer can adapt if the how changes

### Implementation Checklist Quality

The checklist should be:
- **Ordered** — steps flow logically, dependencies respected
- **Concrete** — each step is a single action, not a paragraph
- **Testable** — you know when a step is done
- **Flexible** — says what to achieve, not exactly how (unless the how matters)

Good checklist items:
- "Add a `widgetCount` field to the `Project` schema in `packages/db/schema/`"
- "Create a new route handler following the pattern in `packages/api/routes/users.ts`"
- "Add a Vitest unit test covering the validation logic"

Bad checklist items:
- "Implement the backend" (too vague)
- "On line 47, add `const x = await db.query(...)` with parameters..." (too brittle)
- "Write tests" (what tests? for what?)

</principles>

<completion_checklist>

### Writing the Completion Checklist

The Completion Checklist is the most important section of a ticket. It defines **functional proof that the feature works** plus **build health verification**. Without it, agents deliver code that compiles but doesn't actually do what was asked.

**The litmus test**: Would a demo of this checklist item convince a PM the feature works? If it only proves "the build is green," it's a build health check, not a functional check. You need both.

#### Two-part structure

Every Completion Checklist has two sections:

**1. Functional verification** (mandatory — at least one per deliverable):
Proves the feature actually works as intended. These are the checks that catch "it compiles but doesn't work."

**2. Build health** (mandatory standard checks):
Proves nothing is broken. Always ends with: unit tests pass, typecheck passes, CI passes.

#### Conditional functional checks

| If the ticket... | Add this functional check |
|-------------------|--------------------------|
| Touches UI components | `Navigate to [path], perform [action], verify [specific visible outcome]` using agent-browser |
| Adds/changes an API endpoint | `[METHOD] [path] with [payload] returns [status] with [response shape]` |
| Adds a DB field or migration | `Verify the field exists and is queryable: [specific query] returns [expected result]` |
| Modifies auth or permissions | `Verify unauthorized access to [path] returns 401/403; authorized access returns 200` |
| Changes data display | `Verify [specific data] appears as [specific format] in [specific location]` |
| Adds a new page or route | `Navigate to [path], verify page renders with [specific content]` |

#### Good vs bad examples

**Good (concrete, executable, proves the feature works):**
- `CC-01: Navigate to /settings, change preferred currency to EUR, verify portfolio values update to EUR formatting`
- `CC-02: POST /api/data-feeds with {name: "ETH/USD", source: "chainlink"} returns 201 with {id, name, source, status: "active"}`
- `CC-03: Navigate to /data-feeds, verify the new feed appears in the table with status "Active"`
- `CC-04: Click "Publish" on a data feed detail page, verify status changes to "Published" and the publish button is replaced with "Unpublish"`
- `CC-05: Refresh the page — verify published status persists (server-side state, not just UI)`

**Bad (vague, unverifiable, doesn't prove anything):**
- "Data feeds feature works correctly" — what does "correctly" mean?
- "Settings page looks good" — subjective, not automatable
- "API handles requests properly" — which requests? what's "properly"?
- "Error handling works" — which errors? what's the expected behavior?
- "Performance is acceptable" — no threshold defined

#### Scoping to one context window

Each ticket's completion checklist should be achievable in a single agent context window. Signs a ticket needs splitting:
- More than 8-10 completion criteria
- Criteria span multiple unrelated subsystems
- Some criteria depend on intermediate state that would exceed the agent's context window

#### No ambiguity allowed

All ambiguity is resolved during the brainstorm phase. If a functional check can't be written concretely, the brainstorm didn't go deep enough — go back and resolve it before creating the ticket. A ticket with vague completion criteria is not ready for implementation.

</completion_checklist>

<estimation>
### Estimation Guidelines

The PRD team uses **t-shirt size** estimation. The YAML frontmatter `estimate` field takes the numeric value:

| Size | Numeric | Human Scope | Agent Approach | Typical Ticket |
|------|---------|------------|----------------|----------------|
| XS | 1 | Half a day | Single plan-mode pass | Config change, single file tweak |
| S | 2 | 1 day | Plan-mode or focused session | New component, new endpoint |
| M | 3 | 2-3 days | Plan-mode with research | Cross-cutting feature, new pattern |
| L | 5 | 1 week | Multiple sessions or careful plan | New subsystem, complex integration |
| XL | 8 | 2+ weeks | **Split the ticket** | Too large — decompose further |

**Estimation heuristics:**
- Count the files to modify — each file adds roughly half a size
- New patterns cost more than following existing ones
- Cross-package changes cost more than single-package
- If you're unsure, estimate high — it's easier to close a ticket early than to discover it's huge mid-implementation
- Default estimate is XS (1) for trivial work. Zero is allowed for "not yet estimated".
</estimation>

<module_mapping>
### Module Mapping

The Module Mapping section prevents the implementing agent from reinventing existing infrastructure. During ticket breakdown, explore the codebase to identify which packages, utilities, and patterns the ticket should use.

**Why this matters:** Without explicit module mapping, agents default to writing new code rather than using existing utilities. In a monorepo with shared packages (`@core/cache`, `@core/validation`, `@dalp/ui`, etc.), this creates duplication and drift.

**How to write it:**
- Explore the codebase during ticket breakdown (Step 3) to find exact packages
- Map each "need" (what the ticket requires) to a specific "use this" (existing code)
- Include the file path so the agent can find it quickly
- If a need has NO existing solution, note it explicitly: "Create new — no existing utility"
- Prefer directory-level paths over exact files (more durable)
</module_mapping>

<anti_requirements>
### Anti-Requirements

Anti-requirements are deterministic "never do X" constraints. They are more effective than aspirational goals for agent execution because they are simple pass/fail checks.

**Why anti-requirements beat positive requirements for agents:**
- "Use efficient queries" is vague and requires judgment
- "NEVER use `SELECT *` — always specify columns" is binary and checkable
- Agents can grep their own output for violations before committing

**How to write them:**
- Each anti-requirement starts with "NEVER"
- Each is specific enough to grep for or verify programmatically
- Derive them from: Hard Blockers in CLAUDE.md, project-specific constraints, architectural boundaries, known anti-patterns in the codebase
- Include the WHY in parentheses: "NEVER import from `@dalp/ui` in `@core/` packages (core must not depend on dalp)"
- Be concrete, not aspirational — "NEVER" + specific action + why
</anti_requirements>

<verification_protocol>
### Verification Protocol

The Verification Protocol maps each requirement to a concrete verification command. This closes the gap between "acceptance criteria" (what should be true) and "completion checklist" (how to prove it).

**Difference from Completion Checklist:**
- Completion Checklist = ordered sequence the agent runs at the end (CC-01, CC-02, ...). Includes both functional verification and build health.
- Verification Protocol = reference table mapping requirements to checks. Used during development too, not just at the end.

The Completion Checklist should REFERENCE the Verification Protocol rather than duplicating the commands. Example: "CC-01: Run verification for 'New endpoint returns 201' from the Verification Protocol" — this keeps verification commands in one place and avoids drift.
</verification_protocol>

<anti_patterns>
### Ticket Anti-Patterns

- **The novel**: Wall of text with no structure. Use the template headings.
- **The stub**: "Implement feature X" with no details. Fill every template section.
- **The chain gang**: 10 sequential tickets where each blocks the next. Find parallel paths.
- **The monolith**: One ticket that does everything. Split at vertical slice boundaries.
- **The phantom dependency**: Marking tickets as blocked when they could actually be done in any order.
- **The assumption**: "The user table already has a `role` column" — verify with codebase exploration, don't assume.
- **The mind reader**: Ticket that makes sense only if you've read the full PRD and 5 other tickets. Include context inline.
</anti_patterns>
