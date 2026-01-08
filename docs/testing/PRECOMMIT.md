# Pre-commit Guardrails

This document describes optional pre-commit hooks to prevent common Testcontainers regressions.

---

## Goals

- Prevent use of `@ServiceConnection`
- Prevent hardcoded datasource credentials in tests

---

## Git Hook

Create `.git/hooks/pre-commit`:

```bash
#!/usr/bin/env bash
set -euo pipefail

if grep -R "@ServiceConnection" src/test/java >/dev/null 2>&1; then
  echo "❌ @ServiceConnection is not allowed"
  exit 1
fi

if grep -E "^spring\.datasource\.(url|username|password)="   src/test/resources/application-test.properties >/dev/null 2>&1; then
  echo "❌ Do not hardcode spring.datasource.* in tests"
  exit 1
fi

echo "✅ Pre-commit checks passed"
```

Enable it:

```bash
chmod +x .git/hooks/pre-commit
```
