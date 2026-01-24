<!-- markdownlint-disable-file MD036 -->
<!-- markdownlint-disable MD024 -->

# ✅ Repo Variables & Environment Configuration

This document defines **feature flags** and **runtime environment variables**
used across CI, local development, Render, and future Kubernetes deployments.

> **Security note**
> This file intentionally documents **variable names and behavior only**.
> Secret values must be provided via platform secret managers and must never
> be committed to source control.

---

## ⚡ Environment Variables — Quick Reference

### 🔀 CI Feature Flags (GitHub Actions)

**Purpose:** Control *when* CI publishes artifacts or performs deployments, without code changes.  
🔗 See details: **[CI Feature Flags](#-ci-feature-flags-github-actions)**

```text
PUBLISH_DOCKER_IMAGE   # optional — true|false — enable Docker image publishing on release tags
CANONICAL_REPOSITORY  # required* — <owner>/<repo> — only repo allowed to publish artifacts

PUBLISH_HELM_CHART    # optional — true|false — (future) enable Helm chart publishing
DEPLOY_ENABLED        # optional — true|false — (future) global deployment kill switch
```

\* Required **only when publishing is enabled** (`PUBLISH_DOCKER_IMAGE=true`)

---

### 🌐 Application Runtime (All Environments)

**Purpose:** Define core runtime behavior consistently across local, Render, and Kubernetes.  
🔗 See details: **[Application runtime](#-application-runtime-all-environments)**

```text
SPRING_PROFILES_ACTIVE   # required — dev|test|prod — active Spring profile
SERVER_PORT              # optional — override default server port
```

---

### 🗄️ Database (PostgreSQL)

**Purpose:** Configure database connectivity for the application and Flyway migrations.  
🔗 See details: **[Database (PostgreSQL)](#-database-postgresql)**

```text
SPRING_DATASOURCE_URL        # required — JDBC connection URL
SPRING_DATASOURCE_USERNAME  # required — database username
SPRING_DATASOURCE_PASSWORD  # required — database password (secret)
```

---

### 🔐 Security / Authentication

**Purpose:** Control JWT-based authentication and token behavior.  
🔗 See details: **[Security / Authentication](#-security--authentication)**

```text
JWT_SECRET                  # required — JWT signing secret (secret)
JWT_EXPIRATION_SECONDS      # optional — token lifetime override
```

---

### 🩺 Observability / Health

**Purpose:** Expose health and probe endpoints for platforms and orchestrators.  
🔗 See details: **[Observability / Health](#-observability--health)**

```text
MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE   # optional — actuator endpoints to expose
MANAGEMENT_ENDPOINT_HEALTH_PROBES_ENABLED  # optional — enable readiness/liveness probes
```

---

## ✅ Minimal required per environment

Legend: ✅ required, ⚪ optional, — not used / not applicable

### Runtime variables

| Variable | Local (dev) | CI (tests) | Render (prod) | K8s (prod) | Notes |
|---|---:|---:|---:|---:|---|
| `SPRING_PROFILES_ACTIVE` | ✅ | ✅ | ✅ | ✅ | Usually `dev` / `test` / `prod` |
| `SERVER_PORT` | ⚪ | — | ⚪ | ⚪ | Often provided by platform; override only if needed |
| `SPRING_DATASOURCE_URL` | ✅ | ✅ | ✅ | ✅ | JDBC URL |
| `SPRING_DATASOURCE_USERNAME` | ✅ | ✅ | ✅ | ✅ | DB user |
| `SPRING_DATASOURCE_PASSWORD` | ✅ | ✅ | ✅ | ✅ | **Secret** |
| `JWT_SECRET` | ✅ | ✅ | ✅ | ✅ | **Secret**; use a CI-only value in tests |
| `JWT_EXPIRATION_SECONDS` | ⚪ | ⚪ | ⚪ | ⚪ | Optional override |
| `MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE` | ⚪ | ⚪ | ⚪ | ⚪ | Often set to `health,info` (or similar) |
| `MANAGEMENT_ENDPOINT_HEALTH_PROBES_ENABLED` | ⚪ | ⚪ | ⚪ | ✅ | Typically `true` in K8s for readiness/liveness |

### CI feature flags (workflow-level)

| Variable | Local | CI | Render | K8s | Notes |
|---|---:|---:|---:|---:|---|
| `PUBLISH_DOCKER_IMAGE` | — | ⚪ | — | — | GitHub Actions Variable |
| `CANONICAL_REPOSITORY` | — | ✅* | — | — | Required only when publishing is enabled |
| `PUBLISH_HELM_CHART` | — | ⚪ | — | — | Reserved |
| `DEPLOY_ENABLED` | — | ⚪ | — | — | Reserved kill switch |

\* Required only when `PUBLISH_DOCKER_IMAGE=true`

---

## 🔀 CI Feature Flags (GitHub Actions)

Create these under:

**Settings → Secrets and variables → Actions → Variables**

### Docker image publishing

#### Variables

- `PUBLISH_DOCKER_IMAGE` = `true` | `false`  
  Controls whether Docker images are published to GHCR on semantic-release tags.

- `CANONICAL_REPOSITORY` = `<owner>/<repo>`  
  Defines the **single canonical repository** allowed to publish Docker images.

---

#### Behavior

**Publishing requires *both* conditions to be true:**

1. `PUBLISH_DOCKER_IMAGE == true`
2. The workflow is running in `CANONICAL_REPOSITORY`

Outcomes:

- `true` **and** canonical repo → images are built and pushed on `vX.Y.Z` tags
- `false` → publish job is skipped (no registry login, no push)
- non-canonical repo → publish job is skipped (safety guard)

---

#### Used by

- `.github/workflows/publish-image.yml`

---

#### Rationale

- Allows **emergency shutdown** of publishing without code changes
- Prevents **accidental publishing** from forks or mirrored repositories
- Decouples release versioning (ADR-008) from artifact delivery
- Makes publishing policy **explicit, auditable, and configuration-driven**

---

### Helm chart publishing (future)

- `PUBLISH_HELM_CHART` = `true` | `false`

Reserved for future Helm chart publishing workflows.

Planned behavior:

- `true` → Helm charts published on release tags
- `false` → chart publishing skipped

Status:

- **Not currently used**
- Documented for forward compatibility

---

### Deployment kill switch (future)

- `DEPLOY_ENABLED` = `true` | `false`

Reserved global safety switch for automated deployments.

Planned usage:

- Gate Render, Kubernetes, or other deploy workflows
- Allow instant halt of deploys during incidents

Status:

- **Not currently used**

---

## 🌐 Runtime Environment Variables (All Platforms)

The application follows **12-factor principles**:

- configuration via environment variables only
- no environment-specific config files
- no secrets in source control

The same variable names are used across **local**, **Render**, and **Kubernetes**.

---

## 🧪 Application runtime (all environments)

| Variable                 | Required | Description                                    |
|--------------------------|----------|------------------------------------------------|
| `SPRING_PROFILES_ACTIVE` | ✅       | Active Spring profile (`dev`, `test`, `prod`)  |
| `SERVER_PORT`            | ❌       | Override default server port (optional)        |

---

## 🗄️ Database (PostgreSQL)

| Variable                      | Required | Description         |
|-------------------------------|----------|---------------------|
| `SPRING_DATASOURCE_URL`       | ✅       | JDBC connection URL |
| `SPRING_DATASOURCE_USERNAME`  | ✅       | Database username   |
| `SPRING_DATASOURCE_PASSWORD`  | ✅       | Database password   |

Notes:

- Same variables are used by Flyway migrations
- Values differ per environment (local, CI, Render, Kubernetes)

---

## 🔐 Security / Authentication

| Variable                 | Required | Description              |
|--------------------------|----------|--------------------------|
| `JWT_SECRET`             | ✅       | Secret used to sign JWTs |
| `JWT_EXPIRATION_SECONDS` | ❌       | Token lifetime override  |

Notes:

- Secrets **must** be provided via platform secret storage
- Never log or echo these values

---

## 🩺 Observability / Health

| Variable                                    | Required | Description                      |
|---------------------------------------------|----------|----------------------------------|
| `MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE` | ❌       | Actuator endpoint exposure       |
| `MANAGEMENT_ENDPOINT_HEALTH_PROBES_ENABLED` | ❌       | Enable readiness/liveness probes |

Used by:

- Render health checks
- Kubernetes readiness/liveness probes

---

## ☁️ Platform-specific notes

### Render (Phase 1 – current)

- Environment variables are configured via the Render dashboard
- Secrets are stored encrypted by Render
- Health checks should target:
  - `/actuator/health` or
  - `/actuator/health/readiness`

No CI-controlled deployment occurs in Phase 1 (see ADR-009).

---

### Helm / Kubernetes (Phase 2 – future)

Environment variables will be injected via:

- Helm `values.yaml`
- Kubernetes `ConfigMap` (non-secrets)
- Kubernetes `Secret` (sensitive values)

Helm charts already support:

- image repository + tag injection
- environment variable templating
- readiness/liveness probes

See:

- **ADR-009** — Deployment Strategy
- `helm/pokemon-trainer-platform/values.yaml`

---

## 🔗 Related Decisions

- **ADR-008** — CI-Managed Releases with semantic-release
- **ADR-009** — Deployment Strategy (Render → Kubernetes)

---

## Summary

- CI feature flags control **when artifacts are published**
- Runtime variables control **how the application behaves**
- Variable names are stable across all platforms
- Values are always environment-specific and secret-managed
