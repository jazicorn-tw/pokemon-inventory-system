<!-- markdownlint-disable-file MD036 -->
<!-- markdownlint-disable-file MD060 -->

# 🔧 `.vars` — Repository Variables

This document explains the purpose and usage of the `.vars` file in this repository.

---

## 📄 What is `.vars`?

`.vars` is a **local configuration file** used to define **non-secret, repository-scoped variables**
that influence CI/CD behavior, release gates, and feature toggles.

It is designed to mirror **GitHub Repository Variables** (`Settings → Variables`) so that:

- Local runs behave like CI
- Feature flags are explicit and documented
- No secrets are stored in source control

---

## 🧭 Design Principles

- **Non-secret only** (booleans, names, toggles)
- **Explicit defaults**
- **CI-parity** with GitHub Actions `vars.*`
- Safe to commit **only as `.vars.example`**

---

## 📂 Files

| File | Purpose |
|----|----|
| `.vars.example` | Template documenting all supported variables |
| `.vars` | Local developer override (gitignored) |

---

## 🧪 How it’s used

The Makefile and CI scripts load `.vars` to simulate GitHub Actions behavior locally.

Example:

```bash
ENABLE_SEMANTIC_RELEASE=false
PUBLISH_DOCKER_IMAGE=true
```

In GitHub Actions, these map to:

```yaml
vars.ENABLE_SEMANTIC_RELEASE
vars.PUBLISH_DOCKER_IMAGE
```

---

## 🔀 Common Variables

| Variable | Type | Description |
|------|------|------------|
| `ENABLE_SEMANTIC_RELEASE` | boolean | Gate semantic-release execution |
| `PUBLISH_DOCKER_IMAGE` | boolean | Allow Docker image publishing |
| `CANONICAL_REPOSITORY` | string | Repo allowed to publish artifacts |
| `PUBLISH_HELM_CHART` | boolean | (Future) Helm publishing |
| `DEPLOY_ENABLED` | boolean | (Future) Global deploy kill-switch |

---

## ⚠️ Important Notes

- `.vars` **must not contain secrets**
- Secrets belong in `.secrets` / GitHub Secrets
- CI remains authoritative — `.vars` is for **local parity only**

---

## ✅ Recommended Workflow

```bash
cp .vars.example .vars
$EDITOR .vars
make run-ci
```

This ensures your local checks behave exactly like GitHub Actions.
