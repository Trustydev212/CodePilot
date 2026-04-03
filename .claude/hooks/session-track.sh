#!/bin/bash
# session-track.sh - Track session activity and save context
# PostToolUse hook for all tools
# Tracks: files modified, commands run, time spent
# Saves session summary to .claude/memory/sessions/

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty' 2>/dev/null)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Session directory
SESSION_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/memory/sessions"
mkdir -p "$SESSION_DIR" 2>/dev/null

# Session file (one per day)
TODAY=$(date -u +%Y-%m-%d)
SESSION_FILE="$SESSION_DIR/$TODAY.md"

# Initialize session file if needed
if [ ! -f "$SESSION_FILE" ]; then
  cat > "$SESSION_FILE" << HEADER
# Session Log — $TODAY

## Files Modified
<!-- auto-tracked -->

## Commands Run
<!-- auto-tracked -->

## Summary
<!-- auto-generated at session end -->
HEADER
fi

TIMESTAMP=$(date -u +%H:%M:%S)

# Track file edits
if [ -n "$FILE_PATH" ] && [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" ]]; then
  # Only add if not already listed
  if ! grep -qF "$FILE_PATH" "$SESSION_FILE" 2>/dev/null; then
    sed -i "/<!-- auto-tracked -->/a - \`$FILE_PATH\` ($TIMESTAMP)" "$SESSION_FILE" 2>/dev/null
  fi
fi

# Track significant commands (skip reads/status)
if [ -n "$COMMAND" ] && [[ "$TOOL_NAME" == "Bash" ]]; then
  # Skip trivial commands
  case "$COMMAND" in
    ls*|pwd|echo*|cat*|head*|tail*) ;;
    *)
      # Truncate long commands
      SHORT_CMD=$(echo "$COMMAND" | head -c 100)
      # Append under Commands Run (after the second auto-tracked marker)
      echo "- \`$SHORT_CMD\` ($TIMESTAMP)" >> "$SESSION_FILE" 2>/dev/null
      ;;
  esac
fi

# Always exit 0 — tracking is best-effort
exit 0
