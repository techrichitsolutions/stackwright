---
profile: ts-fastify
role: api
check-root: node
status: written
---

# `ts-fastify` (api)

- **Root files**: as `ts-nest` (pnpm workspace for `packages/contracts`). `REPO_DIRS`:
  `packages`.
- **Source**: same folders as `ts-nest` (`src/apps`, `src/core`, `src/modules`,
  `src/adapters`); apps build a Fastify instance and register each module as a plugin
  (`fastify-plugin` only where a decorator must be shared); routes typed with a Zod type
  provider (`fastify-type-provider-zod` or current equivalent) using `{{scope}}/contracts`.
- **Module layout**: `commands/`, `queries/`, `events.ts`, `repository.ts`, `index.ts`,
  `routes.ts` (plugin), `deps.ts` (explicit dependency wiring; no DI container).
- **Boundaries**: `ts-nest` rules with `fastify` in place of `@nestjs/*`.
- **Tests**: Vitest using `app.inject()`; `tests/unit/modules/kernel/health.test.ts`,
  `tests/integration/apps/api/health.test.ts`.
- **Container / CI / Data**: as `ts-nest`. OpenAPI via `@fastify/swagger` from the Zod
  schemas.
- **Verify**: as `ts-nest`; boundary proof: add `import 'fastify'` in `src/core/`, lint must
  fail, then remove it.
