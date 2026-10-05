---
profile: ts-nest
role: api
check-root: node
status: proven
---

# `ts-nest` (api) — 3DP default

- **Root files**: `package.json` (`"type": "module"`; scripts `build` = `tsc -p
  tsconfig.build.json`, `typecheck` = `tsc --noEmit`, `lint` = `eslint .`, `test` =
  `vitest run`, `check:root`, `check:docs-version`; `engines.node` = current LTS major;
  `packageManager` = current pnpm; Prettier config inside), `pnpm-lock.yaml`,
  `pnpm-workspace.yaml` (`packages: ['packages/*']`), `.npmrc`, `tsconfig*.json`,
  `eslint.config.js`, `vitest.config.ts`. `REPO_DIRS`: `packages`.
- **Source**: one private package `{{scope}}-api/server`.
  `src/apps/{api,gateway?,worker?}/main.ts` (gateway if realtime, worker if jobs) ·
  `src/core/ports/` (Clock, IdGenerator, ReadinessCheck always; RealtimePublisher,
  JobQueue, ObjectStore, Mailer, AiGateway, IdentityVerifier as chosen) ·
  `src/core/domain/` (when the first rule exists) · `src/modules/kernel/` (`/healthz`,
  `/readyz`, error filter, config, shutdown) · `src/modules/<name>/` · `src/adapters/<vendor>/`
  · `packages/contracts/` = `{{scope}}/contracts` (Zod schemas, error codes, keys), linked
  with `workspace:*`, built first.
- **Module layout**: `commands/` (one file per command: schema, `authorize()`, `handle()`),
  `queries/`, `events.ts` (past tense), `repository.ts` (data access, tenant-scoped),
  `index.ts` (only public entry), `<name>.module.ts`.
- **Boundaries** (`eslint.config.js`, `no-restricted-imports` per glob or
  `eslint-plugin-boundaries`): `src/core/**` and `packages/contracts/**` import no NestJS,
  no db package, no vendor SDK; modules import core, db, contracts and other modules'
  `index.ts` only, never `src/apps`; vendor SDKs only in `src/adapters/**`; no relative
  path into `packages/`, no deep contracts imports.
- **Tests**: Vitest. `tests/unit/modules/kernel/health.test.ts`,
  `tests/integration/apps/api/health.test.ts`.
- **tsconfig**: `strict`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`,
  `NodeNext`, ES2023.
- **Container**: one `docker/Dockerfile`, `ARG APP=api|gateway|worker`, slim/distroless
  Node, non-root.
- **Data**: uses `{{scope}}/db` tables and `withTenant` (from `postgres-drizzle`).
- **Verify**: `pnpm install && pnpm lint && pnpm typecheck && pnpm test && pnpm check:root
  && pnpm build`; boundary proof: add `import '@nestjs/common'` in `src/core/`, lint must
  fail, then remove it.
- **CI extras**: on tag `contracts-v*`, publish `{{scope}}/contracts` and attach
  `openapi.json` generated from the Zod schemas (Zod 4 JSON Schema export or a zod-openapi
  helper) for non-TS consumers such as `swift-ios`.
- **3DP reference versions (2026-10-05)**: Node 22 LTS, pnpm 12, TypeScript 6.0 (held for
  typescript-eslint), NestJS 12, Zod 4, Socket.IO 4.8, ioredis 6, Vitest 5.
