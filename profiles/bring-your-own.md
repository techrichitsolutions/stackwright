---
profile: bring-your-own
role: any
check-root: posix
status: written
---

# `bring-your-own` (any role)

Ask, in one round: language/toolchain; root files the toolchain needs (e.g. `go.mod`,
`Cargo.toml`, `*.csproj`, `Makefile`); install / lint / test / build commands; container
base image (or none). Generate the common files, the POSIX `check-root.sh` with
`PROFILE_ALLOWED` filled in, `tests/` and `docs/` READMEs, `AGENTS.md` with those commands,
`.gitignore` (from the github/gitignore template for that language), a Dockerfile stub if
an image was given, and CI running the given commands. No source code. Verify: the given
commands, if the toolchain is installed.
