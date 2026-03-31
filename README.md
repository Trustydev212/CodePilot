# Claudekit

**Production-grade skills, hooks, and automation for Claude Code.**
Build fullstack apps faster. Ship with confidence.

## What Makes This Different

Most Claude Code toolkits are collections of generic prompts. Claudekit is different:

- **Evidence-based** — Every workflow verifies completion with real checks (tests pass, types check, lint clean)
- **Context-aware** — Auto-detects your stack (Next.js, FastAPI, Prisma, etc.) and adapts patterns
- **Safety-first** — Hooks block destructive commands, protect secrets, validate code in real-time
- **Actionable** — Skills produce specific code patterns, not vague advice
- **Fullstack** — Frontend, backend, database, DevOps, testing — all in one toolkit

## Quick Start

### Option 1: Copy to your project
```bash
# Clone and copy the .claude directory to your project
git clone https://github.com/trustydev212/claudehub.git
cp -r claudehub/.claude /path/to/your/project/
cp claudehub/CLAUDE.md /path/to/your/project/
```

### Option 2: Use as Claude Code plugin
```
/plugin marketplace add trustydev212/claudehub
```

## What's Included

### Workflow Commands (Slash Commands)

| Command | Description |
|---------|-------------|
| `/feature <desc>` | Plan → Implement → Test → Review (full lifecycle) |
| `/fix <issue>` | Root cause analysis → Fix → Regression test |
| `/plan <goal>` | Architecture planning with trade-off analysis |
| `/review` | 6-aspect deep code review |
| `/ship` | Pre-flight checks before deployment |
| `/test <scope>` | Generate meaningful tests |
| `/debug <symptom>` | Systematic root cause analysis |
| `/optimize <target>` | Performance profiling with before/after data |
| `/refactor <target>` | Safe refactoring with verification |
| `/audit` | Security + dependency + code quality audit |
| `/api <spec>` | Design and implement API endpoints |

### Expert Skills (Auto-activated)

| Skill | Activates When |
|-------|---------------|
| **react-nextjs** | Working with `.tsx/.jsx` files, Next.js projects |
| **ui-styling** | Working with CSS, Tailwind, shadcn/ui components |
| **api-design** | Working in `api/`, `routes/`, `controllers/` |
| **database** | Working with Prisma, Drizzle, SQL files |
| **auth** | Working with auth, login, session files |
| **nodejs** | Working with Node.js backend code |
| **python-backend** | Working with Python files, FastAPI, Django |
| **docker-cicd** | Working with Dockerfile, docker-compose, GitHub Actions |

### Safety Hooks (Always Active)

| Hook | What It Does |
|------|-------------|
| **safety-guard** | Blocks destructive bash commands (`rm -rf`, force push, insecure chmod) |
| **protect-secrets** | Prevents editing `.env`, `.key`, `.pem`, credential files |
| **quality-gate** | Auto-checks types/syntax after every file edit |

### Coding Rules (Path-scoped)

| Rule | Applied To |
|------|-----------|
| **typescript** | All `.ts/.tsx` files |
| **react** | All React components |
| **testing** | All test files |
| **api** | All API/route files |
| **git** | All files (commit practices) |

## Project Structure

```
.claude/
├── settings.json                    # Permissions, hooks config
├── skills/
│   ├── workflow/                     # Slash commands
│   │   ├── feature/SKILL.md         # /feature
│   │   ├── fix/SKILL.md             # /fix
│   │   ├── plan/SKILL.md            # /plan
│   │   ├── ship/SKILL.md            # /ship
│   │   └── review/SKILL.md          # /review
│   ├── frontend/
│   │   ├── react-nextjs/SKILL.md    # React 19 + Next.js 15
│   │   └── ui-styling/SKILL.md      # Tailwind + shadcn/ui + a11y
│   ├── backend/
│   │   ├── api-design/SKILL.md      # RESTful API patterns
│   │   ├── database/SKILL.md        # PostgreSQL, Prisma, Drizzle
│   │   ├── auth/SKILL.md            # Auth & authorization
│   │   ├── nodejs/SKILL.md          # Node.js/Express/Fastify
│   │   └── python-backend/SKILL.md  # FastAPI/Django/SQLAlchemy
│   ├── devops/
│   │   └── docker-cicd/SKILL.md     # Docker + GitHub Actions
│   ├── quality/
│   │   ├── debugger/SKILL.md        # /debug
│   │   ├── tester/SKILL.md          # /test
│   │   ├── security/SKILL.md        # /audit
│   │   └── optimizer/SKILL.md       # /optimize
│   └── core/
│       └── refactor/SKILL.md        # /refactor
├── hooks/
│   ├── safety-guard.sh              # Block destructive commands
│   ├── protect-secrets.sh           # Protect sensitive files
│   └── quality-gate.sh              # Auto type/syntax check
├── rules/
│   ├── typescript.md                # TypeScript standards
│   ├── react.md                     # React patterns
│   ├── testing.md                   # Testing practices
│   ├── api.md                       # API design rules
│   └── git.md                       # Git workflow rules
└── agents/                          # (extensible)
CLAUDE.md                            # Project context & philosophy
```

## Design Philosophy

### 1. Evidence Over Claims
Every workflow runs real quality gates before reporting completion:
- `tsc --noEmit` for type safety
- `eslint --max-warnings=0` for lint
- `npm test` / `pytest` for test suite
- `npm run build` for build verification

### 2. Fix the Root Cause
`/fix` uses 5 Whys technique to find the actual cause, not just patch symptoms.
`/debug` traces data flow backward from the error to its source.

### 3. Safety by Default
Hooks automatically:
- Block `rm -rf`, `git push --force`, `chmod 777`
- Prevent editing `.env`, `.key`, `.pem` files
- Validate types/syntax after every edit
- Scan for leaked secrets before shipping

### 4. Stack-Aware
Skills auto-detect your tech stack and adapt:
- Next.js project → Server Components patterns, App Router conventions
- FastAPI project → Pydantic models, async patterns
- Prisma → N+1 prevention, transaction patterns
- Docker → Multi-stage builds, security best practices

### 5. Real Patterns, Not Generic Advice
Every skill contains production code patterns you can use immediately:
- Cursor-based pagination implementation
- JWT refresh token rotation
- Multi-stage Docker builds
- Proper error handling middleware
- Database migration safety checklist

## Customization

### Add Your Own Skills
```bash
mkdir -p .claude/skills/my-skill
cat > .claude/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: "What this skill does"
user-invocable: true
---
# Instructions for Claude
Your custom workflow here
EOF
```

### Add Your Own Rules
```bash
cat > .claude/rules/my-rules.md << 'EOF'
---
paths:
  - "src/specific-area/**"
---
# Rules for this area
- Your coding standards here
EOF
```

### Add Your Own Hooks
Add to `.claude/settings.json`:
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "your-script.sh"
      }]
    }]
  }
}
```

## Requirements

- Claude Code (CLI, Desktop, or Web)
- `jq` installed (for hooks): `brew install jq` / `apt install jq`

## License

MIT
