# Bootstrap Scripts

This document describes the purpose and usage of the repo’s bootstrap scripts.

Bootstrap scripts exist to eliminate a class of frustrating, non-obvious **permission** and **git hook** issues on local machines **without affecting CI**.

Scripts covered:

- `scripts/bootstrap-common.sh` (shared logic)
- `scripts/bootstrap-macos.sh` (macOS entry point)
- `scripts/bootstrap-linux.sh` (Linux entry point)

---

## Purpose

Executable permissions (`+x`) can be lost or become inconsistent due to:

- ZIP downloads
- File copies outside of Git
- Certain filesystem / editor behaviors
- Partial checkouts

Bootstrap scripts ensure:

- Required project scripts are executable
- Repo-managed Git hooks are executable
- Git is configured to use `.githooks/`

They are **safe**, **idempotent**, and **explicitly invoked** (no hidden automation).

---

## What bootstrap does

When run on a supported OS, bootstrap:

1. Ensures we operate from the repo root (so paths are correct)
2. Ensures Git uses the repo-managed hooks directory:

   ```bash
   git config core.hooksPath .githooks
   ```

3. Ensures executable permissions for **regular files only** (best effort):

   - files in `.githooks/`
   - files in `scripts/`

   Directories are intentionally ignored and no recursion is performed.

---

## What bootstrap does NOT do

- ❌ Does not run automatically on clone
- ❌ Does not modify CI behavior
- ❌ Does not install dependencies
- ❌ Does not recurse into subdirectories
- ❌ Does not change application configuration

---

## How to run

### Recommended (via Make)

```bash
make hooks
```

or during first-time setup:

```bash
make bootstrap
```

### Direct invocation

macOS:

```bash
./scripts/bootstrap-macos.sh
```

Linux:

```bash
./scripts/bootstrap-linux.sh
```

---

## OS-specific behavior

### macOS (`scripts/bootstrap-macos.sh`)

- Runs only when `uname -s` is `Darwin`
- Prints a friendly message and exits on non-macOS systems
- Delegates all shared work to `scripts/bootstrap-common.sh`

### Linux (`scripts/bootstrap-linux.sh`)

- Runs only when `uname -s` is `Linux`
- Prints a friendly message and exits on non-Linux systems
- Delegates all shared work to `scripts/bootstrap-common.sh`

### Shared helper (`scripts/bootstrap-common.sh`)

The common bootstrap helper performs the actual work:

- Resolves repo root and `cd`s there
- Applies `chmod +x` to **files only** in `scripts/` and `.githooks/` (best effort)
- Sets `git config core.hooksPath .githooks`

---

## When to re-run

Re-run bootstrap if you see errors like:

```text
permission denied
hook was ignored because it's not executable
```

---

## Relationship to other tooling

Bootstrap works together with:

- `scripts/check-executable-bits.sh` — verifies executable bits (auto-fix locally, enforce in CI)
- `make hooks` / `make bootstrap` — canonical entry points
- `docs/LOCAL_ENVIRONMENT.md` — local-only behavior and settings
- `ADR-000` — CI as source of truth
- `ADR-007` — commit message enforcement strategy

---

## Design principles

- Explicit execution (no hidden magic)
- Repo-managed hooks
- OS-specific entry points with shared logic
- Cross-platform safety
- CI remains authoritative
- Local developer convenience only

---

## Summary

Bootstrap scripts eliminate a class of local permission + git hook issues in a safe, explicit way.

If something suddenly stops working locally due to permissions, bootstrap is the first thing to run.
