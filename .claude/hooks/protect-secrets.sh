#!/bin/bash
# protect-secrets.sh - Prevent writing to sensitive files
# Used in PreToolUse hook for Edit/Write tools

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Normalize path
BASENAME=$(basename "$FILE_PATH")
DIRNAME=$(dirname "$FILE_PATH")

# === PROTECTED FILES ===
PROTECTED_EXACT=(
  ".env"
  ".env.local"
  ".env.production"
  ".env.staging"
)

for protected in "${PROTECTED_EXACT[@]}"; do
  if [ "$BASENAME" = "$protected" ]; then
    echo "BLOCKED: Cannot modify $BASENAME - contains secrets. Use .env.example for templates." >&2
    exit 2
  fi
done

# === PROTECTED PATTERNS ===
if echo "$FILE_PATH" | grep -qiE '\.(key|pem|p12|pfx|jks|keystore)$'; then
  echo "BLOCKED: Cannot modify credential files ($BASENAME)" >&2
  exit 2
fi

if echo "$BASENAME" | grep -qiE '^id_(rsa|dsa|ecdsa|ed25519)'; then
  echo "BLOCKED: Cannot modify SSH private key ($BASENAME)" >&2
  exit 2
fi

if echo "$FILE_PATH" | grep -qiE '(credentials|secrets?|tokens?)\.(json|yaml|yml|xml|conf|cfg)$'; then
  echo "BLOCKED: Cannot modify secret configuration ($BASENAME)" >&2
  exit 2
fi

# === PROTECTED DIRECTORIES ===
if echo "$FILE_PATH" | grep -qE '(^|/)\.git/'; then
  echo "BLOCKED: Cannot modify .git internals" >&2
  exit 2
fi

# Block symlinks to protected files
if [ -L "$FILE_PATH" ]; then
  REAL_PATH=$(readlink -f "$FILE_PATH" 2>/dev/null || echo "$FILE_PATH")
  REAL_BASENAME=$(basename "$REAL_PATH")
  for protected in "${PROTECTED_EXACT[@]}"; do
    if [ "$REAL_BASENAME" = "$protected" ]; then
      echo "BLOCKED: Symlink points to protected file $REAL_BASENAME" >&2
      exit 2
    fi
  done
fi

# Allow .env.example
if [ "$BASENAME" = ".env.example" ] || [ "$BASENAME" = ".env.template" ]; then
  exit 0
fi

exit 0
