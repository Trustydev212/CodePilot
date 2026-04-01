#!/bin/bash
# commit-guard.sh - Pre-commit quality check
# Blocks commits containing debug statements, conflict markers, or unsafe patterns
# Used in PreToolUse hook for Bash (git commit) commands

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Only check git commit commands
if ! echo "$COMMAND" | grep -qE '^git commit'; then
  exit 0
fi

# Get staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null)

if [ -z "$STAGED_FILES" ]; then
  exit 0
fi

ISSUES=""
ISSUE_COUNT=0

# Check each staged file
for FILE in $STAGED_FILES; do
  # Skip non-code files
  if ! echo "$FILE" | grep -qiE '\.(ts|tsx|js|jsx|py|go|rs|java|rb|php|swift|kt)$'; then
    continue
  fi

  # Skip test files for debug statement checks
  IS_TEST=false
  if echo "$FILE" | grep -qiE '(test|spec|mock|fixture|__test__)'; then
    IS_TEST=true
  fi

  # Get staged content of the file
  CONTENT=$(git show ":$FILE" 2>/dev/null)
  if [ -z "$CONTENT" ]; then
    continue
  fi

  # === CHECK 1: Conflict markers ===
  if echo "$CONTENT" | grep -qE '^(<<<<<<<|=======|>>>>>>>)'; then
    ISSUES="$ISSUES\n  ✗ $FILE: contains git conflict markers (<<<<<<<)"
    ISSUE_COUNT=$((ISSUE_COUNT + 1))
  fi

  # === CHECK 2: Debug statements (skip test files) ===
  if [ "$IS_TEST" = false ]; then
    # console.log (but not console.error, console.warn which might be intentional)
    if echo "$CONTENT" | grep -qE '^\s*(console\.log|console\.debug)\s*\('; then
      ISSUES="$ISSUES\n  ✗ $FILE: contains console.log/debug statements"
      ISSUE_COUNT=$((ISSUE_COUNT + 1))
    fi

    # debugger statement
    if echo "$CONTENT" | grep -qE '^\s*debugger\s*;?\s*$'; then
      ISSUES="$ISSUES\n  ✗ $FILE: contains debugger statement"
      ISSUE_COUNT=$((ISSUE_COUNT + 1))
    fi

    # Python breakpoint/pdb
    if echo "$FILE" | grep -qiE '\.py$'; then
      if echo "$CONTENT" | grep -qE '(breakpoint\(\)|import pdb|pdb\.set_trace)'; then
        ISSUES="$ISSUES\n  ✗ $FILE: contains Python debugger (pdb/breakpoint)"
        ISSUE_COUNT=$((ISSUE_COUNT + 1))
      fi
    fi
  fi

  # === CHECK 3: Sensitive patterns (all files) ===
  # Hardcoded secrets (simple patterns)
  if echo "$CONTENT" | grep -qiE "(password|secret|api_key|apikey|private_key)\s*[:=]\s*['\"][a-zA-Z0-9+/]{16,}['\"]"; then
    ISSUES="$ISSUES\n  ✗ $FILE: possible hardcoded secret detected"
    ISSUE_COUNT=$((ISSUE_COUNT + 1))
  fi

  # === CHECK 4: TODO HACK / FIXME HACK (intentional hacks left behind) ===
  if echo "$CONTENT" | grep -qiE '(TODO|FIXME):\s*(HACK|REMOVE|DELETE|TEMP|TEMPORARY)'; then
    ISSUES="$ISSUES\n  ✗ $FILE: contains TODO/FIXME marked as temporary hack"
    ISSUE_COUNT=$((ISSUE_COUNT + 1))
  fi

done

# Report
if [ $ISSUE_COUNT -gt 0 ]; then
  echo "COMMIT GUARD: Found $ISSUE_COUNT issue(s) in staged files:" >&2
  echo -e "$ISSUES" >&2
  echo "" >&2
  echo "Fix these issues before committing, or use --no-verify to bypass (not recommended)." >&2
  exit 2
fi

exit 0
