---
name: token-budget
description: "Monitor and optimize context window usage. Get warnings before running out, compact suggestions, and cost tracking."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Grep, Glob
---

# /token-budget - Context Window & Token Budget Advisor

Helps you understand and optimize how much of the context window is being used. Prevents mid-task context overflow and suggests compaction strategies.

## Phase 1: Analyze Current Context Usage

Estimate context window consumption from the conversation state:

```bash
echo "=== CONTEXT WINDOW ANALYSIS ==="

# Count files read in this session
echo "--- Files in Context ---"

# Estimate from session tracking
if [ -f ".claude/memory/sessions/$(date -u +%Y-%m-%d).md" ]; then
  FILES_TRACKED=$(grep -c '\./' ".claude/memory/sessions/$(date -u +%Y-%m-%d).md" 2>/dev/null || echo 0)
  echo "Files touched today: $FILES_TRACKED"
fi

# Estimate project size for context planning
echo ""
echo "--- Project Size ---"
TOTAL_CODE_FILES=$(find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" -o -name "*.rs" \) ! -path "*/node_modules/*" ! -path "*/.next/*" ! -path "*/dist/*" 2>/dev/null | wc -l)
echo "Code files: $TOTAL_CODE_FILES"

TOTAL_LINES=$(find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" -o -name "*.rs" \) ! -path "*/node_modules/*" ! -path "*/.next/*" ! -path "*/dist/*" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
echo "Total lines: ${TOTAL_LINES:-0}"

# Estimate tokens (rough: 1 line ≈ 10 tokens average)
ESTIMATED_TOKENS=$((${TOTAL_LINES:-0} * 10))
echo "Estimated project tokens: ~$ESTIMATED_TOKENS"

# Large files that eat context
echo ""
echo "--- Largest Files (context hogs) ---"
find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" \) ! -path "*/node_modules/*" ! -path "*/.next/*" ! -path "*/dist/*" -exec wc -l {} + 2>/dev/null | sort -rn | head -10

# CodePilot config size
echo ""
echo "--- CodePilot Config Size ---"
CLAUDE_MD_LINES=$(wc -l < CLAUDE.md 2>/dev/null || echo 0)
RULES_LINES=$(find .claude/rules -name "*.md" -exec cat {} + 2>/dev/null | wc -l)
MEMORY_LINES=$(find .claude/memory -name "*.md" -exec cat {} + 2>/dev/null | wc -l)
echo "CLAUDE.md: $CLAUDE_MD_LINES lines (~$((CLAUDE_MD_LINES * 10)) tokens)"
echo "Rules: $RULES_LINES lines (~$((RULES_LINES * 10)) tokens)"
echo "Memory: $MEMORY_LINES lines (~$((MEMORY_LINES * 10)) tokens)"
echo "Total config overhead: ~$(( (CLAUDE_MD_LINES + RULES_LINES + MEMORY_LINES) * 10 )) tokens"
```

## Phase 2: Identify Context Waste

Look for things consuming context unnecessarily:

```bash
echo ""
echo "=== CONTEXT WASTE DETECTION ==="

# 1. Overly verbose CLAUDE.md
CLAUDE_LINES=$(wc -l < CLAUDE.md 2>/dev/null || echo 0)
if [ "$CLAUDE_LINES" -gt 300 ]; then
  echo "⚠ CLAUDE.md is $CLAUDE_LINES lines — consider trimming (target: <300)"
fi

# 2. Large rule files
for rule in $(find .claude/rules -name "*.md" 2>/dev/null); do
  LINES=$(wc -l < "$rule")
  if [ "$LINES" -gt 100 ]; then
    echo "⚠ $(basename "$rule") is $LINES lines — consider splitting or trimming"
  fi
done

# 3. Stale memory files
for mem in $(find .claude/memory -name "*.md" -not -name "README.md" 2>/dev/null); do
  LINES=$(wc -l < "$mem")
  if [ "$LINES" -gt 200 ]; then
    echo "⚠ Memory file $(basename "$mem") is $LINES lines — consider archiving old entries"
  fi
done

# 4. Duplicate/similar rules
echo ""
RULE_COUNT=$(find .claude/rules -name "*.md" 2>/dev/null | wc -l)
echo "Total rule files: $RULE_COUNT"
if [ "$RULE_COUNT" -gt 10 ]; then
  echo "⚠ $RULE_COUNT rule files — check for overlapping rules that could be merged"
fi

# 5. Large test files that might be read
LARGE_TESTS=$(find . -type f \( -name "*.test.*" -o -name "*.spec.*" \) ! -path "*/node_modules/*" -size +500c 2>/dev/null | wc -l)
if [ "$LARGE_TESTS" -gt 20 ]; then
  echo "⚠ $LARGE_TESTS large test files — reading all of them consumes significant context"
fi
```

## Phase 3: Optimization Recommendations

Based on analysis, generate specific recommendations:

```
## /token-budget Report

### Context Budget Overview

| Item | Size | Impact |
|------|------|--------|
| CLAUDE.md | ~[N] tokens | Always loaded |
| Rules (.claude/rules/) | ~[N] tokens | Always loaded |
| Memory (.claude/memory/) | ~[N] tokens | Loaded by skills |
| Project code | ~[N] tokens | Loaded on demand |

### Context Health: [GREEN/YELLOW/RED]

- 🟢 GREEN: Config < 5K tokens, project readable within context
- 🟡 YELLOW: Config 5-15K tokens, some files too large
- 🔴 RED: Config > 15K tokens, context overflow risk

### Waste Found
- [List items consuming context unnecessarily]

### Optimization Plan

#### Quick Wins (save [N] tokens)
1. [Specific recommendations]

#### Medium Effort
1. [Specific recommendations]

#### For Large Projects
1. Split CLAUDE.md into scoped rule files (loaded only when relevant)
2. Use /index to create a compact codebase map instead of reading everything
3. Archive old memory entries (move to .claude/memory/archive/)
4. Use path-scoped rules so only relevant rules load per file

### Tips for Token-Efficient Sessions
1. **Use /index first** — builds a map so Claude doesn't read every file
2. **Be specific** — "fix auth in src/lib/auth.ts" not "fix auth"
3. **One task per session** — context doesn't carry between sessions
4. **Use /checkpoint** — save progress, start fresh session for next task
5. **Avoid reading large files** — ask Claude to read specific line ranges
```

## Phase 4: Generate Context Budget Plan

If the project is large, create a `.claude/memory/context-budget.md` file:

```bash
echo ""
echo "=== GENERATING CONTEXT BUDGET PLAN ==="

cat > .claude/memory/context-budget.md << 'BUDGET'
# Context Budget Plan
# Auto-generated by /token-budget

## Always-Loaded Context
- CLAUDE.md (~X tokens)
- Active rules (~X tokens)
- Reserved for conversation: ~100K tokens

## Per-Task Budget
- Small fix: ~20K tokens (1-3 files)
- Feature: ~50K tokens (5-15 files)
- Refactor: ~80K tokens (10-30 files)
- Full audit: ~100K+ tokens (whole codebase)

## Optimization Rules
1. Never read entire codebase — use /index map
2. Read files with line ranges when possible
3. Use Grep to find relevant code, not Read
4. Compact after completing each subtask
5. Keep memory files under 200 lines each
BUDGET

echo "Saved to .claude/memory/context-budget.md"
```

## Rules

RULE: This skill is read-only analysis — don't modify project code.
RULE: Token estimates are approximate (1 line ≈ 10 tokens). State this in report.
RULE: Always provide actionable recommendations, not just metrics.
RULE: Focus on what the USER can control — config size, file organization, session strategy.
RULE: Update context-budget.md with actual measurements when available.
