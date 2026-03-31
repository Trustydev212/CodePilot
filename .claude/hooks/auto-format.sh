#!/bin/bash
# auto-format.sh - Auto-format files after Claude edits them
# PostToolUse hook for Edit/Write operations
# Runs formatter if available, non-blocking (exit 0 always)

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty' 2>/dev/null)

# Skip if no file path
[ -z "$FILE_PATH" ] && exit 0

# Skip non-code files
case "$FILE_PATH" in
  *.md|*.txt|*.json|*.yml|*.yaml|*.toml|*.lock|*.log|*.csv)
    exit 0
    ;;
esac

# Skip files in node_modules, .next, dist, etc.
case "$FILE_PATH" in
  *node_modules/*|*.next/*|*dist/*|*build/*|*.git/*|*__pycache__/*)
    exit 0
    ;;
esac

# Find project root (look for package.json going up)
DIR=$(dirname "$FILE_PATH")
PROJECT_ROOT=""
while [ "$DIR" != "/" ]; do
  if [ -f "$DIR/package.json" ]; then
    PROJECT_ROOT="$DIR"
    break
  fi
  DIR=$(dirname "$DIR")
done

# Try formatters in order of preference
if [ -n "$PROJECT_ROOT" ]; then
  # Prettier (most common)
  if [ -f "$PROJECT_ROOT/node_modules/.bin/prettier" ]; then
    "$PROJECT_ROOT/node_modules/.bin/prettier" --write "$FILE_PATH" 2>/dev/null
    exit 0
  fi

  # Biome
  if [ -f "$PROJECT_ROOT/node_modules/.bin/biome" ]; then
    "$PROJECT_ROOT/node_modules/.bin/biome" format --write "$FILE_PATH" 2>/dev/null
    exit 0
  fi

  # dprint
  if [ -f "$PROJECT_ROOT/node_modules/.bin/dprint" ]; then
    "$PROJECT_ROOT/node_modules/.bin/dprint" fmt "$FILE_PATH" 2>/dev/null
    exit 0
  fi
fi

# Python: black or ruff
case "$FILE_PATH" in
  *.py)
    if command -v ruff &>/dev/null; then
      ruff format "$FILE_PATH" 2>/dev/null
    elif command -v black &>/dev/null; then
      black --quiet "$FILE_PATH" 2>/dev/null
    fi
    ;;
esac

# Go: gofmt
case "$FILE_PATH" in
  *.go)
    if command -v gofmt &>/dev/null; then
      gofmt -w "$FILE_PATH" 2>/dev/null
    fi
    ;;
esac

# Rust: rustfmt
case "$FILE_PATH" in
  *.rs)
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE_PATH" 2>/dev/null
    fi
    ;;
esac

# Always exit 0 — formatting is best-effort, never block
exit 0
