---
name: changelog
description: "Auto-generate changelogs from conventional commits. Semantic versioning, breaking changes detection, and release notes."
user-invocable: true
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# /changelog - Smart Changelog Generator

Generate release-quality changelogs from your git history. Follows Keep a Changelog format with semantic versioning.

## Target
$ARGUMENTS

## Phase 1: Analyze Git History

```bash
echo "=== GIT HISTORY ANALYSIS ==="

# Get latest tag (for version comparison)
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")
echo "Latest tag: $LATEST_TAG"

# Get commits since last tag (or all commits)
echo ""
echo "--- Commits since $LATEST_TAG ---"
if [ "$LATEST_TAG" != "none" ]; then
  git log "$LATEST_TAG"..HEAD --pretty=format:"%h %s" --no-merges
else
  git log --pretty=format:"%h %s" --no-merges -50
fi

echo ""
echo ""
echo "--- Commit Stats ---"
if [ "$LATEST_TAG" != "none" ]; then
  echo "Total commits: $(git rev-list "$LATEST_TAG"..HEAD --count)"
  echo "Contributors: $(git log "$LATEST_TAG"..HEAD --format='%aN' | sort -u | wc -l)"
  echo ""
  echo "Files changed:"
  git diff --stat "$LATEST_TAG"..HEAD | tail -1
else
  echo "Total commits: $(git rev-list HEAD --count)"
fi

echo ""
echo "--- Existing Changelog ---"
[ -f "CHANGELOG.md" ] && head -30 CHANGELOG.md || echo "No existing CHANGELOG.md"

# Current version from package.json
echo ""
echo "--- Current Version ---"
[ -f "package.json" ] && cat package.json | jq -r '.version // "not set"' 2>/dev/null
[ -f "pyproject.toml" ] && grep '^version' pyproject.toml | head -1
```

## Phase 2: Parse Conventional Commits

Categorize commits by type:

| Prefix | Category | SemVer Impact |
|--------|----------|---------------|
| `feat:` / `feat(scope):` | Features | MINOR |
| `fix:` / `fix(scope):` | Bug Fixes | PATCH |
| `perf:` | Performance | PATCH |
| `refactor:` | Code Refactoring | PATCH |
| `docs:` | Documentation | - |
| `test:` | Tests | - |
| `chore:` | Chores | - |
| `ci:` | CI/CD | - |
| `style:` | Style | - |
| `build:` | Build | - |
| `BREAKING CHANGE:` in body/footer | Breaking Changes | MAJOR |
| `feat!:` / `fix!:` (with `!`) | Breaking Changes | MAJOR |

## Phase 3: Determine Next Version

Based on commits since last tag:
- Any `BREAKING CHANGE` or `!` → **MAJOR** bump (1.x.x → 2.0.0)
- Any `feat:` → **MINOR** bump (1.1.x → 1.2.0)
- Only `fix:`, `perf:`, `refactor:` → **PATCH** bump (1.1.1 → 1.1.2)
- Only `docs:`, `test:`, `chore:` → No version bump needed

## Phase 4: Generate Changelog

Format following [Keep a Changelog](https://keepachangelog.com/):

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [X.Y.Z] - YYYY-MM-DD

### ⚠ Breaking Changes
- **scope:** Description of breaking change ([commit-hash])
  - Migration: How to update existing code

### ✨ Features
- **scope:** Description of feature ([commit-hash])
- Description without scope ([commit-hash])

### 🐛 Bug Fixes
- **scope:** Description of fix ([commit-hash])

### ⚡ Performance
- Description of optimization ([commit-hash])

### ♻️ Refactoring
- Description of refactor ([commit-hash])

### 📖 Documentation
- Description of doc change ([commit-hash])

### 🧪 Tests
- Description of test change ([commit-hash])

### 🔧 Chores
- Description of chore ([commit-hash])
```

## Phase 5: Write Changelog

1. If `CHANGELOG.md` exists: **prepend** the new version section at the top (after the header)
2. If `CHANGELOG.md` doesn't exist: create it with the full header + all versions

```bash
# Also update version in package.json if applicable
if [ -f "package.json" ]; then
  echo "Current version: $(cat package.json | jq -r '.version')"
  echo "Suggested version: [calculated version]"
  echo ""
  echo "To bump version: npm version [major|minor|patch]"
fi
```

## Phase 6: Summary

```
## Changelog Generated

### Version: [X.Y.Z] (from [previous])
### Bump Type: [MAJOR/MINOR/PATCH]
### Changes:
- X features
- X bug fixes
- X breaking changes
- X other changes

### Files Updated:
- CHANGELOG.md

### Next Steps:
1. Review CHANGELOG.md for accuracy
2. Run: npm version [patch|minor|major]
3. Run: git tag v[X.Y.Z]
4. Push: git push --follow-tags
```

RULE: Never fabricate commits. Only document what's actually in git history.
RULE: Breaking changes MUST be prominently highlighted at the top of the release.
RULE: Group related commits under the same bullet point if they're part of the same feature/fix.
RULE: Commit hashes should be short (7 chars) and link to the actual commits if repo URL is known.
