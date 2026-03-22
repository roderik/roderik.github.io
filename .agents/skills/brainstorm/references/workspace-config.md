<overview>
## PRD Team Workspace Configuration

Pre-fetched configuration for the PRD team. This avoids runtime API calls for static data.
</overview>

<team>
### Team

| Field | Value |
|-------|-------|
| Key | `PRD` |
| Name | Product |
| ID | `ebd5e3e8-9dfe-45ca-9f23-a77192a71dab` |
| Cycles | Yes |
</team>

<estimates>
### Estimation: T-Shirt Sizes

The PRD team uses **t-shirt size** estimation. The `--estimate` CLI flag takes the numeric value.

| Size | Numeric | When to use |
|------|---------|-------------|
| None | 0 | Not yet estimated |
| XS | 1 | Trivial — config change, single file tweak |
| S | 2 | Small — new component, simple endpoint |
| M | 3 | Medium — cross-cutting feature, new pattern |
| L | 5 | Large — new subsystem, complex integration |
| XL | 8 | Extra large — **split the ticket** if possible |

Default estimate: 1 (XS). Zero is allowed.
</estimates>

<priorities>
### Priorities

| Value | Label | When to use |
|-------|-------|-------------|
| 0 | No priority | Not yet triaged |
| 1 | Urgent | Blocks everything, do first |
| 2 | High | Core feature, on the critical path |
| 3 | Medium | Important but not blocking |
| 4 | Low | Nice-to-have, polish |
</priorities>

<workflow_states>
### Workflow States

| State | Type | ID |
|-------|------|----|
| Triage | triage | `17652e41-3fb3-46bd-87c2-b2215dc91009` |
| Backlog | backlog | `77532d68-5656-4ce1-9adf-82219e0d94af` |
| Todo | unstarted | `1af6d45d-aba6-405a-923a-6c01dd6b5aee` |
| In Progress | started | `788c6a28-7426-4630-aa9a-9a79a9006104` |
| In Review | started | `81e6531b-6deb-4766-ab22-8e00dc9c5dad` |
| Done | completed | `de7e968a-9bd1-438d-b25f-82ac13f4baef` |
| Canceled | canceled | `f8d971e5-fa36-4652-a8a5-c10ef09d2c48` |
| Duplicate | canceled | `0d58490b-8efc-48b2-80fa-7dfb15bcf448` |

Use state names with `--state` flag: `linear issue create --state "Todo"`
</workflow_states>

<labels>
### Labels (PRD Team)

| Label | ID | Use for |
|-------|----|---------|
| Bug | `14b68967-c983-448e-bdff-895c83e8f816` | Bug fixes |
| Enhancement | `abfc426f-112a-41c6-95e3-a7e2a6904e6e` | Feature improvements |
| Needs analysis | `af561dd9-337c-4f1b-b97e-7d9ed30e65fe` | Tickets needing investigation |
| Security | `ecd9b2e8-bb24-409a-95d1-4b0065d8e129` | Security-related work |
| Release Blocker | `51683d50-2215-45e0-8cc1-aca46a52210e` | Must-fix for release |
| Task : E2E | `75f1b0fb-b424-4d06-bd42-4017464131d7` | End-to-end test tasks |
| onboarding | `193e06cf-e235-4ef0-a38f-731f8bd0516e` | Onboarding flow work |
| Engineering Ready | `bad332d5-ab7d-48a6-84f3-1f60bde22d97` | Spec complete, ready to build |
| Tracer Bullet | `fb4dab01-c4b4-499d-98d2-badad2d64fda` | First end-to-end vertical slice proving the architecture |

Use label names with `--label` flag: `linear issue create --label "Bug"`
Labels can be repeated: `--label "Bug" --label "Security"`
</labels>

<initiatives>
### Active Initiatives

| Initiative | ID |
|------------|----|
| Bringing digital assets to life | `7e2a57dd-9fd7-4afe-869f-6737c7d0b99b` |
| Customer Success | `5732c0fe-bb03-4ee2-8f91-bf677580fb17` |
| Deploy and operate at will | `4cbfe0df-8e8c-4cae-b474-f562007f6b87` |
| Letting go of the past | `f9d00fd2-7c0a-4307-a55a-6a9de25793d6` |

Use with: `linear project create --initiative "Bringing digital assets to life"`
</initiatives>
