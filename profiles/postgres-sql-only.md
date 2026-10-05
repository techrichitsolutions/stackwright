---
profile: postgres-sql-only
role: db
check-root: posix
status: written
---

# `postgres-sql-only` (db)

- **Root files**: none beyond the common list (configuration is by `DATABASE_URL` and
  flags).
- **Source**: `src/migrations/<timestamp>_<name>.sql` (dbmate `-- migrate:up` /
  `-- migrate:down`; DDL, RLS policies, data-class comments) · `src/seed/*.sql` ·
  `src/roles/bootstrap-roles.sql` (re-runnable, per cluster) · `src/schema.sql` (dumped by
  dbmate after migrating; committed and released).
- **Tests**: pgTAP files in `tests/integration/*.sql` run with `pg_prove` against
  Testcontainers or a CI Postgres service: tenancy tests, data-class coverage.
- **Publishes**: `schema.sql` as a release asset on tag `db-v*`; no code package.
- **Container**: `docker/Dockerfile` from the dbmate image with `src/migrations` copied in
  → `{{prefix}}-migrate`.
- **Verify**: `dbmate --migrations-dir src/migrations --schema-file src/schema.sql up`
  against a throwaway Postgres, then `pg_prove tests/integration/*.sql`, then check-root.
