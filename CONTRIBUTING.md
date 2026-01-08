# Contributing

Thank you for your interest in contributing! 🤝

This project is built around **Test-Driven Development (TDD)**, strong testing discipline, and a clean modular Spring Boot architecture. To keep quality high and avoid regressions, please follow the guidelines below.

---

## 🧪 Development Workflow (TDD Required)

All development must follow a **red → green → refactor** loop.

### 1. Write a failing test (RED)

Depending on the layer you’re working on:

- **Service layer**: unit tests (Mockito)
- **Controller layer**: `@WebMvcTest` / MockMvc
- **Integration layer**: Testcontainers (PostgreSQL)

### 2. Write the minimal implementation (GREEN)

- No extra logic
- No speculative features
- Just enough code to make the test pass

### 3. Refactor safely (REFACTOR)

- Improve readability
- Reduce duplication
- Enforce SRP (Single Responsibility Principle)
- Keep all tests green

### 4. Commit with a meaningful message

Use clear, scoped commit messages.

**Examples:**

- `feat(trade): add trade acceptance logic and tests`
- `fix(pokemon): correct PokeAPI validation error handling`
- `test(market): add listing cancellation tests`

---

## 🧩 Code Style Guidelines

- Follow Java & Spring Boot best practices
- Avoid long methods (prefer small, focused methods)
- Use meaningful class, method, and variable names
- Prefer constructor injection
- Avoid static mutable state
- Use DTOs at API boundaries
- Keep controllers thin

---

## 🏗 Architecture Principles

The codebase follows a layered architecture:

- `controller` → request/response handling only
- `service` → business logic
- `repository` → persistence (JPA)
- `client` → external APIs (e.g. PokeAPI)
- `config` → cross-cutting Spring configuration

---

## 🌱 Branching Strategy

- `main` → stable releases
- `develop` → active development
- `feature/*` → one feature per branch
- `hotfix/*` → urgent production fixes

---

## 🧪 Testing Requirements

Every pull request **must include tests**.

| Layer | Test Type |
| ------ | ----------- |
| Services | Unit tests (Mockito) |
| Controllers | `@WebMvcTest` |
| Integration | Testcontainers (PostgreSQL) |
| Security | `spring-security-test` (`@WithMockUser`, JWT tests) |

PRs without appropriate tests will not be merged.

---

## 📝 Pull Request Checklist

Before opening a PR, ensure:

- [ ] Tests added and passing
- [ ] No failing integration tests
- [ ] Code is formatted
- [ ] Feature documented (README or CHANGELOG if applicable)
- [ ] No commented-out code
- [ ] No new Testcontainers strategy introduced

---

## ⚙ Local Development Requirements

### Prerequisites

- Java 21
- Docker
- macOS users: **Colima**

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

Allowed:

- `@Testcontainers`
- static `@Container`
- `@DynamicPropertySource`

Not allowed:

- `@ServiceConnection`
- Mixing multiple Testcontainers strategies

Violating this rule can cause subtle startup failures.

---

## 🧪 Integration Test Base Class

All integration tests **must** extend the shared base class:

```java
class ExampleIT extends BaseIntegrationTest {}
```

This ensures consistent container lifecycle and configuration.

---

## 💬 Need Help?

Open an issue with:

- A clear description of the problem or idea
- What problem it solves
- Any proposed approach or constraints

We welcome discussion, questions, and thoughtful contributions 🚀
