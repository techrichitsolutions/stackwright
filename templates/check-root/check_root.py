#!/usr/bin/env python3
"""Fails CI on anything at the repo root that is not on the allow-list (ADR-0011)."""
import re, sys
from pathlib import Path

COMMON_FILES = {"README.md", "AGENTS.md", "CLAUDE.md", ".{{prefix}}-docs-version",
                ".gitignore", ".dockerignore", ".editorconfig", ".gitattributes"}
COMMON_DIRS = {"src", "docs", "tools", "tests", "docker", ".github"}
IGNORED = {".git", ".venv", "__pycache__", ".pytest_cache", ".ruff_cache", ".mypy_cache",
           "dist", "build", "node_modules"}
PROFILE_FILES = {"pyproject.toml", "uv.lock", ".python-version"}
PROFILE_PATTERNS: list[re.Pattern[str]] = []
REPO_DIRS: set[str] = set()

unexpected = sorted(
    e.name for e in Path(".").iterdir()
    if e.name not in IGNORED and (
        e.name not in COMMON_DIRS | REPO_DIRS if e.is_dir()
        else e.name not in COMMON_FILES | PROFILE_FILES
             and not any(p.match(e.name) for p in PROFILE_PATTERNS)))
if unexpected:
    sys.exit(f"Unexpected at repo root: {', '.join(unexpected)} (see ADR-0011)")
print("check:root ok")
