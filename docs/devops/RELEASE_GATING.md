<!-- markdownlint-disable-file MD036 -->
<!-- markdownlint-disable-file MD060 -->

# 🚦 Release Gating & Local Simulation

This document explains **how release and publish workflows are intentionally gated**
and how to **safely simulate them locally** using `act`.

This repository treats **releases as privileged operations**.
Nothing is released by accident.

---

## 🧠 Design principles

- Releases must be **explicitly enabled**
- Local behavior must **match GitHub Actions**
- Guardrails should fail **closed by default**
- Local overrides must be **obvious and reversible**

---

## 🔐 Release gates (high level)

The release workflow is protected by **two layers**:

1. **Release execution gate**
2. **Artifact publishing gate**

Both must pass for anything to be published.

---

## 1️⃣ Release execution gate

The `release` job only runs when **one** of the following is true:

```yaml
inputs.enable_release == 'true'
OR
vars.ENABLE_SEMANTIC_RELEASE == 'true'
```

### In GitHub Actions

- `ENABLE_SEMANTIC_RELEASE` is defined as a **repository variable**
- Default: `false` (release disabled)

### Locally with `act`

`act` does **not** know about GitHub repo variables.

To simulate them locally, you must provide a `.vars` file.

---

## 2️⃣ Artifact publishing gate

Publishing (Docker image, Helm chart, etc.) is further gated by:

```yaml
github.repository == vars.CANONICAL_REPOSITORY
AND
needs.release.outputs.published_version != ''
```

This ensures:

- Forks can never publish artifacts
- Nothing publishes if no version was released

---

## 🧪 Local setup with `act`

### Step 1: Create `.vars` (local only)

```bash
cp .vars.example .vars
```

⚠️ `.vars` **must be gitignored**.

```gitignore
.vars
```

### Step 2: Run the release workflow locally

```bash
act push -W .github/workflows/release.yml
```

If gates pass, the `release` job will execute exactly as in CI.

---

## 🧯 Safety notes

- `.vars` contains **non-secret values only**
- Secrets still come from `.secrets` or the environment
- CI remains the **authoritative execution environment**
- Local release simulation should be used for:
  - validating workflow logic
  - previewing semantic-release behavior
  - debugging gating conditions

---

## ✅ Expected behavior matrix

| Scenario | Release | Publish |
|--------|--------|---------|
| No `.vars`, local act | ❌ | ❌ |
| `.vars` with ENABLE_SEMANTIC_RELEASE | ✅ | ❌ |
| Canonical repo + published version | ✅ | ✅ |
| Forked repo | ✅ | ❌ |
| GitHub repo vars disabled | ❌ | ❌ |

---

## 🧭 Related docs

- `docs/devops/CI_FEATURE_FLAGS.md`
- `docs/adr/ADR-008-ci-managed-releases.md`
- `.github/workflows/release.yml`

---

> If a release happens, it was intentional.
