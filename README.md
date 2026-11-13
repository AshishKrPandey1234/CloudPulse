# ⚡ CloudPulse: End-to-End Cloud DevOps & Telemetry Pipeline

[![CI/CD Pipeline](https://github.com/AshishKrPandey1234/CloudPulse/actions/workflows/deploy.yml/badge.svg)](https://github.com/AshishKrPandey1234/CloudPulse/actions/workflows/deploy.yml)
[![Java 21 LTS](https://img.shields.io/badge/Java-21%20LTS-ED8B00?logo=openjdk&logoColor=white)](https://adoptium.net/)
[![Spring Boot 3.3](https://img.shields.io/badge/Spring%20Boot-3.3.5-6DB33F?logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![Docker](https://img.shields.io/badge/Docker-Multi--Stage-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![AWS EC2](https://img.shields.io/badge/AWS-EC2%20Ubuntu-FF9900?logo=amazonec2&logoColor=white)](https://aws.amazon.com/ec2/)
[![Prometheus](https://img.shields.io/badge/Prometheus-v2.54-E6522C?logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-v11.2-F46800?logo=grafana&logoColor=white)](https://grafana.com/)
[![Python 3](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **CloudPulse** is a clean, streamlined, evaluation-ready DevOps engineering project built for **AshishKrPandey1234/CloudPulse**. It demonstrates enterprise-grade CI/CD automation, cloud deployment orchestration on AWS EC2, container security, multi-container Docker Compose management, automated Bash deployment with health-checks, synthetic Python health monitoring, and real-time observability using Prometheus and Grafana.

---

## 📋 Table of Contents
- [Architecture Diagram](#-architecture-diagram)
- [Leegality DevOps JD Alignment Matrix](#-leegality-devops-jd-alignment-matrix)
- [Tech Stack & Components](#-tech-stack--components)
- [Project Directory Structure](#-project-directory-structure)
- [Quick Start (Local Deployment)](#-quick-start-local-deployment)
- [Application API Endpoints & Verification](#-application-api-endpoints--verification)
- [CI/CD Pipeline Workflow (GitHub Actions)](#-cicd-pipeline-workflow-github-actions)
- [AWS EC2 Cloud Provisioning & Deployment](#-aws-ec2-cloud-provisioning--deployment)
- [Observability: Prometheus & Grafana Provisioning](#-observability-prometheus--grafana-provisioning)
- [Automation & Synthetics: Python Health Monitor](#-automation--synthetics-python-health-monitor)
- [Production Reliability & Rollback Strategy](#-production-reliability--rollback-strategy)
- [Author & Verification](#-author--verification)

---

## 🏗️ Architecture Diagram

```mermaid
flowchart TD
    subgraph Developer_Workstation["Developer Workstation"]
        Dev["Developer (Ashish Kumar Pandey)"] -->|git push origin main| GHRepo["GitHub Repo: AshishKrPandey1234/CloudPulse"]
    end

    subgraph GitHub_Actions["GitHub Actions CI/CD Pipeline"]
        GHRepo --> Job1["1. Test & Build\n(JDK 21, Maven, H2 DB)"]
        Job1 --> Job2["2. Docker Buildx & Publish\n(Multi-Stage Image)"]
        Job2 -->|Push Tagged Image| DHub[("Docker Hub Registry\nashishkrpandey1234/cloudpulse")]
        Job2 --> Job3["3. Secure SSH Deploy\n(EC2 Host Connection)"]
        Job3 --> Job4["4. Synthetic SLA Verification\n(health_monitor.py Prober)"]
    end

    subgraph AWS_Cloud["AWS Cloud: EC2 Virtual Machine (Ubuntu 24.04 LTS)"]
        Job3 -.->|SSH Key & SCP Configs| EC2Host["AWS EC2 Host Engine"]
        
        subgraph Docker_Compose_Stack["Docker Compose Orchestration Network"]
            DeployScript["deploy.sh Automation Script"] -->|Pull & Recreate| AppCont["Spring Boot Microservice\n(:8080)\nJava 21 JRE Alpine"]
            AppCont <-->|JDBC Port 3306| MySQLCont[("MySQL 8.0 Database\n(:3306)\nPersistent Volume")]
            
            PromCont["Prometheus Server\n(:9090)"] -->|Scrapes /actuator/prometheus\nEvery 10s| AppCont
            GrafCont["Grafana Dashboard\n(:3000)"] -->|Queries PromQL| PromCont
        end
    end

    subgraph Synthetics_Alerting["Synthetic Health Probing & Alerting"]
        PyMonitor["Python Health Monitor\n(scripts/health_monitor.py)"] -->|Pings /health every 10s| AppCont
        PyMonitor -->|SLA Breach / Outage| Webhook["Slack / Discord Webhook Alert"]
        PyMonitor -->|Audit Log| LogFile["health_monitor.log (JSON)"]
    end
```

---

## 🎯 Leegality DevOps JD Alignment Matrix

This project was built from the ground up to rigorously demonstrate the exact proficiencies required by **Leegality** for their DevOps engineering positions:

| Leegality Requirement | CloudPulse Implementation | Production Artifacts |
| :--- | :--- | :--- |
| **Linux Operating System & Administration** | Hardened Ubuntu 22.04/24.04 LTS setup, non-root user permissions (`cloudpulse` user UID 1001), UFW firewall management, log rotation policies to prevent disk full errors, POSIX bash scripting. | [`scripts/setup_ec2.sh`](scripts/setup_ec2.sh)<br>[`scripts/deploy.sh`](scripts/deploy.sh)<br>[`Dockerfile`](Dockerfile) |
| **Cloud Computing (AWS)** | AWS EC2 virtual machine hosting, VPC Security Groups configuring least-privilege ingress (ports 22, 8080, 9090, 3000), Elastic IP / DNS routing, and automated zero-downtime container updates. | [AWS EC2 Deployment Guide](#-aws-ec2-cloud-provisioning--deployment)<br>[`docker-compose.yml`](docker-compose.yml) |
| **DevOps & CI/CD Pipelines** | Fully automated 4-stage GitHub Actions pipeline triggering on `git push`: Maven unit/integration tests, Docker Buildx caching, Docker Hub publishing, automated remote SSH execution, and post-deploy synthetic validation. | [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) |
| **Containerization (Docker)** | Multi-stage `Dockerfile` with separate compilation and runtime stages reducing final footprint to <180MB, Alpine JRE base, container health checks, and Docker Compose multi-service networking. | [`Dockerfile`](Dockerfile)<br>[`docker-compose.yml`](docker-compose.yml)<br>[`.dockerignore`](.dockerignore) |
| **Automation & Scripting (Python & Bash)** | Production Bash deployment runner with error traps (`set -euo pipefail`), automated health polling, container recreation, image garbage collection; Python synthetic health prober with SLA latency measurement, JSON logging, and webhook alerting. | [`scripts/deploy.sh`](scripts/deploy.sh)<br>[`scripts/health_monitor.py`](scripts/health_monitor.py)<br>[`scripts/requirements.txt`](scripts/requirements.txt) |
| **Infrastructure & App Monitoring** | Spring Boot Actuator exposing Prometheus metrics, standalone Prometheus server scraping telemetry, pre-provisioned Grafana dashboard tracking JVM heap, response latencies (P95/P99), throughput, and database status. | [`monitoring/prometheus/prometheus.yml`](monitoring/prometheus/prometheus.yml)<br>[`monitoring/grafana/`](monitoring/grafana/) |

---

## 🛠️ Tech Stack & Components

1. **Application Layer**:
   - **Language**: Java 21 LTS (Eclipse Temurin)
   - **Framework**: Spring Boot 3.3.5
   - **Persistence**: Spring Data JPA & Hibernate
   - **Database**: MySQL 8.0 (with test fallback to in-memory H2)
   - **Telemetry Engine**: Spring Boot Actuator + Micrometer Prometheus Registry
2. **Containerization & Orchestration**:
   - **Engine**: Docker Engine & Docker Buildx
   - **Orchestrator**: Docker Compose V2
   - **Base Images**: `maven:3.9.8-eclipse-temurin-21-alpine` (Builder) & `eclipse-temurin:21-jre-alpine` (Runtime)
3. **Cloud & Infrastructure**:
   - **Cloud Provider**: Amazon Web Services (AWS)
   - **Compute**: Amazon EC2 (t2.micro / t3.small, Ubuntu Linux)
   - **Networking**: VPC Security Groups, Docker Bridge Network (`cloudpulse-network`)
4. **CI/CD Automation**:
   - **Runner**: GitHub Actions (Ubuntu Runner)
   - **Secrets Management**: GitHub Encrypted Secrets
   - **Registry**: Docker Hub (`ashishkrpandey1234/cloudpulse`)
5. **Monitoring & Synthetic Alerting**:
   - **Metrics Collector**: Prometheus v2.54.1
   - **Telemetry Visualization**: Grafana v11.2.0 (Auto-provisioned Dashboards & Datasources)
   - **Synthetic Prober**: Python 3.12 (`requests`, `json`, `logging`, `argparse`)

---

## 📁 Project Directory Structure

```text
CloudPulse/
├── .github/
│   └── workflows/
│       └── deploy.yml                       # Multi-stage CI/CD GitHub Actions pipeline
├── monitoring/
│   ├── prometheus/
│   │   └── prometheus.yml                   # Scrape configurations for Spring Boot Actuator
│   └── grafana/
│       └── provisioning/
│           ├── datasources/
│           │   └── datasource.yml           # Automatic Prometheus datasource provisioning
│           └── dashboards/
│               ├── dashboard.yml            # Dashboard provider configuration
│               └── cloudpulse-dashboard.json # Pre-built Grafana telemetry dashboard
├── scripts/
│   ├── deploy.sh                            # Production Bash continuous deployment script
│   ├── setup_ec2.sh                         # AWS EC2 Ubuntu bootstrap & hardening script
│   ├── health_monitor.py                    # Python synthetic prober, SLA analyzer & alert runner
│   └── requirements.txt                     # Python dependencies (requests, urllib3)
├── src/
│   ├── main/
│   │   ├── java/com/cloudpulse/
│   │   │   ├── CloudPulseApplication.java   # Spring Boot entry point & startup diagnostics
│   │   │   ├── controller/
│   │   │   │   ├── HealthController.java    # /health & / root endpoints with DB checks
│   │   │   │   └── StatusLogController.java # /api/status GET & POST endpoints
│   │   │   ├── model/
│   │   │   │   └── StatusLog.java           # JPA Entity for MySQL persistence
│   │   │   ├── repository/
│   │   │   │   └── StatusLogRepository.java # JPA Repository with custom query filters
│   │   │   └── dto/
│   │   │       ├── HealthResponse.java      # Structured JSON response DTO
│   │   │       └── StatusLogRequest.java    # Request payload DTO
│   │   └── resources/
│   │       ├── application.properties       # Core application & actuator settings
│   │       └── application-prod.properties  # Production HikariCP & database settings
│   └── test/
│       ├── java/com/cloudpulse/
│       │   └── CloudPulseApplicationTests.java # MockMvc unit & integration test suite
│       └── resources/
│           └── application.properties       # In-memory H2 configuration for CI tests
├── .dockerignore                            # Build context optimization rules
├── .gitignore                               # Git ignore exclusions
├── .env.example                             # Environment variable template
├── Dockerfile                               # Multi-stage Docker build file
├── docker-compose.yml                       # 4-tier stack (App, MySQL, Prometheus, Grafana)
├── init.sql                                 # MySQL database initialization script
├── mvnw                                     # Maven wrapper script (POSIX)
├── pom.xml                                  # Maven dependencies & build plugins
└── README.md                                # Comprehensive documentation
```

---

## 🚀 Quick Start (Local Deployment)

You can launch the entire CloudPulse stack locally using a single Docker Compose command without installing Java, Maven, or MySQL on your host machine.

### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (v24+) with Docker Compose V2 enabled.

### Step 1: Clone the Repository
```bash
git clone https://github.com/AshishKrPandey1234/CloudPulse.git
cd CloudPulse
```

### Step 2: Initialize Environment Variables
```bash
cp .env.example .env
```

### Step 3: Launch Full Multi-Container Stack
```bash
docker compose up -d --build
```

### Step 4: Verify Running Containers
```bash
docker compose ps
```
*Expected Output:*
```text
NAME                    IMAGE                             COMMAND                  SERVICE      STATUS                    PORTS
cloudpulse-app          ashishkrpandey1234/cloudpulse     "sh -c 'java $JAVA_O…"   app          Up (healthy)              0.0.0.0:8080->8080/tcp
cloudpulse-grafana      grafana/grafana:11.2.0            "/run.sh"                grafana      Up                        0.0.0.0:3000->3000/tcp
cloudpulse-mysql        mysql:8.0                         "docker-entrypoint.s…"   mysql        Up (healthy)              0.0.0.0:3306->3306/tcp
cloudpulse-prometheus   prom/prometheus:v2.54.1           "/bin/prometheus --c…"   prometheus   Up                        0.0.0.0:9090->9090/tcp
```

---

## 📡 Application API Endpoints & Verification

| Endpoint | HTTP Method | Description | Sample Response Code |
| :--- | :---: | :--- | :---: |
| `/health` | `GET` | Core application health, DB connection, uptime & memory | `200 OK` |
| `/api/status` | `GET` | Retrieves recent status pulses from MySQL | `200 OK` |
| `/api/status` | `POST` | Writes a new status heartbeat event to MySQL | `201 Created` |
| `/api/status/latest` | `GET` | Retrieves the most recent single pulse | `200 OK` |
| `/actuator/prometheus`| `GET` | Exposes standard Micrometer Prometheus metrics | `200 OK` |
| `/actuator/health` | `GET` | Standard Spring Boot Actuator health probe | `200 OK` |

### 1. Test Application Health Probe
```bash
curl -s http://localhost:8080/health | jq .
```
```json
{
  "status": "UP",
  "service": "CloudPulse-API",
  "version": "1.0.0",
  "environment": "production",
  "timestamp": "2026-11-14T00:50:12.184Z",
  "uptimeSeconds": 142,
  "databaseStatus": "CONNECTED",
  "systemMetrics": {
    "heapMemoryUsedMb": 68,
    "heapMemoryTotalMb": 256,
    "availableProcessors": 4
  }
}
```

### 2. Record a Status Heartbeat Event
```bash
curl -X POST http://localhost:8080/api/status \
  -H "Content-Type: application/json" \
  -d '{
    "serviceName": "DocumentSigningWorker",
    "status": "HEALTHY",
    "message": "Processed 45 signature transactions in batch with 0 errors",
    "environment": "production"
  }' | jq .
```
```json
{
  "id": 2,
  "serviceName": "DocumentSigningWorker",
  "status": "HEALTHY",
  "message": "Processed 45 signature transactions in batch with 0 errors",
  "environment": "production",
  "host": "ip-172-31-42-18",
  "createdAt": "2026-11-14T00:51:30.912"
}
```

### 3. Retrieve Latest Status Pulses
```bash
curl -s http://localhost:8080/api/status | jq .
```

### 4. Query Actuator Prometheus Metrics
```bash
curl -s http://localhost:8080/actuator/prometheus | grep "cloudpulse_"
```
```text
# HELP cloudpulse_health_checks_total Total number of health check requests received
# TYPE cloudpulse_health_checks_total counter
cloudpulse_health_checks_total{application="cloudpulse",endpoint="/health",} 14.0
# HELP cloudpulse_status_writes_total Total number of status log entries written
# TYPE cloudpulse_status_writes_total counter
cloudpulse_status_writes_total{application="cloudpulse",} 1.0
```

---

## 🔄 CI/CD Pipeline Workflow (GitHub Actions)

The repository includes a production-grade CI/CD pipeline in [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml).

### Workflow Jobs Breakdown:
1. **`test-and-build`**:
   - Checks out repository source.
   - Sets up **Java 21 (Eclipse Temurin)** with automated Maven caching.
   - Executes Spring Boot tests (`mvn clean test`) against an in-memory H2 database.
   - Archives Surefire test execution reports as pipeline artifacts.
   - Compiles and packages the runnable Spring Boot JAR.
2. **`build-and-push-docker`**:
   - Configures Docker Buildx.
   - Authenticates against Docker Hub using repository secrets.
   - Uses multi-stage caching (`type=gha`) to dramatically accelerate subsequent builds.
   - Builds and pushes images tagged with both `:latest` and the short git commit SHA (e.g. `:sha-a1b2c3d`).
3. **`deploy-to-aws-ec2`**:
   - Securely synchronizes `docker-compose.yml`, `monitoring/`, and `scripts/` to the AWS EC2 instance using SSH (`appleboy/scp-action`).
   - Executes the remote Bash deployment runner (`scripts/deploy.sh`) over encrypted SSH.
   - Recreates containers, validates the `/health` endpoint, and prunes old images.
4. **`synthetic-verification`**:
   - Spawns a Python 3.12 runner.
   - Executes `python scripts/health_monitor.py --host "http://${EC2_HOST}:8080" --once`.
   - Validates live endpoint SLA and database connectivity before marking pipeline successful.

### Required GitHub Repository Secrets

Configure the following secrets under **GitHub Repository -> Settings -> Secrets and variables -> Actions**:

| Secret Name | Description | Example / Format |
| :--- | :--- | :--- |
| `DOCKERHUB_USERNAME` | Your Docker Hub account username | `ashishkrpandey1234` |
| `DOCKERHUB_TOKEN` | Docker Hub Personal Access Token (Read & Write) | `dckr_pat_xxxxxxxxx` |
| `EC2_HOST` | Public IPv4 Address or Public DNS of your AWS EC2 instance | `3.85.120.45` |
| `EC2_USERNAME` | SSH username for the EC2 instance | `ubuntu` |
| `EC2_SSH_KEY` | Raw private SSH key content (`.pem` file) | `-----BEGIN RSA PRIVATE KEY-----...` |

---

## ☁️ AWS EC2 Cloud Provisioning & Deployment

Follow these steps to configure your AWS EC2 instance for hosting CloudPulse.

### Step 1: Launch EC2 Instance
1. Log in to the **AWS Management Console**.
2. Navigate to **EC2 -> Instances -> Launch an instance**.
3. **Name**: `CloudPulse-Production-Host`.
4. **AMI**: Ubuntu Server 24.04 LTS (HVM), SSD Volume Type (64-bit x86).
5. **Instance Type**: `t2.micro` (Free Tier eligible) or `t3.small`.
6. **Key Pair**: Create or select an existing RSA key pair (e.g. `cloudpulse-key.pem`).
7. **Storage**: 20 GiB gp3 root volume.

### Step 2: Configure AWS Security Group
Add the following Inbound Security Group rules:

| Type | Protocol | Port Range | Source | Purpose |
| :--- | :---: | :---: | :---: | :--- |
| SSH | TCP | `22` | `0.0.0.0/0` (or your IP) | Remote SSH administration & CI/CD deployment |
| Custom TCP | TCP | `8080` | `0.0.0.0/0` | CloudPulse Spring Boot REST API & Actuator |
| Custom TCP | TCP | `9090` | `0.0.0.0/0` | Prometheus Metrics Scraper UI |
| Custom TCP | TCP | `3000` | `0.0.0.0/0` | Grafana Telemetry Dashboard |

### Step 3: Run the Host Bootstrap Script
SSH into your fresh EC2 instance and execute the automated setup script:
```bash
ssh -i "cloudpulse-key.pem" ubuntu@<YOUR-EC2-PUBLIC-IP>
```
Once connected, run:
```bash
# Clone the repository
git clone https://github.com/AshishKrPandey1234/CloudPulse.git
cd CloudPulse

# Make scripts executable
chmod +x scripts/*.sh

# Run automated EC2 provisioning (installs Docker, Compose, UFW rules, and log rotation)
sudo ./scripts/setup_ec2.sh
```

### Step 4: Execute Initial Production Deployment
```bash
./scripts/deploy.sh
```

---

## 📊 Observability: Prometheus & Grafana Provisioning

CloudPulse is architected for **zero-manual-configuration observability**. Both the Prometheus scrape configuration and Grafana dashboards are fully automated via code provisioning.

### 1. Prometheus Telemetry (`:9090`)
- Accessible at: `http://<EC2-IP>:9090`
- Configured via [`monitoring/prometheus/prometheus.yml`](monitoring/prometheus/prometheus.yml).
- Automatically targets `app:8080` at path `/actuator/prometheus` with a 10-second scrape interval.

### 2. Grafana Dashboards (`:3000`)
- Accessible at: `http://<EC2-IP>:3000`
- **Default Credentials**: Username: `admin` | Password: `admin` (or configured in `.env`)
- Pre-loaded dashboard: **"CloudPulse Telemetry Dashboard"** located at [`monitoring/grafana/provisioning/dashboards/cloudpulse-dashboard.json`](monitoring/grafana/provisioning/dashboards/cloudpulse-dashboard.json).

#### Dashboard Metrics Visualized:
1. **Application State**: Real-time `UP` (Green) / `DOWN` (Red) status gauge.
2. **Health Check Counter**: Cumulative volume of `/health` queries.
3. **Status Pulses Recorded**: Cumulative database write operations.
4. **JVM Live Threads**: Monitored daemon and user JVM threads.
5. **HTTP Request Throughput**: Split by response code (`2xx`, `4xx`, `5xx`).
6. **Latency Percentiles (P95 & P99)**: Measured via Micrometer histograms.
7. **JVM Heap Utilization**: Allocated vs Used heap bytes.
8. **CPU Utilization**: Process CPU vs System Host CPU percentage.

---

## 🐍 Automation & Synthetics: Python Health Monitor

[`scripts/health_monitor.py`](scripts/health_monitor.py) is an intelligent synthetic health probe and monitoring daemon written in Python using `requests`.

### Key Capabilities:
- **Periodic Synthetic Probes**: Sends periodic requests to `/health`, validating both HTTP status codes and JSON payload integrity (`status == "UP"`).
- **Latency Tracking & SLA Breaches**: Measures response time in milliseconds with configurable SLA alert thresholds (e.g. alert if response > 500ms).
- **Outage Detection & State Transitions**: Detects consecutive failures to prevent false positives; triggers alerts on outage and emits recovery notifications when service recovers.
- **Webhook Integration**: Integrates directly with Slack, Discord, or Microsoft Teams webhooks.
- **CI/CD Integration (`--once` mode)**: Exits with returncode `0` on health and `1` on failure, allowing direct integration into deployment pipelines.
- **Structured JSON Logging**: Appends timestamped JSON logs to `health_monitor.log` for auditability.

### Usage Examples:

```bash
# 1. Install lightweight requirements
pip install -r scripts/requirements.txt

# 2. Run continuous monitor (every 10s with 500ms SLA threshold)
python scripts/health_monitor.py --host "http://localhost:8080" --interval 10 --threshold-ms 500

# 3. Run single check for CI/CD pipeline validation
python scripts/health_monitor.py --host "http://localhost:8080" --once

# 4. Run with webhook alerting enabled
python scripts/health_monitor.py \
  --host "http://localhost:8080" \
  --webhook-url "https://hooks.slack.com/services/XXXX/YYYY/ZZZZ"
```

*Sample Console Output:*
```text
========================================================================
   CloudPulse Automated Telemetry & Health Probe
   Host Target:  http://localhost:8080
   Probe Interval: 10s | Timeout: 5s | SLA: 500.0ms
========================================================================

2026-11-14T00:52:10.142Z | [HEALTHY] HTTP 200 | Latency:  18.42ms | DB: CONNECTED
2026-11-14T00:52:20.185Z | [HEALTHY] HTTP 200 | Latency:  14.88ms | DB: CONNECTED
2026-11-14T00:52:30.220Z | [HEALTHY] HTTP 200 | Latency:  16.12ms | DB: CONNECTED
```

---

## 🛡️ Production Reliability & Rollback Strategy

Production systems require clear failure isolation and recovery procedures. CloudPulse implements multiple layers of operational protection:

1. **Strict Shell Failure Handling**:
   - `scripts/deploy.sh` enforces `set -euo pipefail` and traps errors with line numbers.
2. **Rolling Recreation with Dependency Checks**:
   - The Spring Boot container will not start until MySQL passes its internal `mysqladmin ping` container healthcheck.
3. **Automated Health Polling Loop**:
   - After recreation, `deploy.sh` actively polls the `/health` endpoint for up to 60 seconds.
   - If the application fails to report `UP`, the script prints the last 50 lines of logs and halts deployment with exit code 1.
4. **Rollback Procedure**:
   - In case of a bad commit, GitHub Actions allows you to roll back immediately by re-running the workflow on a previous known good commit tag, or manually running:
   ```bash
   export DOCKER_IMAGE="ashishkrpandey1234/cloudpulse:<PREVIOUS_COMMIT_SHA>"
   ./scripts/deploy.sh
   ```
5. **Disk Full Prevention**:
   - `deploy.sh` automatically prunes dangling Docker images (`docker image prune -f --filter "until=24h"`).
   - `setup_ec2.sh` configures Docker daemon log rotation (`max-size: 20m`, `max-file: 3`) to ensure container logs never saturate EC2 disk storage.

---

## 👨‍💻 Author & Verification

- **Author**: Ashish Kumar Pandey
- **GitHub**: [@AshishKrPandey1234](https://github.com/AshishKrPandey1234)
- **Repository**: [AshishKrPandey1234/CloudPulse](https://github.com/AshishKrPandey1234/CloudPulse)
- **Role Target**: DevOps Intern @ **Leegality**

---

### License
This project is open-source and distributed under the [MIT License](LICENSE).
