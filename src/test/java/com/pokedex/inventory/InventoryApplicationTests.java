package com.pokedex.inventory;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import com.pokedex.inventory.testinfra.BaseIntegrationTest;

@SpringBootTest
@ActiveProfiles("test")
class InventoryApplicationTests extends BaseIntegrationTest {

	@Test
	void contextLoads() {
	}

}
