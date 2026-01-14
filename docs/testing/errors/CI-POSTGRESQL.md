# CI PostgreSQL Notes (Testcontainers)

This project uses **Testcontainers** to start PostgreSQL for integration tests.
In CI, most failures are caused by Docker availability, resource limits, or image pull issues.

---

## Recommended CI approach

✅ Use **Linux runners** with Docker available (e.g. GitHub Actions `ubuntu-latest`) and run tests normally:

```bash
./gradlew test
```

Avoid mixing CI service containers (like `services: postgres`) with Testcontainers unless you intentionally switch strategies.

---

## Common CI failure modes

### 1. Docker not available (most common)

**Symptom:**

- `Could not find a valid Docker environment`
- `NoSuchFileException (/var/run/docker.sock)`

**Fix:**

- Ensure the job runs on Linux (`ubuntu-latest`)
- Do not run the build inside a container unless you mount the Docker socket

---

### 2. Docker-in-Docker / containerized CI jobs

If you run Gradle inside a container, Testcontainers still needs Docker.

**Options:**

- Mount the socket: `/var/run/docker.sock`
- Use Docker-in-Docker (DinD) with privileged mode (more complex)

**Symptom:**

- Docker works on host but not inside the job container

---

### 3. Image pulls fail / rate limiting

**Symptoms:**

- `pull access denied`
- `manifest unknown`
- slow pulls / flaky network

**Fix:**

- Confirm image exists: `postgres:16-alpine`
- Consider authenticating to Docker Hub in CI if rate-limited
- If your org uses a registry mirror, use it

---

### 4. Resource constraints / slow startup

CI runners may be slower than local machines.
Postgres startup can take longer, causing flaky timeouts.

**Fixes:**

- Reduce parallel integration tests
- Avoid running heavy tasks in parallel with integration tests
- If needed, increase startup timeouts (last resort)

---

### 5. Hardcoded host/port assumptions

CI will reveal problems like connecting to `localhost:5432`.

**Fix:**

- Never hardcode `spring.datasource.url` in `application-test.properties`
- Always rely on Testcontainers dynamic properties:

  ```java
  registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
  ```

---

### 6. Ryuk differences in CI

Some CI environments restrict Ryuk.

**Preferred:** keep Ryuk enabled.

**Fallback (last resort):**

```bash
TESTCONTAINERS_RYUK_DISABLED=true ./gradlew test
```

⚠️ Disabling Ryuk can leave orphaned resources. Clean up periodically on self-hosted runners.

---

## GitHub Actions: Recommended Workflow Snippet

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

      - name: Run tests
        run: ./gradlew cleanTest test --info
```

---

## CI debugging checklist (paste into PR comments/issues)

Run (or capture from CI logs):

```bash
./gradlew test --stacktrace --info
```

Include:

- The first `Caused by:` block
- ~20 lines above it
- Any Testcontainers “Docker environment” logs
