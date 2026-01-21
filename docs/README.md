<!-- markdownlint-disable MD033 -->

# 🎒 Pokémon Trainer Platform

<p align="center">
  <em>
    A production-minded Spring Boot 4 REST API demonstrating test-driven backend design, CI-first quality gates, and real-world infrastructure parity
  </em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License: MIT">
  <img src="https://img.shields.io/badge/java-21-blue" alt="Java 21">
  <img src="https://img.shields.io/badge/spring--boot-4.x-brightgreen" alt="Spring Boot 4">
  <img src="https://img.shields.io/badge/database-postgresql-blue" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/docker-ready-blue" alt="Docker">
  <img src="https://img.shields.io/badge/tests-testcontainers-2496ED" alt="Testcontainers">
  <a href="https://github.com/jazicorn-tw/pokemon-inventory-system/actions/workflows/ci.yml"><img src="https://github.com/jazicorn-tw/pokemon-inventory-system/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://github.com/jazicorn-tw/pokemon-inventory-system/actions/workflows/build-image.yml"><img src="https://github.com/jazicorn-tw/pokemon-inventory-system/actions/workflows/build-image.yml/badge.svg" alt="Build Image"></a>
</p>

---

## 🚀 Overview

The **Pokémon Trainer Platform** is a backend API that allows trainers to:

* Manage trainer profiles
* Add and validate Pokémon (via **PokeAPI**)
* Trade Pokémon with other trainers
* Buy and sell Pokémon in a marketplace

---

## 🧭 Developer Experience

This project uses a **doctor-first onboarding workflow** designed for fast feedback,
strong quality gates, and production parity.

New contributors start with:

```bash
make doctor
```

to validate their local environment *before* running Gradle, Docker, or tests.

A single CI-aligned quality gate then enforces formatting, static analysis, and tests.

> **Fail fast locally.  
> Enforce correctness in CI.  
> Document every non-obvious rule with ADRs.**

📄 Start here:

* [`onboarding/DOCTOR.md`](./docs/onboarding/DOCTOR.md)
* [`onboarding/ONBOARDING.md`](./docs/onboarding/ONBOARDING.md)

---

## 🚀 What This Project Demonstrates

This is **not a toy API**.

This project showcases how a backend service can be built **correctly from day one**, with:

* Strict **Test-Driven Development (TDD)**
* **CI parity** enforced locally and remotely
* Real infrastructure (PostgreSQL, Testcontainers)
* Explicit architectural decisions (ADRs)

The domain is playful. The engineering is not.

---

## 🧩 Tech Stack

* **Java 21**
* **Spring Boot 4**
* **PostgreSQL + Flyway**
* **JPA / Hibernate**
* **Spring Security + JWT (phased)**
* **Testcontainers**
* **SpringDoc OpenAPI**
* **MapStruct**

---

## 🧠 Architectural Principles

* **Production parity**  
  Local, CI, and runtime environments behave the same.

* **Single quality gate**  
  If `./gradlew clean check` fails, the change is incorrect.

* **Fail fast, fail explicitly**  
  Infrastructure and environment errors surface early.

* **Decisions are documented**  
  Non-trivial choices are captured as ADRs.

> Architectural trade-offs and decisions are documented in **ARCHITECTURE.md**.

---

## 🗺️ Feature Roadmap (Phased)

| Phase | Focus                                   |
| ----: | --------------------------------------- |
|     0 | Project skeleton, `/ping`, test harness |
|     1 | Trainers & inventory                    |
|     2 | PokeAPI integration                     |
|     3 | Trades                                  |
|     4 | Marketplace                             |
|     5 | Integration hardening                   |
|     6 | Security skeleton                       |
|     7 | JWT authentication                      |
|     8 | Developer-experience improvements       |

> APIs may evolve between phases. Backward compatibility is not guaranteed yet.

---

## 🧪 Testing & Quality Gates

### CI-Equivalent Quality Gate (Authoritative)

```bash
CI=true SPRING_PROFILES_ACTIVE=test ./gradlew clean check
```

This gate includes:

* Unit + integration tests
* Formatting (Spotless)
* Static analysis (Checkstyle, PMD, SpotBugs)
* Build correctness

> If a change does not pass this command, it is **not considered correct**, regardless of feature completeness.

---

### Integration Testing Strategy

* Uses **real PostgreSQL via Testcontainers**
* Containers start eagerly to avoid Spring bootstrap race conditions
* No embedded or in-memory databases are permitted

This ensures failures are **deterministic and production-realistic**.

---

## 🧰 Local Workflow (Optional)

```bash
make test      # fast feedback (tests only)
make test-ci   # CI-equivalent gate
make bootstrap # hooks + full quality gate
```

⚠️ `make test` does **not** catch formatting or static-analysis failures.  
(Assumes `make doctor` already passes.)

---

## 🩺 Health Endpoints

| Endpoint | Purpose |
| ------ | ------- |
| `/ping` | Bootstrap check |
| `/actuator/health` | Overall health |
| `/actuator/health/liveness` | Liveness |
| `/actuator/health/readiness` | Readiness |

---

## 💡 Why This Project Exists

This project exists to demonstrate **production-grade backend engineering**, not just feature delivery.

It prioritizes:

* Test-driven design
* CI as the authority
* Explicit architectural decisions
* Developer ergonomics **without shortcuts**

---

## 🤝 Contributing

Before opening a PR:

* Read **CONTRIBUTING.md**
