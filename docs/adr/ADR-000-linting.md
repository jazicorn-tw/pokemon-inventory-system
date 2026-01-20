<!-- markdownlint-disable-file MD041 -->
<!-- markdownlint-disable-file MD036 -->

# ADR-000: Establish Formatting, Linting, and Static Analysis First

**Status:** Accepted  
**Date:** 2026-01-19  
**Decision Makers:** Project Maintainers  
**Scope:** Entire codebase (current and future projects)

---

## Context

Early stages of this project focused on functionality, environment setup, and architecture.
Formatting, linting, and static analysis were introduced **after** initial development had already begun.

This resulted in:

- Inconsistent formatting and style decisions
- Delayed discovery of avoidable issues
- Extra cleanup work once tooling was enabled
- Unclear quality expectations for early contributions

In hindsight, formatting + linting + static analysis define the **baseline quality contract** of a project
and should be established **before or alongside the first production code**.

---

## Decision

We will **establish formatting, linting, and static analysis as ADR-000**, representing a foundational,
non-negotiable decision that precedes all other architectural choices.

For this project and all future projects:

- Formatting and linting **must be set up first**
- Rules define the minimum quality bar
- CI must enforce them as part of the default quality gate

---

## Chosen Tooling (Java)

This project uses:

- **Spotless (Google Java Format)** — deterministic formatting (Prettier-equivalent)
- **Checkstyle** — code style and consistency
- **PMD** — code smells and best practices
- **SpotBugs** — static bug pattern detection

### Scope (current state)

- ✅ `src/main/**` (production code)
- ✅ `src/test/**` (test code)

> Test code is intentionally included in the quality gate.
> Tests are treated as **first-class code** and held to the same formatting,
> linting, and static analysis standards as production code.

### How it runs

Formatting and linting run via Gradle:

```bash
# Auto-format (local dev)
./gradlew spotlessApply

# Verify formatting (CI-safe)
./gradlew spotlessCheck

# Run the full quality gate
./gradlew clean check
```

> CI must use `spotlessCheck` (non-mutating) rather than `spotlessApply`.

---

## Rationale

### Why formatting + linting come first

Formatting and linting:

- Define *how* code should look and behave before anyone writes it
- Prevent subjective debates in PRs (“tabs vs spaces”, “import order”, etc.)
- Catch issues earlier than tests alone
- Encourage small, incremental changes

By establishing them first:

- All contributors share the same expectations
- Architectural discussions happen on top of a clean baseline
- Refactoring cost is reduced long-term

### Why lint test code as well

Test code:

- Encodes business intent and system behavior
- Lives as long as production code
- Is frequently read during debugging and refactoring

Linting tests:

- Prevents low-signal placeholder assertions
- Encourages meaningful test intent
- Surfaces brittle or misleading patterns early

Noise is handled through:

- Rule tuning
- Narrow suppressions
- Intentional refactors  
—not by excluding test code entirely.

### Why Spotless (Google Java Format)

Spotless provides:

- Deterministic formatting (same output everywhere)
- Gradle-native tasks (`spotlessApply`, `spotlessCheck`)
- CI-friendly checks that don’t mutate files
- Minimal configuration with pinned versions for reproducibility

---

## Alternatives Considered

### 1. Add tooling later (post-MVP)

**Rejected**

- Causes rework
- Creates inconsistent legacy code
- Weakens early quality culture

### 2. Rely only on IDE inspections / auto-formatting

**Rejected**

- Not enforceable
- Inconsistent across contributors
- Not CI-verifiable

### 3. Only add the `google-java-format` dependency and run it manually

**Rejected**

- Not Gradle-native for project-wide formatting
- Hard to enforce consistently across environments
- Encourages ad-hoc formatting instead of a single, automated gate

### 4. Exclude test code from linting entirely

**Rejected**

- Creates a lower quality bar for tests
- Encourages placeholder or low-signal tests
- Defers problems instead of surfacing them early

---

## Consequences

### Positive

- Clear quality baseline from the start
- Faster PR reviews
- Reduced cognitive load when reading code
- CI enforces standards automatically
- Less “style churn” (formatting is deterministic)
- Tests remain readable and intention-revealing

### Trade-offs

- Slight upfront setup cost
- Occasional false positives (managed via exclusions and suppressions)
- Requires discipline to evolve rules intentionally

---

## Follow-ups

- Periodically review rules for relevance
- Prefer narrow suppressions over broad exclusions
