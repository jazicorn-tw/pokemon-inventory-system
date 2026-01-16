# Actuator & Healthchecks

- Health endpoint: `GET /actuator/health`

The Dockerfile includes a HEALTHCHECK that calls `/actuator/health`.
`docker-compose.yml` also defines an app healthcheck.
