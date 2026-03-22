<overview>
## Workpad Protocol

The workpad is a persistent Linear comment on each issue that enables multi-session continuity. When a session ends (context window full, crash, user stops), the next session reads the workpad and continues from the last checkpoint.
</overview>

<format>
## Workpad Format

Every workpad comment starts with `## Workpad — PRD-xxx` and contains these sections:

```markdown
## Workpad — PRD-xxx

### Plan
<implementation plan — the approved approach>

### Decisions
- <key decision>: <rationale>

### Progress
- [x] Step 1 completed
- [x] Step 2 completed
- [ ] Step 3 pending
- [ ] Step 4 pending

### Session Log
**Session 1** (YYYY-MM-DD): <what was done, what remains>
**Session 2** (YYYY-MM-DD): <what was done, what remains>
```

### Section rules

| Section | Purpose | Mutability |
|---------|---------|------------|
| Plan | Implementation approach | Replace if fundamentally reworking; otherwise append amendments |
| Decisions | Architectural choices with rationale | Append-only — never delete a decision, add "REVISED:" if changed |
| Progress | Checklist of steps | Update check states. Add new steps if scope expands. |
| Session Log | What each session accomplished | Append-only — never edit or delete previous entries |
</format>

<rules>
## Rules

1. **One workpad per issue.** Find by searching comments for `## Workpad` prefix.
2. **Create before implementing.** The workpad must exist before the first line of code.
3. **Update before ending a session.** Even if interrupted — always persist current state.
4. **Never delete session log entries.** They are the audit trail.
5. **Progress is the source of truth** for what is done vs what remains.
6. **Plan changes go through Decisions.** If the plan changes mid-implementation, update Plan and add a "REVISED:" entry in Decisions explaining why.
7. **In autonomous mode (ralph.sh)**, the workpad is the ONLY persistent state between retries. Treat it as your lifeline.
</rules>

<cli_reference>
## CLI Reference

### Finding the workpad

```bash
# Get workpad content
linear issue view PRD-xxx --json --no-pager | jq -r '
  [.comments[]? | select(.body | test("^## Workpad")) | .body] | first // "NO_WORKPAD"
'

# Get workpad comment ID (for updates)
linear issue view PRD-xxx --json --no-pager | jq -r '
  [.comments[]? | select(.body | test("^## Workpad")) | .id] | first // ""
'
```

### Creating a new workpad

```bash
cat > /tmp/workpad.md <<'EOF'
## Workpad — PRD-xxx

### Plan
<plan goes here>

### Decisions
- <initial decisions>

### Progress
- [ ] Step 1
- [ ] Step 2

### Session Log
**Session 1** (YYYY-MM-DD): Starting implementation. Plan: <brief summary>
EOF

linear issue comment add PRD-xxx --body-file /tmp/workpad.md
rm -f /tmp/workpad.md
```

### Updating an existing workpad

```bash
# First get the comment ID
WORKPAD_ID=$(linear issue view PRD-xxx --json --no-pager | jq -r '
  [.comments[]? | select(.body | test("^## Workpad")) | .id] | first // ""
')

# Write the full updated content
cat > /tmp/workpad.md <<'EOF'
<full workpad content with updates>
EOF

linear issue comment update "${WORKPAD_ID}" --body-file /tmp/workpad.md
rm -f /tmp/workpad.md
```

### Quick progress check

```bash
# See just the Progress section
linear issue view PRD-xxx --json --no-pager | jq -r '
  [.comments[]? | select(.body | test("^## Workpad")) | .body] | first // ""
' | sed -n '/^### Progress/,/^### /p' | head -n -1
```
</cli_reference>
