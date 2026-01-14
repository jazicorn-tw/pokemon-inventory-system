<!-- markdownlint-disable MD036 -->
# Testcontainers Troubleshooting

This doc covers **Testcontainers-specific** failures (not general Docker/Colima setup).
If you’re failing to reach Docker at all, see `docs/TESTING.md` (Docker/Colima section).

## 1. Docker not reachable (Testcontainers can’t find Docker)

**Symptoms**

- `Could not find a valid Docker environment`
- `NoSuchFileException (/var/run/docker.sock)`
- `permission denied` while connecting to docker socket

**Fix**

- Ensure Docker is running (or Colima on macOS)
- Ensure you’re using the correct Docker context
- Unset conflicting env vars:

```bash
unset DOCKER_HOST
docker context show
docker ps
```

---

## 2. Mixed Testcontainers strategies (classic + @ServiceConnection)

**Symptom**

```bash
Mapped port can only be obtained after the container is started
```

**Cause**
Mixing:

- **Classic Testcontainers**: `@Testcontainers` + static `@Container` + `@DynamicPropertySource`
with:
- **Spring Boot service connections**: `@ServiceConnection`

This can cause Spring to resolve datasource properties **before** the container lifecycle starts.

**Fix**

- Remove `@ServiceConnection`
- Use **only** classic Testcontainers:
  - static `@Container`
  - `@DynamicPropertySource` using suppliers (lazy)
- Do not import test configs that register a `@Bean @ServiceConnection`

✅ Good:

```java
registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
```

❌ Bad (eager call):

```java
registry.add("spring.datasource.url", POSTGRES.getJdbcUrl());
```

---

## 3. Image pull / registry failures

**Symptoms**

- `pull access denied`
- `manifest unknown`
- `toomanyrequests` (Docker Hub rate limit)
- DNS/network errors during pull

**Fix**

- Verify the image exists and can be pulled:

```bash
docker pull postgres:16-alpine
```

- If rate limited:

```bash
docker login
```

- If behind VPN/corporate proxy, toggle and retry.

---

## 4. Ryuk failures / blocked reaper

Ryuk is the Testcontainers “reaper” container used for cleanup.

**Symptoms**

- `Ryuk container failed to start`
- `Could not connect to Ryuk`
- hangs before any container starts

**Fix**

- Verify Docker health:

```bash
docker run --rm hello-world
```

- See `RYUK.md` for step-by-step troubleshooting and the last-resort disable flag.

---

## 5. Container startup timeout / wait strategy failures

**Symptoms**

- `ContainerLaunchException`
- `Wait strategy failed`
- `Timed out waiting for container port to open`

**Common causes**

- CI runner is slow / resource constrained
- Image is large or pulls slowly
- Host is under load

**Fix**

- Reduce parallel integration tests
- Avoid heavy tasks running in parallel with tests
- Re-run once to rule out transient pulls
- (Last resort) increase startup timeouts in Testcontainers or your test framework

## 6. Unexpected reuse / stale state

**Symptoms**

- Flaky tests due to leftover schema/data
- Containers appear to persist between runs
- Cleanup seems inconsistent

**Common causes**

- Reuse enabled (`testcontainers.reuse.enable=true`)
- Orphaned containers/volumes due to blocked Ryuk or interrupted runs

**Fix**

- Prefer reuse **disabled** unless you explicitly need it
- Clean up:

```bash
docker ps
docker rm -f <container_id>
docker system prune
```

## 7. Wrong host/port assumptions

**Symptoms**

- App connects to `localhost:5432`
- Container is running but app cannot connect

**Cause**

- Hardcoded datasource URL/credentials overriding Testcontainers

**Fix**

- Do not set these in `application-test.properties` when using `@DynamicPropertySource`:
  - `spring.datasource.url`
  - `spring.datasource.username`
  - `spring.datasource.password`

- Always use:

```java
registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
```

## 8. Platform/architecture image issues (Apple silicon / arm64)

**Symptoms**

- Image fails immediately
- “exec format” / platform mismatch style errors

**Fix**

- Prefer multi-arch official images (e.g., official `postgres`)
- Avoid custom images without arm64 support

## 9. Quick debug bundle (paste when asking for help)

Run:

```bash
docker ps
docker context show
echo $DOCKER_HOST
./gradlew test --stacktrace --info
```

Paste:

- The first `Caused by:` block
- ~20 lines above it
