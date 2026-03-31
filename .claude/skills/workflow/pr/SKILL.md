---
name: pr
description: "Create a pull request with structured description, test plan, and change summary. Auto-generates from commit history."
user-invocable: true
allowed-tools: Bash, Read, Grep, Glob
---

# /pr - Pull Request Creator

Create a well-structured PR that reviewers actually want to read.

## Details
$ARGUMENTS

## Process

### Step 1: Gather Context

```bash
# Current branch
BRANCH=$(git branch --show-current)
echo "Branch: $BRANCH"

# Base branch (usually main or develop)
BASE=$(git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}' || echo "main")
echo "Base: $BASE"

# Commits in this branch
echo ""
echo "=== COMMITS ==="
git log --oneline "$BASE"..HEAD 2>/dev/null || git log --oneline -10

# Files changed
echo ""
echo "=== FILES CHANGED ==="
git diff --stat "$BASE"..HEAD 2>/dev/null || git diff --stat HEAD~5..HEAD

# Full diff summary
echo ""
echo "=== DIFF SUMMARY ==="
git diff "$BASE"..HEAD --shortstat 2>/dev/null
```

### Step 2: Analyze Changes

Read the actual changes to understand:
1. What was added/modified/removed
2. Why these changes were made (from commit messages)
3. What areas of the codebase are affected
4. Any breaking changes or migration steps needed

### Step 3: Generate PR Description

```markdown
## Summary
<!-- 2-3 bullet points: what this PR does and WHY -->

- [Main change and motivation]
- [Secondary change if applicable]

## Changes

### [Category 1: e.g., Backend]
- [Specific change with file reference]
- [Specific change with file reference]

### [Category 2: e.g., Frontend]
- [Specific change with file reference]

## Test Plan

- [ ] [How to test change 1]
- [ ] [How to test change 2]
- [ ] [Edge case to verify]
- [ ] Existing tests pass
- [ ] New tests added for [what]

## Screenshots
<!-- If UI changes, add before/after screenshots -->

## Breaking Changes
<!-- If any, describe migration steps -->
None / [Description + migration guide]

## Checklist

- [ ] Types check (`tsc --noEmit`)
- [ ] Lint passes (`eslint`)
- [ ] Tests pass
- [ ] Build succeeds
- [ ] Documentation updated (if needed)
```

### Step 4: Create PR

```bash
# Ensure branch is pushed
git push -u origin "$BRANCH" 2>/dev/null

# Create PR using gh CLI if available
if command -v gh &>/dev/null; then
  gh pr create --title "<title>" --body "<body>"
else
  echo "gh CLI not available. Copy the PR description above and create manually."
  echo "URL: https://github.com/<owner>/<repo>/compare/$BASE...$BRANCH"
fi
```

### PR Title Rules:
- Max 72 characters
- Format: `[type]: Short description` or just `Short description`
- Same types as conventional commits (feat, fix, refactor, etc.)
- Examples:
  - `feat: Add JWT refresh token rotation`
  - `fix: Return 404 for missing users instead of 500`
  - `refactor: Extract price calculation to service layer`

### PR Size Guidelines:
- **Small** (<200 lines): Ideal. Easy to review.
- **Medium** (200-500 lines): Acceptable. Add good description.
- **Large** (500+ lines): Consider splitting into smaller PRs.
- **Huge** (1000+ lines): Split this. No one reviews 1000 lines well.

RULE: Every PR needs a test plan. "It works on my machine" is not a test plan.
