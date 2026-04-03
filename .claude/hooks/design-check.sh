#!/bin/bash
# design-check.sh - Warn about generic UI patterns after editing UI files
# PostToolUse hook for Edit/Write on component files
# Catches: generic placeholder text, missing accessibility, hardcoded colors

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty' 2>/dev/null)

# Skip if no file path
[ -z "$FILE_PATH" ] && exit 0

# Only check UI component files
case "$FILE_PATH" in
  *.tsx|*.jsx|*.vue|*.svelte) ;;
  *) exit 0 ;;
esac

# Skip test/story files
case "$FILE_PATH" in
  *.test.*|*.spec.*|*.stories.*|*__test__*) exit 0 ;;
esac

# Read file content
[ ! -f "$FILE_PATH" ] && exit 0
CONTENT=$(cat "$FILE_PATH" 2>/dev/null)
[ -z "$CONTENT" ] && exit 0

WARNINGS=""

# Check 1: Generic placeholder text
if echo "$CONTENT" | grep -qiE '(Lorem ipsum|placeholder text|TODO:.*text|FIXME:.*copy)'; then
  WARNINGS="$WARNINGS\n  ⚠ Contains placeholder/Lorem ipsum text"
fi

# Check 2: Missing alt text on images
if echo "$CONTENT" | grep -qE '<img[^>]+>' && ! echo "$CONTENT" | grep -qE '<img[^>]+alt='; then
  WARNINGS="$WARNINGS\n  ⚠ <img> tag missing alt attribute (a11y)"
fi

# Check 3: Hardcoded color values (should use design tokens/CSS vars)
if echo "$CONTENT" | grep -qE "(color|background|border):\s*#[0-9a-fA-F]{3,8}" | head -3; then
  WARNINGS="$WARNINGS\n  ⚠ Hardcoded color values found — consider using CSS variables or design tokens"
fi

# Check 4: Inline styles (prefer classes/utility classes)
INLINE_COUNT=$(echo "$CONTENT" | grep -cE 'style=\{?\{' 2>/dev/null || echo 0)
if [ "$INLINE_COUNT" -gt 3 ]; then
  WARNINGS="$WARNINGS\n  ⚠ $INLINE_COUNT inline styles found — prefer Tailwind/CSS classes"
fi

# Check 5: Missing key prop in map
if echo "$CONTENT" | grep -qE '\.map\(' && echo "$CONTENT" | grep -qE '\.map\([^)]*\)' ; then
  if ! echo "$CONTENT" | grep -qE 'key='; then
    WARNINGS="$WARNINGS\n  ⚠ .map() without key= prop (React requirement)"
  fi
fi

# Check 6: onClick on non-interactive elements
if echo "$CONTENT" | grep -qE '(div|span|p|section|article)\s+.*onClick'; then
  if ! echo "$CONTENT" | grep -qE 'role=.*(button|link)'; then
    WARNINGS="$WARNINGS\n  ⚠ onClick on non-interactive element without role attribute (a11y)"
  fi
fi

# Report warnings (non-blocking)
if [ -n "$WARNINGS" ]; then
  echo "Design check for $(basename "$FILE_PATH"):" >&2
  echo -e "$WARNINGS" >&2
fi

# Always exit 0 — warnings only, never block
exit 0
