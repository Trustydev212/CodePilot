---
paths:
  - "**/*"
---

# Git Rules

- Commit messages: imperative mood, explain WHY not WHAT. "Fix race condition in order processing" not "Updated orders.ts".
- One logical change per commit. Don't mix feature + refactor + fix.
- Never commit: `.env`, `node_modules/`, `dist/`, `build/`, `*.key`, `*.pem`, credentials.
- Branch naming: `feature/`, `fix/`, `chore/`, `docs/` prefixes.
- Pull before push. Rebase for clean history on feature branches.
- Squash merge for PRs with messy commit history.
- Tag releases with semantic versioning: `v1.2.3`.
- Write meaningful PR descriptions: what changed, why, how to test.
