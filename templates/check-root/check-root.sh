#!/bin/sh
# Fails CI on anything at the repo root that is not on the allow-list (ADR-0011).
ALLOWED='README.md AGENTS.md CLAUDE.md .{{prefix}}-docs-version .gitignore .dockerignore .editorconfig .gitattributes src docs tools tests docker .github .git'
PROFILE_ALLOWED=''   # e.g. dotnet: '{{Name}}.slnx global.json Directory.Build.props Directory.Packages.props nuget.config .config packages'
IGNORED='node_modules .venv dist build target bin obj coverage DerivedData .terraform'
bad=''
for entry in * .[!.]*; do
  [ -e "$entry" ] || continue
  case " $ALLOWED $PROFILE_ALLOWED $IGNORED " in *" $entry "*) ;; *) bad="$bad $entry" ;; esac
done
[ -z "$bad" ] && { echo 'check:root ok'; exit 0; }
echo "Unexpected at repo root:$bad (see ADR-0011)" >&2; exit 1
