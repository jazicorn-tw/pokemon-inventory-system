# Pre-commit hook

This repo uses a **Git `pre-commit` hook** to enforce **ADR-000 quality gates** *before* code leaves your machine.

## What runs on `git commit`

If relevant files are staged (`.java`, `src/**`, Gradle files, `config/**`, GitHub workflows), the hook runs:

1. **Spotless auto-format** (default ON)
2. **Static analysis**
   - `checkstyleMain`
   - `pmdMain`
   - `spotbugsMain`
3. **Unit tests** (optional)

If no relevant files are staged, the hook prints a message and exits.

## Why Spotless runs first

Formatting is deterministic and cheap. Running it first reduces “format-only” CI failures.

**Note:** Spotless **mutates** files. If it reformats anything, the hook stops the commit and asks you to re-stage.

## Overrides (one-off per commit)

- Skip everything once:

  ```bash
  SKIP_QUALITY=1 git commit -m "..."
  ```

- Run unit tests too:

  ```bash
  RUN_TESTS=1 git commit -m "..."
  ```

- Disable auto-format (validate only):

  ```bash
  AUTO_FORMAT=0 git commit -m "..."
  ```

- Hard bypass (skips *all* Git hooks):

  ```bash
  git commit --no-verify
  ```

## Running locally without committing

- Format:

  ```bash
  ./gradlew spotlessApply
  ```

- Static analysis:

  ```bash
  ./gradlew checkstyleMain pmdMain spotbugsMain
  ```

- Tests:

  ```bash
  ./gradlew test
  ```

## Make targets

This repo includes a Makefile for convenience:

- `make hooks` — installs Git hooks (runs `./scripts/install-hooks.sh`)
- `make quality` — runs `spotlessApply` then `./gradlew clean check`
- `make test` — runs unit tests
- `make bootstrap` — runs `hooks` + `quality`
