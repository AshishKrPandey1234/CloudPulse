# ===================================================================
# Multi-Stage Dockerfile for CloudPulse Spring Boot Microservice
# Stage 1: Maven Builder (Compiles & Packages Optimized JAR)
# Stage 2: Distroless/Alpine JRE Runtime (Secure, Minimal Attack Surface)
# ===================================================================

# -------------------------------------------------------------------
# Stage 1: Build Artifact
# -------------------------------------------------------------------
FROM maven:3.9.8-eclipse-temurin-21-alpine AS builder

WORKDIR /build

# Optimize Docker layer caching: Copy only pom.xml and fetch dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build executable jar
COPY src ./src
RUN mvn clean package -DskipTests -B

# -------------------------------------------------------------------
# Stage 2: Production Runtime
# -------------------------------------------------------------------
FROM eclipse-temurin:21-jre-alpine

# Metadata
LABEL maintainer="Ashish Kumar Pandey <ashishkrpandey1234@github>" \
      project="CloudPulse" \
      version="1.0.0" \
      description="Lightweight DevOps Health & Telemetry Microservice"

# Install curl for container healthcheck and configure timezone
RUN apk add --no-cache curl tzdata

# Security Best Practice: Run as unprivileged non-root user
RUN addgroup -S cloudpulse && adduser -S cloudpulse -G cloudpulse

WORKDIR /app

# Copy packaged JAR from builder stage with correct permissions
COPY --from=builder --chown=cloudpulse:cloudpulse /build/target/*.jar /app/cloudpulse.jar

# Switch to unprivileged user
USER cloudpulse

# JVM Tuning for Container Environments (Respect cgroups & limit heap)
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC -XX:+ExitOnOutOfMemoryError -Djava.security.egd=file:/dev/./urandom" \
    SERVER_PORT=8080

EXPOSE 8080

# Built-in Docker Container Health Check
HEALTHCHECK --interval=20s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/cloudpulse.jar"]
