#!/bin/bash
set -e

echo "🟢 [GITOPS] Iniciando sincronización de configuración..."

# Rutas
SOURCE_DIR="/opt/gitops"
DATA_DIR="/data"

# 1. Sincronizar PLUGINS (Jars y Configs)
# Usamos rsync para copiar solo lo nuevo o modificado, sin borrar datos de usuarios (bases de datos)
echo "   --> Sincronizando Plugins y Configs..."
rsync -av --update $SOURCE_DIR/plugins/ $DATA_DIR/plugins/

# 2. Sincronizar Configs de MODS
echo "   --> Sincronizando Configs de Forge..."
mkdir -p $DATA_DIR/config
rsync -av --update $SOURCE_DIR/config/ $DATA_DIR/config/

# 3. Sincronizar Propiedades del Server (Si existen)
if [ -f "$SOURCE_DIR/server-config/server.properties" ]; then
    echo "   --> Forzando server.properties desde el repo..."
    cp $SOURCE_DIR/server-config/server.properties $DATA_DIR/server.properties
fi

echo "✅ [GITOPS] Sincronización completada. Arrancando servidor..."