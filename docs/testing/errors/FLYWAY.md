# Flyway Errors

Flyway issues during tests are almost always caused by **schema state mismatches**
or **unexpected persistence** across runs.

## 1. Validation failed

**Error example:**

```bash
Validate failed: Migrations have failed validation
```

**Cause:**

- A migration file was edited after it was already applied
- The checksum stored in `flyway_schema_history` no longer matches
- A persisted Docker volume is reusing old schema state

**Fix:**

- For ephemeral Testcontainers databases: re-run the tests (fresh container)
- If volumes are persisted:

  ```bash
  docker volume ls
  docker volume rm <volume_name>
  ```

## 2. No migrations found

**Error example:**

```bash
Found no migration scripts in configured locations
```

**Cause:**

- Migrations are not in the default Flyway location
- `spring.flyway.locations` is misconfigured
- Migrations were accidentally placed under `src/test/resources`

**Fix:**

- Ensure migrations live in:

  ```bash
  src/main/resources/db/migration
  ```

- Or explicitly configure:

  ```properties
  spring.flyway.locations=classpath:db/migration
  ```

## 3. Flyway is disabled

**Error example:**

```bash
Flyway is disabled
```

**Cause:**

- `spring.flyway.enabled=false` in a profile or environment variable
- Test profile overriding application defaults

**Fix:**

- Ensure test profile enables Flyway:

  ```properties
  spring.flyway.enabled=true
  ```

## 4. Schema history table errors

**Error examples:**

```bash
relation "flyway_schema_history" does not exist
permission denied for schema public
```

**Cause:**

- Database user lacks permissions
- Schema mismatch
- Custom schema without proper configuration

**Fix:**

- Ensure the test DB user owns the schema
- Or configure schema explicitly:

  ```properties
  spring.flyway.schemas=public
  ```

## 5.  Out-of-order or version conflicts

**Error example:**

```bash
Detected resolved migration not applied to database
```

**Cause:**

- Version numbers skipped or reordered
- Multiple developers adding migrations concurrently

**Fix:**

- Rename migrations to maintain monotonic ordering
- Avoid `outOfOrder=true` in tests unless absolutely necessary

## 6. Baseline vs validate confusion

**Error example:**

```bash
Found non-empty schema but no schema history table
```

**Cause:**

- Database already contains tables
- Flyway expects an empty schema

**Fix (tests only):**

- Prefer clean containers
- Avoid `baselineOnMigrate` unless you know why you need it

## 7. Test profile overrides breaking Flyway

**Cause:**

- `application-test.properties` overriding Flyway settings unexpectedly

**Fix:**

- Keep test Flyway config minimal:

  ```properties
  spring.flyway.enabled=true
  spring.jpa.hibernate.ddl-auto=validate
  ```

- Do **not** mix Hibernate schema generation with Flyway

## 8. Golden rules for Flyway in tests

- ❌ Never edit an applied migration
- ❌ Never rely on persisted DB state
- ✅ Prefer fresh containers per test run
- ✅ Let Flyway own the schema
- ✅ Keep Hibernate in `validate` mode only
