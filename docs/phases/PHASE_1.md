# SQL

> Table Architecture for Phase 1 of project

---

## ✅ What your **initial DB should contain (v1)**

At the beginning, your database should only store **state you own**.
Anything that comes from **PokeAPI** must **NOT** be stored.

### You SHOULD store

* Trainers
* Owned Pokémon (inventory)
* Trades
* Sale listings
* User accounts (for JWT later, optional now)

### You SHOULD NOT store

* Pokémon species
* Moves
* Types
* Stats
  (these come from PokeAPI)

---

## 1️⃣ `trainer`

This is the core domain owner.

```sql
CREATE TABLE trainer (
    id UUID PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

***Why:***

* `username` is your public identifier
* `display_name` is cosmetic
* `created_at` helps with auditing later

---

## 2️⃣ `owned_pokemon`

Each row = **one Pokémon owned by a trainer**

```sql
CREATE TABLE owned_pokemon (
    id UUID PRIMARY KEY,
    trainer_id UUID NOT NULL,
    species_name VARCHAR(50) NOT NULL,
    pokeapi_id INTEGER,
    nickname VARCHAR(50),
    level INTEGER NOT NULL DEFAULT 1,
    shiny BOOLEAN NOT NULL DEFAULT FALSE,
    status VARCHAR(20) NOT NULL,
    acquired_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_owned_pokemon_trainer
        FOREIGN KEY (trainer_id)
        REFERENCES trainer(id)
        ON DELETE CASCADE
);
```

***Why:***

* `species_name` / `pokeapi_id` are references, not duplicated data
* `status` supports:

  * `ACTIVE`
  * `LISTED`
  * `TRADED`
  * `SOLD`
* `ON DELETE CASCADE` cleans inventory if a trainer is deleted

---

## 3️⃣ `trade`

Represents a trade proposal or completed trade.

```sql
CREATE TABLE trade (
    id UUID PRIMARY KEY,
    initiator_id UUID NOT NULL,
    recipient_id UUID NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,

    CONSTRAINT fk_trade_initiator
        FOREIGN KEY (initiator_id)
        REFERENCES trainer(id),

    CONSTRAINT fk_trade_recipient
        FOREIGN KEY (recipient_id)
        REFERENCES trainer(id)
);
```

***Why:***

* Separates trade metadata from Pokémon involved
* Allows trade lifecycle management

---

## 4️⃣ `trade_pokemon`

Join table for Pokémon involved in trades.

```sql
CREATE TABLE trade_pokemon (
    trade_id UUID NOT NULL,
    owned_pokemon_id UUID NOT NULL,
    role VARCHAR(20) NOT NULL,

    PRIMARY KEY (trade_id, owned_pokemon_id),

    CONSTRAINT fk_trade_pokemon_trade
        FOREIGN KEY (trade_id)
        REFERENCES trade(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_trade_pokemon_owned
        FOREIGN KEY (owned_pokemon_id)
        REFERENCES owned_pokemon(id)
);
```

***Role Values:***

* `INITIATOR`
* `RECIPIENT`

***Why:***

* Flexible (1-for-1, many-for-one, etc.)
* Avoids two separate join tables

---

## 5️⃣ `sale_listing`

Marketplace listings.

```sql
CREATE TABLE sale_listing (
    id UUID PRIMARY KEY,
    pokemon_id UUID NOT NULL UNIQUE,
    seller_id UUID NOT NULL,
    buyer_id UUID,
    price NUMERIC(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP,

    CONSTRAINT fk_listing_pokemon
        FOREIGN KEY (pokemon_id)
        REFERENCES owned_pokemon(id),

    CONSTRAINT fk_listing_seller
        FOREIGN KEY (seller_id)
        REFERENCES trainer(id),

    CONSTRAINT fk_listing_buyer
        FOREIGN KEY (buyer_id)
        REFERENCES trainer(id)
);
```

***Why:***

* `pokemon_id` UNIQUE → a Pokémon can’t be listed twice
* `buyer_id` nullable until sold
* Supports `ACTIVE`, `SOLD`, `CANCELLED`

---

## 6️⃣ (Optional now, required later) `user_account`

For JWT authentication.

```sql
CREATE TABLE user_account (
    id UUID PRIMARY KEY,
    trainer_id UUID NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_trainer
        FOREIGN KEY (trainer_id)
        REFERENCES trainer(id)
        ON DELETE CASCADE
);
```

***Why:***

* Decouples auth from game logic
* Makes JWT + RBAC easy later

---

## 📁 How this should exist in your project

Because you’re using **Flyway**, your **init DB should be a migration**, not a manual script.

### 📂 Recommended structure

```bash
src/main/resources/db/migration/
└── V1__init.sql
```

---

## 🧪 Works with

* H2 (dev)
* PostgreSQL (prod)
* Testcontainers
* JPA/Hibernate
* Flyway versioning

---

## 🔮 Future migrations (planned)

* `V2__add_trade_audit.sql`
* `V3__add_balance_and_currency.sql`
* `V4__add_soft_delete_flags.sql`
* `V5__add_event_log.sql`

---

**init DB should:**

* Be **minimal**
* Store **only what you own**
* Avoid Pokémon metadata
* Be delivered via **Flyway**
* Match your domain model exactly

---
