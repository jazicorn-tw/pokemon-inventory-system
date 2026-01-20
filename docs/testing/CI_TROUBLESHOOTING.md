# Troubleshooting Guide

> PostgreSQL + Docker + Colima + Testcontainers + Ryuk

This project uses **Testcontainers** to start a **PostgreSQL** container for integration tests.
This document is the **single source of truth** for diagnosing local failures.

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

## How Tests Are Wired (Authoritative)

- JUnit 5 + `@Testcontainers`
- Static `@Container` PostgreSQL container
- Datasource injected via `@DynamicPropertySource`
- Spring Boot **does not** manage the container lifecycle
- Flyway runs automatically against the container database

❌ `@ServiceConnection` is **not allowed**

## Docker / Testcontainers Failures

If tests fail due to Docker not being available, this is expected behavior.

This project does not support in-memory databases for tests.

Related decisions:

- [ADR-001](../adr/ADR-001-database-postgresql.md): Use PostgreSQL across all environments
- [ADR-002](../adr/ADR-002-testcontainers.md): Use Testcontainers for integration tests

## Common Errors

### 0. Colima

See [COLIMA](errors/COLIMA.md)

### 1. Docker

See [DOCKER](errors/DOCKER.md)

### 2. Testcontainers

See [TESTCONTAINERS](errors/TESTCONTAINERS.md)

### 3. PostgreSQL

See [CI-POSTGRESQL](CI-POSTGRESQL.md)

See [POSTGRESQL](errors/POSTGRESQL.md)

### 4. Flyway

See [FLYWAY](errors/FLYWAY.md)

### 5. Ryuk (Testcontainers Reaper)

See [RYUK](errors/RYUK.md)

## Java Test Runner Notes

VS Code's Java Test Runner may execute tests outside Gradle.
To avoid Mockito dynamic-agent warnings during local development,
we enable:

-XX:+EnableDynamicAgentLoading

Gradle and CI already preload Mockito as a Java agent and do not rely
on dynamic attachment.

## Recommended Test Profile

`src/test/resources/application-test.properties`

```properties
spring.jpa.hibernate.ddl-auto=validate
spring.flyway.enabled=true
logging.level.org.hibernate.SQL=debug
```

❌ Do not hardcode datasource credentials.

---

## When Asking for Help

Include:

```bash
docker ps
docker context show
echo $DOCKER_HOST
colima status
```

And:

```bash
./gradlew test --stacktrace --info
```

Paste the **first `Caused by:` block**.
