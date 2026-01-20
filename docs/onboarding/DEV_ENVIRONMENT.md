# Dev Environment (VS Code + Docker)

This repo is optimized for **repeatable builds**, **TDD**, and **CI parity** using
**Spring Boot 4**, **Java 21**, **Gradle**, and **Testcontainers**.

---

## Requirements

- **Java 21**
  - Enforced via **Gradle Toolchains**
- **Docker**
  - macOS: **Colima** recommended
- **Gradle Wrapper**
  - Always use `./gradlew` (do not rely on system Gradle)

---

## Recommended VS Code setup

VS Code’s Java Test Runner can execute tests **outside Gradle**, which causes
**Mockito inline mocking** to self-attach dynamically and emit JDK warnings.

To keep IDE behavior aligned with **CLI + CI**, this repo enforces:

- Tests run via **Gradle**
- Dev-only JVM flag to silence dynamic agent warnings

### Workspace settings

This repo includes `.vscode/settings.json` that:

- Forces tests to run via **Gradle**
- Adds `-XX:+EnableDynamicAgentLoading` (development only)

> `./gradlew test` and CI runs preload Mockito correctly via Gradle and do **not**
> rely on dynamic attachment.

---

## Local database (PostgreSQL)

### When do you need it?

- ✅ **Required** for:
  - Running the app locally (`bootRun`)
  - Manual API testing
- ❌ **Not required** for:
  - Tests (handled by **Testcontainers**)

### Start PostgreSQL

```bash
docker compose up -d
```

Stop it with:

```bash
docker compose down
```

---

## Environment variables

Copy the example file:

```bash
cp .env.example .env
```

### Important notes

- Spring Boot **does not automatically load `.env`**
- `.env` is used by:
  - Docker Compose
  - Shells that explicitly export it
- CI and production rely on **real environment variables**

---

## Common commands

Run all tests:

```bash
./gradlew test
```

Run the app (local profile):

```bash
./gradlew bootRun
```

Run a single test:

```bash
./gradlew test --tests "com.pokedex.inventory.ping.PingControllerTest"
```

---

## Active profiles

- `local` → default for development
- `test` → Testcontainers-backed integration tests
- `prod` → production-grade configuration (env-driven)

---

## Troubleshooting

- Docker / Testcontainers issues → `TROUBLESHOOTING.md`
- macOS + Colima setup → `COLIMA.md` (if present)
