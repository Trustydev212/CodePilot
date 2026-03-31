#!/bin/bash
# quality-gate.sh - Run quality checks after file edits
# Used in PostToolUse hook for Edit/Write tools

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"

# === TypeScript/JavaScript: Type check changed file ===
if [[ "$EXT" == "ts" || "$EXT" == "tsx" ]]; then
  if [ -f "tsconfig.json" ]; then
    # Quick type check (only errors, suppress warnings)
    TSC_OUTPUT=$(npx tsc --noEmit 2>&1 | grep -i "error" | head -5)
    if [ -n "$TSC_OUTPUT" ]; then
      echo "Type errors detected after edit:" >&2
      echo "$TSC_OUTPUT" >&2
    fi
  fi
fi

# === Python: Quick syntax check ===
if [[ "$EXT" == "py" ]]; then
  SYNTAX_OUTPUT=$(python -c "import py_compile; py_compile.compile('$FILE_PATH', doraise=True)" 2>&1)
  if [ $? -ne 0 ]; then
    echo "Python syntax error:" >&2
    echo "$SYNTAX_OUTPUT" >&2
  fi
fi

# === JSON: Validate syntax ===
if [[ "$EXT" == "json" ]]; then
  if ! jq empty "$FILE_PATH" 2>/dev/null; then
    echo "Invalid JSON in $FILE_PATH" >&2
  fi
fi

# === YAML: Validate syntax ===
if [[ "$EXT" == "yml" || "$EXT" == "yaml" ]]; then
  if command -v python3 &>/dev/null; then
    python3 -c "import yaml; yaml.safe_load(open('$FILE_PATH'))" 2>/dev/null
    if [ $? -ne 0 ]; then
      echo "Invalid YAML in $FILE_PATH" >&2
    fi
  fi
fi

exit 0
