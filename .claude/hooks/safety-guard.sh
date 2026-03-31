#!/bin/bash
# safety-guard.sh - Block destructive and dangerous bash commands
# Used in PreToolUse hook for Bash tool

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

if [ -z "$COMMAND" ]; then
  exit 0
fi

# === DESTRUCTIVE COMMANDS ===
DESTRUCTIVE_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \."
  "rm -rf \*"
  "mkfs\."
  "dd if="
  "> /dev/sd"
  ":(){ :|:& };:"
)

for pattern in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "BLOCKED: Destructive command detected: $pattern" >&2
    exit 2
  fi
done

# === SECRET EXFILTRATION ===
# Block commands that could leak secrets
if echo "$COMMAND" | grep -qiE '(curl|wget|nc|netcat).*\.(env|key|pem|secret)'; then
  echo "BLOCKED: Potential secret exfiltration detected" >&2
  exit 2
fi

# Block piping secrets to network commands
if echo "$COMMAND" | grep -qiE 'cat.*\.(env|key|pem).*\|\s*(curl|wget|nc)'; then
  echo "BLOCKED: Piping secrets to network command" >&2
  exit 2
fi

# === PRODUCTION DATABASE ===
# Block direct production database access
if echo "$COMMAND" | grep -qiE '(DROP\s+TABLE|DROP\s+DATABASE|TRUNCATE|DELETE\s+FROM.*WHERE\s+1|DELETE\s+FROM\s+\w+\s*$)'; then
  echo "BLOCKED: Destructive database command. Use migrations instead." >&2
  exit 2
fi

# === GIT FORCE OPERATIONS ===
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*--force\s' | grep -qvE '\-\-force-with-lease'; then
  echo "BLOCKED: git push --force (use --force-with-lease instead)" >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard\s+origin/main'; then
  echo "BLOCKED: git reset --hard to main. This discards all local changes." >&2
  exit 2
fi

# === PERMISSION CHANGES ===
if echo "$COMMAND" | grep -qE 'chmod\s+(777|666|a\+rwx)'; then
  echo "BLOCKED: Insecure permission change (777/666). Use specific permissions." >&2
  exit 2
fi

# All checks passed
exit 0
