<!-- markdownlint-disable-file MD036 -->
# 🔰 Phase 0 — Project Skeleton (v0.0.1)

> Goal: establish a **production-realistic Spring Boot baseline** with a verified test harness **before any domain logic**.

---

## ⚠️ Test Requirement (Read First)

**Phase 0 tests REQUIRE Docker (or Colima on macOS).**

This project uses **Testcontainers with PostgreSQL** starting in Phase 0 to ensure:

* production-parity database behavior
* early detection of schema/migration issues
* no divergence between test and real environments

If Docker/Colima is not running, `./gradlew test` **will fail**.

---

## ✅ Purpose

Phase 0 establishes the **non-negotiable foundation** of the system:

* Spring Boot application boots cleanly
* PostgreSQL is wired consistently across environments
* Flyway is active from day one
* HTTP + health endpoints are verifiable
* Tests fail for real reasons (not misconfiguration)

This phase intentionally includes **infrastructure weight early** to avoid later rewrites.

---

## 🎯 Outcomes

By the end of Phase 0 you will have:

* A Spring Boot app that starts successfully
* A passing **context-load** test backed by PostgreSQL (Testcontainers)
* A verified `GET /ping` endpoint that returns `pong`
* A verified `GET /actuator/health` endpoint that returns `UP`
* A clean baseline for Phase 1 domain work

---

## 🧪 TDD Flow (Phase 0)

> 🐳 Before running any tests:
>
> ```bash
> docker ps
> ```
>
> If this fails (macOS):
>
> ```bash
> colima start
> docker context use colima
> ```

---

### 1️⃣ Context Load Test (Infrastructure Proof)

This test proves that:

* component scanning works
* auto-configuration is valid
* database + Flyway wiring is correct
* the application can **actually start**

**File**
`src/test/java/com/pokedex/inventory/InventoryApplicationTests.java`

```java
package com.pokedex.inventory;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class InventoryApplicationTests {

    @Test
    void contextLoads() {
        // Fails if Spring, DB, or Flyway are misconfigured
    }
}
```

✅ **Expected result**: passes only if Docker + Testcontainers are working.

---

### 2️⃣ Failing HTTP Test — `/ping`

This test verifies the HTTP boundary **without** starting a full server
and **without touching the database**.

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

❌ **Expected result initially**: fails — controller doesn’t exist yet.

---

### 3️⃣ Minimal Controller (Green)

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

✅ **Expected result**: test passes.

---

## 📦 Dependencies (Phase 0 Baseline)

Phase 0 intentionally includes **real infrastructure dependencies**.

```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-validation'

    implementation 'org.flywaydb:flyway-core'
    runtimeOnly 'org.postgresql:postgresql'

    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.testcontainers:junit-jupiter'
    testImplementation 'org.testcontainers:postgresql'
}
```

---

## ⚙️ Configuration (PostgreSQL-First)

**File**
`src/main/resources/application.properties`

```properties
spring.application.name=inventory-service

spring.datasource.url=${SPRING_DATASOURCE_URL}
spring.datasource.username=${SPRING_DATASOURCE_USERNAME}
spring.datasource.password=${SPRING_DATASOURCE_PASSWORD}

spring.jpa.open-in-view=false
spring.jpa.hibernate.ddl-auto=validate

spring.flyway.enabled=true
spring.flyway.locations=${FLYWAY_LOCATIONS:classpath:db/migration}

management.endpoints.web.exposure.include=health,info
```

---

## ▶️ Runbook

```bash
docker compose up -d postgres
./gradlew test
./gradlew bootRun
```

```bash
curl -i http://localhost:8080/ping
curl -i http://localhost:8080/actuator/health
```

---

## ✅ Definition of Done (Phase 0)

* [ ] Docker/Colima running
* [ ] `contextLoads()` passes using Testcontainers PostgreSQL
* [ ] `PingControllerTest` passes
* [ ] App boots cleanly
* [ ] `/ping` returns `pong`
* [ ] `/actuator/health` returns `UP`

---

## 🧯 Troubleshooting (Phase 0)

```bash
unset DOCKER_HOST
docker context use colima
```

See `DOCKER.md`, `COLIMA.md`, and `TROUBLESHOOTING.md`.

---

## 🔜 Next — Phase 1 Preview

With a verified skeleton in place, Phase 1 can focus purely on **domain logic** without infrastructure refactors.
