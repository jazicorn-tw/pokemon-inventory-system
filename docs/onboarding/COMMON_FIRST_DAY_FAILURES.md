<!-- markdownlint-disable-file MD036 -->

# 🚨 Common First-Day Failures

This document lists **frequent issues new contributors hit on day one**, why they happen, and how to fix them quickly.

The goal is fast unblocking — not blame.

---

## ❌ Docker / Testcontainers Not Running

**Symptom**

- Tests hang or fail immediately
- Errors mentioning `Mapped port can only be obtained after the container is started`
- PostgreSQL connection failures during tests

**Cause**

- Docker (or Colima) is not running
- Testcontainers cannot start PostgreSQL

**Fix**

```bash
colima start
# or ensure Docker Desktop is running
```

Verify:

```bash
docker ps
```

---

## ❌ Pre-commit Hook Fails Immediately

**Symptom**

- `git commit` fails before opening the editor
- Messages mentioning Spotless, PMD, or Checkstyle

**Cause**

- This repo enforces **local quality gates** by design

**Fix**

- Read `docs/onboarding/PRECOMMIT.md`
- Re-run commit after fixing issues

**One-time bypass (not recommended):**

```bash
SKIP_QUALITY=1 git commit -m "message"
```

---

## ❌ Spotless Reformats Files and Aborts Commit

**Symptom**

- Commit stops after formatting
- Message says files were modified

**Cause**

- Spotless auto-formats code and requires re-staging

**Fix**

```bash
git status
git add .
git commit
```

---

## ❌ Tests Expect PostgreSQL (Not H2)

**Symptom**

- Assumptions about in-memory databases
- Confusion about why PostgreSQL is required locally

**Cause**

- This project enforces **production parity**

**Fix**

- Ensure Docker is running
- Do not attempt to switch tests to H2

See:

- `docs/adr/ADR-001-database-postgresql.md`
- `docs/adr/ADR-002-testcontainers.md`

---

## ❌ CI Passes but Local Fails (or Vice Versa)

**Symptom**

- Works on GitHub Actions but not locally
- Or works locally but fails CI

**Cause**

- Local environment drift
- Docker not running
- Skipped hooks locally

**Fix**

```bash
make bootstrap
make quality
```

Local and CI use the **same commands** by contract.

---

## ❌ Permission Denied on Scripts

**Symptom**

```bash
Permission denied: ./scripts/install-hooks.sh
```

**Fix**

```bash
chmod +x scripts/*.sh
```

---

## ✅ If You're Still Stuck

1. Re-run:

   ```bash
   make bootstrap
   ```

2. Check logs carefully (first error matters most)
3. Ask for help — include:
   - Full error output
   - OS
   - Docker/Colima status

---

> **Design note:** These failures are intentional guardrails. If day-one setup feels strict, it’s because production is stricter.
