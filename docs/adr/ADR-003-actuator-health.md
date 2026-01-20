# ADR-003: Expose health endpoints with Spring Boot Actuator

- Date: 2026-01-17
- Status: Accepted

## Context

- Production services require **operability**, not just correctness.
- Platforms such as Docker and Kubernetes rely on health signals for:
  - Container restarts
  - Rollout safety
  - Traffic routing
- A simple `/ping` endpoint is useful for early development and TDD scaffolding,
  but does not provide meaningful insight into application health.
- The project aims to reflect **real production service behavior**, even in early phases.

## Decision

- Use **Spring Boot Actuator** to expose health endpoints.
- Enable `/actuator/health` with **liveness** and **readiness** groups.
- Retain `/ping` as a lightweight bootstrap endpoint during Phase 0 only.
- Health endpoints are explicitly configured and intentionally exposed.

## Consequences

### Positive

- Enables container and platform-level automation.
- Provides clear signals for application health vs application availability.
- Aligns with production observability expectations.

### Trade-offs

- Requires explicit configuration of endpoint exposure.
- Introduces additional surface area that must be secured in later phases.

## Rejected Alternatives

### `/ping` Only

- Rejected because it only proves the app is running, not healthy.
- Does not support readiness/liveness semantics required by orchestration platforms.

### Custom Health Endpoints

- Rejected in favor of standardized Actuator support.
- Would duplicate existing, well-tested framework functionality.

## Related ADRs

- ADR-005: Phase security implementation (health endpoint exposure depends on security phase)
