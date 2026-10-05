# {{prefix}}-{{role}} — agent guide

Owner: {{team}}. Profile: {{profile}}. Ships: {{artifacts}}.

## Read before changing code

- ../{{prefix}}-docs/specs/brief/
- ../{{prefix}}-docs/specs/adr/ (especially {{adr_list}})
- ../{{prefix}}-docs/specs/architecture/03-repository-structure.md

## Rules

- Layout per ADR-0011; the root allow-list is enforced by check-root.
- Tests only under tests/; unit tests mirror src/.
- Decisions are never written here: propose an ADR in {{prefix}}-docs.
{{boundary_rules}}

## Commands

{{commands}}
