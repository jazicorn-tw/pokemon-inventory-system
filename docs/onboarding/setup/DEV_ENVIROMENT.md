# 🛠️ Development Environment

This document describes the **expected local development environment** for this repository.

Keeping environments aligned prevents "works on my machine" failures.

---

## ✅ Required Software

### Core

- **Java 21**
- **Docker**
  - Docker Desktop **or**
  - Colima (recommended on macOS)
- **Git**
- **GNU Make**

Verify:

```bash
java --version
docker --version
git --version
make --version
```

---

## 🐳 Docker / Colima

### macOS (Recommended)

```bash
brew install colima docker
colima start
```

Verify:

```bash
docker ps
```

> Docker must be running **before tests start**.

---

## 🧪 Testing Stack Expectations

This project uses:

- PostgreSQL via **Testcontainers**
- Flyway migrations
- JUnit 5

**No in-memory database is supported.**

All tests must pass with:

```bash
./gradlew clean check
```

---

## 🧹 Local Quality Gates

Enforced via **pre-commit hook**:

- Spotless formatting
- Static analysis (PMD, Checkstyle, SpotBugs)
- Optional unit tests

Installed with:

```bash
make bootstrap
```

Bypassing hooks is possible but discouraged.

---

## 📁 Environment Variables

Copy the example file:

```bash
cp .env.example .env
```

Values are primarily for:

- Local runs
- Docker Compose (if used later)

Secrets should **never** be committed.

---

## ⚙️ Gradle Notes

- Wrapper-based (`./gradlew`)
- Configuration cache may be suggested — optional
- No global Gradle install required

---

## 🧠 Mental Model

- Local == CI == Production (as much as possible)
- Fail fast > fail late
- Automation over tribal knowledge

If setup feels strict, that’s intentional.

---

## 📚 Related Docs

- `docs/onboarding/README.md`
- `docs/onboarding/files/PRECOMMIT.md`
- `docs/adr/ADR-000-quality-gates.md`
- `docs/adr/ADR-002-testcontainers.md`
