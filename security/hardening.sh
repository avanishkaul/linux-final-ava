#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Este script debe ejecutarse con sudo o como root."
  exit 1
fi




if command -v ufw >/dev/null 2>&1; then
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow 22/tcp
  ufw allow 8080/tcp
  ufw --force enable
else
  echo "ufw no está instalado."
fi

 
SSHD_CONFIG="/etc/ssh/sshd_config"

if grep -q "^PermitRootLogin" "$SSHD_CONFIG"; then
  sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONFIG"
else
  echo "PermitRootLogin no" >> "$SSHD_CONFIG"
fi

# Reiniciar servicio SSH
if command -v systemctl >/dev/null 2>&1; then
  systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null
fi

 
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ -f "$REPO_DIR/deploy/setup.sh" ]; then
  chmod 700 "$REPO_DIR/deploy/setup.sh"
fi

if [ -f "$REPO_DIR/security/hardening.sh" ]; then
  chmod 700 "$REPO_DIR/security/hardening.sh"
fi

if [ -f "$REPO_DIR/maintenance/backup.sh" ]; then
  chmod 700 "$REPO_DIR/maintenance/backup.sh"
fi

if [ -f "$REPO_DIR/deploy/docker-compose.yml" ]; then
  chmod 600 "$REPO_DIR/deploy/docker-compose.yml"
fi

echo "Módulo de hardening completado."
