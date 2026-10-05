---
profile: dotnet
role: api
check-root: posix
status: written
---

# `dotnet` (api)

- **Root files**: `{{Name}}.slnx` (.NET 10+ default; `.sln` if an older SDK is pinned),
  `global.json` (SDK pin), `Directory.Build.props` (nullable, warnings as errors, analyzers),
  `Directory.Packages.props` (central package versions), `nuget.config`. `REPO_DIRS`:
  `.config` (`dotnet-tools.json`), `packages` (generated TS contracts).
- **Source**: one project per layer, so boundaries are compile-time project references:
  `src/{{Name}}.Api/` (ASP.NET Core minimal APIs; `/healthz`, `/readyz`) ·
  `src/{{Name}}.Worker/` (if jobs) · `src/{{Name}}.Core/` (ports as interfaces, domain; no
  ASP.NET, no EF, no vendor packages) · `src/{{Name}}.Modules.<Name>/` (commands, queries,
  events, repository, `<Name>Module.cs` with `AddXxx()`/`MapXxx()`) ·
  `src/{{Name}}.Adapters.<Vendor>/`.
- **Boundaries**: project references allow only Api/Worker → Modules → Core and
  Adapters → Core; plus an architecture test (NetArchTest or ArchUnitNET) in
  `tests/unit/{{Name}}.Architecture.Tests/` for rules references can't express (modules
  don't reference each other's internals).
- **Tests**: xUnit. `tests/unit/{{Name}}.<Project>.Tests/` mirror `src/`;
  `tests/integration/{{Name}}.Api.IntegrationTests/` with `WebApplicationFactory` +
  Testcontainers (PostgreSQL).
- **Data**: EF Core + Npgsql. Shared-schema RLS: a `DbConnectionInterceptor` (or
  transaction hook) runs `set_config('app.tenant_id', …, true)` per transaction. Tables come
  from `orm-migrations` / `efcore` or are mapped locally with `postgres-sql-only`.
- **Contracts**: built-in OpenAPI document (`Microsoft.AspNetCore.OpenApi`), exported in CI;
  TS package generated into `packages/contracts/`.
- **Container**: `mcr.microsoft.com/dotnet/aspnet` (chiseled/non-root variant) or
  `dotnet publish /t:PublishContainer`; one image per entry project.
- **Verify**: `dotnet restore && dotnet build -warnaserror && dotnet format
  --verify-no-changes && dotnet test && sh tools/scripts/check-root.sh`; boundary proof:
  reference `Microsoft.AspNetCore` from Core, build or architecture test must fail.
