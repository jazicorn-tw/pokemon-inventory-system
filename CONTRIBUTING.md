# Contributing

Thank you for your interest in contributing! 🤝
We welcome thoughtful, well-tested contributions that improve the quality, clarity, and reliability of the system.

This project is built around **Test-Driven Development (TDD)**, strong testing discipline, and a clean, modular **Spring Boot** architecture. To keep quality high and avoid regressions, please follow the guidelines below.

---

## 🧪 Development Workflow (TDD Required)

All development **must** follow a **red → green → refactor** loop.

### 1. Write a failing test (RED)

Choose the appropriate test type for the layer you are modifying:

* **Service layer** → unit tests (Mockito)
* **Controller layer** → `@WebMvcTest` + MockMvc
* **Integration layer** → Testcontainers (PostgreSQL)

> If you are unsure which layer applies, default to the *lowest* level possible.

---

### 2. Write the minimal implementation (GREEN)

* Implement only what is required to satisfy the test
* No speculative features
* No premature abstractions

---

### 3. Refactor safely (REFACTOR)

* Improve readability and naming
* Reduce duplication
* Enforce **SRP** (Single Responsibility Principle)
* Keep all tests passing at all times

---

### 4. Commit with a meaningful message

Use clear, scoped, and intention-revealing commit messages.

**Examples:**

* `feat(trade): add trade acceptance logic and tests`
* `fix(pokemon): correct PokeAPI validation error handling`
* `test(market): add listing cancellation coverage`

---

## 🧩 Code Style Guidelines

* Follow Java and Spring Boot best practices
* Prefer **small, focused methods**
* Use meaningful class, method, and variable names
* Prefer **constructor injection**
* Avoid static mutable state
* Use DTOs at API boundaries
* Keep controllers thin (no business logic)

---

## 🛡️ Local Quality Gates (ADR-000)

This repository enforces **local quality gates** using a Git `pre-commit` hook.

Before code leaves your machine, the hook may:

* auto-format code (Spotless)
* run static analysis
* optionally run unit tests

To install hooks and run checks locally:

```bash
make bootstrap
```

See `docs/onboarding/PRECOMMIT.md` for details and override options.

---

## 🏗 Architecture Principles

The codebase follows a **layered architecture** with clear boundaries:

* `controller` → HTTP request/response handling only
* `service` → business logic and orchestration
* `repository` → persistence (Spring Data JPA)
* `client` → external integrations (e.g. PokeAPI)
* `config` → cross-cutting Spring configuration

Violations of these boundaries require justification and, if significant, an ADR.

---

## 🌱 Branching Strategy

This repository uses a **promotion-based branching model** with clear stability guarantees per branch:

* `main` → **production-ready** releases only
* `staging` → **release-candidate validation** (CI, migrations, integration parity)
* `dev` → active development and feature integration
* `feature/*` → one feature or change per branch
* `hotfix/*` → urgent production fixes (merged back into `staging` and `main`)

### Promotion Flow

```text
feature/* → dev → staging → main
```

* No direct commits to `main` or `staging`
* All merges require passing CI and required reviews
* `staging` represents the closest approximation to production behavior

---

## 🧪 Testing Requirements

Every pull request **must include appropriate tests**.

| Layer       | Test Type                                           |
| ----------- | --------------------------------------------------- |
| Services    | Unit tests (Mockito)                                |
| Controllers | `@WebMvcTest`                                       |
| Integration | Testcontainers (PostgreSQL)                         |
| Security    | `spring-security-test` (`@WithMockUser`, JWT tests) |

PRs that reduce coverage or omit tests **will not be merged**.

---

## 🚦 Quality Gates (ADR-000)

This project treats **linting, static analysis, and CI enforcement** as a
**foundational architectural decision**.

Before opening a PR:

* Run `./gradlew clean check`
* Address all linting and static analysis findings
* Do **not** disable or bypass checks without an approved ADR

See:

* `docs/adr/ADR-000-linting.md`
* `docs/onboarding/LINTING.md`

---

## 📝 Pull Request Checklist

Before opening a PR, ensure:

* [ ] Tests added and passing
* [ ] No failing integration tests
* [ ] Code is formatted
* [ ] Feature documented (README or CHANGELOG if applicable)
* [ ] No commented-out or dead code
* [ ] No new Testcontainers strategy introduced

---

## ⚙ Local Development Requirements

### Prerequisites

* Java 21
* Docker
* macOS users: **Colima**

Verify your environment:

```bash
java -version
docker ps
```

---

## ▶ Running Tests Locally

```bash
colima start
docker context use colima
./gradlew test
```

If tests fail, consult **`docs/TESTING.md`** before opening an issue.

---

## 🚫 Testcontainers Rules (Important)

This project uses **classic Testcontainers** only.

✅ Allowed:

* `@Testcontainers`
* static `@Container`
* `@DynamicPropertySource`

🚫 Not allowed:

* `@ServiceConnection`
* Mixing multiple Testcontainers strategies

Violating these rules can cause subtle startup and CI failures.

---

## 🧪 Integration Test Base Class

All integration tests **must** extend the shared base class:

```java
class ExampleIT extends BaseIntegrationTest {}
```

This ensures consistent container lifecycle management and configuration across all environments.

---

## 💬 Need Help?

Open an issue with:

* A clear description of the problem or idea
* What problem it solves
* Any proposed approach or constraints

We welcome discussion, questions, and high-quality contributions 🚀
