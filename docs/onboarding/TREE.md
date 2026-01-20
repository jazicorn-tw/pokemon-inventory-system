# Tree

```bash
.
├── .env                    # Local environment variables (not committed)
├── .env.example            # Example env file for contributors
├── .gitattributes
├── .githooks
│   └── pre-commit          # Project pre-commit hook (ADR-000)
├── .github
│   ├── PULL_REQUEST_TEMPLATE
│   │   └── phase_0.md      # Phase-gated PR template
│   ├── pull_request_template.md
│   └── workflows
│       ├── build-image.yml # Docker build (no push)
│       ├── ci.yml          # Main CI pipeline
│       └── ci-failure-comment.yml
├── .gitignore
├── .vscode
│   ├── README.md           # Editor conventions
│   └── settings.json
├── ARCHITECTURE.md         # High-level system design
├── BADGES.md               # Centralized badge definitions
├── build.gradle
├── CHANGELOG.md
├── CONTRIBUTING.md
├── docker-compose.yml      # Local dev + PostgreSQL
├── Dockerfile
├── HELP.md
├── LICENSE
├── Makefile                # Bootstrap & quality shortcuts
├── README.md               # Primary project README
├── README_LITE.md          # Minimal public-facing README
├── settings.gradle
│
├── config                  # Static analysis & quality tooling
│   ├── checkstyle
│   │   └── checkstyle.xml
│   └── spotbugs
│       └── spotbugs-exclude.xml
│
├── docs
│   ├── adr                 # Architecture Decision Records
│   │   ├── ADR_TEMPLATE.md
│   │   ├── ADR-000-linting.md
│   │   ├── ADR-001-database-postgresql.md
│   │   ├── ADR-002-testcontainers.md
│   │   ├── ADR-003-actuator-health.md
│   │   ├── ADR-004-env-and-config.md
│   │   ├── ADR-005-security-phased.md
│   │   └── README.md
│   │
│   ├── devops              # CI/CD & operational docs
│   │   ├── CI.md
│   │   ├── CI_GUARDRAILS.md
│   │   ├── HEALTH.md
│   │   ├── PING_VS_HEALTH.md
│   │   └── SECURITY.md
│   │
│   ├── onboarding          # New contributor journey
│   │   ├── _README.md
│   │   ├── DAY_1_ONBOARDING.md
│   │   ├── DAY_2_FIRST_PR.md
│   │   ├── DEPENDENCIES.md
│   │   ├── DEV_ENVIRONMENT.md
│   │   ├── LINTING.md
│   │   ├── MAKEFILE.md
│   │   ├── PRECOMMIT.md
│   │   ├── SETUP_DOCKER.md
│   │   └── SETUP_TESTING.md
│   │
│   ├── phases              # Delivery phases & gates
│   │   ├── PHASE_0.md
│   │   ├── PHASE_1.md
│   │   └── PHASES.md
│   │
│   └── testing              # Testing & troubleshooting
│       ├── TESTING.md
│       ├── CI_TROUBLESHOOTING.md
│       ├── CI-POSTGRESQL.md
│       └── errors
│           ├── COLIMA.md
│           ├── DOCKER.md
│           ├── FLYWAY.md
│           ├── POSTGRESQL.md
│           ├── RYUK.md
│           └── TESTCONTAINERS.md
│
├── gradle
│   └── wrapper
│       ├── gradle-wrapper.jar
│       └── gradle-wrapper.properties
├── gradle.properties
├── gradlew
├── gradlew.bat
│
├── scripts
│   └── install-hooks.sh     # Hook bootstrap script
│
└── src
    ├── main
    │   ├── java
    │   │   └── com
    │   │       └── pokedex   # Application source code
    │   └── resources
    │       ├── application.properties
    │       ├── db
    │       │   └── migration # Flyway migrations
    │       ├── static
    │       └── templates
    │
    └── test
        ├── java
        │   └── com
        │       └── pokedex   # Tests (unit, web, integration)
        └── resources
            └── application-test.properties
```
