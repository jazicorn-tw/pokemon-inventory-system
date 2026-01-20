# ADR-002: Use Testcontainers for PostgreSQL-backed integration tests

- Date: 2026-01-17
- Status: Accepted

## Context

- The system requires **real PostgreSQL behavior** during automated tests.
- Maintaining a shared test database introduces:
  - State leakage between test runs
  - Environment coupling
  - Manual cleanup complexity
- Developers run tests locally on different platforms (macOS, CI runners).
- CI must be reproducible, isolated, and environment-independent.

## Decision

- Use **Testcontainers** to provision PostgreSQL for all integration tests.
- Each test run starts with a clean, isolated PostgreSQL instance.
- Flyway migrations are applied automatically at test startup.
- No shared, long-lived test databases are permitted.

## Consequences

### Positive

- Tests run against real PostgreSQL behavior.
- Full isolation between test runs.
- Identical behavior locally and in CI.
- Zero manual database setup for contributors.

### Trade-offs

- Requires Docker to be available locally and in CI.
- Slower startup compared to embedded databases.
- Additional complexity when configuring Docker on macOS (Colima).

## Explicit Non-Goals

- Supporting non-Docker-based integration testing.
- Using embedded or in-memory databases for convenience.
- Optimizing test speed at the cost of correctness.

## Related ADRs

- ADR-001: Use PostgreSQL across local, test, CI, and production
