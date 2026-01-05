#!/bin/bash
set -e

echo "🟢 [GITOPS] Iniciando sincronización de configuración..."

# Rutas
SOURCE_DIR="/opt/gitops"
DATA_DIR="/data"

# 1. Sincronizar JARs de PLUGINS (Prioridad: Versión del Repo)
# Borrado de JARs obsoletos
echo "   --> Limpiando plugins antiguos..."
find $DATA_DIR/plugins/ -maxdepth 1 -name "*.jar" -type f | while read jar; do
    filename=$(basename "$jar")
    if [ ! -f "$SOURCE_DIR/plugins/$filename" ]; then
        echo "       [DELETE] Eliminando plugin obsoleto: $filename"
        rm "$jar"
    fi
done

# 2. Sincronizar CONFIGURACIONES (Modo: GitOps Estricto)
# Sobrescribimos SIEMPRE los archivos que existen en el repo.
# No usamos --update porque el server puede haber tocado el timestamp al apagarse.
# No usamos --delete para no borrar datos de usuario (userdata, logs, etc).

echo "🔄 [CONFIGS] Forzando estado desde Git..."

# Configs de Mods
mkdir -p $DATA_DIR/config
rsync -av $SOURCE_DIR/config/ $DATA_DIR/config/

# Plugins y sus Configs
# Excluimos JARs aquí porque ya se manejan arriba (o se copiarán ahora si faltan)
# IMPORTANTE: Excluimos carpetas de DATOS dinámicos (userdata, warps) para no sobrescribir el progreso.
echo "⚙️ [PLUGINS] Sincronizando JARs y Configs..."
rsync -av \
    --exclude='userdata/' \
    --exclude='playerdata/' \
    --exclude='warps/' \
    --exclude='backups/' \
    --exclude='logs/' \
    --exclude='cache/' \
    --exclude='*.db' \
    --exclude='*.sqlite*' \
    --exclude='*.bin' \
    --exclude='*.log' \
    --exclude='*.dat' \
    --exclude='*.lock' \
    --exclude='luckperms-h2*' \
    --exclude='json-storage/' \
    --exclude='yaml-storage/' \
    --exclude='plugins/WorldGuard/worlds/' \
    --exclude='plugins/VotingPlugin/Data/' \
    --exclude='plugins/GrimAC/database/' \
    --exclude='plugins/ProtectionStones/blocks/' \
    $SOURCE_DIR/plugins/ $DATA_DIR/plugins/

# 3. Sincronizar Propiedades del Server (Si existen)
if [ -f "$SOURCE_DIR/server-config/server.properties" ]; then
    echo "   --> Forzando server.properties desde el repo..."
    cp $SOURCE_DIR/server-config/server.properties $DATA_DIR/server.properties
fi

echo "✅ [GITOPS] Sincronización completada. Arrancando servidor..."