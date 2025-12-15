# 🎒 Pokémon Trainer Inventory Service  

_A Spring Boot 4 API for trainers to manage their Pokémon, trade with others, and participate in a marketplace — powered by PokeAPI and built with TDD._

---

## 🚀 Overview

The **Pokémon Trainer Inventory Service** is a backend REST API that allows trainers to:

- Register trainer profiles  
- Add Pokémon to their inventory  
- Validate Pokémon species via [**PokeAPI**](https://pokeapi.co/docs/v2)
- Trade Pokémon with other trainers  
- List Pokémon for sale  
- Buy Pokémon from other trainers  
- Authenticate with **JWT** (later phase)  
- Run integration tests using **Testcontainers** (PostgreSQL in Docker)

The project follows **Test-Driven Development (TDD)** from the first phase onward.  
Each feature is implemented with:

1. Failing test  
2. Minimal passing implementation  
3. Refactoring  

This ensures long-term maintainability and high test coverage.

---

## 🧩 Core Technologies

| Area | Technology |
|------|------------|
| Language | **Java 21** |
| Framework | **Spring Boot 4** |
| Build Tool | Gradle |
| Persistence | JPA / Hibernate |
| External API | PokeAPI (via WebClient) |
| Auth | Spring Security + JWT (JJWT) |
| Testing | JUnit 5, Mockito, AssertJ, Testcontainers |
| API Docs | SpringDoc OpenAPI (Swagger UI) |
| Mapping | MapStruct |
| DB | H2 (dev), PostgreSQL (prod/test) |

---

## 📦 Dependencies Included

### → **Spring Boot Starters**

- spring-boot-starter-web  
- spring-boot-starter-data-jpa  
- spring-boot-starter-validation  
- spring-boot-starter-actuator  
- spring-boot-starter-webflux (WebClient for PokeAPI)  
- spring-boot-starter-security  

### → **Security + JWT**

- jjwt-api  
- jjwt-impl  
- jjwt-jackson  
- spring-security-test  

### → **Database Drivers**

- H2  
- PostgreSQL  

### → **Developer Experience**

- Spring Boot DevTools  
- Jackson datatype JSR-310  
- Logback JSON logging  

### → **API Documentation**

- SpringDoc OpenAPI  

### → **Mapping**

- MapStruct  

### → **Database Migrations**

- Flyway  

### → **Testing**

- spring-boot-starter-test  
- AssertJ  
- Mockito  
- Testcontainers (JUnit Jupiter + PostgreSQL modules)

---

## 📊 Project Structure Diagram

```bash

com.pokedex.inventory
│
├── config/
│   ├── SecurityConfig.java
│   └── WebClientConfig.java
│
├── error/
│   └── GlobalExceptionHandler.java
│
├── trainer/
│   ├── Trainer.java
│   ├── TrainerRepository.java
│   ├── TrainerService.java
│   └── TrainerController.java
│
├── pokemon/
│   ├── OwnedPokemon.java
│   ├── OwnedPokemonRepository.java
│   ├── OwnedPokemonService.java
│   └── OwnedPokemonController.java
│
├── trade/
│   ├── Trade.java
│   ├── TradeRepository.java
│   ├── TradeService.java
│   └── TradeController.java
│
├── market/
│   ├── SaleListing.java
│   ├── SaleListingRepository.java
│   ├── SaleListingService.java
│   └── SaleListingController.java
│
├── pokeapi/
│   ├── PokeApiClient.java
│   ├── PokeApiConfig.java
│   └── PokemonSpeciesDto.java
│
├── security/
│   ├── JwtService.java
│   ├── JwtFilter.java
│   ├── UserAccount.java
│   ├── UserAccountRepository.java
│   └── AuthController.java
│
└── InventoryServiceApplication.java

```

## 🧭 Feature Phases (TDD Roadmap)

### **Phase 0 – Project Skeleton (v0.0.1)**  

- Basic Spring Boot app boots  
- Add `/ping` with TDD  
- Testing environment prepared

### **Phase 1 – Trainers & Inventory (v0.1.0)**  

- Trainer creation  
- Add Pokémon to inventory  
- Basic services + controllers via TDD  

### **Phase 2 – PokeAPI Integration (v0.2.0)**  

- WebClient (WebFlux)  
- Species validation via PokeAPI  
- Error handling  

### **Phase 3 – Trades (v0.3.0)**  

- Create trade proposals  
- Accept/reject/cancel  
- Swapping Pokémon with TDD validations  

### **Phase 4 – Marketplace (v0.4.0)**  

- Create sale listing  
- Buy Pokémon  
- Cancel listings  

### **Phase 5 – Integration Testing (v0.5.0)**  

- Testcontainers + PostgreSQL  
- End-to-end tests  

### **Phase 6 – Security Skeleton (v0.6.0)**  

- Add Spring Security + JWT deps  
- Allow all traffic until JWT is implemented  

### **Phase 7 – Real JWT Auth (v0.7.0)**  

- Register/login trainers  
- Protect endpoints  
- JWT filter + token service  

### **Phase 8 – Developer Experience (v0.8.0)**  

- MapStruct  
- Flyway migrations  
- Swagger UI  
- Logging improvements  

---

## 📘 API Documentation

Swagger UI is available once SpringDoc is enabled:

```bash

[http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)

````

---

## 🧪 Running Tests

### Unit Tests

```bash
./gradlew test
````

### Integration Tests (requires Docker)

```bash
./gradlew test --tests "*IT"
```

Testcontainers will automatically start PostgreSQL.

---

## 🐳 Building a Docker Image

Spring Boot’s buildpacks make this easy:

```bash
./gradlew bootBuildImage
```

This generates a production-ready OCI image.

---

## 🚀 Project Includes

- **API development**
- **PokeAPI integration**
- **JPA/Hibernate**
- **Security + JWT**
- **Testcontainers integration tests**
- **Swagger (SpringDoc)**
- **DTO mapping (MapStruct)**
- **JSON logging**
- **Migrations (Flyway)**
- **DevTools hot restart**
- **H2 + Postgres switching**

---

## 🤝 Contributing

Contributions are welcome!
Follow the TDD workflow outlined in the version roadmap.

---
