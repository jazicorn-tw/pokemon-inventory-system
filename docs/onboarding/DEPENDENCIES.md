# 📦 Project Dependencies Overview

This project uses a modern **Spring Boot 4** stack focused on **production parity** and
realistic infrastructure from day one.

The system is designed for:

- REST API development
- External API integration (**PokeAPI**)
- JPA / Hibernate persistence
- Security and JWT authentication
- Docker-based integration testing
- API documentation (OpenAPI / Swagger)
- DTO mapping
- Database migrations
- Hot reload during development
- PostgreSQL across **local, test, and production** environments

> ❗️**Note:**  
> This project intentionally **does NOT use H2**.  
> PostgreSQL is used everywhere to avoid environment drift and hidden bugs.

Below is the complete dependency set used in `build.gradle`.

---

## 🧩 Core Spring Boot Dependencies

### REST API (Spring MVC)

```groovy
implementation 'org.springframework.boot:spring-boot-starter-web'
```

Used for:

- Controllers
- Request/response handling
- Validation & exception mapping

---

### Data Persistence (JPA / Hibernate)

```groovy
implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
```

Provides:

- Hibernate ORM
- Spring Data repositories
- Transaction management

---

### Validation (Jakarta Validation)

```groovy
implementation 'org.springframework.boot:spring-boot-starter-validation'
```

---

### Actuator (Health & Operability)

```groovy
implementation 'org.springframework.boot:spring-boot-starter-actuator'
```

Used for:

- `/actuator/health`
- Liveness & readiness probes
- Docker / orchestration health checks

---

## 🌐 External API Integration

### WebClient (via WebFlux)

```groovy
implementation 'org.springframework.boot:spring-boot-starter-webflux'
```

> WebFlux is included **only** to use `WebClient` for outbound HTTP calls.  
> The application itself remains **Spring MVC–based** (non-reactive).

---

## 🔐 Security & Authentication

### Spring Security

```groovy
implementation 'org.springframework.boot:spring-boot-starter-security'
```

---

### JWT (JJWT)

```groovy
implementation 'io.jsonwebtoken:jjwt-api:0.12.5'
runtimeOnly   'io.jsonwebtoken:jjwt-impl:0.12.5'
runtimeOnly   'io.jsonwebtoken:jjwt-jackson:0.12.5'
```

Used for:

- Stateless authentication
- Access & refresh tokens
- Signature validation

---

## 🧪 Testing

### Spring Boot Test Stack

```groovy
testImplementation 'org.springframework.boot:spring-boot-starter-test'
```

Includes:

- JUnit Jupiter
- AssertJ
- Mockito
- Spring Test / MockMvc

---

### Spring Security Test

```groovy
testImplementation 'org.springframework.security:spring-security-test'
```

---

### Testcontainers (PostgreSQL)

```groovy
testImplementation 'org.testcontainers:junit-jupiter:1.20.3'
testImplementation 'org.testcontainers:postgresql:1.20.3'
```

Used for:

- Real PostgreSQL integration tests
- CI-safe database provisioning
- Production-like behavior

---

## 🗄️ Database

### PostgreSQL (All Environments)

```groovy
runtimeOnly 'org.postgresql:postgresql'
```

Used in:

- Local development (Docker / native)
- Integration tests (Testcontainers)
- Production

---

## 🛠 Developer Experience

### Spring Boot DevTools

```groovy
developmentOnly 'org.springframework.boot:spring-boot-devtools'
```

Provides:

- Hot restart
- Faster feedback loops during development

---

## 🧭 API Documentation

### SpringDoc OpenAPI (Swagger UI)

```groovy
implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.6.0'
```

Swagger UI available at:

```bash
/swagger-ui/index.html
```

---

## 🔄 DTO Mapping

### MapStruct

```groovy
implementation 'org.mapstruct:mapstruct:1.6.0'
annotationProcessor 'org.mapstruct:mapstruct-processor:1.6.0'
```

Benefits:

- Compile-time safety
- Clear entity ↔ DTO boundaries
- No reflection overhead

---

## 📅 Database Migrations

### Flyway

```groovy
implementation 'org.flywaydb:flyway-core'
```

Used for:

- Versioned schema migrations
- Startup validation
- Repeatable migrations

---

## 📊 Structured JSON Logging

### Logback JSON

```groovy
implementation 'ch.qos.logback.contrib:logback-json-classic:0.1.5'
implementation 'ch.qos.logback.contrib:logback-jackson:0.1.5'
```

---

## ⏱ Jackson Java Time Support

```groovy
implementation 'com.fasterxml.jackson.datatype:jackson-datatype-jsr310'
```

---

## 🧰 Optional Tooling

### Lombok (Optional)

```groovy
compileOnly 'org.projectlombok:lombok'
annotationProcessor 'org.projectlombok:lombok'
testCompileOnly 'org.projectlombok:lombok'
testAnnotationProcessor 'org.projectlombok:lombok'
```

---

## 🚀 Summary

This dependency set intentionally prioritizes:

- PostgreSQL everywhere (no H2)
- Production parity across environments
- Strong testing via Testcontainers
- Clear architectural boundaries
- Enterprise-ready observability and security

This makes the project realistic, interview-ready, and production-aligned.
