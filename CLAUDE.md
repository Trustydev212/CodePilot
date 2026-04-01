# CodePilot - Fullstack Developer Toolkit

> Production-grade skills, agents, and automation for Claude Code.
> Every tool solves a real pain point. No fluff.

## How It Works

**You don't need to memorize 59+ commands.** Just tell Claude what you want in natural language. CodePilot auto-selects the right skill based on your request.

### Auto-Skill Selection

When the user describes a task, Claude MUST automatically read and follow the most relevant skill from `.claude/skills/`. Match by intent:

| User says... | Claude reads & follows |
|---|---|
| "build feature X" / "implement X" / "add X" | `.claude/skills/workflow/cook/SKILL.md` |
| "fix bug X" / "this is broken" / "error when..." | `.claude/skills/workflow/fix/SKILL.md` |
| "review this code" / "is this code good?" | `.claude/skills/workflow/review/SKILL.md` |
| "audit" / "check quality" / "health check" | `.claude/skills/quality/audit/SKILL.md` |
| "refactor X" / "clean up X" / "this is messy" | `.claude/skills/core/refactor/SKILL.md` |
| "add tests" / "write tests for X" | `.claude/skills/quality/test/SKILL.md` |
| "deploy" / "ship" / "go to production" | `.claude/skills/workflow/ship/SKILL.md` |
| "security" / "is this secure?" / "vulnerabilities" | `.claude/skills/workflow/security/SKILL.md` |
| "setup auth" / "multi-tenant" / "RBAC" | `.claude/skills/workflow/saas-auth/SKILL.md` |
| "payment" / "stripe" / "billing" / "subscription" | `.claude/skills/workflow/payment/SKILL.md` |
| "map codebase" / "understand this project" | `.claude/skills/core/index/SKILL.md` |
| "optimize" / "slow" / "performance" | `.claude/skills/quality/optimize/SKILL.md` |
| "plan X" / "how should we architect X" | `.claude/skills/workflow/plan/SKILL.md` |
| "commit" / "save changes" | `.claude/skills/workflow/commit/SKILL.md` |
| "create PR" / "pull request" | `.claude/skills/workflow/pr/SKILL.md` |
| "generate docs" / "document this" | `.claude/skills/workflow/docs/SKILL.md` |
| "background jobs" / "queue" / "async tasks" | `.claude/skills/workflow/queue/SKILL.md` |
| "realtime" / "websocket" / "live updates" | `.claude/skills/workflow/realtime/SKILL.md` |
| "email" / "send notification" | `.claude/skills/workflow/email/SKILL.md` |
| "upload" / "file storage" / "S3" / "images" | `.claude/skills/workflow/storage/SKILL.md` |
| "cache" / "redis" / "slow queries" | `.claude/skills/workflow/cache/SKILL.md` |
| "search" / "full-text" / "autocomplete" | `.claude/skills/workflow/search/SKILL.md` |
| "admin panel" / "dashboard" / "CRUD" | `.claude/skills/workflow/admin/SKILL.md` |
| "analytics" / "tracking" / "metrics" | `.claude/skills/workflow/analytics/SKILL.md` |
| "export" / "PDF" / "CSV" / "invoice" | `.claude/skills/workflow/export/SKILL.md` |
| "state machine" / "approval flow" / "workflow" | `.claude/skills/workflow/process/SKILL.md` |
| "money" / "financial" / "idempotency" / "ledger" | `.claude/skills/workflow/money-safe/SKILL.md` |
| "accessibility" / "a11y" / "WCAG" | `.claude/skills/workflow/a11y/SKILL.md` |
| "i18n" / "translation" / "multilingual" | `.claude/skills/workflow/i18n/SKILL.md` |
| "database migration" / "schema change" | `.claude/skills/workflow/db-migrate/SKILL.md` |
| "UI component" / "generate component" | `.claude/skills/workflow/ui/SKILL.md` |
| "design system" / "design tokens" / "theme" | `.claude/skills/workflow/design-system/SKILL.md` |
| "emergency fix" / "hotfix" / "production bug" / "urgent" | `.claude/skills/workflow/hotfix/SKILL.md` |
| "onboard" / "new developer" / "getting started guide" | `.claude/skills/workflow/onboard/SKILL.md` |
| "clean up" / "dead code" / "unused imports" / "remove junk" | `.claude/skills/workflow/clean/SKILL.md` |
| "explain this" / "how does this work" / "what does this do" | `.claude/skills/workflow/explain/SKILL.md` |
| "health check" / "project health" / "project score" / "how healthy" | `.claude/skills/workflow/health/SKILL.md` |
| "watch issues" / "auto PR" / "monitor repo" / "daemon" | `.claude/skills/workflow/watch/SKILL.md` |

**If the user just says "cook" or gives a vague task**, use `/cook` — it handles everything autonomously.

**If no skill matches**, just help the user directly without a skill. Not everything needs a workflow.

## Philosophy

1. **Evidence over claims** - Never say "done" without proof (tests pass, types check, lint clean)
2. **Context is king** - Auto-detect stack, adapt behavior, minimize token waste
3. **Safety by default** - Block destructive ops, protect secrets, checkpoint before risky changes
4. **Chain, don't repeat** - Workflows orchestrate multiple skills automatically
5. **Ship fast, ship safe** - Speed without sacrificing quality

## Stack Detection

CodePilot auto-detects your project stack from config files:

| File | Stack Detected |
|------|---------------|
| `package.json` | Node.js ecosystem |
| `tsconfig.json` | TypeScript |
| `next.config.*` | Next.js |
| `nuxt.config.*` | Nuxt/Vue |
| `vite.config.*` | Vite + React/Vue/Svelte |
| `requirements.txt` / `pyproject.toml` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `docker-compose.*` | Docker |
| `prisma/schema.prisma` | Prisma ORM |
| `drizzle.config.*` | Drizzle ORM |
| `.env*` | Environment config |

## Available Workflows (Slash Commands)

### Auto-pilot
- `/cook [task]` - One command to ship. Reads CLAUDE.md → brainstorm → plan → code → test → commit. You go get coffee.

### Development
- `/feature <description>` - Plan, implement, test, review a feature end-to-end
- `/fix <issue>` - Diagnose root cause, fix, verify, prevent regression
- `/hotfix <issue>` - Emergency production fix (stash → fix → verify → tag → return)
- `/refactor <target>` - Safe refactoring with evidence trail
- `/clean [target]` - Remove dead code, unused imports, debug statements

### Quality
- `/review` - 6-aspect parallel code review (arch, security, perf, test, quality, DX)
- `/test <scope>` - Generate meaningful tests, not just coverage padding
- `/audit` - Full project health check (deps, security, performance, accessibility)
- `/health` - Project health score dashboard (deps, types, tests, build, security, git)

### Shipping
- `/plan <goal>` - Architecture planning with trade-off analysis
- `/ship` - Pre-flight checks, build, deploy pipeline
- `/deploy <target>` - Environment-aware deployment

### Git Workflow
- `/commit` - Smart conventional commit from staged changes
- `/pr [details]` - Create structured PR with auto-generated description
- `/migrate [target]` - Safe dependency upgrade with checkpoint and rollback

### Project Setup
- `/scaffold <target>` - Generate project structures and feature modules with stack-aware templates
- `/env` - Validate environment variables, generate .env.example, detect leaked secrets
- `/seed` - Generate database seed data from Prisma/Drizzle schema
- `/docs [target]` - Auto-generate API docs, component docs, architecture overviews
- `/onboard` - Auto-generate onboarding guide for new developers

### Automation
- `/batch <operation>` - Apply changes across multiple files in parallel (rename, replace, transform)
- `/loop <type>` - Automated fix-verify cycles until all quality gates pass
- `/issue <number>` - Full issue-to-PR pipeline (read → plan → implement → test → PR)
- `/watch [options]` - Auto-monitor GitHub issues → analyze → create PRs (AI dev team that never sleeps)
- `/upgrade <framework>` - Guided major version upgrades with codemods and migration

### Enterprise / SaaS
- `/saas-auth` - Multi-tenant auth with RBAC, API keys, audit logging
- `/payment` - Stripe integration (checkout, webhooks, billing portal, usage limits)
- `/money-safe` - Financial safety (idempotency, double-entry ledger, fraud detection, reconciliation)
- `/queue` - Background jobs (BullMQ/Celery, dead letter queues, cron scheduling)
- `/realtime` - Real-time updates (SSE, WebSocket, Pusher, optimistic updates)
- `/email` - Transactional email (Resend + React Email templates)
- `/storage` - File uploads (S3/R2 presigned URLs, image optimization, responsive variants)
- `/cache` - Caching strategies (Redis cache-aside, stale-while-revalidate, invalidation)
- `/search` - Full-text search (PostgreSQL FTS, Meilisearch, autocomplete, faceted filters)
- `/admin` - Admin dashboard (role-based layout, CRUD generation, stats)
- `/analytics` - Product analytics (event tracking, funnels, SaaS metrics)
- `/export` - Data export (CSV, PDF invoices, Excel, scheduled reports)
- `/process` - Business processes (state machines, approval flows, multi-step wizards)

### Understanding
- `/explain <target>` - Deep code explanation with Mermaid diagrams (function, feature, architecture)

### Utilities
- `/debug <symptom>` - Systematic root cause analysis
- `/optimize <target>` - Performance profiling and optimization
- `/perf <target>` - Bundle analysis, API latency, render performance, regression detection
- `/security` - Security scanning (deps, secrets, OWASP Top 10, headers)
- `/a11y` - Accessibility audit and auto-fix (WCAG 2.1 AA)
- `/i18n <action>` - Internationalization management (extract, sync, check translations)
- `/storybook <component>` - Auto-generate Storybook stories from components
- `/ui <description>` - Generate UI components from text (v0-style, shadcn-aware)
- `/design-system` - Create, audit, manage design tokens and theme consistency
- `/screenshot-to-code <image>` - Convert screenshots/mockups to React/Vue components
- `/db-migrate` - Safe database migration with rollback generation
- `/api <spec>` - Design and implement API endpoints
- `/e2e <scope>` - End-to-end testing with Playwright
- `/changelog` - Auto-generate changelogs from conventional commits
- `/monitor` - Set up error tracking, health checks, structured logging

### Context Engineering
- `/index` - Map codebase architecture, dependencies, patterns
- `/checkpoint save|restore|list` - Git checkpoint for safe experimentation
- `/common-ground` - Surface and validate Claude's assumptions about your project
- `/mode <name>` - Switch behavioral mode (token-efficient, brainstorm, deep-research, implementation, review, orchestration)
- `/learn` - Analyze codebase patterns and auto-generate custom Claude rules for your project

## Quality Gates (Enforced by Hooks)

Every workflow enforces these gates before claiming completion:

1. **Type Safety** - `tsc --noEmit` must pass (TypeScript projects)
2. **Lint Clean** - ESLint/Prettier with zero errors
3. **Tests Pass** - Existing tests must not break
4. **No Secrets** - .env, keys, tokens never committed
5. **Build Success** - Production build must succeed

## Rules

- Write code that humans will maintain. Clever is the enemy of clear.
- Prefer composition over inheritance, functions over classes.
- Error messages should help the developer fix the problem.
- Tests should test behavior, not implementation details.
- Every API endpoint needs input validation and error handling.
- Database queries need proper indexing consideration.
- Frontend state should be as close to the component that uses it as possible.
- Never store secrets in code. Always use environment variables.
- Commit messages explain WHY, not WHAT.

## Project Context

@.claude/rules/
