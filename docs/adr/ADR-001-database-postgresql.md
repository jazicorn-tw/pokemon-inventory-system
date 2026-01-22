# ADR-001: Use PostgreSQL across local, test, CI, and production

- **Date:** 2026-01-17
- **Status:** Accepted

## Context

- The project prioritizes **production parity** and **enterprise realism**.
- In-memory databases (e.g., H2) hide real-world issues:
  - SQL dialect differences
  - Constraint enforcement
  - Index behavior and query planning
  - Transaction semantics
- Schema evolution must be explicit, reproducible, and environment-agnostic.
- Discovering database issues late (CI or production) is significantly more costly than slower local setup.

## Decision

### Database engine

- **PostgreSQL is the only supported database engine** across all environments.

### Local development

- Uses PostgreSQL via Docker / Docker Compose (recommended) or a native PostgreSQL installation.
- Local behavior must match CI and production semantics as closely as possible.

### Automated tests

- Use PostgreSQL exclusively via **Testcontainers**.
- Embedded or in-memory databases are not permitted for tests.
- Integration tests validate real PostgreSQL behavior (constraints, transactions, and schema evolution).

### CI

- Uses PostgreSQL via Testcontainers or a CI service container.
- CI enforces the same schema and migration behavior as local development.

### Schema management

- All schema changes are applied via **Flyway migrations**.
- Hibernate DDL auto-generation is disabled beyond validation.
- Flyway is the **single source of truth** for schema evolution.

### Phase-based schema evolution

- Flyway migrations are introduced incrementally by project phase.
- **Phase 0 migrations are intentionally minimal**, containing only the schema required to:
  - Validate PostgreSQL connectivity
  - Prove Flyway execution
  - Support application startup and health checks
- Domain-specific tables (inventory, trading, marketplace, authentication)
  are introduced in later migrations aligned with feature phases.

This avoids premature schema coupling while preserving full
PostgreSQL + Flyway parity from the first commit.

## Consequences

### Positive

- Eliminates environment-specific behavior and hidden dialect bugs.
- High confidence that migrations, constraints, and queries behave identically in production.
- Tests validate real PostgreSQL behavior rather than mocked or simplified substitutes.
- Schema evolution is explicit, reviewable, and auditable.
- Architecture aligns with enterprise backend standards and interview expectations.

### Trade-offs

- Higher initial setup cost:
  - Docker is required for local testing.
  - macOS users must run Docker via Colima or Docker Desktop.
- Slower test startup compared to in-memory databases.
- Slightly increased CI execution time.

## Rejected Alternatives

### H2 (In-Memory Database)

- Rejected due to SQL dialect differences from PostgreSQL.
- Does not accurately model constraints, indexing behavior, or transaction semantics.
- Frequently causes “passes locally, fails in production” regressions.

### SQLite

- Rejected due to different locking, concurrency, and transaction semantics.
- Different type system and constraint enforcement.
- Not representative of production behavior for an enterprise backend.

## Related ADRs

- ADR-000: Quality Gates and CI Enforcement
- ADR-002: Use Testcontainers for PostgreSQL-backed integration tests
