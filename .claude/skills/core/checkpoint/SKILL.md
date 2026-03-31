---
name: checkpoint
description: "Create/restore git checkpoints for safe experimentation. Undo risky changes with one command."
user-invocable: true
allowed-tools: Bash, Read
---

# /checkpoint - Safe Experimentation Points

Create save points before risky changes. Restore if things go wrong.

## Usage
- `/checkpoint save [name]` - Create a checkpoint
- `/checkpoint restore [name]` - Restore to a checkpoint
- `/checkpoint list` - Show all checkpoints
- `/checkpoint diff [name]` - Show changes since checkpoint

## Command: $ARGUMENTS

### save [name]

Create a checkpoint (lightweight git tag):

```bash
NAME="${1:-auto-$(date +%Y%m%d-%H%M%S)}"
TAG="checkpoint/$NAME"

# Stash any uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
  git stash push -m "checkpoint-$NAME-uncommitted"
  STASHED=true
fi

# Create checkpoint tag at current HEAD
git tag "$TAG" HEAD 2>/dev/null

echo "Checkpoint created: $TAG"
echo "Commit: $(git rev-parse --short HEAD)"
echo "Uncommitted changes: ${STASHED:-none}"
echo ""
echo "To restore: /checkpoint restore $NAME"
```

### restore [name]

Restore to a checkpoint:

```bash
NAME="$1"
TAG="checkpoint/$NAME"

# Verify checkpoint exists
if ! git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "ERROR: Checkpoint '$NAME' not found" >&2
  echo "Available checkpoints:" >&2
  git tag -l "checkpoint/*" 2>/dev/null
  exit 1
fi

echo "WARNING: This will discard all changes since checkpoint '$NAME'"
echo "Current HEAD: $(git rev-parse --short HEAD)"
echo "Checkpoint:   $(git rev-parse --short $TAG)"
echo ""
echo "Changes that will be lost:"
git diff --stat "$TAG"..HEAD
echo ""
echo "Restoring..."

# Reset to checkpoint
git reset --hard "$TAG"

# Check if there's a stash for this checkpoint
STASH_ID=$(git stash list | grep "checkpoint-$NAME-uncommitted" | head -1 | cut -d: -f1)
if [ -n "$STASH_ID" ]; then
  echo "Restoring uncommitted changes..."
  git stash pop "$STASH_ID" 2>/dev/null
fi

echo "Restored to checkpoint: $NAME"
```

### list

```bash
echo "=== Checkpoints ==="
git tag -l "checkpoint/*" --sort=-creatordate | while read tag; do
  COMMIT=$(git rev-parse --short "$tag")
  DATE=$(git log -1 --format="%ci" "$tag")
  NAME=${tag#checkpoint/}
  echo "  $NAME  ($COMMIT)  $DATE"
done

if [ -z "$(git tag -l 'checkpoint/*')" ]; then
  echo "  No checkpoints found. Create one with: /checkpoint save <name>"
fi
```

### diff [name]

```bash
NAME="$1"
TAG="checkpoint/$NAME"

if ! git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "ERROR: Checkpoint '$NAME' not found" >&2
  exit 1
fi

echo "=== Changes since checkpoint '$NAME' ==="
echo ""
echo "--- Files changed ---"
git diff --stat "$TAG"..HEAD
echo ""
echo "--- Commits since checkpoint ---"
git log --oneline "$TAG"..HEAD
echo ""
echo "--- Uncommitted changes ---"
git status --short
```

## Best Practices

- Create a checkpoint BEFORE: refactoring, dependency upgrades, database migrations, config changes
- Use descriptive names: `/checkpoint save before-auth-refactor`
- Clean up old checkpoints: `git tag -d checkpoint/old-name`
- Checkpoints are LOCAL only - they don't push to remote
