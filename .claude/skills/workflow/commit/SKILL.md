---
name: commit
description: "Smart git commit with conventional commit messages. Analyzes staged changes and generates meaningful commit messages."
user-invocable: true
allowed-tools: Bash, Read, Grep, Glob
---

# /commit - Smart Git Commit

Analyze changes and create a meaningful conventional commit.

## Override message
$ARGUMENTS

## Process

### Step 1: Analyze Changes

```bash
# Check what's staged
echo "=== STAGED FILES ==="
git diff --cached --name-status

# If nothing staged, show what could be staged
if [ -z "$(git diff --cached --name-only)" ]; then
  echo ""
  echo "=== UNSTAGED CHANGES ==="
  git diff --name-status
  echo ""
  echo "Nothing staged. Stage files first with: git add <files>"
fi
```

### Step 2: Understand the Changes

Read the staged diff to understand WHAT changed and WHY:

```bash
git diff --cached --stat
git diff --cached
```

### Step 3: Generate Commit Message

Follow **Conventional Commits** format:

```
<type>(<scope>): <short description>

<body - explain WHY, not WHAT>

<footer - breaking changes, issue refs>
```

#### Types:
| Type | When to Use |
|------|------------|
| `feat` | New feature or functionality |
| `fix` | Bug fix |
| `refactor` | Code restructuring (no behavior change) |
| `perf` | Performance improvement |
| `test` | Adding or fixing tests |
| `docs` | Documentation only |
| `style` | Formatting, semicolons (no logic change) |
| `chore` | Build, CI, deps, tooling |
| `revert` | Reverting a previous commit |

#### Scope (optional):
The module/area affected: `auth`, `api`, `ui`, `db`, `config`, etc.

#### Rules:
- Subject line: imperative mood, lowercase, no period, max 72 chars
- Body: explain WHY the change was made, not what (the diff shows what)
- Reference issues: `Fixes #123`, `Closes #456`
- Breaking changes: `BREAKING CHANGE: <description>` in footer

### Step 4: Commit

If user provided a message in $ARGUMENTS, use that. Otherwise generate one.

```bash
# Stage if user asked to commit specific files
# Then commit with the generated message
git commit -m "<generated message>"
```

### Examples:

```
feat(auth): add JWT refresh token rotation

Prevents token theft from granting permanent access. Refresh tokens
are now single-use and rotated on each access token renewal.

Closes #142
```

```
fix(api): return 404 instead of 500 for missing users

The findById query was throwing an unhandled error when the user
didn't exist, causing a generic 500 response. Now properly catches
and returns a descriptive 404.

Fixes #87
```

```
refactor(orders): extract price calculation to service layer

Price calculation logic was duplicated in 3 route handlers.
Moved to OrderService.calculateTotal() for single source of truth.
```

```
chore(deps): upgrade prisma to v6.2

Fixes connection pooling issues in production under high load.
No schema changes required.
```

RULE: Never write "update file" or "fix bug" as commit messages. Be specific about WHAT and WHY.
