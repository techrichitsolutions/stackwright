#!/usr/bin/env node
// Fails CI on anything at the repo root that is not on the allow-list (ADR-0011).
import { readdirSync } from 'node:fs';

const COMMON_FILES = ['README.md', 'AGENTS.md', 'CLAUDE.md', '.{{prefix}}-docs-version',
  '.gitignore', '.dockerignore', '.editorconfig', '.gitattributes'];
const COMMON_DIRS = ['src', 'docs', 'tools', 'tests', 'docker', '.github'];
const IGNORED = ['.git', 'node_modules', 'dist', 'coverage', '.turbo', '.vite', '.expo'];
const PROFILE_FILES = [/* from the profile */];
const PROFILE_PATTERNS = [/^tsconfig.*\.json$/, /^.+\.config\.(ts|js|mjs|cjs)$/];
const REPO_DIRS = [/* e.g. 'packages', 'e2e', 'public' */];

const unexpected = readdirSync('.', { withFileTypes: true })
  .filter(({ name }) => !IGNORED.includes(name))
  .filter((entry) => entry.isDirectory()
    ? ![...COMMON_DIRS, ...REPO_DIRS].includes(entry.name)
    : ![...COMMON_FILES, ...PROFILE_FILES].includes(entry.name)
      && !PROFILE_PATTERNS.some((p) => p.test(entry.name)))
  .map(({ name }) => name);

if (unexpected.length > 0) {
  console.error(`Unexpected at repo root: ${unexpected.join(', ')} (see ADR-0011)`);
  process.exit(1);
}
console.log('check:root ok');
