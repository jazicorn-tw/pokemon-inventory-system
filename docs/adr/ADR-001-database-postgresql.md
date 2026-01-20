# ADR-001: Use PostgreSQL across local, test, CI, and production

- Date: 2026-01-17
- Status: Accepted

## Context

- The project prioritizes **production parity** and **enterprise realism**.
- In-memory databases (e.g., H2) hide real-world issues:
  - SQL dialect differences
  - JSON / array types
  - Constraint enforcement
  - Index behavior and query planning
- Schema evolution is managed via **Flyway**, which must behave identically in all environments.
- The cost of discovering database issues late (CI or production) is higher than slower local setup.

## Decision

- **PostgreSQL is the only supported database engine** across all environments.
- **Local development**
  - Uses PostgreSQL via Docker / Docker Compose (recommended) or a native Postgres installation.
- **Automated tests**
  - Use PostgreSQL exclusively via **Testcontainers**.
  - Embedded or in-memory databases are not permitted.
- **CI**
  - Uses PostgreSQL via Testcontainers or a CI service container.
- **Schema management**
  - All schema changes are applied via **Flyway migrations**.
  - Hibernate DDL auto-generation is disabled beyond validation.

## Consequences

### Positive

- Eliminates environment-specific behavior and hidden dialect bugs.
- High confidence that migrations, constraints, and queries behave identically in production.
- Tests validate real PostgreSQL behavior (types, constraints, performance characteristics).
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
- Does not accurately model JSON types, indexing, or constraint behavior.
- Frequently causes “passes locally, fails in production” regressions.

### SQLite

- Rejected due to different locking, concurrency, and transaction semantics.
- Different type system and constraint enforcement than PostgreSQL.
- Not representative of production behavior for an enterprise backend.

## Related ADRs

- ADR-002: Use Testcontainers for PostgreSQL-backed integration tests
