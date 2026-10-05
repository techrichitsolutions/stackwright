# Stackwright

Get your stack right from the first commit.

Stackwright is a Claude skill that scaffolds a product's repositories through a short
interview: project name, repo topology, a stack profile per role, modules, tenancy,
hosting, and git/CI. It shows you the plan, writes only after you confirm, and checks
that what it built actually installs, lints, tests and builds.

The layout rules came out of the 3D Prioritization (3DP) platform; the stacks are
pluggable, so the same rules work for TypeScript, Python, .NET, React, Next.js, Expo,
Swift, Postgres and Terraform projects.

## What it does

- **Interview → plan → confirm → generate → verify → commit.** Nothing is written before
  you approve the plan; existing files are never overwritten without asking.
- **Three modes:** a runnable skeleton (one green health check per repo), structure and
  docs only, or add to an existing project (a module, port and adapter, repo, or route).
- **One layout everywhere:** root allow-list enforced in CI, all source in `src/`, all
  tests in `tests/`, decisions only in the docs repo as ADRs.
- **Stack profiles:** everything language-specific lives in [`profiles/`](profiles/).
  Pick one per role; a compatibility check catches pairings that don't fit.

## Profiles

| Role | Profiles |
|---|---|
| api | `ts-nest` · `ts-fastify` · `python-fastapi` · `dotnet` |
| web | `react-vite` · `nextjs` |
| mobile | `expo-react-native` · `swift-ios` |
| db | `postgres-drizzle` · `postgres-sql-only` · `orm-migrations` (alembic, efcore) |
| infra | `compose-northflank` · `compose-terraform` (aws, azure, gcp) |
| any | `bring-your-own` |

`ts-nest`, `react-vite`, `postgres-drizzle` and `compose-northflank` are **proven** in a
real project; the rest are **written** against the contract and get promoted after their
first successful scaffold. See [`profiles/README.md`](profiles/README.md) to add one.

## Install

**Claude (desktop or web):** download `stackwright.zip` from the latest CI run (or build
it with `sh tools/package.sh`), then upload it under Settings → Skills.

**Claude Code:** copy or symlink the repo folder to `~/.claude/skills/stackwright`.

Then ask Claude something like "scaffold a new project" or "add a billing module to 3DP".

## Repository layout

```
SKILL.md              the skill: rules, interview, phases, catalogue
profiles/             one file per stack profile + the profile contract
reference/            tenancy models, docs-repo layout
templates/            AGENTS.md, scaffold ADR, .scaffold.json example, check-root scripts
tools/                test.sh (self-checks), lint_profiles.py, package.sh
.github/workflows/    CI: self-checks + packaged skill artifact
```

## Development

```sh
sh tools/test.sh      # profile lint + check-root templates against fixtures
sh tools/package.sh   # dist/stackwright.zip
```

Needs `python3` and `sh`; `node` for the Node check-root cases.
