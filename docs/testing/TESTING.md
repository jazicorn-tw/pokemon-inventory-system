# Testing Guide

> PostgreSQL + Docker + Colima + Testcontainers + Ryuk

This guide explains how integration tests are run locally using **Testcontainers** with **PostgreSQL**.

---

## TL;DR – Quick Fix

```bash
docker ps
```

If this fails, Docker/Colima is not running.

```bash
unset DOCKER_HOST
docker context use colima
colima start
./gradlew cleanTest test
```

If you see:

```bash
Mapped port can only be obtained after the container is started
```

You are mixing Testcontainers strategies.  
This project uses **classic Testcontainers only**.

---

## How Tests Are Wired

- JUnit 5 + `@Testcontainers`
- Static `@Container` PostgreSQL container
- Datasource injected via `@DynamicPropertySource`
- Spring Boot does **not** manage container lifecycle
- Flyway runs automatically against the container database

❌ Do not use `@ServiceConnection` in this project.

---

## macOS Setup (Colima)

```bash
colima start
docker context use colima
docker ps
```

### Fix: DOCKER_HOST overrides context

```bash
unset DOCKER_HOST
docker context use colima
```

Remove any `export DOCKER_HOST=...` from your shell configuration to make this permanent.

---

## Force Testcontainers to Use Colima

Create `~/.testcontainers.properties`:

```properties
docker.host=unix:///Users/<YOUR_USER>/.colima/default/docker.sock
```

---

## Common Errors

### Docker not found

```bash
Could not find a valid Docker environment
```

➡ Fix: Start Docker or Colima.

---

### Mixed Testcontainers configuration

```bash
Mapped port can only be obtained after the container is started
```

➡ Fix:

- Remove `@ServiceConnection`
- Use static `@Container` + `@DynamicPropertySource`

---

## Flyway Errors

### Validation failed

Cause: migration edited after execution.

Fix:

- Re-run tests (fresh container)
- Or remove persisted Docker volumes

---

## Ryuk Errors

If Ryuk fails:

```bash
docker run --rm hello-world
```

Last resort:

```bash
TESTCONTAINERS_RYUK_DISABLED=true ./gradlew test
```

⚠️ Disabling Ryuk may leave orphaned containers.

---

## Test Profile

`src/test/resources/application-test.properties`

```properties
spring.jpa.hibernate.ddl-auto=validate
spring.flyway.enabled=true
logging.level.org.hibernate.SQL=debug
```

Do **not** define datasource credentials here.
