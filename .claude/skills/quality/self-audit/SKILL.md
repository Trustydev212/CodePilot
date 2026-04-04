---
name: self-audit
description: "Audit your CodePilot configuration — check hooks, rules, skills, memory, and templates are healthy and working."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Grep, Glob
---

# /self-audit - Harness Self-Audit

Checks that your CodePilot setup is healthy: hooks work, rules load, skills exist, memory is fresh, templates are valid.

## Phase 1: Hook Health Check

```bash
echo "=== HOOK HEALTH CHECK ==="

PASS=0
FAIL=0
WARN=0

# Check settings.json exists and is valid JSON
if [ -f ".claude/settings.json" ]; then
  if jq empty .claude/settings.json 2>/dev/null; then
    echo "✓ settings.json valid JSON"
    PASS=$((PASS+1))
  else
    echo "✗ settings.json has invalid JSON!"
    FAIL=$((FAIL+1))
  fi
else
  echo "✗ settings.json not found"
  FAIL=$((FAIL+1))
fi

# Check each hook file exists and is executable
echo ""
echo "--- Hook Files ---"
for hook in $(find .claude/hooks -name "*.sh" 2>/dev/null); do
  BASENAME=$(basename "$hook")
  if [ -x "$hook" ]; then
    echo "✓ $BASENAME — executable"
    PASS=$((PASS+1))
  else
    echo "✗ $BASENAME — NOT executable (run: chmod +x $hook)"
    FAIL=$((FAIL+1))
  fi
done

# Check hooks referenced in settings.json actually exist
echo ""
echo "--- Hook References ---"
REFERENCED_HOOKS=$(grep -oE '"bash.*\.claude/hooks/[^"]+\.sh"' .claude/settings.json 2>/dev/null | grep -oE '\.claude/hooks/[^"]+\.sh')
for ref in $REFERENCED_HOOKS; do
  if [ -f "$ref" ]; then
    echo "✓ $ref — referenced and exists"
    PASS=$((PASS+1))
  else
    echo "✗ $ref — referenced in settings but MISSING"
    FAIL=$((FAIL+1))
  fi
done
```

## Phase 2: Skills Health Check

```bash
echo ""
echo "=== SKILLS HEALTH CHECK ==="

SKILL_COUNT=0
BROKEN_SKILLS=0

# Check each skill has valid frontmatter
for skill_file in $(find .claude/skills -name "SKILL.md" 2>/dev/null); do
  SKILL_DIR=$(dirname "$skill_file")
  SKILL_NAME=$(basename "$SKILL_DIR")
  SKILL_COUNT=$((SKILL_COUNT+1))

  # Check frontmatter exists
  if head -1 "$skill_file" | grep -q "^---"; then
    # Check required fields
    HAS_NAME=$(grep -c "^name:" "$skill_file" 2>/dev/null)
    HAS_DESC=$(grep -c "^description:" "$skill_file" 2>/dev/null)

    if [ "$HAS_NAME" -gt 0 ] && [ "$HAS_DESC" -gt 0 ]; then
      echo "✓ /$SKILL_NAME — valid"
    else
      echo "⚠ /$SKILL_NAME — missing name or description in frontmatter"
      WARN=$((WARN+1))
    fi
  else
    echo "✗ /$SKILL_NAME — missing YAML frontmatter"
    BROKEN_SKILLS=$((BROKEN_SKILLS+1))
  fi
done

echo ""
echo "Total skills: $SKILL_COUNT"
[ "$BROKEN_SKILLS" -gt 0 ] && echo "Broken skills: $BROKEN_SKILLS"
```

## Phase 3: Rules Health Check

```bash
echo ""
echo "=== RULES HEALTH CHECK ==="

# Check manual rules
MANUAL_RULES=$(find .claude/rules -maxdepth 1 -name "*.md" 2>/dev/null | wc -l)
echo "Manual rules: $MANUAL_RULES"

# Check learned rules
LEARNED_RULES=$(find .claude/rules/learned -name "*.md" 2>/dev/null | wc -l)
echo "Learned rules: $LEARNED_RULES"

if [ "$LEARNED_RULES" -eq 0 ]; then
  echo "⚠ No learned rules — run /learn to generate project-specific rules"
  WARN=$((WARN+1))
fi

# Check for rules with path scoping
for rule in $(find .claude/rules -name "*.md" 2>/dev/null); do
  if head -5 "$rule" | grep -q "^paths:"; then
    echo "✓ $(basename "$rule") — has path scoping"
  else
    echo "· $(basename "$rule") — global scope (no path filter)"
  fi
done
```

## Phase 4: Memory Health Check

```bash
echo ""
echo "=== MEMORY HEALTH CHECK ==="

# Check memory files
for mem_file in bugs.md decisions.md patterns.md stack-profile.md; do
  if [ -f ".claude/memory/$mem_file" ]; then
    LINES=$(wc -l < ".claude/memory/$mem_file")
    if [ "$LINES" -gt 5 ]; then
      echo "✓ $mem_file — $LINES lines (populated)"
      PASS=$((PASS+1))
    else
      echo "⚠ $mem_file — exists but nearly empty ($LINES lines)"
      WARN=$((WARN+1))
    fi
  else
    echo "· $mem_file — not created yet (auto-populated by skills)"
  fi
done

# Check session logs
SESSION_COUNT=$(find .claude/memory/sessions -name "*.md" 2>/dev/null | wc -l)
echo ""
echo "Session logs: $SESSION_COUNT"

# Check memory staleness
if [ -f ".claude/memory/stack-profile.md" ]; then
  LAST_MODIFIED=$(stat -c %Y ".claude/memory/stack-profile.md" 2>/dev/null || echo 0)
  NOW=$(date +%s)
  DAYS_OLD=$(( (NOW - LAST_MODIFIED) / 86400 ))
  if [ "$DAYS_OLD" -gt 30 ]; then
    echo "⚠ stack-profile.md is ${DAYS_OLD} days old — run /learn to refresh"
    WARN=$((WARN+1))
  fi
fi
```

## Phase 5: Templates Health Check

```bash
echo ""
echo "=== TEMPLATES HEALTH CHECK ==="

# Manual templates
MANUAL_TPL=$(find .claude/templates -maxdepth 1 -name "*.hbs" 2>/dev/null | wc -l)
echo "Manual templates: $MANUAL_TPL"

# Learned templates
LEARNED_TPL=$(find .claude/templates/learned -name "*.hbs" 2>/dev/null | wc -l)
echo "Learned templates: $LEARNED_TPL"

# Validate templates have placeholders
for tpl in $(find .claude/templates -name "*.hbs" 2>/dev/null); do
  HAS_PLACEHOLDERS=$(grep -c '{{' "$tpl" 2>/dev/null || echo 0)
  if [ "$HAS_PLACEHOLDERS" -gt 0 ]; then
    echo "✓ $(basename "$tpl") — $HAS_PLACEHOLDERS placeholders"
  else
    echo "⚠ $(basename "$tpl") — no {{placeholders}} found"
    WARN=$((WARN+1))
  fi
done

if [ "$MANUAL_TPL" -eq 0 ] && [ "$LEARNED_TPL" -eq 0 ]; then
  echo "⚠ No templates found — run /learn to auto-generate from your codebase"
  WARN=$((WARN+1))
fi
```

## Phase 6: CLAUDE.md Consistency Check

```bash
echo ""
echo "=== CLAUDE.MD CONSISTENCY CHECK ==="

if [ -f "CLAUDE.md" ]; then
  # Check all skills are listed in auto-select table
  for skill_dir in $(find .claude/skills -name "SKILL.md" -exec dirname {} \; 2>/dev/null); do
    SKILL_NAME=$(basename "$skill_dir")
    if grep -q "$SKILL_NAME" CLAUDE.md 2>/dev/null; then
      echo "✓ /$SKILL_NAME — listed in CLAUDE.md"
    else
      echo "✗ /$SKILL_NAME — NOT listed in CLAUDE.md auto-select table"
      FAIL=$((FAIL+1))
    fi
  done

  # Check all hooks mentioned
  for hook in $(find .claude/hooks -name "*.sh" -exec basename {} \; 2>/dev/null); do
    HOOK_NAME="${hook%.sh}"
    if grep -q "$HOOK_NAME" CLAUDE.md 2>/dev/null; then
      echo "✓ $HOOK_NAME hook — documented"
    else
      echo "⚠ $HOOK_NAME hook — not documented in CLAUDE.md"
      WARN=$((WARN+1))
    fi
  done
else
  echo "✗ CLAUDE.md not found!"
  FAIL=$((FAIL+1))
fi
```

## Phase 7: Run Hook Self-Tests

```bash
echo ""
echo "=== HOOK SELF-TESTS ==="

if [ -f ".claude/hooks/self-test.sh" ]; then
  bash .claude/hooks/self-test.sh
else
  echo "⚠ self-test.sh not found — cannot verify hook behavior"
  WARN=$((WARN+1))
fi
```

## Phase 8: Score & Report

Calculate overall harness health score:

```
## /self-audit Report

### Harness Health Score: [X]/100

| Category | Status | Score |
|----------|--------|-------|
| Hooks | [N] working, [N] broken | /25 |
| Skills | [N] valid, [N] broken | /20 |
| Rules | [N] manual, [N] learned | /15 |
| Memory | [N] populated, [N] empty | /15 |
| Templates | [N] valid, [N] empty | /10 |
| CLAUDE.md | [N] consistent, [N] missing | /10 |
| Self-Tests | [N] pass, [N] fail | /5 |

### Critical Issues
- [List any FAIL items]

### Warnings
- [List any WARN items]

### Recommendations
1. [Actionable steps to improve score]
2. ...

### How to Fix
- Missing hooks: Add to .claude/hooks/ and register in settings.json
- Broken skills: Ensure YAML frontmatter with name + description
- Empty memory: Run /learn to populate, then skills auto-update
- Missing rules: Run /learn to generate project-specific rules
- CLAUDE.md gaps: Add missing skills/hooks to documentation
```

## Rules

RULE: Never modify any files during self-audit — this is read-only analysis.
RULE: Always run the self-test.sh if available.
RULE: Score objectively — don't inflate scores for missing components.
RULE: Provide specific, actionable recommendations for every issue found.
RULE: Check file permissions — hooks MUST be executable to work.
