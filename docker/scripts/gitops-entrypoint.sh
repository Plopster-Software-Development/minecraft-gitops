#!/bin/bash
set -e

echo "🟢 [GITOPS] Iniciando sincronización de configuración..."

# Rutas
SOURCE_DIR="/opt/gitops"
DATA_DIR="/data"

# 1. Sincronizar PLUGINS (Jars y Configs)
# Primero copiamos todo lo nuevo sin borrar nada (Seguridad)
echo "   --> Sincronizando Plugins y Configs..."
rsync -av --update $SOURCE_DIR/plugins/ $DATA_DIR/plugins/

# Borrado Selectivo: Solo eliminamos .jar que ya no están en el repo
# Esto evita borrar carpetas de datos (ej: plugins/Essentials/)
echo "   --> Limpiando plugins antiguos..."
find $DATA_DIR/plugins/ -maxdepth 1 -name "*.jar" -type f | while read jar; do
    filename=$(basename "$jar")
    if [ ! -f "$SOURCE_DIR/plugins/$filename" ]; then
        echo "       [DELETE] Eliminando plugin obsoleto: $filename"
        rm "$jar"
    fi
done

# 2. Sincronizar Configs de MODS
echo "🔄 Sincronizando configuraciones y plugins desde GitOps..."

# Sincronizamos CONFIGS con --update (protege cambios en runtime)
mkdir -p $DATA_DIR/config
rsync -av --update $SOURCE_DIR/config/ $DATA_DIR/config/

# Sincronizamos JARs SIN --update (siempre copia los del repo)
echo "📦 Copiando plugin JARs..."
rsync -av --include='*.jar' --exclude='*/' $SOURCE_DIR/plugins/ $DATA_DIR/plugins/

# Sincronizamos carpetas de configuración de plugins CON --update
echo "⚙️ Sincronizando configuraciones de plugins..."
rsync -av --update --exclude='*.jar' $SOURCE_DIR/plugins/ $DATA_DIR/plugins/

# 3. Sincronizar Propiedades del Server (Si existen)
if [ -f "$SOURCE_DIR/server-config/server.properties" ]; then
    echo "   --> Forzando server.properties desde el repo..."
    cp $SOURCE_DIR/server-config/server.properties $DATA_DIR/server.properties
fi

echo "✅ [GITOPS] Sincronización completada. Arrancando servidor..."