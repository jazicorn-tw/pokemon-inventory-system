package com.pokedex.inventory.testinfra;

import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.TestInstance;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

/**
 * Base infrastructure for PostgreSQL-backed integration tests.
 *
 * <p><strong>ADR-style note:</strong> This class is intentionally {@code abstract} and
 * intentionally contains no {@code @Test} methods.
 *
 * <ul>
 *   <li>It is not a test case; it is shared test infrastructure.
 *   <li>It exists solely to centralize Testcontainers + Spring wiring.
 *   <li>Concrete integration tests extend this class and define the actual tests.
 * </ul>
 *
 * <p>PMD is opinionated about test classes and abstraction:
 *
 * <ul>
 *   <li>{@code AbstractClassWithoutAbstractMethod}
 *   <li>{@code TestClassWithoutTestCases}
 * </ul>
 *
 * Both warnings are suppressed deliberately to document intent and prevent future refactors from
 * accidentally inlining or duplicating container wiring.
 *
 * <p><strong>Important:</strong> We start the container eagerly (static init) because Spring may
 * resolve {@code spring.datasource.url} during auto-configuration condition checks while the
 * ApplicationContext is being built. If the container is not started yet, {@code getJdbcUrl()}
 * throws: "Mapped port can only be obtained after the container is started".
 */
@Testcontainers
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
@SuppressWarnings({
  "resource",
  "PMD.AbstractClassWithoutAbstractMethod",
  "PMD.TestClassWithoutTestCases"
})
public abstract class BaseIntegrationTest {

  private static final String POSTGRES_IMAGE =
      System.getenv().getOrDefault("TEST_DATASOURCE_IMAGE", "postgres:16-alpine");

  private static final String POSTGRES_DB =
      System.getenv().getOrDefault("TEST_DATASOURCE_DB", "pokedex_test");

  private static final String POSTGRES_USER =
      System.getenv().getOrDefault("TEST_DATASOURCE_USER", "test");

  private static final String POSTGRES_PASSWORD =
      System.getenv().getOrDefault("TEST_DATASOURCE_PASSWORD", "test");

  @Container
  protected static final PostgreSQLContainer<?> POSTGRES =
      new PostgreSQLContainer<>(POSTGRES_IMAGE)
          .withDatabaseName(POSTGRES_DB)
          .withUsername(POSTGRES_USER)
          .withPassword(POSTGRES_PASSWORD);

  static {
    // Ensure the container is started before Spring evaluates DynamicPropertySource values.
    if (!POSTGRES.isRunning()) {
      POSTGRES.start();
    }
  }

  /**
   * Optional hook for subclasses to perform additional verification or setup once the container is
   * running.
   *
   * <p>Examples (future):
   *
   * <ul>
   *   <li>Verify schema state
   *   <li>Seed reference data
   *   <li>Assert required extensions exist
   * </ul>
   */
  protected void onContainerReady() {
    // no-op by default
  }

  @BeforeAll
  void verifyContainerIsRunningAndReady() {
    assertTrue(
        POSTGRES.isRunning(), "PostgreSQL Testcontainer should be running for integration tests.");
    onContainerReady();
  }

  @DynamicPropertySource
  static void registerProperties(DynamicPropertyRegistry registry) {

    // Datasource (container must already be started)
    registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
    registry.add("spring.datasource.username", POSTGRES::getUsername);
    registry.add("spring.datasource.password", POSTGRES::getPassword);

    // Flyway
    registry.add("spring.flyway.enabled", () -> "true");
    registry.add(
        "spring.flyway.locations",
        () -> System.getenv().getOrDefault("FLYWAY_LOCATIONS", "classpath:db/migration"));

    // JPA
    registry.add("spring.jpa.hibernate.ddl-auto", () -> "validate");
    registry.add("spring.jpa.open-in-view", () -> "false");
  }
}
