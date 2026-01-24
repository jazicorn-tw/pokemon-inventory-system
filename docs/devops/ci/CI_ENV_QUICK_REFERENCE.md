<!-- markdownlint-disable-file MD036 -->

# ⚡ Environment Variables — Quick Reference

## 🔀 CI Feature Flags (GitHub Actions)

```text
PUBLISH_DOCKER_IMAGE   # true|false — enable Docker image publishing on release tags
CANONICAL_REPOSITORY  # <owner>/<repo> — only repo allowed to publish artifacts

PUBLISH_HELM_CHART    # true|false — (future) enable Helm chart publishing
DEPLOY_ENABLED        # true|false — (future) global deployment kill switch
```

---

## 🌐 Application Runtime (All Environments)

```text
SPRING_PROFILES_ACTIVE   # dev|test|prod — active Spring profile (required)
SERVER_PORT              # optional — override default server port
```

---

## 🗄️ Database (PostgreSQL)

```text
SPRING_DATASOURCE_URL        # JDBC connection URL
SPRING_DATASOURCE_USERNAME  # database username
SPRING_DATASOURCE_PASSWORD  # database password (secret)
```

---

## 🔐 Security / Authentication

```text
JWT_SECRET                  # JWT signing secret (secret)
JWT_EXPIRATION_SECONDS      # optional — token lifetime override
```

---

## 🩺 Observability / Health

```text
MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE   # actuator endpoints to expose
MANAGEMENT_ENDPOINT_HEALTH_PROBES_ENABLED  # enable readiness/liveness probes
```

---

## Notes

- CI variables live in **GitHub Actions → Variables**
- Runtime variables are injected via **Render / Helm / Kubernetes**
- Secrets must always be provided via **platform secret managers**
- Defaults are **fail-closed** where applicable
