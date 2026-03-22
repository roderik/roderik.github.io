---
name: seed-database
description: Run migrations and seed base data for a clean dev environment
requires: []
provides:
  - database-seeded
type: cli
last-verified: 2026-03-18
confidence: low
---

## Prerequisites
- Infrastructure running (`bun run infra:up` — PostgreSQL, Anvil, etc.)
- No active dev server (migrations may conflict)

## Steps

### Step 1: Run dev setup
```bash
bun run dev:setup
```
**Expected**: Contracts deployed, subgraph synced, migrations applied, .env.local written
**If different**: Check if infrastructure is running with `docker ps`. If no containers, run `bun run infra:up` first.

### Step 2: Verify database is accessible
```bash
bun run --cwd kit/migrator db:check
```
**Expected**: No errors, migration state is clean
**If different**: If migration conflicts, follow the CLAUDE.md migration conflict flow (rm + regenerate)

## Success indicators
- `bun run dev:setup` completes without errors
- `kit/migrator` db:check passes
- `.env.local` files exist in kit packages

## Known issues
- First run after `infra:reset` may take 2-3 minutes for contract deployment
- Subgraph indexing wait can be skipped with `SKIP_SUBGRAPH_WAIT=1` if not testing subgraph features
