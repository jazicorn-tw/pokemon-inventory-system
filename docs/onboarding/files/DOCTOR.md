# 🩺 Doctor (Local Environment Sanity)

This project includes a **local-only environment sanity check** to catch setup issues
*before* you run Gradle, tests, or Testcontainers.

> **Important:** This does **not** replace CI.  
> CI runs Gradle directly and remains the source of truth.

---

## What this is

`make doctor` is a **fail-fast local environment check**.

Its job is to answer one question:

> *“Is my machine correctly set up to run this project?”*

If the answer is **no**, it exits early with **clear, actionable instructions**
(for example: “install Java 21” or “run `colima start`”).

This avoids confusing failures later in:

- Gradle configuration
- Spring Boot startup
- Testcontainers initialization

---

## How it’s implemented

The checks are implemented as a script:

```bash
scripts/doctor.sh
```

The naming is intentional:

- **Script:** `scripts/doctor.sh` (technical, explicit)
- **Command:** `make doctor` (human-friendly entry point)

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
  - (`DOCTOR_REQUIRE_COLIMA=1`)
  - Colima must be installed **and** running

This allows flexibility between:

- Docker Desktop users
- Colima users

---

### Best-effort / advisory checks

These checks provide **guidance**, not hard failure
(unless strict mode is enabled):

- Docker provider detection
  - Docker Desktop
  - Colima
  - Rancher Desktop
  - Podman
- Docker memory inspection
  - Warns if below the recommended minimum
  - Helps avoid slow or flaky Testcontainers runs

---

## How to run it

```bash
make doctor
```

Use this:

- After cloning
- During onboarding
- When something “feels wrong” locally
- Before running longer checks (`make quality`, integration tests, etc.)

---

## Optional configuration (advanced)

Doctor can be tuned **per invocation** using environment variables.

### `DOCTOR_STRICT`

```bash
DOCTOR_STRICT=1 make doctor
```

Treats warnings as failures.

### `DOCTOR_MIN_DOCKER_MEM_GB`

```bash
DOCTOR_MIN_DOCKER_MEM_GB=6 make doctor
```

Sets the *recommended* Docker memory threshold.

### `DOCTOR_REQUIRE_COLIMA` (macOS only)

```bash
DOCTOR_REQUIRE_COLIMA=1 make doctor
```

Enforces Colima usage on macOS.

---

## CI behavior

When `CI=true` is set:

- the script exits immediately
- no checks are performed

CI remains the **only authoritative quality gate**.

---

## Related Make targets

```bash
make doctor
make verify
make quality
make test
make bootstrap
```

---

## Summary

If doctor passes, your environment is sane.
