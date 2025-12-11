# Phases

Below is a tailored to the phased development plan.
It documents the project *and* serves as a roadmap for contributors, including how TDD drives each version.

This is ready to drop into your repository as `README.md`.

---

## 🎒 Pokémon Trainer Inventory Service

*A Spring Boot API for managing trainers, their Pokémon, trades, and marketplace listings — built with Test-Driven Development.*

---

## 📘 Overview

The **Pokémon Trainer Inventory Service** is a Spring Boot 4 backend that lets trainers:

* Register and manage trainer profiles
* Add Pokémon to their inventory (validated via PokeAPI)
* Trade Pokémon with other trainers
* List Pokémon for sale and buy from other trainers
* Authenticate with JWT (later phase)

The project is built using **TDD (Test-Driven Development)** at all phases.
Each version introduces new functionality only after writing failing tests first.

---

## 🧩 Tech Stack

| Area          | Technology                                             |
| ------------- | ------------------------------------------------------ |
| Language      | Java 21 (or 17)                                        |
| Framework     | Spring Boot 4.0                                        |
| Database      | H2 (dev), PostgreSQL (prod/testcontainers)             |
| HTTP Client   | WebClient (Spring WebFlux)                             |
| Auth          | Spring Security + JWT (JJWT)                           |
| Testing       | JUnit 5, AssertJ, Mockito, Spring Test, Testcontainers |
| Documentation | SpringDoc OpenAPI (Swagger)                            |
| Mapping       | MapStruct                                              |

---

## 🧪 Test-Driven Development Workflow

Every feature in this project follows:

1. **Write failing tests** (unit or controller tests)
2. **Implement the minimal passing code**
3. **Refactor with confidence**

No feature is added without tests.

---

## 🗂 Version Roadmap (TDD Phases)

This roadmap defines the evolution of the system.
Each phase produces a tagged release (e.g., `v0.1.0`, `v0.2.0`, etc.).

---

## 🔰 Phase 0 — Project Skeleton (v0.0.1)

### **Purpose**

Set up the Spring Boot application & testing environment before any domain logic.

### **TDD Steps**

* Create context-load test (`InventoryServiceApplicationTests`)
* Add `GET /ping` endpoint with a test that expects `"pong"`
* Implement minimal controller to satisfy test

### **Dependencies**

* Spring Boot Web
* Spring Boot Data JPA
* Validation
* H2 DB
* Spring Boot Test
* AssertJ
* Mockito

---

## 🐣 Phase 1 — Trainers & Pokémon Inventory (v0.1.0)

### **Purpose**

Enable trainers to register accounts and store Pokémon in their inventory.

### **TDD Steps**

* Write service tests for `TrainerService`
* Implement trainer domain
* Write controller tests for `POST /api/trainers`
* Add `OwnedPokemon` tests
* Validate trainer existence when adding Pokémon
* Write controller tests for `/api/pokemon` endpoints

### **Resulting Features**

* Create trainer
* Add/Delete/Get Pokémon
* List trainer Pokémon
* Validation & error responses

---

## 🧬 Phase 2 — PokeAPI Species Validation (v0.2.0)

### **Purpose**

Verify Pokémon species using [https://pokeapi.co/api/v2](https://pokeapi.co/api/v2) before adding to trainer inventory.

### **TDD Steps**

* Mock `PokeApiClient` responses
* Write failing tests ensuring a Pokémon cannot be added if species doesn’t exist
* Implement WebClient-based API client
* Add DTO mapping tests

### **New Dependency**

* `spring-boot-starter-webflux` for WebClient

### **Result**

Adding Pokémon now requires valid PokeAPI species.

---

## ⚔️ Phase 3 — Trading System (v0.3.0)

### **Purpose**

Enable Pokémon trades between trainers.

### **TDD Steps**

* Write tests for creating trades

  * Ownership validation
  * Pokémon lists
* Write failing tests for accepting a trade

  * Ownership swaps correctly
* Write tests for rejecting/canceling trades
* Add controller tests for `/api/trades`

### **Result**

* Create trade proposals
* Accept trade (swap ownership)
* Reject trade
* Cancel trade

---

## 💰 Phase 4 — Marketplace / Sale Listings (v0.4.0)

### **Purpose**

Trainers can list Pokémon for sale and buy listed Pokémon.

### **TDD Steps**

* Write failing tests for creating a listing
* Write failing tests for buying Pokémon
* Write failing tests for canceling a listing
* Implement marketplace service & controller

### **Add Dependency**

* SpringDoc OpenAPI for API docs

### **Endpoints**

* `POST /api/listings`
* `GET /api/listings`
* `POST /api/listings/{id}/buy`
* `POST /api/listings/{id}/cancel`

---

## 🧪 Phase 5 — Integration Testing & Testcontainers (v0.5.0)

### **Purpose**

Ensure real-world behavior using PostgreSQL in Docker.

### **TDD Steps**

* Add integration tests for:

  * Full trade flow
  * Listing / buying flow
* Replace H2 with Testcontainers Postgres in tests

### **New Dependencies**

```groovy
testImplementation 'org.testcontainers:junit-jupiter'
testImplementation 'org.testcontainers:postgresql'
runtimeOnly 'org.postgresql:postgresql'
```

---

## 🔐 Phase 6 — Security Skeleton (v0.6.0)

### **Purpose**

Introduce Spring Security & JWT libraries without enforcing authentication yet.

### **TDD Steps**

* Write tests confirming all routes are still accessible without auth
* Add `SecurityConfig` allowing all requests
* Add JWT dependencies

### **New Dependencies**

* `spring-boot-starter-security`
* `jjwt-api`, `jjwt-impl`, `jjwt-jackson`
* `spring-security-test` (test support)

### **Result**

Security infrastructure exists but does nothing yet.

---

## 🛡 Phase 7 — Real JWT Authentication (v0.7.0)

### **Purpose**

Lock down API and require token-based authentication.

### **TDD Steps**

* Write tests for:

  * `/auth/register`
  * `/auth/login`
  * Protected endpoints returning 401 without token
  * Valid JWT allows access
* Implement:

  * `UserAccount` entity
  * JWT service
  * Auth controller
  * Security filter chain
  * Password encoding

---

## 🌱 Phase 8 — Developer Experience + Refactor (v0.8.0)

### **Purpose**

Clean code, improve mapping, add API documentation.

### **TDD Steps**

* Ensure all test coverage remains green during refactor
* Replace manual DTO mapping with MapStruct
* Add Swagger UI
* Optional: Add Flyway migrations

### **New Dependencies**

```groovy
developmentOnly 'org.springframework.boot:spring-boot-devtools'
implementation 'org.mapstruct:mapstruct'
annotationProcessor 'org.mapstruct:mapstruct-processor'
implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui'
```

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

## 🗺 Future Roadmap Beyond v0.8.0

* v0.9.0 — Trading history/audit
* v1.0.0 — Stable public release
* v1.1.0 — GraphQL endpoints
* v1.2.0 — Docker + K8s deployment
* v2.0.0 — Multi-region trading marketplace

---

## 🎉 Contribute

This project is built intentionally for practicing:

* Clean architecture
* Test-driven development
* Spring Boot microservices
* Integration with external APIs
* JWT-based authentication

Pull requests are welcome!

---
