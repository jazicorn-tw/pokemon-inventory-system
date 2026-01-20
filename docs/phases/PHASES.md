<!-- markdownlint-disable-file MD024 -->
# 📦 Delivery Phases & Roadmap

## 🎒 Pokémon Trainer Inventory Service

_A Spring Boot 4 backend for managing trainers, Pokémon inventories, trades, and a marketplace — built with strict Test‑Driven Development (TDD)._

This document is the **authoritative delivery contract** for the system.
Each phase is completed **only** when its release criteria are met.

For design rationale and trade‑offs, see **./ARCHITECTURE.md**.

---

## 📘 Overview

The **Pokémon Trainer Inventory Service** is a Spring Boot 4 backend that lets trainers:

* Register and manage trainer profiles
* Add Pokémon to their inventory (validated via PokeAPI)
* Trade Pokémon with other trainers
* List Pokémon for sale and buy from other trainers
* Authenticate with JWT

The project is built using **TDD (Test-Driven Development)** at all phases.
Each version introduces new functionality only after writing failing tests first.

---

## 🧩 Tech Stack

| Area          | Technology                                                         |
| ------------- | ------------------------------------------------------------------ |
| Language      | Java 21                                                            |
| Framework     | Spring Boot 4.0.x                                                  |
| Database      | PostgreSQL (local/dev/prod), Testcontainers (tests)                |
| HTTP Client   | WebClient (Spring WebFlux)                                         |
| Auth          | Spring Security + JWT (JJWT)                                       |
| Testing       | JUnit 5, AssertJ, Mockito, Spring Test, Testcontainers             |
| Documentation | SpringDoc OpenAPI (Swagger)                                        |
| Mapping       | MapStruct                                                          |

---

## 🧪 Test-Driven Development Workflow

Every feature in this project follows:

1. **Write failing tests** (unit or controller tests)
2. **Implement the minimal passing code**
3. **Refactor with confidence**

No feature is added without tests.

---

## 🧪 Global TDD Rules

* Every feature starts with failing tests
* Minimal implementation to pass tests
* Refactors only happen with green tests
* No phase is complete without release criteria

---

## 🔰 Phase 0 — Project Skeleton (v0.0.1)

> ⚠️ Phase 0 tests require Docker (or Colima on macOS) due to Testcontainers usage.

* See [`PHASE_0.md`](PHASE_0.md) for full details.

### Purpose

Establish a runnable, testable Spring Boot service with production-aware scaffolding and infrastructure parity.

### Phase-Gate ADRs

The following architectural decisions must be **accepted and committed** before Phase 0 is considered complete:

* **ADR-001** — PostgreSQL baseline (no H2)
* **ADR-002** — Flyway for schema migrations
* **ADR-003** — Testcontainers for integration testing
* **ADR-004** — Actuator health endpoints + Docker healthchecks
* **ADR-005** — Security phased approach (dependencies first, enforcement later)

### TDD Steps

* Create context-load test (validates Spring + DB + Flyway wiring)
* Add `GET /ping` endpoint test (`pong`)
* Verify Actuator health endpoint (`/actuator/health`)
* Add Dockerfile and Docker Compose healthchecks

## 📦 Dependencies (Phase 0)

Baseline:

* Spring Boot Web
* Spring Boot Data JPA
* Validation
* Actuator
* PostgreSQL driver
* Flyway
* Spring Boot Test
* Testcontainers (PostgreSQL + JUnit Jupiter)

### Release Criteria

* Docker/Colima running locally
* Application boots locally
* `./gradlew test` passes (Testcontainers PostgreSQL)
* `/ping` returns `"pong"`
* `/actuator/health` reports `UP`
* Docker healthcheck passes

---

## 🐣 Phase 1 — Trainers & Pokémon Inventory (v0.1.0)

### Purpose

Introduce the core domain: trainers and owned Pokémon.

### TDD Steps

* Write service tests for `TrainerService`
* Implement `Trainer` domain entity
* Write controller tests for `POST /api/trainers`
* Add `OwnedPokemon` entity tests
* Validate trainer existence when adding Pokémon
* Write controller tests for `/api/pokemon` endpoints

### Resulting Features

* Create trainer
* Add, remove, list Pokémon
* Validation & structured error responses

### Release Criteria

* Trainers can be created and retrieved
* Pokémon ownership enforced
* Invalid trainer references rejected

---

## 🧬 Phase 2 — PokeAPI Species Validation (v0.2.0)

### Purpose

Ensure Pokémon species are valid before adding to inventory.

### TDD Steps

* Mock `PokeApiClient` responses
* Write failing tests for invalid species
* Implement WebClient‑based PokeAPI client
* Add DTO mapping tests

> WebClient is used in a **blocking** manner (`.block()`).
> Full reactive architecture is intentionally deferred.

### New Dependency

* `spring-boot-starter-webflux`

### Release Criteria

* Invalid species cannot be added
* External API failures handled gracefully
* PokeAPI fully mocked in tests

---

## ⚔️ Phase 3 — Trading System (v0.3.0)

### Purpose

Enable Pokémon trades between trainers.

### TDD Steps

* Write tests for trade creation
  * Ownership validation
  * Pokémon list validation
* Write failing tests for accepting trades
  * Atomic ownership swap
* Write tests for rejecting and canceling trades
* Add controller tests for `/api/trades`

### Resulting Features

* Trade proposals
* Accept, reject, cancel trade
* Ownership swaps

### Release Criteria

* Only owners can trade Pokémon
* Accepting a trade swaps ownership atomically
* Invalid trades rejected

---

## 💰 Phase 4 — Marketplace / Sale Listings (v0.4.0)

### Purpose

Allow trainers to buy and sell Pokémon.

### TDD Steps

* Write failing tests for creating listings
* Write failing tests for buying Pokémon
* Write failing tests for canceling listings
* Implement marketplace service & controller

### New Dependency

* SpringDoc OpenAPI

### Endpoints

* `POST /api/listings`
* `GET /api/listings`
* `POST /api/listings/{id}/buy`
* `POST /api/listings/{id}/cancel`

### Release Criteria

* Pokémon can be listed for sale
* Listings cannot be double‑purchased
* Ownership transferred correctly
* Swagger UI available

---

## 🧪 Phase 5 — Integration Testing & Testcontainers (v0.5.0)

### Purpose

Validate real‑world behavior using PostgreSQL.

### TDD Steps

* Add full‑flow integration tests:
  * Trade lifecycle
  * Marketplace purchase lifecycle
* Replace H2 with PostgreSQL Testcontainers
* Apply Flyway migrations in tests

### New Dependencies

* `org.testcontainers:junit-jupiter`
* `org.testcontainers:postgresql`
* `org.postgresql:postgresql`

### Release Criteria

* No H2 usage in integration tests
* Migrations apply cleanly
* Full flows pass against real DB

---

## 🔐 Phase 6 — Security Skeleton (v0.6.0)

### Purpose

Introduce security infrastructure without enforcement.

### TDD Steps

* Write tests confirming all routes are accessible
* Add `SecurityConfig` permitting all requests
* Add JWT dependencies

### New Dependencies

* `spring-boot-starter-security`
* `jjwt-*`
* `spring-security-test`

### Release Criteria

* No endpoint regressions
* Security infrastructure present but inactive

---

## 🛡 Phase 7 — JWT Authentication (v0.7.0)

### Purpose

Enforce authentication and authorization.

### TDD Steps

* Write tests for:
  * `/auth/register`
  * `/auth/login`
  * 401 on protected routes without token
  * Valid JWT access
* Implement:
  * User account entity
  * JWT service
  * Security filter chain
  * Password encoding

### Release Criteria

* Unauthorized requests return 401
* Valid JWT grants access
* Passwords stored securely

---

## 🌱 Phase 8 — Developer Experience & Refactor (v0.8.0)

### Purpose

Improve maintainability and developer experience.

### TDD Steps

* Refactor mapping to MapStruct
* Add Swagger UI
* Optional Flyway hardening

### New Dependencies

* Spring Boot DevTools
* MapStruct
* SpringDoc OpenAPI UI

### Release Criteria

* No behavior changes
* All tests remain green
* Documentation complete

---

## 📦 Installation

```bash
git clone https://github.com/yourname/inventory-service
cd inventory-service
./gradlew bootRun
```

Swagger UI (from Phase 4+):

```bash
http://localhost:8080/swagger-ui.html
```

---

## 🧪 Running Tests

```bash
./gradlew test
```

Integration tests (Phase 5+) require Docker.

---

## ⚙️ Operational Readiness

* Actuator liveness & readiness
* Docker‑friendly healthchecks
* Kubernetes‑compatible design

---

## 🗺 Beyond v0.8.0

* v0.9.0 — Audit & history
* v1.0.0 — Stable public API
* v1.1.0 — GraphQL
* v1.2.0 — Docker + Kubernetes
* v2.0.0 — Multi‑region marketplace
