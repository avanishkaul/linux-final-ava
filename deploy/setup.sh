#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Este script debe ejecutarse con sudo o como root."
  exit 1
fi


if ! command -v apt >/dev/null 2>&1; then
  echo "No se encontró apt. Este script está pensado para Ubuntu / Debian."
  exit 1
fi

echo "Actualizando paquetes..."
apt update -y
apt install -y git curl ufw docker.io docker-compose


if command -v systemctl >/dev/null 2>&1; then
  systemctl enable docker 2>/dev/null
  systemctl start docker 2>/dev/null
fi


WEBROOT="/opt/webapp/html"
mkdir -p "$WEBROOT"


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR" || exit 1


COMPOSE_URL="https://gist.githubusercontent.com/DarkestAbed/0c1cee748bb9e3b22f89efe1933bf125/raw/5801164c0a6e4df7d8ced00122c76895997127a2/docker-compose.yml"
curl -s -o docker-compose.yml "$COMPOSE_URL"


cat > "$WEBROOT/index.html" <<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Servidor Seguro</title>
  </head>
  <body>
    <h1>Servidor Seguro Propiedad de Ava - Acceso Restringido</h1>
  </body>
</html>
EOF


if [ ! -e "$SCRIPT_DIR/html" ]; then
  ln -s "$WEBROOT" "$SCRIPT_DIR/html"
fi


if id sysadmin >/dev/null 2>&1; then
  echo "Usuario sysadmin ya existe."
else
  useradd -m -s /bin/bash sysadmin
fi


if getent group docker >/dev/null 2>&1; then
  usermod -aG docker sysadmin
fi

echo "Módulo de aprovisionamiento completado."
