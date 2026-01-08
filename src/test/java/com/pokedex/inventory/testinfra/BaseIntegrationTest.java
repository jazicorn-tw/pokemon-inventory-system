package com.pokedex.inventory.testinfra;

import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
@SuppressWarnings("resource")
public abstract class BaseIntegrationTest {

  private static final String POSTGRES_IMAGE =
      System.getenv().getOrDefault("TEST_POSTGRES_IMAGE", "postgres:16-alpine");

  private static final String POSTGRES_DB =
      System.getenv().getOrDefault("TEST_POSTGRES_DB", "pokedex_test");

  private static final String POSTGRES_USER =
      System.getenv().getOrDefault("TEST_POSTGRES_USER", "test");

  private static final String POSTGRES_PASSWORD =
      System.getenv().getOrDefault("TEST_POSTGRES_PASSWORD", "test");

  @Container
  protected static final PostgreSQLContainer<?> POSTGRES =
      new PostgreSQLContainer<>(POSTGRES_IMAGE)
          .withDatabaseName(POSTGRES_DB)
          .withUsername(POSTGRES_USER)
          .withPassword(POSTGRES_PASSWORD);

  @DynamicPropertySource
  static void registerProperties(DynamicPropertyRegistry registry) {
    registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
    registry.add("spring.datasource.username", POSTGRES::getUsername);
    registry.add("spring.datasource.password", POSTGRES::getPassword);

    registry.add("spring.flyway.enabled", () -> "true");
    registry.add("spring.jpa.hibernate.ddl-auto", () -> "validate");
    registry.add("spring.jpa.open-in-view", () -> "false");

  }
}
