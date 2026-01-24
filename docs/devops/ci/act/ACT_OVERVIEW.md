<!-- markdownlint-disable-file MD036 -->

# 🧪 act — What it is and how we use it

`act` lets you run **GitHub Actions workflows locally** by spinning up a Docker container that simulates a GitHub runner.

In this repo, `act` is used for:

- Debugging workflow logic quickly
- Reproducing CI failures locally
- Validating workflow changes before pushing

---

## ✅ Prerequisites

- Docker daemon running (macOS: Colima or Docker Desktop)
- The standard Docker socket available at `/var/run/docker.sock`

On macOS + Colima, we recommend a symlink:

```bash
sudo ln -sf "$HOME/.colima/default/docker.sock" /var/run/docker.sock
```

---

## 🔥 The repo-standard way to run act

We wrap `act` with Make targets:

```bash
make run-ci                 # defaults to ci workflow
make run-ci ci              # run .github/workflows/ci.yml
make run-ci ci test         # run only the 'test' job
make list-ci build-image    # list jobs in build-image.yml
```

The wrapper exists because:

- It pins the runner image mapping for `ubuntu-latest`
- It forces the container architecture to `linux/amd64`
- It runs the runner as root to allow Docker socket access

---

## ⚠️ What act does NOT replicate perfectly

`act` is excellent for logic and most shell steps, but some things are different:

- Toolcache behavior (e.g., hosted tool installs) may differ
- Secrets are not available unless you provide them explicitly
- Some GitHub runner filesystem permissions differ

In this repo, we guard a few steps using `env.ACT` to keep local runs stable.

---

## Secrets and releases

Workflows that require GitHub App tokens or production secrets (e.g., release/publish) are **not** typically run locally.

Use `make run-ci` (CI-focused workflows) for local simulation.
