---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# TypeScript Rules

- Enable `strict` mode in tsconfig.json. No exceptions.
- Never use `any`. Use `unknown` with type guards, or proper generics.
- Prefer `interface` for object shapes, `type` for unions and intersections.
- Use `satisfies` for type-safe object literals: `const config = {...} satisfies Config`
- Export types from the module that defines them, import from there.
- Use `as const` for literal types and discriminated unions.
- Prefer `readonly` for arrays and objects that shouldn't be mutated.
- Function return types: explicit for public APIs, inferred for internal functions.
- Use `z.infer<typeof Schema>` to derive types from Zod schemas (single source of truth).
- Avoid enums. Use `as const` objects or union types instead.
- Handle `null`/`undefined` explicitly. No non-null assertions (`!`) unless provably safe.
