<!-- markdownlint-disable-file MD036 -->
<!-- markdownlint-disable-file MD024 -->

# 🧼 Local hygiene (disk cleanup)

This repo includes **safe-by-default** cleanup helpers to prevent local `act` runs
(and Docker/Colima workloads) from failing due to disk pressure.

These helpers are designed to be:

- ✅ **Discoverable** via `make help` (targets include `##` descriptions)
- ✅ **Safe by default** (destructive actions are gated behind explicit flags)
- ✅ **Script-backed** (complex logic lives in `scripts/`)

---

## 📌 Quick start

### 1) Show what you have

```bash
make clean-local-info
```

This prints a quick snapshot of:

- act Gradle cache
- docker disk usage
- colima status

### 2) Clean act caches (safe-by-default)

```bash
make clean-act
```

- Always emits a warning if `.gradle-act` is large
- Only deletes when explicitly enabled (or auto mode triggers)

---

## 🧪 act hygiene

### Targets

- `make act-gradle-cache-info` — show cache path + size
- `make act-gradle-cache-warn` — warn if cache exceeds threshold
- `make act-gradle-cache-remove` — remove cache (gated)
- `make clean-act` — warn + optional remove

### Knobs

```text
ACT_GRADLE_CACHE_REMOVE=false|true|auto   # default is repo-defined (see make/53-act-clean.mk)
ACT_GRADLE_CACHE_PATH=.gradle-act
ACT_GRADLE_CACHE_DRY_RUN=false|true
ACT_GRADLE_CACHE_WARN_GB=8
ACT_COLIMA_DISK_MIN_FREE_GB=6
ACT_COLIMA_PROFILE=default
ACT_COLIMA_MIN_FREE_INODES=5000          # auto-mode inode threshold (containerd fs)
```

### Examples

Always remove cache:

```bash
make clean-act ACT_GRADLE_CACHE_REMOVE=true
```

Auto mode (remove only when Colima containerd filesystem is low):

```bash
make clean-act ACT_GRADLE_CACHE_REMOVE=auto
```

Dry run (no deletion):

```bash
make clean-act ACT_GRADLE_CACHE_REMOVE=true ACT_GRADLE_CACHE_DRY_RUN=true
```

---

## 🐳 Docker hygiene

### Targets

- `make docker-cache-info` — show docker context + disk usage
- `make clean-docker` — prune docker caches (gated)

### Knobs

```text
CLEAN_DOCKER_PRUNE=false|true
CLEAN_DOCKER_VOLUMES=false|true
CLEAN_DOCKER_VERBOSE=false|true
```

### Examples

Prune caches (images/containers/networks/build cache):

```bash
make clean-docker CLEAN_DOCKER_PRUNE=true
```

Prune caches + volumes:

```bash
make clean-docker CLEAN_DOCKER_PRUNE=true CLEAN_DOCKER_VOLUMES=true
```

Verbose before/after summary:

```bash
make clean-docker CLEAN_DOCKER_PRUNE=true CLEAN_DOCKER_VERBOSE=true
```

> ⚠️ `CLEAN_DOCKER_VOLUMES=true` can delete data volumes you expected to keep.

---

## 🧊 Colima hygiene

### Targets

- `make colima-info` — show Colima status
- `make clean-colima` — reset Colima VM (gated)

### Knobs

```text
CLEAN_COLIMA_RESET=false|true
CLEAN_COLIMA_DISK_GB=80
CLEAN_COLIMA_PROFILE=default
CLEAN_COLIMA_ASSUME_YES=false|true
```

### Example (reset Colima VM)

```bash
make clean-colima CLEAN_COLIMA_RESET=true
```

Increase disk size after reset:

```bash
make clean-colima CLEAN_COLIMA_RESET=true CLEAN_COLIMA_DISK_GB=120
```

> ⚠️ Resetting Colima deletes images/containers inside the VM.

---

## 🧼 One-button local cleanup

### Targets

- `make clean-local-info` — quick snapshot (act + docker + colima)
- `make clean-local` — run act clean + docker clean (Colima reset is separate)

### Knobs

`clean-local` respects the same knobs as the underlying components:

- act knobs (`ACT_GRADLE_CACHE_*`)
- docker knobs (`CLEAN_DOCKER_*`)
- colima knobs (`CLEAN_COLIMA_*`)

### Examples

Clean act + docker (non-destructive default gates stay off):

```bash
make clean-local
```

Clean act + prune docker caches:

```bash
make clean-local CLEAN_DOCKER_PRUNE=true
```

Clean act + prune docker caches + reset Colima:

```bash
make clean-local CLEAN_DOCKER_MODE=true
```

---

## 🗂️ Where the logic lives

- act cache: `scripts/act/gradle-cache.sh`
- docker cache: `scripts/docker/docker-cache.sh`
- colima reset: `scripts/colima/colima-clean.sh`
- orchestrator: `scripts/local/clean-local.sh`

---

## ✅ Recommendation

If `act` fails with:

```text
no space left on device
... /var/lib/containerd/ ...
```

run:

```bash
make clean-local CLEAN_DOCKER_PRUNE=true CLEAN_DOCKER_VERBOSE=true
```

If it still fails, consider a one-time Colima reset (explicit, nuclear):

```bash
make clean-local CLEAN_DOCKER_MODE=true
```
