package com.pokedex.inventory;

import static org.junit.jupiter.api.Assertions.assertNotNull;

import com.pokedex.inventory.testinfra.BaseIntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationContext;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
class InventoryApplicationTests extends BaseIntegrationTest {

  @Autowired private ApplicationContext applicationContext;

  @Override
  protected void onContainerReady() {
    // No-op for now.
    // Hook reserved for future integration-test setup or verification.
  }

  @Test
  void contextLoads() {
    assertNotNull(
        applicationContext,
        "Spring application context should load successfully for integration tests.");
  }
}
