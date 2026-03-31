# Changelog

All notable changes to CodePilot will be documented in this file.

## [1.0.0] - 2026-03-31

### Added

#### Enterprise / SaaS Skills (13 new)
- `/saas-auth` — Multi-tenant auth with RBAC, API keys, audit logging
- `/payment` — Stripe integration (checkout, webhooks, billing portal, usage limits)
- `/money-safe` — Financial safety (idempotency, double-entry ledger, fraud detection)
- `/queue` — Background jobs (BullMQ/Celery, dead letter queues, cron scheduling)
- `/realtime` — Real-time updates (SSE, WebSocket, Pusher, optimistic updates)
- `/email` — Transactional email (Resend + React Email templates)
- `/storage` — File uploads (S3/R2 presigned URLs, image optimization)
- `/cache` — Caching strategies (Redis cache-aside, stale-while-revalidate)
- `/search` — Full-text search (PostgreSQL FTS, Meilisearch, autocomplete)
- `/admin` — Admin dashboard (role-based layout, CRUD generation)
- `/analytics` — Product analytics (event tracking, funnels, SaaS metrics)
- `/export` — Data export (CSV, PDF invoices, Excel, scheduled reports)
- `/process` — Business processes (state machines, approval flows, wizards)

#### UI & Design Skills (3 new)
- `/ui` — Generate UI components from text descriptions (v0-style, shadcn-aware)
- `/design-system` — Design tokens, theme audit, consistency enforcement
- `/screenshot-to-code` — Convert screenshots/mockups to production components

#### Automation Skills (4 new)
- `/batch` — Apply changes across multiple files in parallel
- `/loop` — Automated fix-verify cycles until all quality gates pass
- `/issue` — Full issue-to-PR pipeline (read → plan → implement → test → PR)
- `/upgrade` — Guided major version upgrades with codemods

#### Quality & Security Skills (6 new)
- `/security` — Security scanning (deps, secrets, OWASP Top 10, headers)
- `/a11y` — Accessibility audit and auto-fix (WCAG 2.1 AA)
- `/i18n` — Internationalization management (extract, sync, check)
- `/storybook` — Auto-generate Storybook stories from components
- `/db-migrate` — Safe database migration with rollback generation
- `/perf` — Bundle analysis, API latency, render performance

#### Development Workflow Skills (7 new)
- `/scaffold` — Generate project structures with stack-aware templates
- `/env` — Validate environment variables, detect leaked secrets
- `/seed` — Generate database seed data from Prisma/Drizzle schema
- `/docs` — Auto-generate API docs, component docs, architecture
- `/changelog` — Auto-generate changelogs from conventional commits
- `/monitor` — Error tracking, health checks, structured logging
- `/e2e` — End-to-end testing with Playwright

#### Core Features
- `/feature` — Plan, implement, test, review a feature end-to-end
- `/fix` — Root cause analysis with 5 Whys technique
- `/plan` — Architecture planning with trade-off analysis
- `/review` — 6-aspect parallel code review
- `/ship` — Pre-flight checks before deployment
- `/test` — Generate meaningful tests
- `/debug` — Systematic root cause analysis
- `/optimize` — Performance profiling with before/after data
- `/refactor` — Safe refactoring with evidence trail
- `/audit` — Full project health check
- `/api` — Design and implement API endpoints
- `/deploy` — Environment-aware deployment
- `/commit` — Smart conventional commit
- `/pr` — Structured PR with auto-generated description
- `/migrate` — Safe dependency upgrade with checkpoint

#### Context Engineering
- `/index` — Map codebase architecture and dependencies
- `/checkpoint` — Git checkpoints for safe experimentation
- `/common-ground` — Surface and validate assumptions
- `/mode` — 7 behavioral modes (token-efficient, brainstorm, etc.)
- `/learn` — Auto-generate custom rules from codebase patterns

#### Infrastructure
- 10 auto-activated expert skills (React, Vue, Python, Node.js, etc.)
- 6 specialized agents (planner, reviewer, debugger, tester, security, performance)
- 5 coding rules (TypeScript, React, testing, API, git)
- 4 safety hooks with 100+ protection patterns
- SSH private key protection (id_rsa, id_ed25519)
- CI/CD templates (GitHub Actions)
- One-line installer (`setup.sh`)
- Comprehensive test suite (270 checks across 10 categories)
