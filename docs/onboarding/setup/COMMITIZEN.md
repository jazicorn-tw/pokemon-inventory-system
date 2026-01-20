# 🧾 Commit Messages & Commitizen

This project enforces **Conventional Commits** to ensure:

- predictable versioning
- meaningful changelogs
- clean CI and release automation

Commit message validation is enforced **locally** via a `commit-msg` hook and **authoritatively** via CI.

---

## ✨ What this gives us

- Consistent, machine-readable commit history
- Automatic semantic version bumps
- Auto-generated `CHANGELOG.md`
- Clear intent for refactors, breaking changes, and features

---

## 🧠 The rules (Conventional Commits)

All commit messages must follow this format:

```text
<type>(optional scope): <description>
```

### Common types

| Type        | Purpose                             |
|-------------| ----------------------------------- |
| `feat`      | New feature (minor version bump)    |
| `fix`       | Bug fix (patch bump)                |
| `refactor`  | Code change with no behavior change |
| `test`      | Tests only                          |
| `docs`      | Documentation only                  |
| `chore`     | Tooling, config, housekeeping       |
| `build`     | Build system or dependency changes  |
| `ci`        | CI configuration changes            |

### Breaking changes (pre-1.0)

For this project (currently `0.x`):

```text
feat!: change API contract
```

Breaking changes **do not** bump to `1.0.0` until we explicitly decide the API is stable.

---

## 🛠️ Commitizen (`cz`)

This repo uses **Commitizen** to:

- validate commit messages
- calculate semantic versions
- generate `CHANGELOG.md`
- create version tags

### Interactive commits (recommended)

Instead of writing commit messages manually, run:

```bash
cz commit
```

---

## 🔍 commit-msg hook (local enforcement)

We use a **repo-managed Git hook** at:

```text
.githooks/commit-msg
```

Git is configured with:

```bash
git config core.hooksPath .githooks
```

### What the hook does

- Runs on **every commit**
- Validates the commit message using:

  ```bash
  cz check --commit-msg-file <file>
  ```

- Rejects invalid commit messages immediately

---

## 🏷️ Versioning & changelog

When you’re ready to cut a release:

```bash
cz bump
```

---

## 📌 Notes for contributors

- You do **not** need Python to build the project
- Commitizen is only required for committing
- Install Commitizen via:

  ```bash
  pipx install commitizen
  ```
