# CI Testcontainers

## Testcontainers Initialization Order (Important)

### Why the PostgreSQL container is started eagerly

Integration tests in this project use **Testcontainers + PostgreSQL** wired via
`@DynamicPropertySource` in `BaseIntegrationTest`.

Spring Boot may resolve datasource properties **very early** during application
startup, including while evaluating auto-configuration conditions such as:

```bash
DataSourceAutoConfiguration$EmbeddedDatabaseConfiguration
```

During this phase, Spring attempts to read:

- `spring.datasource.url`
- `spring.datasource.username`
- `spring.datasource.password`

These values are supplied by Testcontainers via:

```java
POSTGRES.getJdbcUrl()
```

### The failure we are explicitly preventing

If the container is **not started yet** when Spring evaluates these properties,
Testcontainers throws:

```bash
IllegalStateException: Mapped port can only be obtained after the container is started
```

This manifests as a context bootstrap failure:

```bash
Failed to load ApplicationContext
Error processing condition on DataSourceAutoConfiguration$EmbeddedDatabaseConfiguration
```

### The chosen solution

We **start the container eagerly** in a static initializer inside
`BaseIntegrationTest`:

```java
static {
  if (!POSTGRES.isRunning()) {
    POSTGRES.start();
  }
}
```

This guarantees:

- the container is running before Spring evaluates datasource conditions
- `getJdbcUrl()` is always safe to call from `@DynamicPropertySource`
- tests behave consistently across:
  - local development
  - CI
  - different JVM execution orders

### Why we do NOT rely on the JUnit extension alone

The JUnit 5 `@Testcontainers` extension starts containers **after**
Spring has already begun building the application context.

That is too late for datasource condition evaluation.

### Guardrail for future refactors

If you see any of the following errors during test startup:

- `Mapped port can only be obtained after the container is started`
- `Failed to load ApplicationContext` with `DataSourceAutoConfiguration`
- failures inside `SpringBootCondition` or `Preconditions`

Do **not** remove the eager container start.
Doing so reintroduces this class of failures.

If test wiring changes, update this section accordingly.
