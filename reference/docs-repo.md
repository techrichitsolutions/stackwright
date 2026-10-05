# Docs role

The docs repo (or `docs/` in a monorepo) holds every decision. It is not a code repo, so
it keeps its own layout instead of `src/`.

```
ideation/            drafts (non-binding)
specs/brief/         project instructions
specs/adr/           scaffold ADR + one per non-default answer
specs/architecture/  03-repository-structure.md generated from the answers; profiles/
specs/features/      README (feature spec format)
specs/naming/        README (naming map)
templates/<repo>/    AGENTS.md per code repo
guides/product/      README
guides/developer/    local-setup.md (clone order, linking unreleased packages, compose up)
.scaffold.json       every answer, incl. topology and profile per role (Add mode reads it)
README.md, CONTRIBUTING.md
```

- The scaffold ADR follows [`templates/adr-scaffold.md`](../templates/adr-scaffold.md).
  If ADRs already exist, number after the highest.
- `.scaffold.json` follows [`templates/scaffold.example.json`](../templates/scaffold.example.json).
- `specs/architecture/profiles/<name>.md` records each profile the first time it is
  proven in this project: what was generated, pinned versions, anything that had to change.
- Code repos pin a docs tag in `.<prefix>-docs-version`; CI checks out the docs repo at
  that tag.
