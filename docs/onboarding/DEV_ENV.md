# Dev Environment (VS Code + Docker)

This repo is optimized for **repeatable builds** and **TDD** with Spring Boot 4 + Java 21.

## Requirements

- **Java 21** (Gradle toolchains will enforce this for builds)
- **Docker / Colima** (recommended on macOS) for local PostgreSQL
- Gradle Wrapper (use `./gradlew`)

## Recommended VS Code setup

VS Code’s Java Test Runner can run tests outside Gradle, which can cause **Mockito inline mocking** to self-attach dynamically and print JDK warnings.
To keep VS Code behavior aligned with CLI/CI, we recommend running tests via **Gradle**, and we silence dynamic-agent warnings in the VS Code runner.

### Workspace settings

This repo includes `.vscode/settings.json` with:

- Run tests via **Gradle**
- Add `-XX:+EnableDynamicAgentLoading` to silence dynamic-agent warnings (dev-only)

> CLI/CI runs (`./gradlew test`) already preload Mockito as a proper agent (via Gradle config) and do not rely on dynamic attachment.

## Local database (PostgreSQL)

For local development, use Docker Compose to run PostgreSQL:

```bash
docker compose up -d
```

Stop it with:

```bash
docker compose down
```

### Environment variables

Copy `.env.example` to `.env` and adjust if needed.

## Common commands

Run tests:

```bash
./gradlew test
```

Run the app:

```bash
./gradlew bootRun
```

Run a single test (example):

```bash
./gradlew test --tests "com.pokedex.inventory.ping.PingControllerTest"
```

## Troubleshooting

- For Docker/Testcontainers issues, see `TROUBLESHOOTING.md`
- For Colima setup on macOS, see `COLIMA.md` (if present)
