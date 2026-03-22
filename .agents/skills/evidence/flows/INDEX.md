# Flow Registry

All available testing flows, their state tokens, and dependency graph.

## Bootstrap Chain (clean slate → ready to test)

```
cli/seed-database ──provides──→ database-seeded
       │
       ▼
browser/first-login ──provides──→ authenticated-session
       │
       ▼
browser/complete-onboarding ──provides──→ onboarding-complete
       │
       ▼
cli/create-api-key ──provides──→ api-key-available
```

## State Token Graph

| Token | Provided by | Required by |
|-------|-------------|-------------|
| `database-seeded` | `cli/seed-database` | `browser/first-login` |
| `authenticated-session` | `browser/first-login` | `browser/complete-onboarding`, `browser/navigate-*`, all browser flows |
| `onboarding-complete` | `browser/complete-onboarding` | `cli/create-api-key`, `browser/create-token`, most feature flows |
| `api-key-available` | `cli/create-api-key` | All `cli/` flows that call the API |
| `token-created` | `cli/create-token` or `browser/create-token` | Transfer flows, token detail flows |
| `transfer-user-exists` | `cli/create-transfer-user` | Transfer flows |

## Flow Inventory

### CLI Flows (`flows/cli/`)

| Flow | Provides | Requires | Confidence |
|------|----------|----------|------------|
| `seed-database` | `database-seeded` | — | low (not yet verified) |
| `create-api-key` | `api-key-available` | `onboarding-complete` | low (not yet verified) |
| `create-token` | `token-created` | `api-key-available` | low (not yet verified) |
| `create-transfer-user` | `transfer-user-exists` | `api-key-available` | low (not yet verified) |

### Browser Flows (`flows/browser/`)

| Flow | Provides | Requires | Confidence |
|------|----------|----------|------------|
| `first-login` | `authenticated-session` | `database-seeded` | low (not yet verified) |
| `complete-onboarding` | `onboarding-complete` | `authenticated-session` | low (not yet verified) |
| `create-token` | `token-created` | `onboarding-complete`, `authenticated-session` | low (not yet verified) |

---

*This index is updated automatically as flows are created, verified, or retired. Confidence levels reflect last verification date.*
