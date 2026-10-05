---
name: stackwright
description: Interactive, stack-neutral project scaffolder. Asks for name, mode, topology, a stack profile per role, tenancy and git/CI, then builds or extends the repo layout.
---

# Stackwright

Scaffolds a product's repositories with one set of layout rules and pluggable **stack
profiles**. The rules come from the 3D Prioritization (3DP) decisions: ADR-0010 (repos per
team, code crosses repo lines only as versioned artifacts) and ADR-0011 (root allow-list;
`src/ docs/ tools/ tests/ docker/ .github/`; tests outside `src/`; decisions in the docs
repo). Those rules hold for every stack. Everything that depends on a language or
framework lives in a profile under [`profiles/`](profiles/).

Use it when the user asks to "boilerplate / scaffold / bootstrap a project", "create the
repos", "add a module", "add a repo", "add a mobile app", or "set up the folder structure".

## Files in this skill

| Path | Read when |
|---|---|
| [`profiles/<name>.md`](profiles/) | Only for the profiles chosen in the interview (Phase 2 onwards) |
| [`profiles/README.md`](profiles/README.md) | Drafting a new profile |
| [`reference/tenancy.md`](reference/tenancy.md) | A db or api role is chosen |
| [`reference/docs-repo.md`](reference/docs-repo.md) | A docs role is chosen, or in Add mode |
| [`templates/`](templates/) | Phase 3: `AGENTS.md`, `adr-scaffold.md`, `scaffold.example.json`, `check-root/*` |

Don't load every profile up front; read the ones the user picks.

## Ground rules

1. **Interview first, write second.** Nothing is written before the plan (Phase 2) is
   confirmed. Use `AskUserQuestion` (max 4 questions per call, 2–4 options each,
   recommended option first, labelled "(Recommended)"; the user can always type "Other").
2. **Never overwrite.** If a target file exists, show a short diff and ask: keep, replace,
   or write `<file>.new`. Re-running the skill must be safe.
3. **Folders are created when they have content.** No empty placeholders, no `.gitkeep`.
   `docs/`, `tools/`, `tests/` each get a short README listing what they hold.
4. **No tests in `src/`.** Tests go in `tests/unit/<same path as source>`,
   `tests/integration/`, `tests/support/`. Cross-repo journeys live only in the infra repo's
   `e2e/`.
5. **Decisions go to the docs repo.** Every answer that differs from the defaults becomes
   an ADR; code repos link to ADRs, never restate them.
6. **Profiles own all stack detail.** This file never names a framework's internals. If a
   choice needs a stack detail that the chosen profile doesn't define, ask; don't borrow
   from another profile.
7. **Pin current versions at scaffold time** with the profile's lookup command
   (`npm view`, PyPI, `dotnet list package --outdated`, `npx expo --version` …). Reference
   versions in a profile are hints, not pins. If a peer range blocks the latest, pin the
   newest compatible version and say why in the scaffold ADR.
8. **Where to write.** If a shell on the user's computer is available (Cowork
   `device_bash` with a connected folder), write there directly under
   `$HOME/mnt/<folder>`. Otherwise write to the local filesystem. Windows paths (`C:\...`)
   are on the user's machine; never search the container for them.

## Concepts

- **Role**: what a repo (or monorepo area) is for: `docs`, `api`, `web`, `mobile`, `db`,
  `infra`. A project picks the roles it needs.
- **Topology**: how roles map to repos.
  - **Polyrepo** (3DP default): one repo per role, siblings under `<parent>/<prefix>/`,
    named `<prefix>-<role>` (3DP keeps `app` as the web repo name; ask).
  - **Monorepo**: one repo `<prefix>`; each role becomes `src/<role>/`, shared published
    packages go in `packages/`, decision docs in `docs/specs/`, cross-role journeys in
    `e2e/`. Same root allow-list.
  - **Custom**: user lists repos and the roles each one holds.
- **Profile**: a named bundle for one role, written against the contract in
  [`profiles/README.md`](profiles/README.md): root files, source layout, boundaries, tests,
  health path, container, CI, data and tenancy, contracts, verify, check-root.

## Profile catalogue

| Role | Profile | Check-root | Status | Notes |
|---|---|---|---|---|
| api | [`ts-nest`](profiles/ts-nest.md) | Node | proven | 3DP default |
| api | [`ts-fastify`](profiles/ts-fastify.md) | Node | written | Lighter TS api; same contracts as `ts-nest` |
| api | [`python-fastapi`](profiles/python-fastapi.md) | Python | written | |
| api | [`dotnet`](profiles/dotnet.md) | POSIX | written | ASP.NET Core |
| web | [`react-vite`](profiles/react-vite.md) | Node | proven | 3DP default; static SPA |
| web | [`nextjs`](profiles/nextjs.md) | Node | written | Server-rendered; needs a Node runtime |
| mobile | [`expo-react-native`](profiles/expo-react-native.md) | Node | written | iOS + Android from one codebase |
| mobile | [`swift-ios`](profiles/swift-ios.md) | POSIX | written | Native iOS; CI needs macOS |
| db | [`postgres-drizzle`](profiles/postgres-drizzle.md) | Node | proven | 3DP default; TS api only |
| db | [`postgres-sql-only`](profiles/postgres-sql-only.md) | POSIX | written | Plain SQL (dbmate); any api language |
| db | [`orm-migrations`](profiles/orm-migrations.md) | per variant | written | `alembic` (Python) or `efcore` (.NET) |
| infra | [`compose-northflank`](profiles/compose-northflank.md) | POSIX | proven | 3DP default |
| infra | [`compose-terraform`](profiles/compose-terraform.md) | POSIX | written | Variants `aws`, `azure`, `gcp` |
| any | [`bring-your-own`](profiles/bring-your-own.md) | POSIX | written | Layout, docs and checks only |

**proven** = built and verified in a real project. **written** = follows the contract but
hasn't been through a real scaffold yet: say so in Phase 2, and after Phase 4 passes,
record it in the project's docs repo (`specs/architecture/profiles/<name>.md`) and suggest
the user changes its status here in a pull request.

**A stack that isn't listed?** Offer `bring-your-own` for that role, or draft a new
profile following [`profiles/README.md`](profiles/README.md), show it in Phase 2 marked
**unverified**, and offer to add it to this repo once it builds.

## Compatibility rules

Check in Phase 2; explain each conflict in one line.

| db profile | Pairs with | How the api gets tables |
|---|---|---|
| `postgres-drizzle` | `ts-nest`, `ts-fastify` | imports `{{scope}}/db` |
| `orm-migrations` / `alembic` | `python-fastapi` | imports the `{{pkg}}-db` wheel |
| `orm-migrations` / `efcore` | `dotnet` | references the `{{Name}}.Db` NuGet package |
| `postgres-sql-only` | any api | declares its own table mappings; CI runs a schema-drift test against the released `schema.sql` |

Any other pairing: suggest the matching row, or fall back to `postgres-sql-only`.

- **Contracts.** Every api publishes `openapi.json` on release. A TS api also publishes Zod
  contracts as `{{scope}}/contracts`; a non-TS api publishes a TS package under the same
  name generated from `openapi.json`. TS consumers (`react-vite`, `nextjs`,
  `expo-react-native`) use the package; `swift-ios` generates its client from
  `openapi.json`. Record the strategy in the scaffold ADR.
- **`nextjs`** runs a Node server: infra must run its container (not static hosting), and
  calls to the api from server components forward the user's token server-side.
- **`swift-ios`** needs a macOS CI runner and Xcode; Phase 4 build steps run only on macOS.
- **Realtime + `compose-terraform` / `aws`**: use ECS Fargate behind an ALB (WebSockets).
- `mobile` without an `api` role: ask for the backend the app talks to.

## Phase 0 — Detect context

- Look for an existing parent folder with `<prefix>-*` siblings, a monorepo with
  `src/<role>/`, or a `.scaffold.json` (docs repo root, or `docs/` in a monorepo). If
  found, propose **Add** mode and load previous answers as defaults.
- Check which tools exist (`git`, `gh`, `docker`, plus each profile's toolchain: `node`/
  `pnpm`, `python`/`uv`, `dotnet`, `xcodebuild`/`xcodegen`, `dbmate`, `tofu`/`terraform`,
  `tflint`). Missing tools only limit Phase 4/5; say which steps will be skipped.

## Phase 1 — Interview

Ask in rounds; skip what is already known (user's message, `.scaffold.json`, project
docs). After each round echo the answers in one line.

**Round 1 — Mode and identity**

| Question | Options (default first) |
|---|---|
| Mode | **Runnable skeleton** (configs + a green health path per role) · **Structure + docs only** · **Add to existing** |
| Project name & prefix | `3D Prioritization` / `3dp` · Other (prefix: lowercase, hyphenated, ≤ 8 chars) |
| Package scope / namespace | `@<prefix>` (npm), `<prefix>_` (Python), `<Name>` (.NET) · Other |
| Parent folder | `<connected folder>/<prefix>` · Other |

If mode = **Add to existing**, go to *Add mode*.

**Round 2 — Topology and roles**

| Question | Options |
|---|---|
| Topology | **Polyrepo** (one repo per role) · Monorepo · Custom |
| Roles (multi-select) | `docs` · `api` · `web` · `db` · `infra` · `mobile` (3DP: all but mobile) |
| Profile set | **3DP defaults** (`ts-nest`, `react-vite`, `postgres-drizzle`, `compose-northflank`) · Pick per role |

If "Pick per role": one question per chosen role listing its profiles from the catalogue
(max 4 options; put the rest under "Other"), plus `bring-your-own`. For `orm-migrations`
and `compose-terraform`, follow up with the variant.

**Round 3 — Modules and areas**

| Question | Options |
|---|---|
| Bounded-context modules (api) | **Kernel only, add later** · List them (kebab-case) · 3DP set (tenancy, settings, audit, boards, cards, themes, voting, connectivity, current-state, handoff, ai, guard, comments, publishing, exports, notifications) |
| Scaffold now | **Kernel + first 1–3 named** · All listed, each with a stub command and query |
| Web / mobile areas | **Minimal** (`app, ui, lib`) · 3DP set (`app, steps, participant, admin, render, realtime, ui, lib`) · Other |

**Round 4 — Tenancy and data** (see [`reference/tenancy.md`](reference/tenancy.md))

| Question | Options |
|---|---|
| Tenancy | **Multi-tenant, shared schema + row-level security** · Single-tenant · Schema per tenant · Database per tenant |
| Data classification | **None** · C1/C2/C3 column labels + log-hygiene check (3DP) |
| Seed data | **Demo tenant + users** · None |

**Round 5 — Runtime and hosting**

| Question | Options |
|---|---|
| Identity | **OIDC provider: Keycloak** · Microsoft Entra ID · Auth0 · AWS Cognito · None yet |
| Runtime features (multi-select) | Realtime gateway · Background jobs · AI gateway port · Object storage · Email |
| Hosting target | **Northflank** (`compose-northflank`) · AWS · Azure · GCP (`compose-terraform`) · Decide later (Compose only) — skip if the infra profile already fixes it |
| Package registry | **GitHub Packages** · npm private · Azure Artifacts · Local (Verdaccio / devpi) |

**Round 6 — Git and CI**

| Question | Options |
|---|---|
| Git | **`git init` + first commit on `main`** · Init, no commit · Skip |
| Remote | **Don't create remotes** · Private GitHub repos via `gh` (ask for org) |
| CI | **GitHub Actions** · GitLab CI · Azure Pipelines · None |
| CODEOWNERS | **One team per repo** (`@<org>/<prefix>-<role>-team`; contracts co-owned by api + consumers) · Single owner · Skip |

## Phase 2 — Plan and confirm

Read the chosen profile files now. Print in one message: the answers table; profile per
role with its status and any compatibility notes; the tree to be written (only folders
with content); the ADRs to be created; the commands Phase 4/5 will run. Ask **Proceed ·
Change answers · Cancel**. Write nothing before "Proceed".

## Phase 3 — Generate

Placeholders: `{{Name}}`, `{{prefix}}`, `{{scope}}`, `{{pkg}}` (Python package,
`{{prefix}}` with `-` → `_`), `{{date}}`. Order: docs → db → api → web → mobile → infra.

**Docs role:** layout and files from [`reference/docs-repo.md`](reference/docs-repo.md);
scaffold ADR from [`templates/adr-scaffold.md`](templates/adr-scaffold.md); answers to
`.scaffold.json` shaped like [`templates/scaffold.example.json`](templates/scaffold.example.json).

**Every code repo (or monorepo root):**

- Root: `README.md`, `AGENTS.md`, `CLAUDE.md` (one line: "Read AGENTS.md"),
  `.{{prefix}}-docs-version` (polyrepo only), `.gitignore`, `.dockerignore`,
  `.editorconfig`, `.gitattributes`, plus the profile's root files. Nothing else.
- `tools/scripts/` gets the check-root implementation the profile names, copied from
  [`templates/check-root/`](templates/check-root/) (`check-root.mjs`, `check_root.py` or
  `check-root.sh`) with the profile's root files and `REPO_DIRS` filled in.
- `tools/scripts/check-docs-version.*`: fail if the pinned docs tag doesn't exist (in CI,
  check out the docs repo at that tag into `../{{prefix}}-docs`).
- `docs/README.md` (implementation plans, runbooks; never decisions).
- `AGENTS.md` from [`templates/AGENTS.md`](templates/AGENTS.md), also copied to the docs
  repo's `templates/<repo>/AGENTS.md`.
- CI (if chosen): one workflow with the profile's steps, in this order: checkout · checkout
  docs at the pinned tag · toolchain setup with cache · install (frozen lockfile) · lint ·
  typecheck · test · check-root · build · publish job on a release tag. GitHub Actions is
  the reference syntax; for GitLab or Azure Pipelines write the same steps in that syntax.
  Add `CODEOWNERS` and a pull request template (links to the feature spec and ADRs).

Then everything the role's profile file lists.

## Add mode

Load `.scaffold.json`, read the profiles it names, then ask what to add:

| Add | Writes |
|---|---|
| **Module** `<name>` | api module (profile layout) + registration; unit test folder; db schema/migration per tenancy (if a db role exists); contracts entry; row in docs `03-repository-structure.md` |
| **Port + adapter** | port in `core/ports/`, adapter in `adapters/<vendor>/`, binding, adapter test |
| **Role / repo** | e.g. `mobile` later: full Phase 3 for that role with its profile, plus docs tree and ADR |
| **Area / route** | `web` or `mobile` area + route + smoke test |
| **Profile switch** | not automatic: write an ADR and a migration plan in the docs repo instead |

Run Phase 2 for the change, then Phase 4 for touched repos only; update `.scaffold.json`.

## Phase 4 — Verify (skeleton and add modes)

Per repo, in dependency order, run the profile's **Verify** commands and report a
pass/fail table. Link unreleased packages between siblings (`pnpm link ../<repo>/...`,
`uv add --editable ../<repo>`, a local NuGet feed folder for `dotnet`) when they aren't
published yet. Fix failures before Phase 5. If a step can't run (tool missing, no network),
say so; never claim it passed.

## Phase 5 — Git and remotes

Per answers: `git init -b main`, `git add -A`, commit
`chore: scaffold {{prefix}}-<role> (ADR-<n>)`. Create remotes with `gh repo create
<org>/<repo> --private --source . --push` only after the org was confirmed. Never push
without that confirmation.

## Phase 6 — Report

One short message: repos and their profiles, modules scaffolded, ADRs written, verify
results, skipped steps and why, the next command to run per repo. If the session is
attached to a project knowledge base, save the generated `03-repository-structure.md` and
scaffold ADR there too.
