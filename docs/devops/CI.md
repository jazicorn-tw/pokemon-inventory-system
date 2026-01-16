# CI Guide

This guide covers running tests in CI environments such as **GitHub Actions**.

---

## Requirements

- Linux runner with Docker enabled
- Java 21
- No Colima (macOS-only)
- No `DOCKER_HOST` overrides

---

## Common CI Failures

### Docker unavailable

```bash
Could not find a valid Docker environment
```

Fix:

- Use `ubuntu-latest`
- Ensure Docker is enabled on the runner

---

### Ryuk blocked

```bash
Ryuk container failed to start
```

Fix (last resort):

```yaml
env:
  TESTCONTAINERS_RYUK_DISABLED: true
```

---

## Example GitHub Actions Workflow

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 21
      - run: ./gradlew test
```
