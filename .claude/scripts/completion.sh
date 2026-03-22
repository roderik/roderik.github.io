#!/usr/bin/env bash
#
# Stop hook: keep the agent working until all tasks and review gates are done.
# Enforces the workflow in CLAUDE.md (CI after edits, refiner launch, task completion).
#
# Loop guard: session-scoped counter prevents infinite retries.
# Set TASKMASTER_MAX to change the cap (default: 10, 0 = infinite).
#
# Thresholds (edits since last gate):
#   COMPLETION_CI_THRESHOLD      — edits before requiring CI again (default: 5)
#   COMPLETION_REFINER_THRESHOLD — edits before requiring refiner again (default: 5)
#
set -euo pipefail

INPUT=$(cat)
SESSION_ID=$(jq -r '.session_id' <<<"${INPUT}")
TRANSCRIPT=$(jq -r '.transcript_path' <<<"${INPUT}")

# ── loop guard ────────────────────────────────────────────────────────────────
COUNTER_DIR="${TMPDIR:-/tmp}/completion-hook"
mkdir -p "${COUNTER_DIR}"
COUNTER_FILE="${COUNTER_DIR}/${SESSION_ID}"
MAX=${TASKMASTER_MAX:-10}

COUNT=0
if [[ -f "${COUNTER_FILE}" ]]; then
  raw=$(cat "${COUNTER_FILE}")
  [[ "${raw}" =~ ^[0-9]+$ ]] && COUNT="${raw}"
fi

if [[ "${MAX}" -gt 0 && "${COUNT}" -ge "${MAX}" ]]; then
  rm -f "${COUNTER_FILE}"
  exit 0
fi

# ── thresholds ────────────────────────────────────────────────────────────────
CI_THRESHOLD=${COMPLETION_CI_THRESHOLD:-8}
REFINER_THRESHOLD=${COMPLETION_REFINER_THRESHOLD:-15}

# ── transcript analysis (single jq pass) ─────────────────────────────────────
[[ -z "${TRANSCRIPT}" || ! -f "${TRANSCRIPT}" ]] && exit 0

ANALYSIS=$(jq -s --argjson ci_thresh "${CI_THRESHOLD}" --argjson ref_thresh "${REFINER_THRESHOLD}" '
  # Collect all tool_use events with monotonic index (message * 10000 + item)
  [to_entries[] | .key as $msg_i | .value |
    select(.type == "assistant") |
    .message.content | to_entries[] | .key as $item_i | .value |
    select(.type == "tool_use") |
    {pos: ($msg_i * 10000 + $item_i), name: .name, input: .input}
  ] as $tools |

  # All source-code edit positions
  [$tools[] | select(
    ((.name | test("^(Edit|Write)$")) and
     (.input.file_path // "" | test("\\.(ts|tsx|js|jsx|mjs|cjs|sol|graphql|py|sh)$|/package\\.json$"))) or
    (.name == "NotebookEdit") or
    ((.name == "Task" or .name == "Agent") and ((.input.subagent_type // "") | test("^(general-purpose|shepherd)$")))
  )] as $edits |

  # Tasks: created vs resolved
  ($tools | map(select(.name == "TaskCreate")) | length) as $created |
  ($tools | map(select(.name == "TaskUpdate" and
    (.input.status == "completed" or .input.status == "deleted"))) | length) as $resolved |

  # Last CI position
  ([$tools[] | select(
    .name == "Bash" and
    ((.input.command // "") | test("bun run ci"))
  )] | if length > 0 then last.pos else -1 end) as $last_ci |

  # Last refiner position (sweep/simplify skill invocations OR refiner agent launches)
  ([$tools[] | select(
    ((.name == "Skill") and ((.input.skill // "") | test("^(sweep|simplify)$"))) or
    ((.name == "Task" or .name == "Agent") and ((.input.description // "") | test("(?i)sweep|code.?cleanup|reuse review|quality review|efficiency review|security review")))
  )] | if length > 0 then last.pos else -1 end) as $last_refiner |

  # Count edits since last CI / last refiner
  ($edits | map(select(.pos > $last_ci)) | length) as $edits_since_ci |
  ($edits | map(select(.pos > $last_refiner)) | length) as $edits_since_refiner |

  {
    has_edits: (($edits | length) > 0),
    tasks_incomplete: ($created > 0 and $resolved < $created),
    tasks_created: $created,
    tasks_resolved: $resolved,
    edits_since_ci: $edits_since_ci,
    edits_since_refiner: $edits_since_refiner,
    ci_needed: ($edits_since_ci >= $ci_thresh),
    refiner_needed: ($edits_since_refiner >= $ref_thresh)
  }
' "${TRANSCRIPT}" 2>/dev/null || echo '{}')

# ── build list of blockers ───────────────────────────────────────────────────
BLOCKERS=()

TASKS_INCOMPLETE=$(jq -r '.tasks_incomplete // false' <<<"${ANALYSIS}")
if [[ "${TASKS_INCOMPLETE}" == "true" ]]; then
  CREATED=$(jq -r '.tasks_created' <<<"${ANALYSIS}")
  RESOLVED=$(jq -r '.tasks_resolved' <<<"${ANALYSIS}")
  BLOCKERS+=("Incomplete tasks: ${RESOLVED}/${CREATED} resolved — finish or delete remaining tasks")
fi

HAS_EDITS=$(jq -r '.has_edits // false' <<<"${ANALYSIS}")
if [[ "${HAS_EDITS}" == "true" ]]; then
  CI_NEEDED=$(jq -r '.ci_needed // false' <<<"${ANALYSIS}")
  REFINER_NEEDED=$(jq -r '.refiner_needed // false' <<<"${ANALYSIS}")
  EDITS_CI=$(jq -r '.edits_since_ci' <<<"${ANALYSIS}")
  EDITS_REF=$(jq -r '.edits_since_refiner' <<<"${ANALYSIS}")

  [[ "${CI_NEEDED}" == "true" ]] && BLOCKERS+=("Run 'bun run ci' — ${EDITS_CI} edits since last run")
  [[ "${REFINER_NEEDED}" == "true" ]] && BLOCKERS+=("Run /sweep to review changed code for reuse, quality, efficiency, and security — ${EDITS_REF} edits since last review")
fi

# ── decide ───────────────────────────────────────────────────────────────────
if [[ ${#BLOCKERS[@]} -eq 0 ]]; then
  rm -f "${COUNTER_FILE}"
  exit 0
fi

# Block and continue
NEXT=$((COUNT + 1))
echo "${NEXT}" >"${COUNTER_FILE}"

if [[ "${MAX}" -gt 0 ]]; then
  LABEL="COMPLETION (${NEXT}/${MAX})"
else
  LABEL="COMPLETION (${NEXT})"
fi
ITEMS=$(printf '  - %s\n' "${BLOCKERS[@]}")

jq -n --arg reason "${LABEL}: Cannot stop yet.
${ITEMS}
Re-read the user's original request and confirm every part is addressed. Do the work — do not describe it." \
  '{ decision: "block", reason: $reason }'
