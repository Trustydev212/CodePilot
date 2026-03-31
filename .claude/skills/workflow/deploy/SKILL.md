---
name: deploy
description: "Environment-aware deployment. Validates target, runs pre-deploy checks, executes deployment, verifies health."
user-invocable: true
allowed-tools: Bash, Read, Grep, Glob
---

# /deploy - Environment-Aware Deployment

Deploy to a specific environment with safety checks at every step.

## Target
$ARGUMENTS

Default: staging. Specify `production` explicitly for prod deploys.

## Phase 1: Environment Detection

```bash
# Detect deployment platform
if [ -f "vercel.json" ] || [ -f ".vercel" ]; then echo "Platform: Vercel"
elif [ -f "fly.toml" ]; then echo "Platform: Fly.io"
elif [ -f "railway.json" ] || [ -f "railway.toml" ]; then echo "Platform: Railway"
elif [ -f "render.yaml" ]; then echo "Platform: Render"
elif [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then echo "Platform: Docker"
elif [ -f "serverless.yml" ]; then echo "Platform: Serverless"
elif [ -d ".github/workflows" ]; then echo "Platform: GitHub Actions CI/CD"
elif [ -f "Procfile" ]; then echo "Platform: Heroku"
else echo "Platform: Unknown - manual deployment"
fi
```

## Phase 2: Pre-Deploy Checks

Run ALL checks. ANY failure = deploy blocked.

```bash
# 1. Clean working tree
if [ -n "$(git status --porcelain)" ]; then
  echo "ERROR: Uncommitted changes. Commit or stash before deploying." && exit 1
fi

# 2. On correct branch
BRANCH=$(git branch --show-current)
echo "Current branch: $BRANCH"

# 3. Up to date with remote
git fetch origin "$BRANCH" 2>/dev/null
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse "origin/$BRANCH" 2>/dev/null || echo "no-remote")
if [ "$LOCAL" != "$REMOTE" ] && [ "$REMOTE" != "no-remote" ]; then
  echo "WARNING: Local differs from remote. Push first."
fi

# 4. Run quality gates (same as /ship)
[ -f "tsconfig.json" ] && npx tsc --noEmit 2>&1
npm test 2>&1 || python -m pytest 2>&1 || go test ./... 2>&1
npm run build 2>&1
```

## Phase 3: Deploy

### Production Safety Gate
If target is `production`:
- Require explicit confirmation
- Check that staging deploy was tested first
- Verify no migrations pending that haven't been tested

### Execute Deployment
```bash
# Vercel
vercel --prod  # or vercel (for preview)

# Fly.io
fly deploy --strategy rolling

# Docker
docker compose -f docker-compose.prod.yml up -d --build

# Railway
railway up

# GitHub Actions (trigger workflow)
gh workflow run deploy.yml -f environment=production
```

## Phase 4: Post-Deploy Verification

```bash
# Health check
DEPLOY_URL="${DEPLOY_URL:-http://localhost:3000}"
echo "Checking health at: $DEPLOY_URL/api/health"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL/api/health" 2>/dev/null || echo "000")
if [ "$STATUS" = "200" ]; then
  echo "Health check: PASS"
else
  echo "Health check: FAIL (status: $STATUS)"
  echo "ROLLBACK MAY BE NEEDED"
fi
```

## Deploy Report

```
## Deployment Report

| Item | Status |
|------|--------|
| Environment | [staging/production] |
| Platform | [detected platform] |
| Branch | [branch name] |
| Commit | [short hash] |
| Pre-deploy checks | PASS/FAIL |
| Deployment | SUCCESS/FAILED |
| Health check | PASS/FAIL |
| URL | [deployed URL] |

### Rollback Command
[platform-specific rollback command]
```
