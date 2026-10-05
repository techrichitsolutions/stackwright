---
profile: orm-migrations
role: db
check-root: per-variant
status: written
---

# `orm-migrations` (db)

Same shape as `postgres-drizzle`, in the api's language: the db repo owns the table model
and migrations, publishes the model as a package, and ships the `{{prefix}}-migrate` image.
Hand-written RLS and data-class comments go in migrations as raw SQL.

| | `alembic` (pairs with `python-fastapi`) | `efcore` (pairs with `dotnet`) |
|---|---|---|
| Root files | `pyproject.toml`, `uv.lock`, `.python-version`, `alembic.ini` | `{{Name}}.Db.slnx`, `global.json`, `Directory.Build.props`, `Directory.Packages.props`, `nuget.config`; `REPO_DIRS` `.config` |
| Source | `src/{{pkg}}_db/tables/` (SQLAlchemy Core per context), `with_tenant.py`, `data_classes.py`; `src/{{pkg}}_db/migrations/` (Alembic `env.py`, `versions/`) | `src/{{Name}}.Db/` (`DbContext`, entity configs per context, tenant interceptor, data classes); `src/{{Name}}.Db/Migrations/`; `src/{{Name}}.Migrator/` (applies migrations with a lock) |
| Publishes | wheel `{{pkg}}-db` (tables only; migrations not imported by the api) | NuGet `{{Name}}.Db` |
| Tests | pytest + Testcontainers: tenancy tests, upgrade/downgrade round trip | xUnit + Testcontainers: tenancy tests, migrations apply cleanly |
| Check-root | Python | POSIX |
| Verify | `uv sync && uv run alembic upgrade head` (throwaway DB) `&& uv run pytest` | `dotnet build -warnaserror && dotnet test` |
