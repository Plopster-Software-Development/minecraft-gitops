#!/bin/bash
set -e

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="/data/Backups/Essentials"
mkdir -p "$BACKUP_DIR"

# SEGURIDAD: Garantizar que save-on se ejecute siempre, incluso si falla el script
trap 'echo "🛡️ [Safety] Restaurando autoguardado..."; rcon-cli "save-on"' EXIT

# 1. Forzar guardado y pausar escritura (vía RCON)
# Esto asegura que el backup no esté corrupto
echo "[Backup] Notificando al servidor y pausando autoguardado..."
rcon-cli "say 📦 Iniciando backup del sistema..."
rcon-cli "save-all flush"
rcon-cli "save-off"

# 2. Ejecutar el Backup
cd /data || { echo "❌ Error: No se pudo acceder a /data"; exit 1; }
shopt -s nullglob

FILES_TO_BACKUP=( "world" "plugins" "config" "server.properties" *.json )

echo "[Backup] Comprimiendo archivos..."
tar -czf "$BACKUP_DIR/backup-$TIMESTAMP.tar.gz" \
    --exclude "plugins/dynmap/web" \
    --exclude "Backups" \
    --exclude "logs" \
    --exclude "cache" \
    "${FILES_TO_BACKUP[@]}"

# 3. Reactivar el guardado
rcon-cli "save-on"
rcon-cli "say ✅ Backup finalizado correctamente."

# 4. Limpieza (Retención de 3 días)
find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +3 -delete

echo "✅ Proceso finalizado: backup-$TIMESTAMP.tar.gz"