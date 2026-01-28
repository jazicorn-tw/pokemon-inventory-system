<!-- markdownlint-disable-file MD036 -->

# Syncing the commit-msg prompt with semantic-release

This repository keeps the **commit-msg guard** in sync with **semantic-release**
by using the *same commit analysis engine*:
`@semantic-release/commit-analyzer`.

The goal is simple:

> If a commit message would trigger a release in CI, you should know **before**
> the commit is created.

---

## What this repo provides

- `scripts/git/semantic-release-impact.mjs`  
  Computes release impact using `@semantic-release/commit-analyzer` and emits:
  - `impact=major|minor|patch|none`
  - `rule_label=default|releaseRules[i]|heuristic`
  - `rule_detail=<human explanation>`

- `scripts/git/confirm-release-commit.sh`  
  A `commit-msg` guard that:
  - Prompts when `impact != none`
  - Explains **why** the commit triggers a release
  - Requires explicit confirmation when configured
  - Degrades safely when tools are unavailable

---

## Install the hook

```bash
git config core.hooksPath .githooks
chmod +x .githooks/commit-msg   scripts/git/confirm-release-commit.sh   scripts/git/semantic-release-impact.mjs
```

> The hook runs locally only. CI remains the source of truth.

---

## Make it fully synced (recommended)

Install the same analyzer semantic-release uses:

```bash
npm i -D semantic-release @semantic-release/commit-analyzer
```

If your semantic-release config lives outside `package.json`
(e.g. `.releaserc`, `release.config.js`), also install:

```bash
npm i -D cosmiconfig
```

Without these dependencies, the hook falls back to a lightweight heuristic.

---

## How config sync works

The Node script loads semantic-release configuration in this order:

1. `package.json` → `"release": { ... }`
2. If `cosmiconfig` is installed:
   - `.releaserc*`
   - `release.config.*`

From there it extracts the options for
`@semantic-release/commit-analyzer`, including any custom
`preset` or `releaseRules`.

This ensures local behavior mirrors CI behavior as closely as possible.

---

## What the prompt shows

When a commit would trigger a release, the prompt includes:

- **Impact icon**
  - 🚨 `major`
  - ⚠️ `minor`
  - ℹ️ `patch`
- **Impact level** (major / minor / patch)
- **Mode**
  - `semantic-release` (fully synced)
  - `heuristic` (fallback)
- **Rule explanation**
  - `default — type=fix -> patch`
  - or `releaseRules[2] — type=feat -> minor`
- **Commit message**
- A clear **confirm / abort** choice

Patch releases use a **collapsed layout** to reduce noise.

---

## Strict confirmation mode (paranoid days)

By default, if the hook cannot prompt (no TTY), it will **warn and proceed**.

To require *explicit confirmation*:

```bash
STRICT_RELEASE_CONFIRM=1 git commit -m "feat: risky change"
```

Behavior in strict mode:

- If a prompt can be shown → ask the user
- If no prompt is possible → **block the commit**

The UI will display a 🔒 **STRICT** badge when enabled.

---

## Local default for strict mode (optional)

You may define a **machine-local default** in `local-settings.json`:

```json
{
  "git": {
    "releaseConfirm": {
      "strictDefault": false
    }
  }
}
```

Rules:

- Environment variables always win  
  (`STRICT_RELEASE_CONFIRM=0/1`)
- If `jq` is not installed, the file is ignored
- Defaults should remain **strict off**

---

## Emergency / recovery bypass

For exceptional situations only:

```bash
SKIP_COMMIT_MSG_CHECK=1 git commit -m "fix: unblock broken history"
```

This bypasses **all** commit-msg checks for a single command.

---

## Design philosophy

- Guardrails, not handcuffs
- Explicit intent beats silent automation
- Local checks provide feedback, CI enforces truth
- Safety defaults, easy escape hatches, no persistence of bypasses
