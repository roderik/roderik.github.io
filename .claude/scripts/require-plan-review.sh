#!/usr/bin/env bash
# Hook: PermissionRequest → ExitPlanMode
# Reads the plan from stdin (tool_input.plan), saves it, and triggers the
# planner skill's review phases if the plan hasn't been reviewed yet.

set -euo pipefail

# Read hook JSON from stdin and extract the plan content
hook_input=$(cat)
plan_content=$(echo "$hook_input" | jq -r '.tool_input.plan // empty')

if [[ -z "$plan_content" ]]; then
  echo "BLOCKED: Could not extract plan content from hook input."
  exit 2
fi

# Hash the plan to track whether this exact plan has been reviewed
plan_hash=$(echo "$plan_content" | shasum -a 256 | cut -d' ' -f1)
review_marker="/tmp/plan-reviewed-${plan_hash}"

if [[ -f "$review_marker" ]]; then
  echo "Plan already reviewed (hash: ${plan_hash:0:12}). Proceeding."
  exit 0
fi

# Save plan so the skill's subagents can read it
plan_file="/tmp/plan-for-review-${plan_hash}.md"
echo "$plan_content" >"$plan_file"

cat <<EOF
BLOCKED: The plan must be reviewed before exiting plan mode.

Read the planner skill's SKILL.md and run Phase 4 (Parallel expert review) through Phase 6 (Final quality check) on this plan: $plan_file

Create this marker when done: touch $review_marker
EOF
exit 2
