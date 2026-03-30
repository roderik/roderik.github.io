---
name: postiz
description: >-
  Draft and schedule social media posts to X and LinkedIn via Postiz.
  Use when publishing a new blog post, sharing a release, or amplifying
  any piece of content. Triggers: "draft a post", "schedule to LinkedIn",
  "share on X", "write social copy for", "post about".
user-invocable: true
disable-model-invocation: false
---

<objective>
Draft, review, and schedule posts to X and LinkedIn using the Postiz CLI.
The binary is at `~/.local/bin/postiz`. The API key is in `POSTIZ_API_KEY`.
</objective>

## Connected Accounts

| Platform | Name | Integration ID |
|----------|------|----------------|
| LinkedIn | Roderik van der Veer | `cmncu68kt033avv0yksn9xhve` |
| X | Roderik | `cmncu6hs0035tph0ybhzcir0u` |

## Environment Setup

```bash
export POSTIZ_API_KEY="ef2d364b46acae7fbb60601b39b0bf98966ed7e92db4d47bd3f6a64810b4e7dd"
export PATH="$HOME/.local/bin:$PATH"
```

Verify connection:
```bash
postiz integrations:list
```

## Workflow: Blog Post Launch

When a blog post is published or a PR with a new post is merged, follow this sequence:

### 1. Draft the copy

Write two variants — one for each platform:

**X (max ~280 chars, punchy, link at end):**
- Lead with the problem or insight, not the product name
- One concrete detail (stat, code snippet, or quote from post)
- CTA: link to post
- 2-3 relevant hashtags max: `#AIAgents #DevTools #OpenSource`

**LinkedIn (3-5 short paragraphs, more context OK):**
- Hook line (same as X but can be longer)
- 2-3 sentences on the problem
- What the post/tool does about it
- Why it matters for developers
- Link + call to engagement ("What's your experience with X?")

### 2. Schedule the posts

```bash
# Post to both platforms immediately
postiz posts:create \
  --integrationId cmncu6hs0035tph0ybhzcir0u \
  --content "Your X copy here" \
  --date "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

postiz posts:create \
  --integrationId cmncu68kt033avv0yksn9xhve \
  --content "Your LinkedIn copy here" \
  --date "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Or schedule for a specific time (prefer 9am CET on a weekday)
postiz posts:create \
  --integrationId cmncu6hs0035tph0ybhzcir0u \
  --content "Your X copy here" \
  --date "2026-03-31T08:00:00Z"
```

### 3. Verify scheduling

```bash
postiz posts:list
```

## Voice and Tone Rules

- Write like a senior developer, not a marketer.
- Never use words like: "game-changer", "revolutionary", "leverage", "synergy".
- Lead with the problem. Mention the tool after.
- Technical credibility first — one concrete detail beats three adjectives.
- Understate. Let the code or the use case do the selling.

## Post Templates

### Blog post launch (X)

```
AI agents write the code. You're still babysitting the PR loop.

bellwether closes that: npx bellwether check --watch pipes your CI failures
and review comments directly to the agent. No copy-paste, no context switches.

New post: [link]

#AIAgents #DevTools
```

### Blog post launch (LinkedIn)

```
AI coding agents have gotten good at writing code. The part nobody talks
about: what happens after the PR is opened.

CI fails. You read the logs. You summarise the error. You paste it back into
the agent. Repeat until green.

That loop is manual plumbing that shouldn't exist.

bellwether is a TypeScript CLI that reads your PR state — CI status, review
comments, mergeable — and returns it structured for an agent to act on.
One command, no browser polling.

New post walking through how it works: [link]

What does your post-PR loop look like right now?
```

### Release announcement (X)

```
bellwether v[VERSION] is out.

[1-2 key changes]

npx -y bellwether@latest check --watch

[link to release/changelog]

#OpenSource #DevTools #AIAgents
```

## When to Post

- **New blog post**: within 24h of publish, weekday 9-11am CET preferred
- **Release**: same day, any time
- **Community milestone** (stars, downloads): opportunistic, tie to a genuine update
- **Never**: don't post just to post. Every post needs a concrete thing to point at.

## CLI Reference

```bash
# List scheduled/published posts
postiz posts:list

# Create a post (schedule for future)
postiz posts:create --integrationId <id> --content "text" --date "ISO8601"

# Delete a scheduled post
postiz posts:delete <id>

# Check analytics
postiz analytics:platform <integrationId>

# Upload media for a post
postiz upload ./image.png
```
