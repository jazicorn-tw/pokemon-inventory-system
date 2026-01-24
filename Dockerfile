# syntax=docker/dockerfile:1.7

FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# Stable Gradle cache location for BuildKit
ENV GRADLE_USER_HOME=/home/gradle/.gradle

COPY gradlew ./
COPY gradle/ ./gradle/
COPY build.gradle settings.gradle ./

# Warm dependency cache (quiet, cached across builds)
RUN --mount=type=cache,target=/home/gradle/.gradle \
    chmod +x ./gradlew && \
    ./gradlew --no-daemon -q dependencies || true

COPY src/ ./src/

# Build application JAR (no clean, quiet output, cached deps)
RUN --mount=type=cache,target=/home/gradle/.gradle \
    ./gradlew --no-daemon bootJar

FROM eclipse-temurin:21-jre AS run
WORKDIR /app

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash appuser
USER appuser

COPY --from=build /app/build/libs/*.jar /app/app.jar

ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75 -XX:+UseG1GC -XX:+ExitOnOutOfMemoryError -Djava.security.egd=file:/dev/./urandom "

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=3s --start-period=20s --retries=10 \
  CMD curl -fsS http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java","-jar","/app/app.jar"]
