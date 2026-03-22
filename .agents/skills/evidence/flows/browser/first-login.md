---
name: first-login
description: Login as admin user and establish an authenticated browser session
requires:
  - database-seeded
provides:
  - authenticated-session
type: browser
last-verified: 2026-03-18
confidence: low
---

## Prerequisites
- Database seeded (run `cli/seed-database` flow first)
- Dev server running (`bun run dev`)
- Frontend URL available: `cat kit/dapp/.portless/url.txt`

## Steps

### Step 1: Navigate to sign-in page
```bash
agent-browser --native open "$(cat kit/dapp/.portless/url.txt)/auth/sign-in"
```
**Expected**: Sign-in form with email and password fields
**If different**: May redirect to root `/` — check if already authenticated. If so, flow is already satisfied.

### Step 2: Snapshot to get element refs
```bash
agent-browser --native snapshot -i
```
**Expected**: Interactive snapshot showing form fields with refs (@e1, @e2, etc.)
**If different**: Wait for page load: `agent-browser --native wait --load networkidle`

### Step 3: Fill email
```bash
agent-browser --native fill @<email-field> "admin@settlemint.com"
```
**Expected**: Email field populated
**If different**: Look for field with placeholder "Email" or `[name="email"]`

### Step 4: Fill password
```bash
agent-browser --native fill @<password-field> "settlemint"
```
**Expected**: Password field populated (masked)
**If different**: Look for field with type "password" or `[name="password"]`

### Step 5: Submit the form
```bash
agent-browser --native click @<sign-in-button>
```
**Expected**: Form submits, page navigates
**If different**: Look for button with text "Sign in" or role "button"

### Step 6: Wait for navigation
```bash
agent-browser --native wait --load networkidle
agent-browser --native snapshot -i
```
**Expected**: Dashboard or onboarding page (depends on user state)
**If different**: If pincode prompt appears, enter `111111`. If error message, check credentials.

### Step 7: Handle pincode if prompted
```bash
# Check if pincode prompt is visible
agent-browser --native get text body
```
If pincode is requested:
```bash
agent-browser --native fill @<pincode-field> "111111"
agent-browser --native click @<confirm-button>
agent-browser --native wait --load networkidle
```

## Success indicators
- URL is no longer `/auth/sign-in`
- Page shows either dashboard content or onboarding wizard
- No error messages visible

## Known issues
- After `dev:reset`, the admin user may not exist yet — `dev:setup` must complete first
- Sign-in page sometimes has a brief loading spinner before form appears — add 500ms wait if fields aren't found
