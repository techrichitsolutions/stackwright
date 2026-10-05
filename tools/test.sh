#!/bin/sh
# Runs every self-check: profile lint, then each check-root template against fixtures.
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
failures=0

pass() { echo "ok   $1"; }
fail() { echo "FAIL $1"; failures=$((failures + 1)); }

python3 "$ROOT/tools/lint_profiles.py" && pass "profile lint" || fail "profile lint"

# render <template> <dest> <profile-files> <repo-dirs>: fill placeholders the way Phase 3 does
render() {
  python3 - "$1" "$2" "$3" "$4" <<'PY'
import sys, re
src, dest, files, dirs = sys.argv[1:5]
text = open(src).read().replace("{{prefix}}", "acme")
files = [f for f in files.split() if f]
dirs = [d for d in dirs.split() if d]
if src.endswith(".mjs"):
    text = text.replace("const PROFILE_FILES = [/* from the profile */];",
                        f"const PROFILE_FILES = {files!r};")
    text = re.sub(r"const REPO_DIRS = \[.*?\];", f"const REPO_DIRS = {dirs!r};", text)
elif src.endswith(".py"):
    text = re.sub(r'PROFILE_FILES = \{.*?\}', "PROFILE_FILES = " + repr(set(files) or set()), text)
    text = text.replace("REPO_DIRS: set[str] = set()", f"REPO_DIRS: set[str] = {set(dirs) or 'set()'}")
else:
    text = re.sub(r"^PROFILE_ALLOWED=.*$", "PROFILE_ALLOWED='" + " ".join(files + dirs) + "'",
                  text, flags=re.M)
open(dest, "w").write(text)
PY
}

# case <name> <runner> <template> <profile-files> <repo-dirs> <setup> <expect: ok|fail>
case_run() {
  name=$1; runner=$2; template=$3; files=$4; dirs=$5; setup=$6; expect=$7
  dir="$WORK/$name"; mkdir -p "$dir/tools/scripts"
  script="$dir/tools/scripts/$(basename "$template")"
  render "$ROOT/templates/check-root/$template" "$script" "$files" "$dirs"
  (cd "$dir" && sh -c "$setup")
  if (cd "$dir" && $runner "tools/scripts/$(basename "$template")" >/dev/null 2>&1); then got=ok; else got=fail; fi
  [ "$got" = "$expect" ] && pass "$name (expected $expect)" || fail "$name (expected $expect, got $got)"
}

clean='mkdir -p src docs tests .github && touch README.md AGENTS.md CLAUDE.md .gitignore .acme-docs-version'

if command -v node >/dev/null 2>&1; then
  case_run node-clean node check-root.mjs "package.json pnpm-lock.yaml" "packages" \
    "$clean && mkdir -p packages node_modules && touch package.json pnpm-lock.yaml tsconfig.json vite.config.ts" ok
  case_run node-stray-file node check-root.mjs "package.json" "" "$clean && touch package.json notes.txt" fail
  case_run node-stray-dir node check-root.mjs "package.json" "" "$clean && touch package.json && mkdir scripts" fail
else
  echo "skip node cases (node not installed)"
fi

case_run python-clean python3 check_root.py "pyproject.toml uv.lock .python-version" "" \
  "$clean && mkdir -p .venv __pycache__ && touch pyproject.toml uv.lock .python-version" ok
case_run python-stray python3 check_root.py "pyproject.toml uv.lock" "" "$clean && touch pyproject.toml requirements.txt" fail

case_run posix-dotnet-clean sh check-root.sh "Acme.slnx global.json nuget.config" ".config packages" \
  "$clean && mkdir -p .config packages bin obj && touch Acme.slnx global.json nuget.config" ok
case_run posix-stray-dir sh check-root.sh "project.yml" "" "$clean && touch project.yml && mkdir fastlane" fail

if [ "$failures" -gt 0 ]; then
  echo "$failures check(s) failed"; exit 1
fi
echo "all checks passed"
