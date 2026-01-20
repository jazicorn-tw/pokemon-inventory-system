# ADR-005: Phase security implementation (dependencies first, enforcement later)

- Date: 2026-01-17
- Status: Accepted

## Context

- Early development phases focus on domain modeling and correctness.
- Full security enforcement from day one can:
  - Slow iteration
  - Obscure domain-level failures
  - Increase cognitive load during TDD setup
- Security remains a **non-negotiable production requirement**.
- The project roadmap includes explicit security milestones.

## Decision

- Add Spring Security and JWT dependencies early as a **skeleton configuration**.
- Keep all endpoints open during early phases.
- Enforce JWT-based authentication and authorization starting in **Phase 7**.
- Clearly document the security posture in the README to avoid confusion.

## Consequences

### Positive

- Faster early development and clearer domain validation.
- Avoids security configuration masking domain errors.
- Maintains realistic production intent without premature enforcement.

### Trade-offs

- Requires discipline to enable enforcement at the planned phase.
- Temporary unsecured endpoints must be clearly documented.

## Rejected Alternatives

### Full Security Enforcement from Day One

- Rejected due to unnecessary complexity during early phases.
- Slows feedback loops and obscures core domain issues.

### No Security Until “Later”

- Rejected to avoid unrealistic architecture.
- Dependencies and structure are required early to prevent refactors.

## Related ADRs

- ADR-003: Expose health endpoints (security impacts actuator exposure)
