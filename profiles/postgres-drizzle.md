---
profile: postgres-drizzle
role: db
check-root: node
status: proven
---

# `postgres-drizzle` (db) — 3DP default

- **Root files**: as `ts-nest` minus the workspace file; `drizzle.config.ts`.
- **Source**: `src/schema/<context>.ts` (one per module that owns tables, tenancy first) ·
  `src/migrations/` (generated DDL + hand-written RLS, constraints, data-class comments) ·
  `src/seed/` (if chosen) · `src/with-tenant.ts` (per tenancy model) · `src/data-classes.ts`
  (if chosen) · `src/migrator.ts` + `src/migrate-cli.ts` (advisory lock, checksums) ·
  `src/index.ts` = public surface of `{{scope}}/db` (no migrations).
- **Tests**: tenancy tests from the tenancy table, against Testcontainers Postgres.
- **Container**: `docker/Dockerfile` → `{{prefix}}-migrate` image, run as a pre-deploy job.
- **CI extras**: RLS integration job with a Postgres service; publish `{{scope}}/db` on tag
  `db-v*`.
- **Verify**: `pnpm install && pnpm lint && pnpm typecheck && pnpm test && pnpm check:root
  && pnpm build`; the integration tests run migrations against Testcontainers Postgres and
  must prove tenant isolation and forced RLS (skip with a note if Docker isn't available).
- **Pairs with**: TS api profiles only (see the compatibility rules in `SKILL.md`).
- **3DP reference versions**: PostgreSQL 16+, Drizzle 0.45, postgres.js 3.4.
