#!/bin/bash

# Script de Backup para EssentialsX
# Guarda Mundo + Plugins (Homes, Warps, Inventarios)

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="/data/Backups/Essentials"
mkdir -p "$BACKUP_DIR"

echo "[Backup] Iniciando backup periódico: $TIMESTAMP"

# Guardamos World + Plugins
# Excluimos Dynmap o backups antiguos para ahorrar espacio
tar -czf "$BACKUP_DIR/backup-$TIMESTAMP.tar.gz" \
    /data/world \
    /data/plugins \
    --exclude "plugins/dynmap/web" \
    --exclude "plugins/Essentials/backup" \
    --exclude "/data/Backups"

# Retención: Borrar backups de más de 3 días para no llenar el disco
find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +3 -delete

echo "[Backup] Completado: $BACKUP_DIR/backup-$TIMESTAMP.tar.gz"
