# macOS: Colima Setup (Recommended)

Colima is the recommended Docker runtime for macOS when using Testcontainers.

Docker **must be reachable** through Colima for integration tests to work.

---

## 1. Start Colima and verify Docker

```bash
colima start
docker context use colima
docker ps
```

If `docker ps` fails, Docker/Testcontainers will fail.

---

## 2. Verify you are using Colima

```bash
docker context show
echo $DOCKER_HOST
```

- If `DOCKER_HOST` is set, it can override the active Docker context.
- This is a common cause of Testcontainers failures on macOS.

---

## 3. Fix: `DOCKER_HOST` overrides context

For the current terminal session:

```bash
unset DOCKER_HOST
docker context use colima
docker ps
```

Permanent fix (recommended):

```bash
grep -n DOCKER_HOST ~/.zshrc ~/.zprofile ~/.bashrc 2>/dev/null
```

Remove or comment out any `export DOCKER_HOST=...` lines, then restart your terminal.

---

## 4. Verify Colima socket exists

```bash
ls -la $HOME/.colima/default/docker.sock
```

The socket must exist and be readable by your user.

If the socket is missing:

```bash
colima stop
colima start
```

---

## 5. Force Testcontainers to use Colima’s socket (recommended)

Create or edit `~/.testcontainers.properties`:

```properties
docker.host=unix:///Users/<YOUR_USER>/.colima/default/docker.sock
```

This ensures Testcontainers uses the same socket as the Docker CLI.

---

## 6. Colima troubleshooting commands

Check Colima status:

```bash
colima status
```

Restart Colima:

```bash
colima stop
colima start
```

Reset Colima (last resort — deletes Colima VM data):

```bash
colima delete
colima start
```

---

## 8. Optional: `/var/run/docker.sock` compatibility symlink

Some tools expect Docker at `/var/run/docker.sock`.
Colima uses a user-scoped socket instead.

You can create a compatibility symlink:

```bash
sudo mkdir -p /var/run
sudo ln -sf "$HOME/.colima/default/docker.sock" /var/run/docker.sock
ls -l /var/run/docker.sock
```

---

## 9. Golden rules for Colima + Testcontainers

- ❌ If `docker ps` fails, Testcontainers will fail
- ❌ Do not mix Docker Desktop and Colima contexts
- ❌ Avoid `DOCKER_HOST` unless you know why it’s set
- ✅ Always verify Docker works before debugging Spring or Testcontainers
