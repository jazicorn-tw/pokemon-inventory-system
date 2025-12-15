# 📦 Project Dependencies Overview

This project uses a fully modern **Spring Boot 4** stack with everything you need for:

- API development
- Integration with external APIs [**PokeAPI**](https://pokeapi.co/docs/v2)
- JPA / Hibernate
- Security and JWT authentication
- Integration testing with [**Testcontainers**](https://java.testcontainers.org/)
- API documentation (**Swagger / SpringDoc**)
- DTO mapping
- Database migrations
- Hot reload for development
- Database switching (**H2 ↔ PostgreSQL**)

Below is the complete list of dependencies included in `build.gradle`.

---

## 🧩 Core Spring Boot Dependencies

### REST API & MVC

```groovy
implementation 'org.springframework.boot:spring-boot-starter-web'
```

### Data Persistence (JPA / Hibernate)

```groovy
implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
```

### Validation

```groovy
implementation 'org.springframework.boot:spring-boot-starter-validation'
```

### Actuator (Health & Metrics)

```groovy
implementation 'org.springframework.boot:spring-boot-starter-actuator'
```

---

## 🌐 WebClient / PokeAPI Integration

### WebFlux (required for WebClient)

```groovy
implementation 'org.springframework.boot:spring-boot-starter-webflux'
```

---

## 🔐 Security & Authentication

### Spring Security

```groovy
implementation 'org.springframework.boot:spring-boot-starter-security'
```

### JWT (JSON Web Token) – JJWT

```groovy
implementation 'io.jsonwebtoken:jjwt-api:0.12.5'
runtimeOnly   'io.jsonwebtoken:jjwt-impl:0.12.5'
runtimeOnly   'io.jsonwebtoken:jjwt-jackson:0.12.5'
```

---

## 🧪 Testing Dependencies

### Spring Boot Test

```groovy
testImplementation 'org.springframework.boot:spring-boot-starter-test'
```

### AssertJ (fluent assertions)

```groovy
testImplementation 'org.assertj:assertj-core:3.26.0'
```

### Mockito (mocking)

```groovy
testImplementation 'org.mockito:mockito-core:5.12.0'
```

### Spring Security Test

```groovy
testImplementation 'org.springframework.security:spring-security-test'
```

### Testcontainers (Integration Testing with Docker)

For running PostgreSQL in an isolated environment:

```groovy
testImplementation 'org.testcontainers:junit-jupiter:1.20.3'
testImplementation 'org.testcontainers:postgresql:1.20.3'
```

---

## 🗄️ Database Drivers

### H2 (Development / In-Memory DB)

```groovy
runtimeOnly 'com.h2database:h2'
```

### PostgreSQL (Production + Testcontainers)

```groovy
runtimeOnly 'org.postgresql:postgresql'
```

---

## 🛠 Developer Experience

### Spring Boot DevTools

```groovy
developmentOnly 'org.springframework.boot:spring-boot-devtools'
```

---

## 🧭 API Documentation

### SpringDoc OpenAPI (Swagger UI)

```groovy
implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.6.0'
```

---

## 🔄 DTO Mapping

### MapStruct

```groovy
implementation 'org.mapstruct:mapstruct:1.6.0'
annotationProcessor 'org.mapstruct:mapstruct-processor:1.6.0'
```

---

## 📅 Database Migrations

### Flyway

```groovy
implementation 'org.flywaydb:flyway-core'
```

---

## 📊 JSON Logging

### Logback JSON appenders

```groovy
implementation 'ch.qos.logback.contrib:logback-json-classic:0.1.5'
implementation 'ch.qos.logback.contrib:logback-jackson:0.1.5'
```

---

## ⏱ Java Time Module

### Jackson JSR-310

```groovy
implementation 'com.fasterxml.jackson.datatype:jackson-datatype-jsr310'
```

---

## 🧰 Optional Tooling

### Lombok (only if you decide to use it)

```groovy
compileOnly 'org.projectlombok:lombok'
annotationProcessor 'org.projectlombok:lombok'
testCompileOnly 'org.projectlombok:lombok'
testAnnotationProcessor 'org.projectlombok:lombok'
```

---

## 🚀 Your Project Is Fully Equipped

Your project now has support for:

### ✔ API Development

Complete Spring MVC stack for building REST endpoints.

### ✔ PokeAPI Integration

WebClient (WebFlux) for external API calls.

### ✔ JPA / Hibernate

Entity modeling, repositories, transactional boundaries.

### ✔ Security + JWT

Spring Security foundation + JJWT for authentication and authorization.

### ✔ Testcontainers Integration Tests

Full Docker-based integration testing with real PostgreSQL.

### ✔ Swagger (SpringDoc)

Interactive API documentation available at:

```bash
/swagger-ui.html
```

### ✔ DTO Mapping (MapStruct)

Cleaner, maintainable entity-to-DTO transformations.

### ✔ JSON Logging

Structured logs for observability and cloud deployments.

### ✔ Migrations (Flyway)

Version-controlled database schema evolution.

### ✔ DevTools Hot Restart

Improved developer experience.

### ✔ H2 + Postgres Switching

Lightweight local development with production-ready database support.
