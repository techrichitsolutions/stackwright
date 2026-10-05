---
profile: nextjs
role: web
check-root: node
status: written
---

# `nextjs` (web)

- **Root files**: `package.json`, `pnpm-lock.yaml`, `.npmrc`, `tsconfig.json`,
  `next.config.ts` (`output: 'standalone'`), `next-env.d.ts` (generated, git-ignored but
  allow-listed), `eslint.config.mjs`, `vitest.config.ts`, `postcss.config.mjs` if Tailwind.
  `REPO_DIRS`: `public` (Next serves it only from the root).
- **Source**: `src/app/` (App Router; route groups per area, e.g. `(admin)/`) ·
  `src/proxy.ts` (Next 16+ name for middleware: auth redirects only) · `src/server/`
  (server-only code: api client with the user's token, session; first line
  `import 'server-only'`) · `src/lib/` (client-safe helpers on `{{scope}}/contracts`) ·
  `src/ui/`. Auth: OIDC with Auth.js (or the IdP's Next SDK), tokens kept server-side.
- **Boundaries**: `src/server/**` never imported from `'use client'` files; only
  `{{scope}}/contracts` crosses in; no fetch outside `src/server/` and `src/lib/`; `ui/`
  imports nothing app-specific.
- **Tests**: Vitest + Testing Library for components (`tests/unit/`); route smoke tests
  run in the infra `e2e/`.
- **Container**: Node slim, copy `.next/standalone` + `.next/static` + `public`, non-root.
- **Verify**: `pnpm install && pnpm lint && pnpm typecheck && pnpm test && pnpm check:root
  && pnpm build`.
