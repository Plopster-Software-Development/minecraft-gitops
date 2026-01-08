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
# Usamos --no-o --no-g porque si corremos como non-root, rsync falla al intentar setear owner/group
rsync -avc --no-o --no-g $SOURCE_DIR/config/ $DATA_DIR/config/

# 2.5 Sincronizar Server Configs (Para mundos existentes)
# Minecraft ignora cambios en config/*-server.toml si ya existe una copia en world/serverconfig.
# Forzamos la actualización si la carpeta del mundo existe.
if [ -d "$DATA_DIR/world/serverconfig" ]; then
    echo "🌍 [WORLD] Actualizando configs de servidor en world/serverconfig..."
    # Copiamos cualquier archivo -server.toml desde configs
    # Copiamos solo los archivos que terminan en -server.toml
    cp -v $DATA_DIR/config/*-server.toml $DATA_DIR/world/serverconfig/ 2>/dev/null || true
fi

# Plugins y sus Configs
# Excluimos JARs aquí porque ya se manejan arriba (o se copiarán ahora si faltan)
# IMPORTANTE: Excluimos carpetas de DATOS dinámicos (userdata, warps) para no sobrescribir el progreso.
echo "⚙️ [PLUGINS] Sincronizando JARs y Configs..."
rsync -avci --no-o --no-g \
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
    --exclude='WorldGuard/worlds/' \
    --exclude='VotingPlugin/Data/' \
    --exclude='GrimAC/database/' \
    --exclude='ProtectionStones/blocks/' \
    $SOURCE_DIR/plugins/ $DATA_DIR/plugins/

# 3. Sincronizar Propiedades del Server (Si existen)
if [ -f "$SOURCE_DIR/server-config/server.properties" ]; then
    echo "   --> Forzando server.properties desde el repo..."
    cp $SOURCE_DIR/server-config/server.properties $DATA_DIR/server.properties
fi

# 4. Ajustar Permisos FINAL (Crucial para imagenes de itzg)
# MOVIDO AL FINAL: Ejecutamos esto AL FINAL para asegurar que todo lo copiado 
# (incluso si rsync corrió como root) pertenezca al usuario minecraft (1000).
if [ "$(id -u)" -eq 0 ]; then
    echo "👮 [PERMISSIONS] Ajustando propietario a 1000:1000..."
    chown -R 1000:1000 $DATA_DIR/config
    chown -R 1000:1000 $DATA_DIR/plugins
    if [ -d "$DATA_DIR/world/serverconfig" ]; then
        chown -R 1000:1000 $DATA_DIR/world/serverconfig
    fi
    if [ -f "$DATA_DIR/server.properties" ]; then
        chown 1000:1000 "$DATA_DIR/server.properties"
    fi
else
    echo "⚠️ [PERMISSIONS] Saltando ajuste de permisos (No soy root, UID=$(id -u))"
fi

echo "✅ [GITOPS] Sincronización completada. Arrancando servidor..."