# 🎒 Pokémon Trainer Inventory Service

_A Spring Boot 4 API for trainers to manage their Pokémon, trade with others, and participate in a marketplace — powered by PokeAPI and built with Test‑Driven Development (TDD)._

![Java](https://img.shields.io/badge/java-21-blue)
![Spring Boot](https://img.shields.io/badge/spring--boot-4.x-brightgreen)
![Docker](https://img.shields.io/badge/docker-ready-blue)
[![CI](https://github.com/jazicorn-tw/pokemon-inventory-system/actions/workflows/ci.yml/badge.svg)](https://github.com/jazicorn-tw/pokemon-inventory-system/actions/workflows/ci.yml)
[![Build Image](https://github.com/jazicorn-tw/pokemon-inventory-system/actions/workflows/build-image.yml/badge.svg)](https://github.com/jazicorn-tw/pokemon-inventory-system/actions/workflows/build-image.yml)

---

## 🚀 Overview

The **Pokémon Trainer Inventory Service** is a backend REST API that allows trainers to:

- Register trainer profiles  
- Add Pokémon to their inventory  
- Validate Pokémon species via **PokeAPI**  
- Trade Pokémon with other trainers  
- List Pokémon for sale  
- Buy Pokémon from other trainers  

The project follows **strict Test‑Driven Development (TDD)** and enforces
**foundational quality gates** to maintain production realism from the start.

---

## 🧩 Tech Stack (High Level)

- **Java 21**
- **Spring Boot 4**
- **PostgreSQL**
- **JPA / Hibernate**
- **Spring Security + JWT (phased)**
- **Testcontainers**
- **Flyway**
- **SpringDoc OpenAPI**
- **MapStruct**

> Detailed dependency rationale lives in **ARCHITECTURE.md**.

---

## 🧭 Feature Roadmap

| Phase | Focus |
| ----- | ------ |
| 0 | Project skeleton, `/ping`, test harness |
| 1 | Trainers & inventory |
| 2 | PokeAPI integration |
| 3 | Trades |
| 4 | Marketplace |
| 5 | Integration tests |
| 6 | Security skeleton |
| 7 | JWT authentication |
| 8 | Developer experience improvements |

---

## 🩺 Health & Observability

| Endpoint | Purpose |
| -------- | -------- |
| `/ping` | Bootstrap check |
| `/actuator/health` | Overall health |
| `/actuator/health/liveness` | Liveness |
| `/actuator/health/readiness` | Readiness |

---

## ⚙️ Configuration

Profiles:

- `local`
- `test`
- `prod`

Local `.env` loading is supported:

```properties
spring.config.import=optional:file:.env[.properties]
```

OS / CI environment variables always take precedence.

---

## 🧪 Running Tests

```bash
./gradlew test
```

Integration tests:

```bash
./gradlew test --tests "*IT"
```

---

## 🚦 Quality Gates

This project enforces **foundational quality gates** before feature development.

All changes are expected to pass:

```bash
./gradlew clean check
```

This includes:

- Automated tests
- Linting and static analysis
- CI enforcement

Quality gates are treated as an **architectural decision** and are captured in
**ADR-000** (linting & static analysis as a first-class concern).

See:

- `docs/adr/ADR-000-linting.md`
- `docs/onboarding/LINTING.md`

---

## 🐳 Docker

```bash
./gradlew bootBuildImage
```

---

## 🧠 Architecture & Design

For system design, trade-offs, and rationale, see:

👉 **ARCHITECTURE.md**  
👉 **docs/adr/** (Architecture Decision Records, including ADR-000)

---

## 🤝 Contributing

Before opening a pull request, please read **CONTRIBUTING.md**.

Contributors are expected to:

- Respect **ADR-000** (quality gates come first)
- Keep PRs phase-scoped and reviewable
- Update or add ADRs when decisions change architecture or quality policy
