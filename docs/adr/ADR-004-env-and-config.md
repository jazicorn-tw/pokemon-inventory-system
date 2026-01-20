# ADR-004: Support .env for local dev without overriding CI/prod

- Date: 2026-01-17
- Status: Accepted

## Context

- Developers need a simple and predictable way to configure local environments.
- Spring Boot does not load `.env` files by default.
- CI and production environments rely on OS-level environment variables.
- Configuration precedence must be explicit to prevent accidental overrides.

## Decision

- Support optional local `.env` loading via:
  `spring.config.import=optional:file:.env[.properties]`
- Treat OS-level and CI-provided environment variables as the **source of truth**
  in non-local environments.
- `.env` is strictly a local development convenience.

## Consequences

### Positive

- Simplifies local onboarding and setup.
- Avoids shell-level tooling (e.g., `direnv`) for most use cases.
- Maintains predictable and safe configuration precedence.

### Trade-offs

- Requires developers to understand Spring property precedence.
- `.env` files must be excluded from version control.

## Rejected Alternatives

### `direnv` / Shell Injection

- Rejected due to shell pollution and onboarding complexity.
- Makes configuration harder to reason about across machines.

### Committed `.env` Files

- Rejected to avoid leaking secrets.
- Risks accidental overrides of CI or production configuration.

## Related ADRs

- ADR-001: Use PostgreSQL across all environments (configuration consistency)
- ADR-002: Use Testcontainers for integration tests
