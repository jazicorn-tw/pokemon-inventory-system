# 🩺 Doctor (Local Environment Sanity)

This project includes a **local-only pre-flight check** to catch environment issues *before* you run Gradle, tests, or Testcontainers.

> **Important:** This does **not** replace CI.  
> CI runs Gradle directly and remains the source of truth.

---

## What this is

`make doctor` is a **fail-fast environment sanity check**.

Its job is to answer one question:

> *“Is my machine correctly set up to run this project?”*

If the answer is **no**, it exits early with **clear, actionable instructions** (for example: “install Java 21” or “run `colima start`”).

This avoids confusing failures later in:

- Gradle configuration
- Spring Boot startup
- Testcontainers initialization

---

## How it’s implemented

The check is implemented as a script:

```bash
scripts/precheck.sh
```

The script name is intentionally technical; the Make target is intentionally human-friendly:

- Script: `scripts/precheck.sh`
- Command: `make doctor`

---

## What it checks

### Required (hard failures)

These must pass for the project to work locally.

- **Java 21+**
  - `java` must be on `PATH`
  - Version must be ≥ 21
- **Gradle wrapper**
  - `./gradlew` must exist
  - Must be executable
- **Docker**
  - Docker CLI installed
  - Docker daemon reachable
  - Docker socket healthy

If any of these fail, the script **exits immediately**.

---

### macOS-specific (conditional)

- If **Colima** is installed:
  - It must be running
- If Colima is explicitly required:
  - (`PRECHECK_REQUIRE_COLIMA=1`)
  - Colima must be installed **and** running

This allows flexibility between:

- Docker Desktop users
- Colima users

---

### Best-effort / advisory checks

These checks provide **guidance**, not hard failure (unless strict mode is enabled):

- Docker provider detection
  - Docker Desktop
  - Colima
  - Rancher Desktop
  - Podman
- Docker memory inspection
  - Warns if below recommended minimum
  - Helps avoid slow or flaky Testcontainers runs

---

## How to run it

```bash
make doctor
```

Use this:

- After cloning
- When onboarding
- When something “feels wrong” locally
- Before running longer checks (`make quality`, integration tests, etc.)

---

## Optional configuration (advanced)

The doctor check can be tuned **per invocation** using environment variables.

These are intentionally *not* committed defaults.

### `PRECHECK_STRICT`

```bash
PRECHECK_STRICT=1 make doctor
```

Converts warnings into failures.

### `PRECHECK_MIN_DOCKER_MEM_GB`

```bash
PRECHECK_MIN_DOCKER_MEM_GB=6 make doctor
```

Sets the *recommended* Docker memory threshold used by the advisory memory check.

### `PRECHECK_REQUIRE_COLIMA` (macOS only)

```bash
PRECHECK_REQUIRE_COLIMA=1 make doctor
```

Enforces Colima usage on macOS (fail if Colima is not installed/running).

### One-off vs persistent configuration

All variables apply **only to that invocation**:

```bash
PRECHECK_STRICT=1 PRECHECK_MIN_DOCKER_MEM_GB=6 make doctor
```

If you want persistence:

- Use shell config (`.zshrc` / `.bashrc`)
- Or a local `.envrc` (via `direnv`, not committed)

---

## CI behavior (critical)

When `CI=true` is set (for example in GitHub Actions):

- the script **exits immediately**
- no checks are performed

This guarantees:

- CI never depends on local tooling
- macOS-specific checks never run on Linux runners
- CI remains the **only authoritative gate**

---

## Related Make targets

```bash
make doctor     # Environment sanity (local)
make verify     # doctor + lint + test (“am I good to push?”)
make quality    # doctor + format + clean check (CI-aligned)
make test       # doctor + unit tests
make bootstrap  # hooks + doctor + full quality gate
```

---

## Summary

- **Script:** `scripts/precheck.sh`
- **Command:** `make doctor`
- Optional configuration exists for advanced users
- CI remains authoritative

If doctor passes, your environment is sane.
