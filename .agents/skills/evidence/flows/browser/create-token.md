---
name: create-token-browser
description: Create a token through the dapp UI — asset designer wizard
requires:
  - onboarding-complete
  - authenticated-session
provides:
  - token-created
type: browser
last-verified: 2026-03-18
confidence: low
---

## Prerequisites
- Authenticated browser session with onboarding complete
- Dev server running

## Steps

### Step 1: Navigate to asset creation
```bash
agent-browser --native open "$(cat kit/dapp/.portless/url.txt)/my-assets"
agent-browser --native wait --load networkidle
agent-browser --native snapshot -i
```
**Expected**: My Assets page with a "Create" or "New Asset" button
**If different**: Check the current route structure — the path may have changed. Try `/asset-management` or look for asset-related navigation items.

### Step 2: Start the asset creation wizard
```bash
agent-browser --native click @<create-button>
agent-browser --native wait --load networkidle
agent-browser --native snapshot -i
```
**Expected**: Asset designer wizard opens — multi-step form for token configuration
**If different**: May navigate to `/addon-designer` or a different creation path

### Step 3: Walk through the wizard

The asset designer is a multi-step wizard. The exact steps depend on the token type. This flow needs self-learning on first run.

Common wizard steps:
1. **Select token type** — e.g., Stablecoin, Equity, Bond
2. **Configure name and symbol** — fill in token name, symbol, decimals
3. **Set features** — select features like compliance, dividends, etc.
4. **Review and deploy** — confirm settings and submit

For each step:
```bash
agent-browser --native snapshot -i              # See current state
agent-browser --native fill @<field> "value"    # Fill fields
agent-browser --native click @<next-button>     # Advance
agent-browser --native wait --load networkidle  # Wait for transition
```

**IMPORTANT**: This wizard is complex and changes with new token types and features. Self-learn the exact steps on first execution.

### Step 4: Wait for deployment
```bash
agent-browser --native wait 5000  # Allow time for transaction processing
agent-browser --native snapshot -i
```
**Expected**: Success message or redirect to the token detail page
**If different**: May show a pending state — check for transaction status indicators

## Success indicators
- Token appears in the My Assets list
- Token detail page shows the configured name and symbol
- No error messages visible

## Known issues
- Token deployment involves on-chain transactions that may take 10-30 seconds
- The wizard may have conditional steps based on token type selection
- This flow is intentionally underspecified — it MUST self-learn the exact wizard steps on first execution
