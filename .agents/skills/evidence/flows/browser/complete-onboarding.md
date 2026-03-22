---
name: complete-onboarding
description: Complete the full onboarding wizard — wallet setup, KYC, organization creation
requires:
  - authenticated-session
provides:
  - onboarding-complete
type: browser
last-verified: 2026-03-18
confidence: low
---

## Prerequisites
- Authenticated browser session (run `browser/first-login` flow first)
- Dev server running

## Steps

### Step 1: Check if already onboarded
```bash
agent-browser --native get url
```
**Expected**: If URL contains `/onboarding`, proceed. If on dashboard, onboarding is already complete — skip this flow.

### Step 2: Snapshot onboarding wizard
```bash
agent-browser --native snapshot -i
```
**Expected**: Multi-step wizard. Identify the current step from the page content.
**If different**: The onboarding flow may have changed. Take a screenshot for reference: `agent-browser --native screenshot`

### Step 3: Walk through each wizard step

The onboarding wizard has multiple steps. The exact steps may change — use snapshots to navigate each one. Common steps include:

1. **Wallet setup** — may involve generating a wallet or importing one
2. **KYC / Identity verification** — filling in personal information
3. **Organization creation** — naming the organization, setting preferences
4. **Pincode setup** — setting or confirming a pincode (use `111111`)

For each step:
```bash
agent-browser --native snapshot -i              # See current state
agent-browser --native fill @<field> "value"    # Fill fields
agent-browser --native click @<next-button>     # Advance
agent-browser --native wait --load networkidle  # Wait for transition
```

**IMPORTANT**: This flow WILL need self-learning. The onboarding wizard is complex and changes frequently. On first run, explore step-by-step, record what works, and update this flow with the actual steps discovered.

### Step 4: Verify onboarding complete
```bash
agent-browser --native wait --load networkidle
agent-browser --native get url
```
**Expected**: URL is the main dashboard (e.g., `/actions` or `/my-assets`)
**If different**: May have additional steps. Snapshot and continue navigating.

## Success indicators
- URL is on the main application (not `/onboarding`)
- Dashboard or main navigation is visible
- No onboarding prompts remain

## Known issues
- Wallet setup uses a web worker that needs 2-3 seconds to initialize
- KYC step may involve file uploads in some configurations
- Onboarding takes ~30-90 seconds total on first run
- This flow is intentionally underspecified — it MUST self-learn the exact steps on first execution
