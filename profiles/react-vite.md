---
profile: react-vite
role: web
check-root: node
status: proven
---

# `react-vite` (web) — 3DP default

- **Root files**: `index.html`, `package.json`, `pnpm-lock.yaml`, `.npmrc`,
  `tsconfig*.json`, `vite.config.ts`, `eslint.config.js`, `vitest.config.ts`.
  `REPO_DIRS`: `public`.
- **Source**: `src/app/` (router, providers, OIDC client for the chosen IdP, query
  client) · `src/lib/` (API client on `{{scope}}/contracts`) · `src/ui/` (tokens,
  components) · one folder per chosen area. 3DP extras: Radix, Tailwind, TanStack Query.
- **Boundaries**: only `{{scope}}/contracts` crosses in; no fetch outside `lib/`; `ui/`
  imports nothing app-specific.
- **tsconfig**: as `ts-nest` but `module` `ESNext`, `moduleResolution` `Bundler`.
- **Tests**: Vitest + jsdom + Testing Library; `tests/unit/app/router.test.tsx` smoke test.
- **Container**: `docker/Dockerfile` + `docker/nginx.conf` (nginx-unprivileged, static).
- **Verify**: `pnpm install && pnpm lint && pnpm typecheck && pnpm test && pnpm check:root
  && pnpm build`.
- **3DP reference versions**: React 19, React Router 8, TanStack Query 5, Vite 8,
  Tailwind 4.
