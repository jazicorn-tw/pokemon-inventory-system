# Ryuk Errors (Testcontainers Reaper)

Ryuk is a small helper container started by **Testcontainers** to automatically clean up
containers, networks, and volumes after tests finish.

In most environments, Ryuk runs silently in the background.
When it fails, **all Testcontainers-based tests may fail or hang**.

---

## Common Ryuk error messages

You may see errors such as:

- `Ryuk container failed to start`
- `Could not connect to Ryuk`
- `Timed out waiting for Ryuk`
- `permission denied while connecting to docker.sock`
- Tests hang indefinitely before any container starts

---

## Common causes

Ryuk failures are almost always **environment-related**, not code-related.

Typical causes include:

- Docker is not healthy or not reachable
- Corporate security software blocks internal container networking
- Firewall rules block localhost container communication
- Docker socket permission issues
- Rootless or non-standard Docker setups (including some enterprise configurations)
- macOS setups where Docker context or socket is misconfigured (e.g. Colima + DOCKER_HOST)

---

## Step-by-step fixes

### 1. Verify Docker itself works

```bash
docker ps
docker run --rm hello-world
```

If either command fails, **Ryuk cannot work**, and Testcontainers will fail.
Fix Docker or Colima first before continuing.

---

### 2. Verify Colima’s Docker socket (macOS)

```bash
ls -la $HOME/.colima/default/docker.sock
```

The socket must exist and be readable by your user.

If the socket is missing, restart Colima:

```bash
colima stop
colima start
```

---

### 3. Ensure Testcontainers is using the correct socket

Check your Testcontainers configuration:

```bash
cat ~/.testcontainers.properties
```

Expected content:

```properties
docker.host=unix:///Users/<YOUR_USER>/.colima/default/docker.sock
```

If this file is missing, create it to force Testcontainers to use Colima’s socket.

---

### 4. Last resort: disable Ryuk

WARNING: Only disable Ryuk if your environment blocks it and you understand the tradeoff.

```bash
TESTCONTAINERS_RYUK_DISABLED=true ./gradlew test
```

Disabling Ryuk means Testcontainers **cannot automatically clean up**
containers, networks, and volumes.

⚠️ Disabling Ryuk may leave orphaned containers.

You must clean up manually from time to time:

```bash
docker system prune
```

---

## When Ryuk issues are most common

Ryuk failures are frequently reported on:

- macOS + Colima
- Corporate-managed laptops
- Locked-down Docker installations
- Environments with aggressive endpoint security software
