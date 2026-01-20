# Actuator & Healthchecks

- Health endpoint: `GET /actuator/health`

The Dockerfile includes a HEALTHCHECK that calls `/actuator/health`.
`docker-compose.yml` also defines an app healthcheck.

## Health Endpoints

The `/actuator/health` endpoint is used for container healthchecks.

This replaces `/ping` for production readiness and liveness signaling.

See:

- [ADR-003](../adr/ADR-003-actuator-health.md): Expose health endpoints with Spring Boot Actuator
