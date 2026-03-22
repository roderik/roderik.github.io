## Brainstorm GraphQL Operations

Specific GraphQL mutations and queries used by brainstorm workflows. These are not covered by the `linear-cli` reference docs — they are brainstorm-specific operations that use `linear api` as the transport.

For `linear api` syntax (heredocs, `--variable`, `--variables-json`), see `linear-cli/references/api.md`.

---

### Update project description + content

Linear projects have TWO text fields:
- `description` (max 255 chars): short subtitle shown under the project name
- `content` (unlimited markdown): full rich-text body — this is where the PRD lives

There is no CLI command for project update — use GraphQL.

```bash
linear api \
  --variable "projectId=<project-uuid>" \
  --variable "description=<1-2 sentence summary, max 255 chars>" \
  --variable "content=@/tmp/prd-<project-id>.md" \
  <<'GRAPHQL'
mutation($projectId: String!, $description: String!, $content: String!) {
  projectUpdate(id: $projectId, input: { description: $description, content: $content }) {
    project { id name }
  }
}
GRAPHQL
```

Note: `@/path/to/file` reads the file content as the variable value.

---

### Update project metadata (lead, dates)

```bash
linear api \
  --variable "projectId=<project-uuid>" \
  --variable "leadId=<user-uuid>" \
  --variable "targetDate=YYYY-MM-DD" \
  <<'GRAPHQL'
mutation($projectId: String!, $leadId: String, $targetDate: TimelessDate) {
  projectUpdate(id: $projectId, input: {
    leadId: $leadId,
    targetDate: $targetDate
  }) {
    project { id name }
  }
}
GRAPHQL
```

Only include variables that were confirmed. `status` cannot be set via `projectUpdate` — it derives from the project's state machine.

---

### Resolve current user to UUID

```bash
linear api '{ viewer { id } }' | jq -r '.data.viewer.id'
```

### Resolve email to user UUID

```bash
linear api --variable email="<user-email>" <<'GRAPHQL'
query($email: String!) {
  users(filter: { email: { eq: $email } }) {
    nodes { id name email }
  }
}
GRAPHQL
```

---

### Fetch project content (PRD)

```bash
linear api --variable "projectId=<project-uuid>" <<'GRAPHQL'
query($projectId: String!) {
  project(id: $projectId) {
    id name description content
    status { name }
    lead { name email }
    startDate targetDate
    initiatives { nodes { name } }
  }
}
GRAPHQL
```

---

### List active projects (filtered)

`project list` does not support `--json`. For programmatic filtering:

```bash
linear api --variable teamKey="PRD" <<'GRAPHQL'
query($teamKey: String!) {
  teams(filter: { key: { eq: $teamKey } }) {
    nodes {
      projects(filter: { status: { name: { nin: ["Completed", "Canceled"] } } }) {
        nodes { id name status { name } description }
      }
    }
  }
}
GRAPHQL
```

---

### Retrieve milestone IDs for a project

```bash
linear api --variable "projectId=<project-uuid>" <<'GRAPHQL'
query($projectId: String!) {
  project(id: $projectId) {
    projectMilestones { nodes { id name } }
  }
}
GRAPHQL
```

---

### Resolve issue identifier to UUID

```bash
linear api --variable "identifier=PRD-123" <<'GRAPHQL'
query($identifier: String!) {
  issue(id: $identifier) { id identifier title }
}
GRAPHQL
```

---

### Assign issue to milestone

The CLI's `issue create` does not support `--milestone`. Use GraphQL after creation:

```bash
linear api \
  --variable "issueId=<issue-uuid>" \
  --variable "milestoneId=<milestone-uuid>" \
  <<'GRAPHQL'
mutation($issueId: String!, $milestoneId: String!) {
  issueUpdate(id: $issueId, input: { projectMilestoneId: $milestoneId }) {
    issue { identifier title }
  }
}
GRAPHQL
```
