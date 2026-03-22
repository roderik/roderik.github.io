---
name: create-token
description: Create a test token via the API for use in subsequent test flows
requires:
  - api-key-available
provides:
  - token-created
type: cli
last-verified: 2026-03-18
confidence: low
---

## Prerequisites
- API key available at `/tmp/dalp-api-key.txt` (run `cli/create-api-key` flow first)
- DAPI running

## Steps

### Step 1: Create a stablecoin token
```bash
DAPI_URL=$(cat kit/dapi/.portless/url.txt)
API_KEY=$(cat /tmp/dalp-api-key.txt)
TOKEN_NAME="Test-$(date +%s)"

TOKEN_RESPONSE=$(curl -s -X POST "${DAPI_URL}/api/v2/tokens" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -d "{
    \"name\": \"${TOKEN_NAME}\",
    \"symbol\": \"TST\",
    \"decimals\": 18,
    \"typeId\": \"stablecoin\"
  }")

echo "$TOKEN_RESPONSE" | jq .
TOKEN_ID=$(echo "$TOKEN_RESPONSE" | jq -r '.id // empty')
```
**Expected**: 201/202 response with token ID
**If different**: The endpoint or request shape may have changed. Check `packages/dalp/api-contract/src/routes/` for the current token creation contract. Common issues: wrong `typeId`, missing required fields.

### Step 2: Wait for token deployment (if async)
```bash
# If the creation returns a transaction request, poll for completion
TX_ID=$(echo "$TOKEN_RESPONSE" | jq -r '.transactionId // empty')
if [ -n "$TX_ID" ]; then
  echo "Waiting for transaction ${TX_ID}..."
  for i in $(seq 1 30); do
    STATUS=$(curl -s -H "x-api-key: ${API_KEY}" \
      "${DAPI_URL}/api/v2/transaction-requests/${TX_ID}" | jq -r '.status')
    echo "  Status: ${STATUS}"
    if [ "$STATUS" = "completed" ] || [ "$STATUS" = "mined" ]; then
      break
    fi
    sleep 2
  done
fi
```
**Expected**: Transaction completes within 60 seconds
**If different**: Check blockchain node is running, check restate worker is processing

### Step 3: Store token info for other flows
```bash
echo "$TOKEN_ID" > /tmp/dalp-test-token-id.txt
echo "Token ID stored: ${TOKEN_ID}"
```

## Success indicators
- Token ID stored at `/tmp/dalp-test-token-id.txt`
- `curl -s -H "x-api-key: ${API_KEY}" "${DAPI_URL}/api/v2/tokens/${TOKEN_ID}" | jq .name` returns the token name

## Known issues
- Token creation is asynchronous — the API returns a transaction request, not the token directly
- The exact typeId values may change — check the contract registry
- This flow needs self-learning for the exact API shape on first run
