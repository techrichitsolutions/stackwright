# Profiles

A profile is everything stack-specific for one **role** (`api`, `web`, `mobile`, `db`,
`infra`, or `any`). The core [`SKILL.md`](../SKILL.md) never names a framework; it reads the
profile files the user picks.

## File format

One Markdown file per profile, named `<profile>.md`, starting with front matter:

```yaml
---
profile: ts-nest          # must match the file name
role: api                 # api | web | mobile | db | infra | any
check-root: node          # node | python | posix | per-variant
status: written           # proven | written
---
```

Then a `# \`<profile>\` (<role>)` heading and the contract below as bold-labelled bullets.
A profile may say "as `<other-profile>`" for an item it shares, but only within the same
language.

## The contract

| Item | What the profile defines |
|---|---|
| **Root files** | Manifests and tool configs that must sit at the repo root (added to the check-root allow-list), plus `REPO_DIRS` (extra root folders such as `packages`, `public`, `e2e`) |
| **Source** | Folders under `src/` and what goes in each |
| **Boundaries** | Import rules and the tool that enforces them in CI, plus a "boundary proof" (a forbidden import that must fail) |
| **Tests** | Runner, `tests/` layout, the first test it writes |
| **Health path** | The smallest thing that proves the skeleton runs (often `/healthz`) |
| **Container** | `docker/Dockerfile`, or "none" with the reason |
| **CI** | Extra steps beyond the common order, and the publish job |
| **Data** | How it implements the chosen tenancy model ([`reference/tenancy.md`](../reference/tenancy.md)); db and api roles only |
| **Contracts** | What it publishes or consumes across roles |
| **Verify** | Exact commands Phase 4 runs |

`tools/lint_profiles.py` checks the front matter, the file name, and that every profile
appears in the `SKILL.md` catalogue (and vice versa).

## Adding a profile

1. Copy the closest existing profile, rename it, set `status: written`.
2. Fill every contract item; use the current official docs for names and commands.
3. Add a row to the catalogue and, if it pairs with a db profile, to the compatibility
   table in `SKILL.md`.
4. Run `sh tools/test.sh`.
5. Use it on a real project. When Phase 4 passes there, change `status` to `proven` and
   note the project and versions in `CHANGELOG.md`.
