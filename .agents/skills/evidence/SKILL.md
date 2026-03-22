---
name: evidence
description: >-
  Record browser and CLI flows as video and screenshots, upload evidence to Linear
  tickets and embed in GitHub PRs. Owns the self-learning composable flow system —
  step-by-step procedures for navigating the application that adapt when they break
  and get created when new flows are needed. Use when the user says "evidence",
  "record evidence", "capture proof", "test and record", or needs visual verification
  for PR reviews and CC-xx items. Also triggers when the testing skill's manual tier
  needs browser-based verification, when uploading screenshots/recordings to Linear
  or GitHub, or when you need to create, update, or execute application flows.
  If you're about to do manual browser testing, load this skill first.
user-invocable: true
---

<objective>
Capture verifiable evidence of application behavior through recorded browser flows and
screenshots, then distribute that evidence to Linear tickets and GitHub PRs.

The flow system is the backbone: a self-learning library of composable, self-correcting
procedures that encode institutional knowledge about how to operate the application. Instead
of writing browser automation from scratch each time, flows are recorded once, composed via
dependency chains, and updated when they break.

Evidence serves two purposes:
1. **Verification** — proving features work as specified (CC-xx items, PR reviews)
2. **Documentation** — creating a visual record of application state at key moments

**Evidence is NOT complete until ALL of these are done:**
1. Video recorded (via `agent-browser record start/stop`) and post-processed to Retina via ffmpeg
2. Screenshots taken at key steps (all 3024x1964 Retina)
3. All files attached to the Linear ticket (via `linear issue attach`) — save returned URLs
4. Evidence comment posted on Linear with **inline images** (`![](url)`) and **inline video** (URL on own line)
5. Evidence comment posted on GitHub PR with **inline screenshots** and video link to Linear (via `gh pr comment`)

Do NOT stop after taking screenshots. Do NOT stop after posting a text-only comment. Every comment MUST have inline images using the URLs from `linear issue attach`. Both Linear AND GitHub must have the evidence comment.
</objective>

<important if="always">
## What to Test

When invoked as `/evidence`, determine what to test from these sources, in order:

1. **Explicit arguments** — `/evidence login flow` → test the login flow
2. **Current context** — if mid-implementation, test that feature
3. **Linear ticket** — if a ticket ID is in context (branch name, conversation), test its acceptance criteria
4. **Ask the user** — if none of the above provide clarity, ask: "What should I capture evidence for? Give me a feature, flow name, or describe what to verify."

Never guess blindly. If in doubt, ask.
</important>

<evidence_workflow>
## Evidence Workflow

When invoked as `/evidence`:

1. **Determine what to test** (see "What to Test" above)
2. **Find the Linear ticket** — from branch (`linear issue id`), argument, or ask the user
3. **Ensure dev server is running** — check portless URLs. If not running, start with `bun run dev`.
4. **Ensure ffmpeg is installed** — run `which ffmpeg`. If missing, install with `brew install ffmpeg`. Video recording requires ffmpeg.
5. **Read `flows/INDEX.md`** to find relevant flows and their dependency chains
6. **Compose the flow chain** from requirements to target
7. **Set up browser and recording** — the order is critical because `record start` resets the viewport:
   ```bash
   # 1. Open the starting page
   agent-browser close
   agent-browser open "<start-url>" --wait networkidle
   # 2. Start recording (this resets viewport to default 1280x577!)
   agent-browser record start "$EVIDENCE_DIR/evidence-video.webm"
   # 3. Set viewport AFTER record start
   agent-browser set viewport 1512 982 2   # MacBook Pro 14" Retina (3024x1964 pixels)
   # 4. Reload to render at correct size
   agent-browser reload
   agent-browser wait --load networkidle --timeout 10000
   ```
   **CRITICAL ordering**: `open` → `record start` → `set viewport` → `reload`. Any other order produces 1280x577 screenshots.
   After this setup, navigate ONLY via `click` (not `open`) to preserve the viewport.

   **Video resolution limitation**: `record start` hardcodes the screencast at 1280x578 regardless of viewport changes. The video must be post-processed after `record stop`:
   ```bash
   # Trim the first 3s (viewport resize frames) and scale to Retina
   ffmpeg -y -i "$EVIDENCE_DIR/raw-video.webm" \
     -ss 3 \
     -vf "scale=3024:1964:flags=lanczos,setsar=1" \
     -c:v libvpx-vp9 -b:v 4M -quality good -speed 2 \
     "$EVIDENCE_DIR/evidence-video.webm"
   ```
   Name the recording `raw-video.webm`, post-process to `evidence-video.webm`, upload only the processed version.
8. **Form submission gotcha**: After `set viewport` + `reload`, React form `fill`+`click` may silently fail to submit. Use JS form submission as fallback: `agent-browser eval "document.querySelector('form')?.requestSubmit()"`.
9. **Execute flows** — take screenshots at these three moments:
   - **Entry state** — the page/state before any action (proves the starting point)
   - **Key interactions** — after filling forms, clicking buttons, state transitions
   - **Final state** — the result that proves the feature works
10. **If a flow fails**: diagnose, fix the flow (self-learning protocol), re-run
11. **If no flow exists**: create one by exploring manually, then record it
12. **Stop recording**: `agent-browser record stop`
13. **Post-process video**: trim first 3s and scale to Retina (see ffmpeg command above). Delete raw, keep only processed.
14. **Upload ALL files to Linear** — video AND every screenshot. Use `linear issue attach PRD-xxx <file> --title "..."` for each file. Save the returned URLs — you need them for inline embedding.
15. **Post evidence comment to Linear** — embed screenshots inline using `![alt](url)` with the URLs from step 14. Embed video URL on its own line for auto-play. Include API verification table if applicable.
16. **Post evidence comment to GitHub PR** — this is NOT optional. Use the same inline screenshot URLs from Linear (they're publicly accessible). Link to the Linear ticket for the video (GitHub doesn't render external video). Use `gh pr comment <number> --body-file /tmp/pr-evidence.md`.
    ```bash
    PR_NUMBER=$(gh pr view --json number -q '.number' 2>/dev/null)
    if [ -z "$PR_NUMBER" ]; then
      echo "WARNING: No PR found — skipping GitHub evidence"
    else
      gh pr comment "$PR_NUMBER" --body-file /tmp/pr-evidence.md
    fi
    ```
    **Evidence is NOT complete until both Linear AND GitHub have the comment with inline images.**
17. **Report results**: which flows passed, what evidence was captured, what was updated

### Evidence Capture Steps

```bash
# 1. Set up recording directory
EVIDENCE_DIR="./evidence/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$EVIDENCE_DIR"

# 2. Find the Linear ticket
TICKET_ID=$(linear issue id 2>/dev/null)
# If empty, ask the user

# 3. Set up browser + recording + viewport (ORDER MATTERS!)
agent-browser close
agent-browser open "$(cat kit/dapp/.portless/url.txt)/auth/sign-in" --wait networkidle
agent-browser record start "$EVIDENCE_DIR/evidence-video.webm"
agent-browser set viewport 1512 982 2   # MacBook Pro 14" Retina
agent-browser reload
agent-browser wait --load networkidle --timeout 10000

# 4. Execute flows, capturing screenshots at key steps
agent-browser screenshot "$EVIDENCE_DIR/step-01-sign-in-page.png"

# ... execute flow steps (navigate via click, NOT open) ...

agent-browser screenshot "$EVIDENCE_DIR/step-final-result.png"

# 5. Stop recording
agent-browser record stop

# 6. Upload to Linear (see references/evidence-capture.md for full patterns)
linear issue attach "$TICKET_ID" "$EVIDENCE_DIR/flow-recording.webm" \
  --title "Evidence: Flow recording"
linear issue attach "$TICKET_ID" "$EVIDENCE_DIR/step-01-sign-in-page.png" \
  --title "Step 1: Sign-in page"

# 7. Create evidence comment on Linear ticket
linear issue comment add "$TICKET_ID" --body-file /tmp/evidence-comment.md

# 8. Post to GitHub PR if one exists
gh pr comment --body-file /tmp/pr-evidence.md 2>/dev/null
```

Name screenshots descriptively: `step-NN-description.png`. The recording captures
everything, but screenshots highlight the key moments reviewers care about.
</evidence_workflow>

<flow_system>
## Flow System

Flows are step-by-step procedures stored as markdown files in `flows/`. They encode
institutional knowledge about how to operate the application — login sequences, data
creation, navigation paths, verification steps.

### Flow types

| Type | Directory | Purpose | Example |
|------|-----------|---------|---------|
| **Browser flows** | `flows/browser/` | Step-by-step agent-browser commands | Login, navigate, fill form, verify |
| **CLI flows** | `flows/cli/` | CLI/SDK commands for fast data setup | Create token via API, seed users |

### When to use which

- **Browser flows**: When you need to test the actual UI, verify visual state, capture screenshots
- **CLI flows**: When you need prerequisite data quickly — e.g., creating a token via API to test the transfer UI
- **Compose both**: CLI flows for setup, then browser flows for UI verification and evidence capture

### Flow file format

Every flow file follows this structure:

```markdown
---
name: flow-name
description: What this flow accomplishes
requires: [state tokens that must exist — e.g., "authenticated-session"]
provides: [state tokens this flow creates — e.g., "token-created"]
type: browser | cli
last-verified: YYYY-MM-DD
confidence: high | medium | low
---

## Prerequisites
- [What must be true before this flow runs]

## Steps

### Step 1: [Action description]
` ``bash
[exact command to run]
` ``
**Expected**: [What you should see/get]
**If different**: [What to do if the expected result doesn't match]

## Success indicators
- [How to know this flow completed successfully]

## Known issues
- [Any quirks, timing issues, or workarounds]
```

For the full format specification including state tokens and composition rules, read
`references/flow-format.md`.

### Composability

Flows declare `requires` (dependencies) and `provides` (outputs). Compose by:

1. Reading the target flow's `requires`
2. Finding flows that `provide` each requirement
3. Running the dependency chain in order
4. Running the target flow

Example: Testing "transfer tokens" → requires `["authenticated-session", "token-created",
"transfer-user-exists"]` → composes: `browser/first-login` → `cli/create-token` →
`cli/create-transfer-user` → `browser/transfer-tokens`.

**Rules:**
- Resolve requires recursively until reaching flows with no requirements
- Prefer CLI over browser for setup (faster, more reliable) — use browser flows only when testing the UI path
- Don't re-run satisfied requires — skip if state token already provided
- Fresh state per session — re-run the full chain after dev server restart or database reset

### Self-Learning Protocol

Flows are living documents that improve with every session.

**When a flow step fails:**

1. **Snapshot** the actual state: `agent-browser snapshot -i` or read the error
2. **Compare** expected vs actual: wrong selector? URL changed? new step needed?
3. **Update** the flow file with the fix
4. **Adjust confidence**:
   - Selector change → keep `high` after fix
   - New intermediate step needed → set `medium`
   - Fundamental redesign → set `low` until fully re-verified
5. **Add to Known Issues** if intermittent
6. **Re-run** to confirm the fix works
7. **Update `last-verified`** to today

**When creating a new flow:**

1. **Explore** manually with agent-browser, snapshotting every step
2. **Record** each action: exact command, what you saw, what you clicked
3. **Write** the flow file with all "If different" fallbacks
4. **Test** end-to-end
5. **Index** in `flows/INDEX.md` with provides/requires
6. **Set confidence** to `medium` — new flows start at medium until verified in a later session

**Confidence levels:**
- **high**: Verified within 7 days, no known issues
- **medium**: Verified within 30 days, or has minor workarounds
- **low**: Older than 30 days, or has known reliability issues
</flow_system>

<linear_upload>
## Uploading Evidence to Linear

After capturing evidence, upload all artifacts to the Linear ticket and create a summary comment.

### Attaching files

```bash
# Attach video recording
linear issue attach PRD-123 "$EVIDENCE_DIR/flow-recording.webm" \
  --title "Evidence: Full recording"

# Attach key screenshots
linear issue attach PRD-123 "$EVIDENCE_DIR/step-01-login.png" \
  --title "Step 1: Login page"
linear issue attach PRD-123 "$EVIDENCE_DIR/step-final-dashboard.png" \
  --title "Final: Dashboard verified"
```

### Creating the evidence comment

Write a structured comment with **inline images** using the URLs returned by `linear issue attach`. The comment MUST embed screenshots directly — not just list them as text. Use markdown image syntax `![alt](url)` with the public URLs from the attach step.

```bash
# After attaching files, use the returned URLs in the comment:
cat > /tmp/evidence-comment.md <<EOF
## Evidence Capture

**Date**: $(date +%Y-%m-%d) | **Viewport**: MacBook Pro 14" Retina (3024×1964)
**Flows executed**: first-login → complete-onboarding → [target flow]

### Results

| Step | Screenshot | Status |
|------|-----------|--------|
| Sign-in | ![Sign-in](<URL from attach step 1>) | Pass |
| After login | ![After login](<URL from attach step 2>) | Pass |
| [Target] | ![Target](<URL from attach step N>) | Pass |

### API Verification
| Route | Status | Response |
|-------|--------|----------|
| route.name | 200 | Brief description |

Video recording attached separately.
EOF

linear issue comment add PRD-123 --body-file /tmp/evidence-comment.md \
  --attach "$EVIDENCE_DIR/step-final-dashboard.png"
```

The `--attach` flag on `comment add` inlines the file in the comment. Use it for the
most important screenshot. Attach remaining files to the issue directly.

For full upload patterns, see `references/evidence-capture.md`.
</linear_upload>

<github_pr>
## Embedding Evidence in GitHub PRs

**This step is NOT optional.** If a PR exists for the current branch, post an evidence comment with inline screenshots. This is as important as the Linear upload.

### Approach

Linear `public.linear.app` URLs are publicly accessible and render inline on GitHub.
Use them directly in the PR comment for inline screenshots. For video, link to the
Linear ticket (GitHub doesn't render external `.webm`).

```bash
PR_NUMBER=$(gh pr view --json number -q '.number' 2>/dev/null)

if [ -n "$PR_NUMBER" ]; then
  TICKET_URL=$(linear issue url PRD-123 2>/dev/null)

  cat > /tmp/pr-evidence.md <<EOF
## Evidence — PRD-123

**Viewport**: MacBook Pro 14" Retina (3024×1964)

### Flow recording

[Watch video on Linear](${TICKET_URL})

### Steps

| Step | Screenshot | Status |
|------|-----------|--------|
| 1. Entry state | ![Step 1](<URL from linear issue attach>) | Pass |
| 2. Key interaction | ![Step 2](<URL from linear issue attach>) | Pass |
| 3. Final state | ![Step 3](<URL from linear issue attach>) | Pass |

### API Verification

| Route | Status | Response |
|-------|--------|----------|
| route.name | 200 | Brief description |

> Evidence captured on $(date +%Y-%m-%d). Full video on [Linear ticket](${TICKET_URL}).
EOF

  gh pr comment "$PR_NUMBER" --body-file /tmp/pr-evidence.md
fi
```

### When to upload directly to GitHub

For critical screenshots that **must** render inline in the PR (not just linked), you can
upload directly using the GitHub API. This is heavier but ensures the image persists
regardless of Linear URL expiry:

```bash
# Upload to GitHub via the REST API (requires repo write access)
# The response contains a URL that can be embedded in markdown
```

In most cases, linking to the Linear ticket is sufficient — reviewers can click through
to see the full evidence.
</github_pr>

<prerequisites>
## Prerequisites

1. **Dev server running.** Check portless URLs:
   ```bash
   cat kit/dapp/.portless/url.txt   # Frontend URL
   cat kit/dapi/.portless/url.txt   # API URL
   ```

2. **Linear CLI authenticated.** Verify: `linear auth token`

3. **GitHub CLI authenticated.** Verify: `gh auth status`

4. **Read `flows/INDEX.md`** before starting to understand available flows and dependencies.
</prerequisites>

<credentials>
## Test Credentials

| Role | Email | Password | Pincode |
|------|-------|----------|---------|
| Admin | admin@settlemint.com | settlemint | 111111 |

Default dev credentials. Use for all evidence capture unless the flow specifies otherwise.
</credentials>

<bootstrap>
## Starting from a Clean Slate

After `dev:reset`, the bootstrap chain sets up first-time state:

1. `flows/cli/seed-database` — Run migrations, seed base data
2. `flows/browser/first-login` — Login as admin, handle first-time prompts
3. `flows/browser/complete-onboarding` — Wallet setup, KYC, organization creation
4. `flows/cli/create-api-key` — Create API key for CLI/SDK access

These compose automatically when downstream flows require their `provides`.
</bootstrap>

<gotchas>
## Gotchas

- **Dev server not running**: agent-browser gets connection errors. Always check portless URLs first.
- **Stale flows after UI refactor**: When dapp UI changes, browser flows break. Set `confidence` to `low` and re-verify.
- **CLI flows need API key**: Most CLI commands need auth. The `create-api-key` flow provides this.
- **Agent-browser refs are ephemeral**: After navigation or DOM changes, re-snapshot for fresh refs.
- **Flow dependency cycles**: If A requires B and B requires A, composition loops. Validate the graph.
- **Linear attachment URLs rotate**: Link to the ticket, not individual file URLs, for permanent references.
- **WebM in GitHub**: GitHub markdown doesn't render external WebM inline. Link to Linear instead.
- **Recording overhead**: Video recording adds slight performance overhead to browser automation.
</gotchas>

<integration>
## Integration with Other Skills

| Skill | How evidence integrates |
|-------|----------------------|
| **testing** | Manual tier (Tier 4) delegates to evidence for browser-based verification |
| **verifier** | Functional UI CC items invoke evidence to capture visual proof |
| **execute** | Calls evidence after implementation to document what was built |
| **linear-cli** | File upload and comment creation for evidence distribution |
| **agent-browser** | Browser automation engine — flow execution and recording |
| **navigation-learning** | Selector reliability data improves flow accuracy |
</integration>

<reference_index>
## References

- `references/flow-format.md` — Full flow file format spec, composition rules, state tokens
- `references/evidence-capture.md` — Recording setup, screenshot strategy, upload workflow
- `flows/INDEX.md` — Registry of all flows with provides/requires graph

## Related Skills

- **agent-browser** — Command reference for browser automation. Read before writing browser flows.
- **navigation-learning** — Records selector reliability scores. Flows build on this knowledge.
- **linear-cli** — File upload and comment management. Read `references/file-uploads.md` for upload patterns.
</reference_index>

<success_criteria>
## Success Criteria

- Target test/flow determined (from context, args, or user confirmation)
- Linear ticket identified for evidence upload
- Video recording captures the full flow execution
- Screenshots taken at key verification points
- All evidence uploaded to Linear ticket with descriptive titles
- Evidence comment created on Linear ticket with results summary
- GitHub PR comment posted (if PR exists) linking to evidence
- Failed flows diagnosed and updated (self-learning)
- New flows created and indexed when needed
- All flow files follow standard format with requires/provides/confidence
</success_criteria>
