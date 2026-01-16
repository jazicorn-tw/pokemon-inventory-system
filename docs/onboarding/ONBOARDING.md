# Day-1 Onboarding Checklist

This project follows **strict but boring** conventions to ensure
repeatable builds, reliable tests, and production parity.

If you follow this checklist, you will not fight the tooling.

---

## Prerequisites

- Java **21**
- Docker (Docker Desktop or Colima on macOS)
- Git
- No global Gradle install needed

---

## 1. Clone & enter repo

```bash
git clone <repo-url>
cd pokemon-inventory-system
```

---

## 2. Environment setup

```bash
cp .env.example .env
```

Do **not** hardcode secrets in config files.

---

## 3. Start local database

```bash
docker compose up -d postgres
```

---

## 4. Run tests (source of truth)

```bash
./gradlew test
```

If this fails, stop and fix it before continuing.

---

## 5. Run the app (local profile)

```bash
SPRING_PROFILES_ACTIVE=local ./gradlew bootRun
```

- App: <http://localhost:8080>
- Health: <http://localhost:8080/actuator/health>
