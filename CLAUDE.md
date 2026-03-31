# Claudekit - Fullstack Developer Toolkit

> Production-grade skills, agents, and automation for Claude Code.
> Every tool solves a real pain point. No fluff.

## Philosophy

1. **Evidence over claims** - Never say "done" without proof (tests pass, types check, lint clean)
2. **Context is king** - Auto-detect stack, adapt behavior, minimize token waste
3. **Safety by default** - Block destructive ops, protect secrets, checkpoint before risky changes
4. **Chain, don't repeat** - Workflows orchestrate multiple skills automatically
5. **Ship fast, ship safe** - Speed without sacrificing quality

## Stack Detection

Claudekit auto-detects your project stack from config files:

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

### Development
- `/feature <description>` - Plan, implement, test, review a feature end-to-end
- `/fix <issue>` - Diagnose root cause, fix, verify, prevent regression
- `/refactor <target>` - Safe refactoring with evidence trail

### Quality
- `/review` - 6-aspect parallel code review (arch, security, perf, test, quality, DX)
- `/test <scope>` - Generate meaningful tests, not just coverage padding
- `/audit` - Full project health check (deps, security, performance, accessibility)

### Shipping
- `/plan <goal>` - Architecture planning with trade-off analysis
- `/ship` - Pre-flight checks, build, deploy pipeline
- `/deploy <target>` - Environment-aware deployment

### Utilities
- `/debug <symptom>` - Systematic root cause analysis
- `/optimize <target>` - Performance profiling and optimization
- `/api <spec>` - Design and implement API endpoints
- `/e2e <scope>` - End-to-end testing with Playwright

### Context Engineering
- `/index` - Map codebase architecture, dependencies, patterns
- `/checkpoint save|restore|list` - Git checkpoint for safe experimentation
- `/common-ground` - Surface and validate Claude's assumptions about your project
- `/mode <name>` - Switch behavioral mode (token-efficient, brainstorm, deep-research, implementation, review, orchestration)

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
