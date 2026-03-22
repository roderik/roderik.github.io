<overview>
## Brainstorming Techniques

Facilitation patterns for turning vague ideas into structured requirements. Use these during Phase C of the brainstorm loop to generate, challenge, and refine ideas.
</overview>

<techniques>

### Diverge-Converge

The fundamental brainstorming pattern. First generate options broadly (diverge), then narrow down (converge).

**Diverge** (generate 2-3 approaches):
- Each approach should be genuinely different, not variations of the same idea
- Include trade-offs: complexity vs. simplicity, build vs. buy, speed vs. quality
- One approach should always be the simplest thing that could work

**Converge** (narrow down):
- Present approaches with clear pros/cons
- Ask the user (via `AskUserQuestion` or `request_user_input`) to choose, or combine elements from multiple approaches
- Commit to one direction before deepening

### Five Whys

Drill into the root cause of the problem. Ask "why?" five times to get past surface-level symptoms.

**When to use**: The user describes a feature but the underlying problem is unclear.

**Example**:
- "We need a dashboard" — Why?
- "To see metrics" — Why do you need to see them?
- "To catch issues early" — Why are issues being caught late?
- "No alerting system" — Why not?
- "We didn't know which metrics matter" → The real problem is metric definition, not a dashboard.

### SCAMPER

Systematic innovation framework. Apply each lens to the current idea:

- **Substitute**: What component could be replaced with something simpler?
- **Combine**: Can two features be merged into one?
- **Adapt**: What existing solution in the codebase can be adapted?
- **Modify**: What if we changed the scale, scope, or target?
- **Put to other use**: Can this serve a different user or purpose?
- **Eliminate**: What can we remove and still deliver value?
- **Reverse**: What if we approached this from the opposite direction?

**When to use**: The initial idea feels bloated or the scope is unclear.

### Assumption Challenging

List every assumption the proposed solution makes, then challenge each.

**Process**:
1. Extract assumptions: "This assumes that..."
2. For each assumption, ask: "What if this is wrong?"
3. Use `mcp__codex__codex` to get an independent challenge:
   > "Here are our assumptions for [project]. Challenge each one. Which are risky? Which should we validate first?"
4. Prioritize: which assumptions carry the most risk if wrong?

**When to use**: Before finalizing any major technical decision.

### Second Opinion Pattern

Use the codex MCP as an independent reviewer to catch blind spots.

**CRITICAL**: Codex has NO shared context with the current session. Every codex prompt must be **fully self-contained** — include all relevant facts, constraints, and tech stack details directly in the prompt. Do NOT ask codex to explore the codebase, read files, or research the project. Give it the information and ask a focused question.

**Prompts to use with `mcp__codex__codex`**:

- **Architecture review**: "I'm building [X] with [tech stack]. The approach is: [full details including constraints]. What are we missing? What would you do differently?"
- **Risk identification**: "Here's the full PRD: [paste PRD text]. What are the top 3 things that could go wrong?"
- **Alternative approaches**: "We want to solve [problem]. Constraints: [list]. What are 3 different ways to approach this?"
- **Scope validation**: "Here's the scope: [details]. Timeline: [X]. Team: [Y]. Is this realistic? What should we cut?"

Always share the codex response with the user — they decide what to act on.

### Research-Backed Validation

Use external research tools to validate feasibility and approach.

**Technical feasibility** (`mcp__context7__query-docs`, `mcp__exa__get_code_context_exa`):
- Can the proposed stack support the requirements?
- Are there known limitations or gotchas?
- What do the docs say about the specific patterns we're planning?

**Market/competitive research** (`mcp__exa__web_search_exa`, `mcp__exa__deep_researcher_start`):
- How do others solve this problem?
- What's the state of the art?
- Are there open-source solutions we should build on?

**When to use**: Before committing to a technical approach or when the user asks "is this possible?"

</techniques>

<anti_patterns>
### Brainstorming Anti-Patterns

- **Premature convergence**: Jumping to the first idea without exploring alternatives
- **Solution before problem**: Proposing architecture before understanding the core problem
- **Kitchen sink**: Trying to include everything — use SCAMPER's "Eliminate" lens
- **Assumption blindness**: Not questioning implicit assumptions about users, scale, or constraints
- **Research rabbit hole**: Spending too long researching without presenting findings — cap research at 2-3 queries per topic, then share what you found
</anti_patterns>
