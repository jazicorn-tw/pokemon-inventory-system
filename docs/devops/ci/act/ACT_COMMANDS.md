<!-- markdownlint-disable-file MD036 -->

# 🧪 act Commands (repo cheat sheet)

This repo wraps `act` behind Make targets to keep local runs consistent.

---

## List jobs in a workflow

```bash
make list-ci              # defaults to ci
make list-ci ci
make list-ci build-image
```

---

## Run an entire workflow

```bash
make run-ci               # defaults to ci
make run-ci ci
make run-ci build-image
```

---

## Run a single job in a workflow

```bash
make run-ci ci test
make run-ci build-image helm-lint
```

---

## Raw act (if you need it)

Equivalent of `make run-ci ci test`:

```bash
ACT=true act push   -W .github/workflows/ci.yml   -j test   -P ubuntu-latest=catthehacker/ubuntu:full-latest   --container-daemon-socket /var/run/docker.sock   --container-architecture linux/amd64   --container-options="--user 0:0"
```

---

## Notes

- `--container-options="--user 0:0"` prevents Docker socket permission errors in the runner.
- Some workflows (release/publish) are intentionally not run locally.
