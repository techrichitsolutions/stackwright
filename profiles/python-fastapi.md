---
profile: python-fastapi
role: api
check-root: python
status: written
---

# `python-fastapi` (api)

- **Root files**: `pyproject.toml` (project, deps, `[tool.ruff]`, `[tool.mypy]` strict,
  `[tool.pytest.ini_options]`, `[tool.importlinter]`), `uv.lock`, `.python-version`.
- **Source**: `src/{{pkg}}_api/` with `apps/api/main.py` (FastAPI app factory),
  `apps/worker/main.py` (if jobs; arq or Celery, ask) · `core/ports/` (`typing.Protocol`) ·
  `core/domain/` · `modules/kernel/` (`/healthz`, `/readyz`, error handlers, settings via
  pydantic-settings) · `modules/<name>/` (`commands/`, `queries/`, `events.py`,
  `repository.py`, `__init__.py` as the only public entry, `router.py`) · `adapters/<vendor>/`.
- **Boundaries**: import-linter contracts in CI: layers `apps > modules > core`;
  `core` forbidden from importing `fastapi`, `sqlalchemy`, vendor SDKs; vendor SDKs only in
  `adapters`; modules independent except through their `__init__`.
- **Tests**: pytest + httpx `AsyncClient`. `tests/unit/modules/kernel/test_health.py`,
  `tests/integration/apps/api/test_health.py`; Testcontainers for Postgres.
- **Data**: SQLAlchemy 2 (async) Core tables in `modules/<name>/tables.py`;
  `with_tenant(session, tenant_id)` runs the tenancy statement per transaction. With a
  separate db repo, migrations stay there (SQL) and CI runs a schema-drift test; in a
  monorepo or without a db role, Alembic lives in `src/{{pkg}}_api/migrations/`.
- **Contracts**: export `openapi.json` in CI (`tools/codegen/export_openapi.py`); publish
  `{{scope}}/contracts` as a TS package generated from it (openapi-typescript + a Zod
  generator) from `packages/contracts/` (`REPO_DIRS`: `packages`, with its own
  `package.json`; Node only needed for that publish job).
- **Container**: `python:<ver>-slim` + uv, non-root, `uvicorn {{pkg}}_api.apps.api.main:app`.
- **Verify**: `uv sync && uv run ruff check && uv run ruff format --check && uv run mypy src
  && uv run lint-imports && uv run pytest && python tools/scripts/check_root.py`; boundary
  proof: add `import fastapi` in `core/`, `lint-imports` must fail.
