# 🧰 Makefile Commands Overview

This project uses a small set of **simple, memorable Makefile commands** to standardize local development and **mirror CI behavior exactly**, as defined in **ADR-000**.

Formatting, linting, static analysis, and tests are treated as a **single quality gate**.

---

## ✅ What this gives you

### Simple, memorable commands

```bash
make hooks     # install git hooks
make quality   # formatting + linting + static analysis + tests
make test      # run tests only
```

Each command does **one clear thing** and maps directly to an existing workflow.

---

## 🔍 What each command actually runs

### `make hooks`

Sets up local safeguards.

- Installs pre-commit hooks
- Ensures formatting and quality checks run before commits
- Mirrors CI expectations locally

Run once after cloning.

---

### `make quality` (the full quality gate)

Runs the **same checks as CI**, in the same order:

1. **Formatting**
   - `./gradlew spotlessApply` (local convenience)
2. **Formatting verification, linting & static analysis**
   - `./gradlew clean check`
   - Includes:
     - Spotless (format verification)
     - Checkstyle
     - PMD
     - SpotBugs
     - Tests

This is the **non-negotiable baseline** defined in ADR-000.

---

### `make test`

```bash
./gradlew test
```

- Runs tests only
- Useful during tight feedback loops
- Does **not** replace `make quality` before pushing

---

## 🤔 Why this is good

### 1. Lowers cognitive load

Contributors don’t need to remember long Gradle commands or internal task wiring.

One mental model:

> “Before I push, I run `make quality`.”

---

### 2. Mirrors CI exactly

- `make quality` == CI quality gate
- No “but it passed locally” surprises
- Same tools, same order, same failure modes

---

### 3. No new tooling required

- Uses `make` (already available on most systems)
- Wraps existing Gradle tasks
- No additional CLIs, wrappers, or custom runners

---

### 4. Reinforces ADR-000 in practice

This Makefile operationalizes the decision that:

- Formatting comes first
- Linting defines the baseline
- Static analysis is non-optional
- CI is not special — it just runs the same commands

---

### 5. Reads well in docs & interviews

- Easy to explain during onboarding
- Clear signal of engineering maturity
- Demonstrates intentional developer-experience design
- Shows alignment between docs, tooling, and CI

---

## 📌 Recommended usage

- Run `make hooks` once after cloning
- Run `make quality` before pushing any change
- Use `make test` during day-to-day development

For first-time setup, prefer:

```bash
make bootstrap
```

This installs hooks **and** verifies the full quality gate passes on your machine.
