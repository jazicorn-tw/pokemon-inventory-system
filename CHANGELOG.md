# 📝 **3. CHANGELOG.md (Phased Release Log)**

## Changelog  

All notable changes to this project will be documented in this file.

This project follows **semantic versioning** and uses a **TDD-first roadmap**.

---

## [v0.0.1] — Project Skeleton

- Initial Spring Boot 4 project setup.
- `/ping` endpoint and basic context bootstrap test.
- Testing environment (JUnit, AssertJ, Mockito).

---

## [v0.1.0] — Trainers & Inventory

- Trainer entity, service, repository, and controller.
- Owned Pokémon entity and inventory CRUD operations.
- Validation + global exception handler.
- Comprehensive TDD coverage for service + controller layers.

---

## [v0.2.0] — PokeAPI Integration

- WebClient-based PokeAPI client.
- Species validation when adding Pokémon.
- Expanded DTO models for external API data.

---

## [v0.3.0] — Trading System

### Added

- Trade entity, service, controller.
- Pending/Completed/Rejected/Cancelled trade flow.
- Ownership swapping logic.
- Full TDD suite for trade lifecycle.

---

## [v0.4.0] — Marketplace Listings

- SaleListing entity, service, controller.
- Buying/selling Pokémon logic.
- Validation tests for seller/buyer scenarios.
- Swagger/UI documentation (SpringDoc).

---

## [v0.5.0] — Integration Tests

- Testcontainers support with PostgreSQL.
- Full E2E tests (trainer → pokemon → trade → listing → buy flow).

---

## [v0.6.0] — Security Foundation

- Spring Security scaffolding.
- JWT dependency setup.
- Security config allowing all endpoints (pre-JWT stage).

---

## [v0.7.0] — Authentication / JWT


- UserAccount entity + repository.
- `/auth/register` + `/auth/login` endpoints.
- JWT token provider + filter.
- Endpoint protection + integration tests.

---

## [v0.8.0] — Developer Experience & Polish

- MapStruct mappers.
- Flyway migrations.
- JSON logging (Logback).
- DevTools for hot reload.
- Dependency cleanup + config refactor.

---

## Future Releases

- v0.9.0: Advanced auditing (trade history)
- v1.0.0: Production launch
- v1.1.0: GraphQL API
- v2.0.0: Multi-region marketplace
