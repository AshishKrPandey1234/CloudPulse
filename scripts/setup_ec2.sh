#!/usr/bin/env bash
# ===================================================================
# CloudPulse AWS EC2 Provisioning & Hardening Script
# Target OS: Ubuntu 22.04 / 24.04 LTS (AWS EC2 t2.micro / t3.small)
# Author: Ashish Kumar Pandey (ashishkrpandey1234)
# ===================================================================

set -euo pipefail

echo "=================================================================="
echo " CloudPulse AWS EC2 Host Bootstrap & Hardening"
echo "=================================================================="

# Check if running as root
if [[ "${EUID}" -ne 0 ]]; then
    echo "[-] Please execute this script as root or with sudo."
    exit 1
fi

echo "[+] Step 1: Updating system packages and installing essentials..."
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    jq \
    ufw \
    htop \
    python3 \
    python3-pip \
    python3-venv

echo "[+] Step 2: Setting up official Docker repository..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y

echo "[+] Step 3: Installing Docker Engine, CLI, and Docker Compose Plugin..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[+] Step 4: Configuring Docker Daemon (log rotation to prevent disk exhaustion)..."
mkdir -p /etc/docker
cat << 'EOF' > /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "20m",
    "max-file": "3"
  }
}
EOF

systemctl enable docker
systemctl restart docker

echo "[+] Step 5: Granting docker socket permissions to 'ubuntu' user..."
if id "ubuntu" &>/dev/null; then
    usermod -aG docker ubuntu
    echo "[✓] User 'ubuntu' added to docker group."
fi

echo "[+] Step 6: Configuring UFW (Uncomplicated Firewall) rules..."
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment "SSH Remote Administration"
ufw allow 8080/tcp comment "CloudPulse Spring Boot Application"
ufw allow 9090/tcp comment "Prometheus Metrics Server"
ufw allow 3000/tcp comment "Grafana Telemetry Dashboard"
echo "y" | ufw enable || true

echo "[+] Step 7: Creating deployment directory at /home/ubuntu/cloudpulse..."
TARGET_DIR="/home/ubuntu/cloudpulse"
mkdir -p "${TARGET_DIR}"
chown -R ubuntu:ubuntu "${TARGET_DIR}" || true

echo "=================================================================="
echo " CloudPulse EC2 Bootstrap Completed Successfully!"
echo " Docker Version:  $(docker --version)"
echo " Compose Version: $(docker compose version)"
echo " Project Directory: ${TARGET_DIR}"
echo " Note: Run 'newgrp docker' or re-login to apply docker group changes."
echo "=================================================================="
