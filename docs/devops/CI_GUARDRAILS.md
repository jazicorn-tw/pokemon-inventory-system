# CI Guardrails

CI is the **final authority** for correctness.

---

## Enforced rules

### Environment variables

Only Spring-standard datasource variables are allowed:

- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`

---

### Profiles

- `local` → dev
- `test` → CI
- `prod` → production

---

### Tests

CI runs:

```bash
./gradlew clean test
```

IDE-only passing tests are considered broken.

---

## Philosophy

Fail fast. Fix the code. Never weaken CI.
