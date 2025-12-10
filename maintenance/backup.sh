#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Este script debe ejecutarse con sudo o como root."
  exit 1
fi

ORIG_DIR="/opt/webapp/html"
LOCAL_BACKUP_DIR="/var/backups/webapp"

if [ ! -d "$ORIG_DIR" ]; then
  echo "No existe el directorio $ORIG_DIR"
  exit 1
fi

mkdir -p "$LOCAL_BACKUP_DIR"

TIMESTAMP=$(date +%F_%H%M)
BACKUP_NAME="backup_web_${TIMESTAMP}.tar.gz"
TEMP_PATH="/tmp/$BACKUP_NAME"

 
tar -czf "$TEMP_PATH" -C /opt/webapp html

 
rsync -av "$TEMP_PATH" "$LOCAL_BACKUP_DIR/"

 
REMOTE_DEST="backup@localhost:/backups/webapp/"
scp -o BatchMode=yes "$TEMP_PATH" "$REMOTE_DEST" 2>/dev/null
SCP_EXIT=$?

echo "Backup local generado en: $TEMP_PATH"
echo "Copiado a: $LOCAL_BACKUP_DIR"
echo "Código de salida de scp: $SCP_EXIT"
