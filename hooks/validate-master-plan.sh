#!/bin/bash
#
# Hook: Validate MASTER_PLAN.md Format for Dev-Manager
# Triggers on Edit/Write to MASTER_PLAN.md
#
# Ensures tasks are formatted correctly for the dev-manager Kanban parser:
# - Proper ID prefixes (TASK-, BUG-, ROAD-, IDEA-, ISSUE-)
# - Correct header format: ### TASK-XXX: Title (STATUS)
# - Valid status keywords for Kanban columns
# - Required ## Active Work section for tasks
#

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract file path from tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# Only validate MASTER_PLAN.md edits
if [[ "$FILE_PATH" != *"MASTER_PLAN.md" ]]; then
  exit 0
fi

# Extract the new content being written
NEW_CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // ""')

# If no content (e.g., reading file), skip validation
if [[ -z "$NEW_CONTENT" ]]; then
  exit 0
fi

# Define valid ID patterns
VALID_PREFIXES="TASK|BUG|ROAD|IDEA|ISSUE"

# Valid status keywords for dev-manager parser
# Done: DONE, COMPLETE, COMPLETED, FIXED, ✅
# In Progress: IN PROGRESS, IN_PROGRESS, ACTIVE, WORKING, 🔄, ⏳
# Review: REVIEW, MONITORING, AWAITING, 👀
# Todo: PLANNED, TODO, or no keyword (default)
VALID_STATUSES="DONE|COMPLETE|COMPLETED|FIXED|IN PROGRESS|IN_PROGRESS|ACTIVE|WORKING|REVIEW|MONITORING|AWAITING|PLANNED|TODO"

ERRORS=""
WARNINGS=""

# ==============================================================================
# DEV-MANAGER FORMAT VALIDATION
# ==============================================================================

# 1. Check for ## Active Work section (REQUIRED for tasks to show in Kanban)
if ! echo "$NEW_CONTENT" | grep -q "^## Active Work"; then
  WARNINGS="$WARNINGS\n- Missing '## Active Work' section - tasks won't appear in dev-manager Kanban"
fi

# 2. Check task header format: ### TASK-XXX: Title (STATUS)
# Common mistake: using dash instead of colon after ID
if echo "$NEW_CONTENT" | grep -E "^### (TASK|BUG|ISSUE)-[0-9]+ -" | head -1 | grep -q .; then
  ERRORS="$ERRORS\n- Task headers use dash '-' instead of colon ':' after ID"
  ERRORS="$ERRORS\n  Wrong: ### TASK-001 - Title"
  ERRORS="$ERRORS\n  Correct: ### TASK-001: Title (STATUS)"
fi

# 3. Check for task headers without proper format in Active Work section
# Extract content between ## Active Work and next ## section
ACTIVE_WORK_CONTENT=$(echo "$NEW_CONTENT" | sed -n '/^## Active Work/,/^## [^A]/p')

if [[ -n "$ACTIVE_WORK_CONTENT" ]]; then
  # Check for ### headers that don't match expected format
  # Expected: ### TASK-XXX: Title or ### ~~TASK-XXX~~: Title
  INVALID_HEADERS=$(echo "$ACTIVE_WORK_CONTENT" | grep -E "^### " | grep -vE "^### (~~)?(TASK|BUG|ISSUE)-[0-9]+(~~)?:" | grep -vE "^### (Smart Group|Calendar|Phases|Dependency)" || true)

  if [[ -n "$INVALID_HEADERS" ]]; then
    FIRST_INVALID=$(echo "$INVALID_HEADERS" | head -1)
    WARNINGS="$WARNINGS\n- Found task header without proper format: '$FIRST_INVALID'"
    WARNINGS="$WARNINGS\n  Expected format: ### TASK-XXX: Title (STATUS)"
  fi

  # 4. Check if task headers have status in parentheses
  HEADERS_WITHOUT_STATUS=$(echo "$ACTIVE_WORK_CONTENT" | grep -E "^### (~~)?(TASK|BUG|ISSUE)-[0-9]+(~~)?:" | grep -vE "\([^)]+\)\s*$" || true)

  if [[ -n "$HEADERS_WITHOUT_STATUS" ]]; then
    FIRST_NO_STATUS=$(echo "$HEADERS_WITHOUT_STATUS" | head -1)
    WARNINGS="$WARNINGS\n- Task header missing status in parentheses: '$FIRST_NO_STATUS'"
    WARNINGS="$WARNINGS\n  Add status like: (TODO), (IN PROGRESS), (✅ DONE)"
  fi
fi

# 5. Check Roadmap section - tables should have ID column
if echo "$NEW_CONTENT" | grep -q "^## Roadmap"; then
  if echo "$NEW_CONTENT" | grep -E "^\| [^|]+\| [^|]+\| P[1-3]" | grep -vE "^\| ($VALID_PREFIXES)-[0-9]+" | grep -vE "^\| ~~($VALID_PREFIXES)-[0-9]+~~" | grep -vE "^\| ID " | head -1 | grep -q .; then
    WARNINGS="$WARNINGS\n- Roadmap table rows missing IDs (should be ROAD-XXX)"
  fi
fi

# 6. Check Known Issues section
if echo "$NEW_CONTENT" | grep -q "^## Known Issues"; then
  if echo "$NEW_CONTENT" | grep -E "^\| \*\*[^|]+\*\*" | grep -vE "^\| ($VALID_PREFIXES)-[0-9]+" | grep -vE "^\| ID " | head -1 | grep -q .; then
    WARNINGS="$WARNINGS\n- Known Issues table rows missing IDs (should be ISSUE-XXX)"
  fi
fi

# 7. Check for completed tasks - should have strikethrough on ID
COMPLETED_WITHOUT_STRIKETHROUGH=$(echo "$NEW_CONTENT" | grep -E "^### (TASK|BUG|ISSUE)-[0-9]+:.*\((✅|DONE|COMPLETE)" | grep -vE "^### ~~" || true)

if [[ -n "$COMPLETED_WITHOUT_STRIKETHROUGH" ]]; then
  FIRST_COMPLETED=$(echo "$COMPLETED_WITHOUT_STRIKETHROUGH" | head -1)
  WARNINGS="$WARNINGS\n- Completed task without strikethrough on ID: '$FIRST_COMPLETED'"
  WARNINGS="$WARNINGS\n  Format as: ### ~~TASK-XXX~~: Title (✅ DONE)"
fi

# ==============================================================================
# OUTPUT RESULTS
# ==============================================================================

# Build the format guide
FORMAT_GUIDE="

📋 DEV-MANAGER FORMAT GUIDE:

REQUIRED SECTION:
  ## Active Work

TASK HEADER FORMAT:
  ### TASK-XXX: Title (STATUS)
  ### ~~TASK-XXX~~: Title (✅ DONE)

STATUS KEYWORDS (for Kanban columns):
  Done: DONE, COMPLETE, ✅, ~~strikethrough~~
  In Progress: IN PROGRESS, 🔄, ACTIVE
  Review: REVIEW, MONITORING, 👀
  Todo: PLANNED, TODO, or default

PRIORITY FORMAT:
  In header: (P1-HIGH), (P2-MEDIUM)
  Or line: **Priority**: P1-HIGH

PROGRESS (from checkboxes):
  - [x] Completed step ✅
  - [ ] Pending step"

# Combine errors and warnings
if [[ -n "$ERRORS" || -n "$WARNINGS" ]]; then
  MESSAGE=""

  if [[ -n "$ERRORS" ]]; then
    MESSAGE="❌ FORMAT ERRORS (will break dev-manager parsing):$ERRORS"
  fi

  if [[ -n "$WARNINGS" ]]; then
    if [[ -n "$MESSAGE" ]]; then
      MESSAGE="$MESSAGE\n\n"
    fi
    MESSAGE="${MESSAGE}⚠️ FORMAT WARNINGS:$WARNINGS"
  fi

  MESSAGE="$MESSAGE$FORMAT_GUIDE"

  # Escape for JSON
  MESSAGE=$(echo -e "$MESSAGE" | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')

  cat << EOF
{
  "additionalContext": "$MESSAGE"
}
EOF
fi

exit 0
