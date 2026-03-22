---
name: create-api-key
description: Create an API key for CLI/SDK access to the DALP API
requires:
  - onboarding-complete
provides:
  - api-key-available
type: cli
last-verified: 2026-03-18
confidence: low
---

## Prerequisites
- Onboarding complete (admin user fully set up)
- DAPI running: `cat kit/dapi/.portless/url.txt`

## Steps

### Step 1: Create API key via the API
```bash
DAPI_URL=$(cat kit/dapi/.portless/url.txt)

# First, authenticate to get a session cookie
AUTH_RESPONSE=$(curl -s -X POST "${DAPI_URL}/api/auth/sign-in/email" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@settlemint.com","password":"settlemint"}' \
  -c /tmp/dalp-cookies.txt)

echo "$AUTH_RESPONSE" | jq .
```
**Expected**: 200 response with session info
**If different**: Check if DAPI is running. Check if admin user exists.

### Step 2: Create the API key
```bash
API_KEY_RESPONSE=$(curl -s -X POST "${DAPI_URL}/api/v2/api-keys" \
  -H "Content-Type: application/json" \
  -b /tmp/dalp-cookies.txt \
  -d '{"name":"test-key","expiresAt":null}')

echo "$API_KEY_RESPONSE" | jq .
API_KEY=$(echo "$API_KEY_RESPONSE" | jq -r '.key // .apiKey // empty')
```
**Expected**: Response with API key starting with `sm_dalp_`
**If different**: The endpoint path or request shape may have changed. Check `kit/dapi/src/routes/` for the current API key creation route.

### Step 3: Store the key for other flows
```bash
echo "$API_KEY" > /tmp/dalp-api-key.txt
echo "API key stored at /tmp/dalp-api-key.txt"
```
**Expected**: File created with API key value
**If different**: Check if $API_KEY is empty — authentication may have failed

## Success indicators
- `/tmp/dalp-api-key.txt` contains a key starting with `sm_dalp_`
- Key works: `curl -s -H "x-api-key: $(cat /tmp/dalp-api-key.txt)" "${DAPI_URL}/api/v2/tokens" | jq .status`

## Known issues
- API key creation endpoint may require specific permissions — admin role should have them
- Session cookies expire — if this flow is run much later, re-authenticate first
- The exact API key endpoint path needs verification on first run — this flow needs self-learning
