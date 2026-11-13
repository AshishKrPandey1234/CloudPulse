#!/usr/bin/env bash
# ===================================================================
# CloudPulse Automated Continuous Deployment Script
# Target: AWS EC2 Ubuntu Host Running Docker & Docker Compose
# Author: Ashish Kumar Pandey (ashishkrpandey1234)
# ===================================================================

set -euo pipefail
IFS=$'\n\t'

# -------------------------------------------------------------------
# Colors & Formatting
# -------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# -------------------------------------------------------------------
# Logging Helpers
# -------------------------------------------------------------------
log_info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] [INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] [SUCCESS]${NC} ${BOLD}$1${NC}"
}

log_warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] [WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] [ERROR]${NC} ${BOLD}$1${NC}" >&2
}

# -------------------------------------------------------------------
# Error Trap & Cleanup
# -------------------------------------------------------------------
on_error() {
    local exit_code=$?
    local line_number=$1
    log_error "Deployment failed at line ${line_number} with exit code ${exit_code}!"
    exit "${exit_code}"
}
trap 'on_error $LINENO' ERR

# -------------------------------------------------------------------
# Configuration Defaults
# -------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${PROJECT_ROOT}/.env"
HEALTH_CHECK_URL="http://localhost:8080/health"
MAX_HEALTH_ATTEMPTS=15
HEALTH_INTERVAL=4
COMPOSE_FILE="${PROJECT_ROOT}/docker-compose.yml"

echo -e "${CYAN}${BOLD}"
cat << "EOF"
  ____ _                 _ ____        _           
 / ___| | ___  _   _  __| |  _ \ _   _| |___  ___  
| |   | |/ _ \| | | |/ _` | |_) | | | | / __|/ _ \ 
| |___| | (_) | |_| | (_| |  __/| |_| | \__ \  __/ 
 \____|_|\___/ \__,_|\__,_|_|    \__,_|_|___/\___| 
            Production Deployment Automation
EOF
echo -e "${NC}"

log_info "Starting deployment workflow..."
log_info "Project Directory: ${PROJECT_ROOT}"

# -------------------------------------------------------------------
# Step 1: Pre-flight Verification
# -------------------------------------------------------------------
log_info "Step 1: Validating environment and tools..."

cd "${PROJECT_ROOT}"

if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed or not in PATH. Please install Docker."
    exit 1
fi

# Detect docker compose plugin vs standalone binary
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    log_error "Neither 'docker compose' nor 'docker-compose' could be located."
    exit 1
fi
log_info "Using Docker Compose command: ${COMPOSE_CMD}"

# Load environment configuration if available
if [[ -f "${ENV_FILE}" ]]; then
    log_info "Loading environment variables from ${ENV_FILE}"
    # shellcheck disable=SC1090
    set -a && source "${ENV_FILE}" && set +a
else
    log_warn "No .env file found at ${ENV_FILE}. Using default environment variables."
fi

# -------------------------------------------------------------------
# Step 2: Pull Latest Docker Images
# -------------------------------------------------------------------
log_info "Step 2: Pulling latest container images from registry..."
DOCKER_IMAGE="${DOCKER_IMAGE:-ashishkrpandey1234/cloudpulse:latest}"
log_info "Target Application Image: ${DOCKER_IMAGE}"

${COMPOSE_CMD} -f "${COMPOSE_FILE}" pull

# -------------------------------------------------------------------
# Step 3: Rolling Update / Container Recreation
# -------------------------------------------------------------------
log_info "Step 3: Recreating containers with zero-downtime rolling restart..."
${COMPOSE_CMD} -f "${COMPOSE_FILE}" up -d --remove-orphans

# -------------------------------------------------------------------
# Step 4: Health Check & Verification
# -------------------------------------------------------------------
log_info "Step 4: Executing post-deployment health verification..."
log_info "Waiting for service to report UP at ${HEALTH_CHECK_URL}..."

attempt=1
healthy=false

while [[ ${attempt} -le ${MAX_HEALTH_ATTEMPTS} ]]; do
    if curl -s -f -m 3 "${HEALTH_CHECK_URL}" | grep -q '"status":"UP"'; then
        healthy=true
        break
    else
        echo -ne "${YELLOW}•${NC}"
        sleep "${HEALTH_INTERVAL}"
        attempt=$((attempt + 1))
    fi
done
echo ""

if [[ "${healthy}" == true ]]; then
    log_success "Health check PASSED on attempt ${attempt}!"
else
    log_error "Health check FAILED after ${MAX_HEALTH_ATTEMPTS} attempts!"
    log_error "Dumping recent container logs for diagnosis:"
    ${COMPOSE_CMD} -f "${COMPOSE_FILE}" logs --tail 50 app
    exit 1
fi

# -------------------------------------------------------------------
# Step 5: Clean Up Dangling Docker Resources
# -------------------------------------------------------------------
log_info "Step 5: Pruning dangling Docker images and build caches..."
docker image prune -f --filter "until=24h" || true

# -------------------------------------------------------------------
# Step 6: Deployment Summary
# -------------------------------------------------------------------
log_success "Deployment completed successfully! Container status:"
${COMPOSE_CMD} -f "${COMPOSE_FILE}" ps

echo ""
log_info "Endpoint Verification:"
log_info "  Application Health:  ${HEALTH_CHECK_URL}"
log_info "  Status API:          http://localhost:8080/api/status"
log_info "  Prometheus Metrics:  http://localhost:8080/actuator/prometheus"
log_info "  Grafana Dashboard:   http://localhost:3000"
echo ""
