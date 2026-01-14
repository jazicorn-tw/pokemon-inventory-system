# Docker Errors

Docker must be reachable for **Testcontainers** to work.
If Docker is unavailable or misconfigured, all integration tests will fail.

## 1. Docker not found

**Error example:**

```bash
Could not find a valid Docker environment
```

**Cause:**

- Docker is not installed
- Docker daemon is not running
- Colima is not running (macOS)

**Fix:**

```bash
colima start
docker ps
```

If `docker ps` fails, Docker is not usable.

## 2. `docker ps` fails

**Symptoms:**

- `Cannot connect to the Docker daemon`
- `Error during connect`
- `permission denied`

**Cause:**

- Docker daemon is not running
- Wrong Docker context
- Invalid socket configuration

**Fix:**

```bash
docker context show
docker context ls
```

On macOS with Colima:

```bash
colima start
docker context use colima
docker ps
```

## 3. Wrong Docker context

**Symptoms:**

- Docker installed but commands fail
- Docker Desktop context selected while Colima is running (or vice versa)

**Fix:**

```bash
docker context use colima
docker context show
```

## 4. `DOCKER_HOST` overrides context

**Symptoms:**

```bash
DOCKER_HOST environment variable overrides the active context
```

**Cause:**

- `DOCKER_HOST` exported in shell configuration

**Fix (current session):**

```bash
unset DOCKER_HOST
docker context use colima
docker ps
```

**Permanent fix:**

```bash
grep -n DOCKER_HOST ~/.zshrc ~/.zprofile ~/.bashrc 2>/dev/null
```

Remove or comment out any `export DOCKER_HOST=...` lines.

## 5. Docker socket permission errors

**Symptoms:**

- `permission denied while connecting to docker.sock`
- Testcontainers fails even though `docker ps` works with sudo

**Cause:**

- Incorrect socket permissions
- Non-standard Docker socket path

**Fix:**
Use Colima’s socket via Testcontainers config:

```properties
docker.host=unix:///Users/<YOUR_USER>/.colima/default/docker.sock
```

Verify socket exists:

```bash
ls -la $HOME/.colima/default/docker.sock
```

## 6. Docker works, but Testcontainers cannot find it

**Symptoms:**

- `docker ps` works
- Testcontainers reports no Docker environment

**Cause:**

- Testcontainers using a different socket than Docker CLI
- `DOCKER_HOST` mismatch
- Missing `~/.testcontainers.properties`

**Fix:**
Align Docker + Testcontainers socket:

```properties
docker.host=unix:///Users/<YOUR_USER>/.colima/default/docker.sock
```

## 7. `/var/run/docker.sock` missing

**Symptoms:**

- Tools expect `/var/run/docker.sock`
- Colima uses a user-scoped socket

**Fix (optional compatibility workaround):**

```bash
sudo mkdir -p /var/run
sudo ln -sf "$HOME/.colima/default/docker.sock" /var/run/docker.sock
```

## 8. Apple Silicon (arm64) issues

**Symptoms:**

- Images fail immediately
- Platform / exec format errors

**Fix:**

- Prefer official multi-arch images
- Avoid custom images without arm64 support

## 9. Docker in CI

**Notes:**

- CI runners must support Docker
- Do not assume Docker-in-Docker unless explicitly configured
- See `CI-POSTGRESQL.md` for CI-specific guidance

## 10. Golden rules for Docker in tests

- ❌ If `docker ps` fails, Testcontainers will fail
- ❌ Do not mix Docker Desktop and Colima contexts
- ❌ Avoid `DOCKER_HOST` unless you know why you need it
- ✅ Always verify Docker before debugging Spring/Testcontainers
