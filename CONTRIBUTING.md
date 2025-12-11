# 🤝 **4. CONTRIBUTING.md (TDD Workflow + Standards)**

## Contributing Guidelines

Thank you for your interest in contributing!

This project is built around **Test-Driven Development (TDD)** and a clean modular architecture.
To keep quality high, contributors must follow the guidelines below.

---

## 🧪 Development Workflow (TDD Required)

### 1. Write a failing test

- Unit tests for services  
- Controller tests using MockMvc  
- Integration tests using Testcontainers  

### 2. Write the minimal implementation

- No extra logic  
- Just enough to satisfy the test  

### 3. Refactor the implementation

- Clean up code  
- Improve readability  
- Keep tests green  

### 4. Commit with a meaningful message

**Example:**

***feat(trade)***: add trade acceptance logic and tests

***fix(pokemon)***: correct PokeAPI validation error handling

***test(market)***: add listing cancellation tests

---

## 🧩 Code Style

- Follow Java & Spring Boot best practices  
- Avoid long methods (SRP)  
- Use meaningful class and method names  
- Prefer constructor injection  
- Avoid static state  
- Use DTOs for API boundaries  

---

## 🛠 Architecture Principles

- `controller` → thin, request/response  
- `service` → business logic  
- `repository` → persistence  
- `client` → external API (PokeAPI)  
- `config` → cross-cutting Spring configuration  

---

## 📦 Branching Strategy

- `main`: stable releases  
- `develop`: active development  
- `feature/*`: one feature per branch  
- `hotfix/*`: urgent fixes  

---

## 🧪 Testing Requirements

Every PR **must include tests**.

| Layer | Test Type |
|-------|------------|
| Services | Unit tests (Mockito) |
| Controllers | WebMvcTest |
| Integration | Testcontainers (Postgres) |
| Security | spring-security-test (`@WithMockUser`, JWT tests) |

---

## 📝 Pull Request Checklist

- [ ] Tests added and passing  
- [ ] No failing integration tests  
- [ ] Code formatted  
- [ ] Feature documented in README or CHANGELOG  
- [ ] No commented-out code  

---

## 💬 Need help?

Open an issue with:

- Description of your idea  
- The problem it solves  
- Proposed changes  

We welcome discussion and collaboration!
