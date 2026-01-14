<!-- markdownlint-disable-file MD036 -->
# 🔰 Phase 0 — Project Skeleton (v0.0.1)

> Goal: set up a **running Spring Boot app + test harness** before any domain logic.

## ✅ Purpose

Set up the Spring Boot application and testing environment so future phases can be built using **TDD** with confidence.

By the end of Phase 0 you will have:

- A Spring Boot app that starts successfully
- A passing **context-load** test
- A verified `GET /ping` endpoint that returns `pong`
- A clean baseline for Phase 1 domain work

## 🧪 TDD Steps

### 1. Create a context-load test (`InventoryServiceApplicationTests`)

This test proves Spring can bootstrap your app (component scan, auto-config, dependency wiring).

**File**
`src/test/java/com/pokedex/inventory/InventoryServiceApplicationTests.java`

```java
package com.pokedex.inventory;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class InventoryServiceApplicationTests {

    @Test
    void contextLoads() {
        // If the application context fails to start, this test fails.
    }
}
```

✅ **Expected result**: test passes without adding any controllers/services.

---

### 2. Write the failing test for `GET /ping`

Use MockMvc to test the HTTP layer without starting a full server.

**File**
`src/test/java/com/pokedex/inventory/ping/PingControllerTest.java`

```java
package com.pokedex.inventory.ping;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(PingController.class)
class PingControllerTest {

    @Autowired
    MockMvc mockMvc;

    @Test
    void ping_returns_pong() throws Exception {
        mockMvc.perform(get("/ping"))
                .andExpect(status().isOk())
                .andExpect(content().string("pong"));
    }
}
```

✅ **Expected result** (at first): fails because `PingController` doesn’t exist yet.

---

### 3. Implement the minimal controller to satisfy the test

**File**
`src/main/java/com/pokedex/inventory/ping/PingController.java`

```java
package com.pokedex.inventory.ping;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
class PingController {

    @GetMapping("/ping")
    String ping() {
        return "pong";
    }
}
```

✅ **Expected result**: `PingControllerTest` now passes.

## 📦 Dependencies (Phase 0)

You listed these as the Phase 0 baseline:

- Spring Boot Web
- Spring Boot Data JPA
- Validation
- H2 DB
- Spring Boot Test
- AssertJ
- Mockito

### Gradle snippet (example)

> If you already have these, keep yours — this is just a reference.

```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-validation'

    runtimeOnly 'com.h2database:h2'

    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}
```

**Notes**

- `spring-boot-starter-test` already bundles JUnit 5, AssertJ, Mockito, and Spring Test (MockMvc).
- H2 is fine for Phase 0/1 local dev; you can switch to PostgreSQL later.

## 🗂️ Suggested folder structure (end of Phase 0)

```bash
src/
├─ main/
│  ├─ java/
│  │  └─ com/pokedex/inventory/
│  │     ├─ InventoryServiceApplication.java
│  │     └─ ping/
│  │        └─ PingController.java
│  └─ resources/
│     └─ application.properties
└─ test/
   └─ java/
      └─ com/pokedex/inventory/
         ├─ InventoryServiceApplicationTests.java
         └─ ping/
            └─ PingControllerTest.java
```

## ⚙️ Minimal configuration (H2)

**File**
`src/main/resources/application.properties`

```properties
spring.application.name=inventory-service

# H2 (dev)
spring.datasource.url=jdbc:h2:mem:inventory;MODE=PostgreSQL;DB_CLOSE_DELAY=-1
spring.datasource.username=sa
spring.datasource.password=
spring.datasource.driver-class-name=org.h2.Driver

# JPA
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.format_sql=true

# H2 console (optional)
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
```

**Why `MODE=PostgreSQL`?**
It reduces surprises later when you migrate to PostgreSQL (especially around SQL syntax and casing).

## ▶️ Run commands

### Run tests

```bash
./gradlew test
```

### Run the app

```bash
./gradlew bootRun
```

### Quick manual check

```bash
curl -i http://localhost:8080/ping
# HTTP/1.1 200
# pong
```

## ✅ Definition of Done (Phase 0)

- [ ] `InventoryServiceApplicationTests` passes (`contextLoads`)
- [ ] `PingControllerTest` passes (expects `"pong"`)
- [ ] App boots cleanly with no extra domain logic
- [ ] `curl /ping` returns `pong`

## 🔜 Next (Phase 1 preview)

Once Phase 0 is green, Phase 1 can start safely:

- Introduce the first domain object (Trainer or Inventory item)
- Add repository + service + controller via red → green → refactor
- Add Flyway migrations once you move beyond in-memory prototyping
