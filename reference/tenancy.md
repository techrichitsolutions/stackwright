# Tenancy and data classification

Profile-independent intent. Every profile that touches data (db and api roles) implements
the row for the model chosen in the interview, in its own language.

| Model | Per-request scoping | Migrations | Required tests |
|---|---|---|---|
| Shared schema + RLS | in each transaction, `set_config('app.tenant_id', <id>, true)` | every `tenant_id` table: `ENABLE` + `FORCE ROW LEVEL SECURITY`, policy `tenant_id = current_setting('app.tenant_id')::uuid`; app role not owner, no `BYPASSRLS` | tenant A can't read B; forced RLS on every `tenant_id` table |
| Schema per tenant | `set_config('search_path', 't_<slug>,public', true)` | template schema + `create-tenant` script in `tools/scripts/` | every tenant schema fully migrated |
| Database per tenant | connection resolved per tenant from a pool | migrator loops tenant databases | migrator idempotent per database |
| Single-tenant | none, no `tenant_id` | plain DDL | migrations apply cleanly |

The third argument `true` in `set_config` makes the setting local to the transaction, so a
pooled connection can never carry one tenant's id into another request.

## Data classification (optional)

When chosen: every column carries a `C1|C2|C3` comment and a test fails when one is
missing; logs never include C2/C3 values. The db profile exports the column → class map so
api log-hygiene checks can use it.
