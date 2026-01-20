package com.pokedex.inventory.testinfra;

import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.BeforeAll;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
@SuppressWarnings("resource")
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

  /**
   * Hook for subclasses to perform additional verification or setup once the container is running.
   *
   * <p>Examples (future): - Verify schema state - Seed reference data - Assert required extensions
   * exist
   */
  protected abstract void onContainerReady();

  @BeforeAll
  static void verifyContainerIsRunning() {
    assertTrue(
        POSTGRES.isRunning(), "PostgreSQL Testcontainer should be running for integration tests.");
  }

  @DynamicPropertySource
  static void registerProperties(DynamicPropertyRegistry registry) {

    // Datasource
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
