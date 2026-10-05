---
profile: compose-northflank
role: infra
check-root: posix
status: proven
---

# `compose-northflank` (infra) — 3DP default

- **Source**: `src/compose/compose.yaml` (postgres; redis if realtime/jobs; minio if
  storage; the IdP, with realm import for Keycloak; mailpit if email; migrate job; app
  images under profile `apps`; assumes sibling layout `../{{prefix}}-<role>`) ·
  `src/environments/<env>.yaml` (pinned image digests) · `src/iac/northflank/` (ADR-0003) ·
  `src/helm/` only if asked.
- **e2e**: `e2e/` (root, `REPO_DIRS`) with Playwright: "web loads and api `/healthz` is
  green". Mobile journeys stay in the mobile repo.
- **3DP reference versions**: Playwright 1.63.
- **Verify**: `docker compose -f src/compose/compose.yaml config`; if Docker runs,
  `up -d`, migrate, hit `/healthz`.
