# TESTING

> **Purpose:** Explain why this project’s testing wiring exists, so future refactors don’t quietly break integration tests.

This project uses **Spring Boot 4**, **JUnit 5**, **Testcontainers**, **PostgreSQL**, and **Flyway**.

## The contract

All integration tests must run with one command:

```bash
./gradlew test
```

They must work the same way:

- on a developer laptop (Docker Desktop or Colima)
- in CI
- without a manually installed PostgreSQL server
- without devs maintaining a local `pokedex_test` database

If tests ever require extra steps, the wiring has regressed.

## Why Tests Require Docker

This project intentionally runs integration tests against a real PostgreSQL
instance using Testcontainers.

This is a deliberate architectural decision to ensure production parity.

See:

- [ADR-001](../adr/ADR-001-database-postgresql.md): Use PostgreSQL across local, test, CI, and production
- [ADR-002](../adr/ADR-002-testcontainers.md): Use Testcontainers for PostgreSQL-backed integration tests

## Why Testcontainers (real Postgres) instead of H2

We use Testcontainers + PostgreSQL because it prevents “works in tests, fails in prod” problems:

- PostgreSQL SQL dialect and behavior (constraints, indexes, JSON types, enums, timestamps)
- Flyway migrations applied the same way as production
- Connection pooling, transaction behavior, and isolation levels are closer to reality

If you switch to an in-memory database for tests, you must accept that some production issues will only be caught after deployment.

## The key pattern: `BaseIntegrationTest`

Integration tests extend a shared base class:

- a **single** PostgreSQL container is started once per test run
- Spring is pointed at that container via **DynamicPropertySource**
- Flyway is enabled so migrations run against the container

This keeps tests consistent and prevents every test class from duplicating container boilerplate.

### Why the container is `static`

The container is `static` so it starts **once** for the entire test suite (per JVM):

- much faster test runs
- fewer “port already in use” issues
- less flakiness in CI

If you make the container non-static, the suite will get dramatically slower and more failure-prone.

### Why we use `@DynamicPropertySource`

We do **not** hardcode a JDBC URL in test config.

Testcontainers chooses a random host port at runtime. `@DynamicPropertySource` registers the actual JDBC URL, username, and password that the container generated:

- `spring.datasource.url`
- `spring.datasource.username`
- `spring.datasource.password`

This is the most reliable way to connect Spring Boot to Testcontainers.

### Why we enable Flyway in tests

Flyway is enabled in integration tests so the schema is created exactly as it is in production:

- migrations are the single source of truth
- tests fail fast if a migration is missing, broken, or out of order

Without Flyway in tests, you can accidentally:

- validate against a stale schema
- rely on Hibernate auto-DDL in tests but not in prod
- ship broken migrations that CI never executed

## Environment variables: what is used where

This project intentionally splits runtime (app) configuration from test-only configuration.

### Runtime (Spring standard)

Used for `bootRun`, docker-compose runtime, staging, production:

- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`
- `SPRING_FLYWAY_ENABLED` (preferred)

These are Spring-native names so Spring Boot can bind them automatically.

### Tests (Testcontainers only)

Used only by `BaseIntegrationTest` when it constructs the container:

- `TEST_DATASOURCE_IMAGE` (default `postgres:16-alpine`)
- `TEST_DATASOURCE_DB` (default `pokedex_test`)
- `TEST_DATASOURCE_USER` (default `test`)
- `TEST_DATASOURCE_PASSWORD` (default `test`)

These values do **not** affect runtime configuration.

### Why we avoid custom DB env vars

Avoid patterns like `DB_HOST`, `DB_PORT`, `DB_NAME`, then concatenating a JDBC URL yourself. That creates drift between:

- local
- CI
- Docker
- production

Using `SPRING_DATASOURCE_URL` keeps the configuration predictable and portable.

## Why `ddl-auto=validate` in integration tests

We set Hibernate DDL to `validate` (not `update`, `create`, or `create-drop`) in integration tests.

Reason:

- The database schema must come from **Flyway migrations**
- Hibernate should only verify that entities match the migrated schema

If you change this to `update` or `create` in tests, you can end up with:

- tests passing while migrations are broken
- entities and migrations diverging
- production failing on deploy

## Common refactor traps (and why they break CI)

These are the most common ways people accidentally break this setup.

### Trap 1: “Let’s just use `application-test.yml` with a fixed JDBC URL”

Bad because the container port is random. A fixed URL will fail on most machines and in CI.

### Trap 2: “We can turn off Flyway in tests to speed things up”

You will eventually ship a migration that breaks production because tests never executed it.

### Trap 3: “Let’s remove the base class and create containers in each test”

- slower by an order of magnitude
- more flaky due to many container startups
- harder to keep properties consistent

### Trap 4: “Let’s switch integration tests to H2”

You lose PostgreSQL reality. If you do this, document the tradeoff clearly.

## How to write tests in this repo

### Integration tests (hit DB)

Use `@SpringBootTest` and extend `BaseIntegrationTest`:

```java
@SpringBootTest
class PokemonRepositoryIT extends BaseIntegrationTest {
  // tests
}
```

### Slice tests (no DB)

Use Spring slice tests when you do not need a database:

- `@WebMvcTest` for controller layer
- `@JsonTest` for serialization

Slice tests should not extend `BaseIntegrationTest`.

## Local Docker runtime notes

Testcontainers requires a working Docker runtime.

On macOS, Colima is supported and commonly used. If Docker is not running, you may see errors like:

- "Could not find a valid Docker environment"
- failures resolving the Docker socket

See `DOCKER.md` / `COLIMA.md` (if present in the repo) for local troubleshooting.

## If you change this wiring

If you modify any of the following, update this document and validate both local and CI runs:

- Testcontainers image/version
- Flyway enablement or locations
- Hibernate DDL mode
- how env vars are named or loaded
- the base test class structure

The goal is stability: future you should be able to trust that a green test suite means the database + migrations are healthy.
