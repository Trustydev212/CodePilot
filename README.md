# CodePilot

**Production-grade skills, hooks, and automation for Claude Code.**
Build fullstack apps faster. Ship with confidence.

## What Makes This Different

Most Claude Code toolkits are collections of generic prompts. CodePilot is different:

- **Evidence-based** — Every workflow verifies completion with real checks (tests pass, types check, lint clean)
- **Context-aware** — Auto-detects your stack (Next.js, FastAPI, Prisma, etc.) and adapts patterns
- **Safety-first** — Hooks block destructive commands, protect secrets, validate code in real-time
- **Actionable** — Skills produce specific code patterns, not vague advice
- **Fullstack** — Frontend, backend, database, DevOps, testing — all in one toolkit

## Quick Start

### Option 1: One-line install
```bash
curl -fsSL https://raw.githubusercontent.com/trustydev212/codepilot/main/setup.sh | bash
```

### Option 2: Manual copy
```bash
git clone https://github.com/trustydev212/codepilot.git
cp -r codepilot/.claude /path/to/your/project/
cp codepilot/CLAUDE.md /path/to/your/project/
```

### Option 3: Git submodule (auto-update)
```bash
git submodule add https://github.com/trustydev212/codepilot.git .codepilot
cp -r .codepilot/.claude .claude/
cp .codepilot/CLAUDE.md CLAUDE.md
```

## What's Included

### 40+ Workflow Commands (Slash Commands)

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
| `/e2e <scope>` | End-to-end testing with Playwright |
| `/deploy <target>` | Environment-aware deployment with health checks |
| `/commit` | Smart conventional commit from staged changes |
| `/pr [details]` | Create structured PR with auto-generated description |
| `/migrate [target]` | Safe dependency upgrade with checkpoint and rollback |
| `/scaffold <target>` | Generate project structures and feature modules |
| `/docs [target]` | Auto-generate API docs, component docs, architecture |
| `/changelog` | Auto-generate changelogs from conventional commits |
| `/env` | Validate env vars, generate .env.example, detect leaks |
| `/seed` | Generate database seed data from schema |
| `/monitor` | Set up error tracking, health checks, logging |
| `/batch <operation>` | Apply changes across multiple files in parallel |
| `/loop <type>` | Automated fix-verify cycles until all checks pass |
| `/issue <number>` | Full issue-to-PR pipeline |
| `/perf <target>` | Bundle analysis, API latency, render performance |
| `/security` | Security scanning (deps, secrets, OWASP, headers) |
| `/a11y` | Accessibility audit and auto-fix (WCAG 2.1 AA) |
| `/i18n <action>` | Internationalization (extract, sync, check translations) |
| `/storybook <component>` | Auto-generate Storybook stories from components |
| `/db-migrate` | Safe database migration with rollback generation |
| `/upgrade <framework>` | Guided major version upgrades with codemods |
| `/ui <description>` | Generate UI components from text (v0-style) |
| `/design-system` | Design tokens, theme audit, consistency enforcement |
| `/screenshot-to-code` | Convert screenshots/mockups to production components |
| `/index` | Map codebase architecture, dependencies, patterns |
| `/checkpoint save\|restore\|list` | Git checkpoints for safe experimentation |
| `/common-ground` | Surface and validate Claude's assumptions |
| `/mode <name>` | Switch behavioral mode (token-efficient, brainstorm, etc.) |
| `/learn` | Analyze codebase patterns, auto-generate custom rules |

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
| **vue-svelte** | Working with `.vue/.svelte` files, Nuxt/SvelteKit |
| **state-graphql** | Working with stores, GraphQL, tRPC files |

### Safety Hooks (Always Active)

| Hook | What It Does |
|------|-------------|
| **safety-guard** | Blocks destructive bash commands (`rm -rf`, force push, insecure chmod) |
| **protect-secrets** | Prevents editing `.env`, `.key`, `.pem`, credential files |
| **quality-gate** | Auto-checks types/syntax after every file edit |
| **auto-format** | Auto-formats files after edits (Prettier, Black, gofmt, rustfmt) |

### Coding Rules (Path-scoped)

| Rule | Applied To |
|------|----------|
| **typescript** | All `.ts/.tsx` files |
| **react** | All React components |
| **testing** | All test files |
| **api** | All API/route files |
| **git** | All files (commit practices) |

## Design Philosophy

1. **Evidence Over Claims** — Real quality gates, not just promises
2. **Fix the Root Cause** — 5 Whys technique, backward tracing
3. **Safety by Default** — Hooks block destructive ops automatically
4. **Stack-Aware** — Auto-detect and adapt to your tech stack
5. **Real Patterns** — Production code you can use immediately

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

## Requirements

- Claude Code (CLI, Desktop, or Web)
- `jq` installed (for hooks): `brew install jq` / `apt install jq`

## License

MIT
