# 🔰 Phase 0 — Project Skeleton PR

> Phase 0 establishes the **foundation** of the project.
> No domain behavior is introduced in this phase.

---

## Summary

-

---

## Quality Gates (ADR-000) — Required

> ADR-000 defines linting, static analysis, and CI enforcement as
> the **first architectural decision**.

- [ ] `./gradlew clean check` passes locally
- [ ] No linting rules disabled or bypassed
- [ ] Static analysis reports reviewed (no unexpected violations)
- [ ] CI quality gate passes

---

## Evidence (required)

- [ ] `./gradlew test` passes (Docker / Colima running)
- [ ] `curl -i http://localhost:8080/ping` returns `pong`
- [ ] `curl -i http://localhost:8080/actuator/health` reports `UP`
- [ ] Dockerfile healthcheck passes (if present)
- [ ] Docker Compose healthcheck passes (if present)

---

## Phase 0 Rules (keep it clean)

- [ ] **No domain logic added**
  - No entities, aggregates, or services beyond scaffolding
- [ ] No persistence domain tables beyond minimal Flyway baseline (if any)
- [ ] `/ping` remains a minimal controller (no auth or business logic)
- [ ] Testcontainers remains the source of truth for test databases
- [ ] Flyway is enabled and validates cleanly at startup
- [ ] No security enforcement (dependencies only)

---

## 🏛 Phase-gate ADRs (must be accepted)

- [ ] ADR-000 — Linting & static analysis as a foundational decision
- [ ] ADR-001 — PostgreSQL baseline (no H2)
- [ ] ADR-002 — Flyway for schema migrations
- [ ] ADR-003 — Testcontainers for integration testing
- [ ] ADR-004 — Actuator health endpoints + Docker healthchecks
- [ ] ADR-005 — Phase security implementation (deps first, enforcement later)

---

### ADRs referenced / modified (if any)

- ADR-___
- ADR-___

---

## Files / areas touched

-

---

## Notes for reviewers

- Confirm **no domain behavior** was introduced
- Confirm quality gates are enforced and passing
- Confirm this PR leaves the project in a clean, extensible state
