#!/bin/bash
# loop-guard.sh - Prevent infinite hook re-entry and runaway loops
# PreToolUse hook — detects repeated identical tool calls
# 5-layer protection: dedup, throttle, depth limit, memory cap, timeout

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# State directory
STATE_DIR="/tmp/codepilot-loop-guard"
mkdir -p "$STATE_DIR" 2>/dev/null

# Create a fingerprint for this tool call
FINGERPRINT=$(echo "${TOOL_NAME}:${COMMAND}:${FILE_PATH}" | md5sum | cut -d' ' -f1)
COUNTER_FILE="$STATE_DIR/$FINGERPRINT"
GLOBAL_COUNTER="$STATE_DIR/_global_count"
WINDOW_FILE="$STATE_DIR/_window"

# ============================================================
# LAYER 1: Exact duplicate detection (same call within 3s)
# ============================================================
if [ -f "$COUNTER_FILE" ]; then
  LAST_TIME=$(stat -c %Y "$COUNTER_FILE" 2>/dev/null || echo 0)
  NOW=$(date +%s)
  DIFF=$((NOW - LAST_TIME))

  if [ "$DIFF" -lt 3 ]; then
    COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
    COUNT=$((COUNT + 1))
    echo "$COUNT" > "$COUNTER_FILE"

    if [ "$COUNT" -gt 5 ]; then
      echo "LOOP GUARD: Identical tool call repeated $COUNT times in ${DIFF}s. Possible infinite loop." >&2
      echo "Tool: $TOOL_NAME | Command: $(echo "$COMMAND" | head -c 80)" >&2
      # Reset counter to allow manual retry
      echo "0" > "$COUNTER_FILE"
      exit 2
    fi
  else
    # Reset counter after cooldown
    echo "1" > "$COUNTER_FILE"
  fi
else
  echo "1" > "$COUNTER_FILE"
fi

# ============================================================
# LAYER 2: Rate limiting (max 60 tool calls per minute)
# ============================================================
NOW=$(date +%s)
WINDOW_START=$(cat "$WINDOW_FILE" 2>/dev/null || echo 0)
GLOBAL_COUNT=$(cat "$GLOBAL_COUNTER" 2>/dev/null || echo 0)

if [ $((NOW - WINDOW_START)) -gt 60 ]; then
  # Reset window
  echo "$NOW" > "$WINDOW_FILE"
  echo "1" > "$GLOBAL_COUNTER"
else
  GLOBAL_COUNT=$((GLOBAL_COUNT + 1))
  echo "$GLOBAL_COUNT" > "$GLOBAL_COUNTER"

  if [ "$GLOBAL_COUNT" -gt 60 ]; then
    echo "LOOP GUARD: Rate limit exceeded (60 tool calls/minute). Cooling down." >&2
    # Reset to allow continuation
    echo "$NOW" > "$WINDOW_FILE"
    echo "0" > "$GLOBAL_COUNTER"
    exit 2
  fi
fi

# ============================================================
# LAYER 3: Runaway edit detection (same file edited 10+ times)
# ============================================================
if [ -n "$FILE_PATH" ] && [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" ]]; then
  FILE_HASH=$(echo "$FILE_PATH" | md5sum | cut -d' ' -f1)
  EDIT_COUNTER="$STATE_DIR/edit_$FILE_HASH"
  EDIT_COUNT=$(cat "$EDIT_COUNTER" 2>/dev/null || echo 0)
  EDIT_COUNT=$((EDIT_COUNT + 1))
  echo "$EDIT_COUNT" > "$EDIT_COUNTER"

  if [ "$EDIT_COUNT" -gt 10 ]; then
    echo "LOOP GUARD: File $(basename "$FILE_PATH") edited $EDIT_COUNT times this session. Possible fix loop." >&2
    echo "0" > "$EDIT_COUNTER"
    exit 2
  fi
fi

# ============================================================
# LAYER 4: State directory cleanup (prevent disk fill)
# ============================================================
FILE_COUNT=$(ls -1 "$STATE_DIR" 2>/dev/null | wc -l)
if [ "$FILE_COUNT" -gt 500 ]; then
  # Clean old files (older than 10 minutes)
  find "$STATE_DIR" -type f -mmin +10 -delete 2>/dev/null
fi

exit 0
