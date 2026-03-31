---
name: upgrade
description: "Framework upgrade wizard. Guided migration for Next.js, React, TypeScript, Node.js major version upgrades."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /upgrade — Framework Upgrade Wizard

Guided major version upgrades with automated migration steps.

## Usage

```
/upgrade next                   # Upgrade Next.js
/upgrade react                  # Upgrade React
/upgrade typescript             # Upgrade TypeScript
/upgrade node                   # Upgrade Node.js target
/upgrade <package>              # Upgrade any package
/upgrade all                    # Upgrade all outdated
```

## Execution Protocol

### Phase 1: Detect Current Versions

Read package.json, lock files, .nvmrc for current state.

### Phase 2: Create Checkpoint

```bash
git add -A && git commit -m "checkpoint: before upgrade" --allow-empty
```

### Phase 3: Upgrade Guide

Generate step-by-step migration with breaking changes and codemods:

- **Next.js 14→15**: async cookies/headers/params, fetch caching changes
- **React 18→19**: forwardRef removal, use() hook, Context changes
- **Tailwind 3→4**: CSS-first config, new import syntax
- **TypeScript**: new strict options

### Phase 4: Apply Upgrade

1. Run upgrade command
2. Apply codemods
3. Fix breaking changes
4. Run type check + tests

### Phase 5: Verify

Full pipeline: tsc, eslint, tests, build.

### Phase 6: Report

Packages upgraded, breaking changes resolved, files modified, verification results.

## Rules

- ALWAYS checkpoint before upgrading
- One major upgrade at a time
- Run codemods before manual fixes
- Verify after each step
- Document all breaking changes
- Keep lock file in sync
