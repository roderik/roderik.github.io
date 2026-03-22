## Evidence Capture Reference

Detailed patterns for recording, screenshotting, uploading, and distributing evidence.

### Contents

- [Recording Setup](#recording-setup)
- [Screenshot Strategy](#screenshot-strategy)
- [Upload to Linear](#upload-to-linear)
- [Retrieve Attachment URLs](#retrieve-attachment-urls)
- [GitHub PR Comments](#github-pr-comments)
- [Evidence Directory Structure](#evidence-directory-structure)

### Recording Setup

Start recording before executing any flow steps. Always use a timestamped directory
to avoid overwriting previous evidence.

```bash
EVIDENCE_DIR="./evidence/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$EVIDENCE_DIR"

# Start video recording
agent-browser record start "$EVIDENCE_DIR/flow-recording.webm"

# ... execute flows ...

# Stop recording (always stop, even on failure)
agent-browser record stop
```

**Error handling**: Use a trap to ensure recording stops on failure:

```bash
cleanup() {
    agent-browser record stop 2>/dev/null || true
}
trap cleanup EXIT
```

**Headed mode**: For better video quality and visibility, use headed mode:

```bash
AGENT_BROWSER_HEADED=1 agent-browser record start "$EVIDENCE_DIR/recording.webm"
```

### Screenshot Strategy

Take screenshots at three types of moments:

1. **Entry state** — the page before any action (proves the starting point)
2. **Key interactions** — after filling forms, clicking buttons, state changes
3. **Final state** — the result that proves the feature works

```bash
# Entry
agent-browser screenshot "$EVIDENCE_DIR/step-01-login-page.png"

# Interaction
agent-browser fill @e1 "admin@settlemint.com"
agent-browser fill @e2 "settlemint"
agent-browser click @e3
agent-browser wait --load networkidle
agent-browser screenshot "$EVIDENCE_DIR/step-02-after-login.png"

# Final
agent-browser screenshot "$EVIDENCE_DIR/step-03-dashboard.png"
```

**Naming convention**: `step-NN-description.png` where NN is zero-padded and
description is lowercase-hyphenated.

**Annotated screenshots**: Use `--annotate` when you need to highlight interactive elements
for the reviewer:

```bash
agent-browser screenshot --annotate "$EVIDENCE_DIR/step-04-annotated-form.png"
```

### Upload to Linear

Two methods for attaching evidence to a Linear ticket:

#### Method 1: Attach files to the issue (recommended for bulk)

```bash
# Attach video
linear issue attach PRD-123 "$EVIDENCE_DIR/flow-recording.webm" \
  --title "Evidence: Full flow recording"

# Attach screenshots
for screenshot in "$EVIDENCE_DIR"/step-*.png; do
  title=$(basename "$screenshot" .png | sed 's/step-[0-9]*-//' | tr '-' ' ')
  linear issue attach PRD-123 "$screenshot" --title "Screenshot: $title"
done
```

#### Method 2: Attach to a comment (for inline display)

```bash
# Create comment with inline attachment — the image renders in the comment
linear issue comment add PRD-123 \
  --body-file /tmp/evidence-comment.md \
  --attach "$EVIDENCE_DIR/step-03-dashboard.png" \
  --attach "$EVIDENCE_DIR/step-01-login-page.png"
```

The `--attach` flag can be used multiple times. Attached files render inline in
Linear's UI when the comment is viewed.

### Creating the Evidence Comment

Structure the comment for quick scanning:

```bash
cat > /tmp/evidence-comment.md <<EOF
## Evidence Capture

**Date**: $(date +%Y-%m-%d)
**Branch**: $(git branch --show-current)
**Flows executed**: first-login → complete-onboarding → [target]

### Results

| Step | Status | Details |
|------|--------|---------|
| Navigate to sign-in | Pass | Page loaded |
| Fill credentials | Pass | Fields populated |
| Submit form | Pass | Redirect to dashboard |
| Verify dashboard | Pass | Welcome message visible |

### Flow Updates

- Updated `browser/first-login`: email field selector @e3 → @e5
- Confidence: high (verified today)

### Attachments

- Full video recording (attached to issue)
- 3 screenshots at key steps (attached to issue)
EOF

linear issue comment add PRD-123 --body-file /tmp/evidence-comment.md
```

### Retrieve Attachment URLs

After uploading, you may need attachment URLs (e.g., for GitHub PR embedding).
Use the Linear GraphQL API:

```bash
# Get attachment URLs for an issue
ISSUE_ID=$(linear issue view PRD-123 --json | jq -r '.id')
linear api --variable issueId="$ISSUE_ID" <<'GRAPHQL'
query($issueId: String!) {
  issue(id: $issueId) {
    attachments {
      nodes {
        title
        url
        metadata
        createdAt
      }
    }
  }
}
GRAPHQL
```

**Note**: Linear attachment URLs are signed S3 URLs. They are publicly accessible but
rotate periodically. For permanent references, link to the Linear ticket URL rather
than individual attachment URLs.

### GitHub PR Comments

Post a summary comment on the GitHub PR linking back to the Linear ticket
for full evidence:

```bash
PR_NUMBER=$(gh pr view --json number -q '.number' 2>/dev/null)
TICKET_ID=$(linear issue id 2>/dev/null)
TICKET_URL=$(linear issue url "$TICKET_ID" 2>/dev/null)

if [ -n "$PR_NUMBER" ] && [ -n "$TICKET_ID" ]; then
  cat > /tmp/pr-evidence.md <<EOF
## Evidence

Browser-based verification completed. Screenshots and video recording
available on the [Linear ticket](${TICKET_URL}).

### Verification Summary

| Check | Status |
|-------|--------|
| Login flow | Pass |
| Feature X | Pass |
| Edge case Y | Pass |

> Evidence captured on $(date +%Y-%m-%d) from branch $(git branch --show-current).
EOF

  gh pr comment "$PR_NUMBER" --body-file /tmp/pr-evidence.md
fi
```

### Evidence Directory Structure

```
evidence/
└── 20260319-143052/          # Timestamped session
    ├── flow-recording.webm   # Full video recording
    ├── step-01-login-page.png
    ├── step-02-credentials-filled.png
    ├── step-03-dashboard.png
    └── step-final-feature-verified.png
```

Each evidence session gets its own timestamped directory. Old sessions can be
cleaned up after uploading — the canonical copy lives on Linear.
