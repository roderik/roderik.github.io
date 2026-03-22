## Flow File Format

Flows are step-by-step procedures stored as markdown. They encode institutional knowledge about how to operate the application — login sequences, data creation, navigation paths, verification steps.

### YAML Frontmatter

```yaml
---
name: kebab-case-name
description: One sentence — what this flow accomplishes
requires: []          # Flow names that must complete before this one
provides: []          # State tokens this flow creates (e.g., "authenticated-session")
type: browser         # browser | cli
last-verified: 2026-03-18
confidence: high      # high | medium | low
---
```

**State tokens** are the composition mechanism. A flow declares what state it `provides` (e.g., `"token-created"`) and what state it `requires` (e.g., `"authenticated-session"`). The evidence skill resolves the dependency graph automatically.

**Standard state tokens:**

| Token | Meaning | Provided by |
|-------|---------|-------------|
| `database-seeded` | Migrations run, base data exists | `cli/seed-database` |
| `authenticated-session` | Admin user logged in with active browser session | `browser/first-login` |
| `onboarding-complete` | Wallet, KYC, and org setup done | `browser/complete-onboarding` |
| `api-key-available` | API key created for CLI/SDK access | `cli/create-api-key` |
| `token-created` | At least one token exists | `cli/create-token` or `browser/create-token` |
| `transfer-user-exists` | A second user exists for transfer tests | `cli/create-transfer-user` |

Add new tokens as flows are created. Keep them specific and descriptive.

### Body Structure

#### Prerequisites

List what must be true before running. Reference required flows by name.

```markdown
## Prerequisites
- Database seeded (run `cli/seed-database` flow first)
- Dev server running (check `kit/dapp/.portless/url.txt`)
```

#### Steps

Each step is one atomic action. Include the exact command, the expected result, and what to do if reality differs.

**Browser flow steps:**

```markdown
### Step 1: Navigate to login page
```bash
agent-browser --native open $(cat kit/dapp/.portless/url.txt)/auth/sign-in
```
**Expected**: Sign-in form with email and password fields
**If different**: Check if redirected to onboarding — may need `complete-onboarding` flow first

### Step 2: Fill email
```bash
agent-browser --native snapshot -i
agent-browser --native fill @<email-field-ref> "admin@settlemint.com"
```
**Expected**: Email field populated
**If different**: Re-snapshot, look for field with placeholder "Email" or role textbox
```

**CLI flow steps:**

```markdown
### Step 1: Create token via API
```bash
curl -s -X POST "$(cat kit/dapi/.portless/url.txt)/api/v2/tokens" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $(cat /tmp/dalp-api-key.txt)" \
  -d '{"name": "Test Token", "symbol": "TST", "decimals": 18}' | jq .
```
**Expected**: 201 response with `{id, name, symbol}` shape
**If different**: Check API key validity, check if token type is enabled
```

#### Success Indicators

How to confirm the flow completed correctly.

```markdown
## Success indicators
- Browser shows the dashboard with "Welcome" message
- `agent-browser --native get text @<welcome-ref>` contains "Welcome"
- OR: API response has `status: "active"`
```

#### Known Issues

Recurring problems, timing workarounds, quirks.

```markdown
## Known issues
- Login form sometimes requires a 500ms wait after page load before fields are interactive
- Onboarding wallet step uses a web worker that needs 2-3 seconds to initialize
```

### Composition Rules

1. **Resolve requires recursively**: If flow A requires `["token-created"]`, find the flow that provides `"token-created"`, check ITS requires, resolve those too — until you reach flows with no requirements.

2. **Prefer CLI over browser for setup**: When both a `cli/` and `browser/` flow provide the same token, prefer the CLI flow for setup (faster, more reliable). Use the browser flow only when the test specifically needs to verify the browser path.

3. **Don't re-run satisfied requires**: If a state token was already provided by a prior flow in the chain, skip the flow that provides it.

4. **Fresh state per test session**: Assume state tokens expire when the dev server restarts or the database resets. Re-run the full chain if in doubt.

### Self-Learning Protocol

When a flow step fails:

1. **Snapshot the actual state**: `agent-browser --native snapshot -i` or read the error output
2. **Compare expected vs actual**: Is the selector wrong? Did the URL change? Is there a new step?
3. **Update the flow file**:
   - Fix the specific step that failed
   - Update `last-verified` to today
   - Adjust `confidence` based on severity:
     - Selector change → keep `high` after fix
     - New intermediate step needed → set `medium`
     - Fundamental flow redesign → set `low` until fully re-verified
4. **Add to Known Issues** if the failure is intermittent or timing-related
5. **Test the fix**: Re-run the flow to confirm it passes

When creating a new flow:

1. **Explore manually**: Navigate the app with `agent-browser --native`, taking snapshots at every step
2. **Record each action**: Note the exact command, what you saw, what you clicked
3. **Write the flow file**: Follow the format above, including all "If different" fallbacks
4. **Test it**: Run the flow end-to-end
5. **Index it**: Add to `flows/INDEX.md` with its provides/requires
6. **Set confidence to `medium`**: New flows get medium until verified in a subsequent session
