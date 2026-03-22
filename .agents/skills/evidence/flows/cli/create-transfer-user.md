---
name: create-transfer-user
description: Create a second user for transfer testing scenarios
requires:
  - api-key-available
provides:
  - transfer-user-exists
type: cli
last-verified: 2026-03-18
confidence: low
---

## Prerequisites
- API key available at `/tmp/dalp-api-key.txt`
- DAPI running

## Steps

### Step 1: Create a new user via the API
```bash
DAPI_URL=$(cat kit/dapi/.portless/url.txt)
API_KEY=$(cat /tmp/dalp-api-key.txt)

USER_RESPONSE=$(curl -s -X POST "${DAPI_URL}/api/v2/users" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -d '{
    "email": "transfer-test@settlemint.com",
    "password": "settlemint",
    "name": "Transfer Test User",
    "role": "user"
  }')

echo "$USER_RESPONSE" | jq .
TRANSFER_USER_ID=$(echo "$USER_RESPONSE" | jq -r '.id // empty')
```
**Expected**: 201 response with user ID
**If different**: The user creation endpoint may require different fields or follow an invitation flow. Check `packages/dalp/api-contract/src/routes/` for the current user creation contract. The user may need to be invited and then accept, rather than created directly.

### Step 2: Store user info
```bash
echo "$TRANSFER_USER_ID" > /tmp/dalp-transfer-user-id.txt
echo "transfer-test@settlemint.com" > /tmp/dalp-transfer-user-email.txt
echo "Transfer user created: ${TRANSFER_USER_ID}"
```

## Success indicators
- Transfer user ID stored at `/tmp/dalp-transfer-user-id.txt`
- User can authenticate: `curl -s -X POST "${DAPI_URL}/api/auth/sign-in/email" -H "Content-Type: application/json" -d '{"email":"transfer-test@settlemint.com","password":"settlemint"}'`

## Known issues
- User creation may follow an invitation flow rather than direct creation — needs self-learning
- The transfer user may need onboarding completed before they can receive transfers
- This is a scaffolding flow — exact API shape needs verification on first run
