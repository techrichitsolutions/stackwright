#!/bin/sh
# Builds dist/stackwright.zip: the skill folder you upload in Claude (Settings > Skills)
# or copy to ~/.claude/skills/stackwright. Repo-only files (tests, tools, CI) are left out.
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
rm -rf dist && mkdir -p dist/stackwright
cp -R SKILL.md profiles reference templates dist/stackwright/
(cd dist && zip -qr stackwright.zip stackwright)
rm -rf dist/stackwright
echo "built dist/stackwright.zip"
