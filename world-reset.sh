#!/bin/bash

# --- CONFIGURACIÓN ---
NAMESPACE="minecraft"
DEPLOYMENT="survival-server-minecraft"
DATE=$(date +%Y%m%d_%H%M%S)

echo "====================================================="
echo "🚀 INICIANDO RESETEO TOTAL: TEMPORADA ASTRALIS 🚀"
echo "====================================================="

# 1. Obtener el nombre del Pod
POD_NAME=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/instance=$DEPLOYMENT -o jsonpath="{.items[0].metadata.name}")

if [ -z "$POD_NAME" ]; then
    echo "❌ ERROR: No se encontró el Pod. ¿Está el servidor encendido?"
    exit 1
fi

# 2. Detectar dinámicamente el nombre del mundo actual
WORLD_NAME=$(kubectl exec -n $NAMESPACE $POD_NAME -- grep "level-name" /data/server.properties | cut -d'=' -f2 | tr -d '\r')
echo "📦 Pod detectado: $POD_NAME"
echo "🌍 Mundo activo detectado: '$WORLD_NAME'"

# 3. Backup de seguridad (Pre-wipe)
echo "📂 Creando backup total antes del borrado..."
kubectl exec -n $NAMESPACE $POD_NAME -- tar -czf /data/Backups/PRE_RESET_$DATE.tar.gz --exclude=/data/Backups /data
echo "✅ Backup guardado en: /data/Backups/PRE_RESET_$DATE.tar.gz"

# 4. Limpieza Profunda de Datos
echo "-----------------------------------------------------"
echo "🧹 Iniciando limpieza de archivos..."

# Reset de Plugins (Spawn y Datos de Jugador)
echo "📍 Borrando puntos de spawn viejos (Essentials/AuthMe)..."
kubectl exec -n $NAMESPACE $POD_NAME -- rm -f /data/plugins/Essentials/spawn.yml
kubectl exec -n $NAMESPACE $POD_NAME -- rm -f /data/plugins/AuthMe/spawn.yml

echo "💰 Limpiando bases de datos de jugadores (Economía/Homes)..."
kubectl exec -n $NAMESPACE $POD_NAME -- rm -rf /data/plugins/Essentials/userdata
kubectl exec -n $NAMESPACE $POD_NAME -- rm -rf /data/plugins/Essentials/userdata-npc-backup

# Reset de Mapa (Mundo y dimensiones extra)
echo "🌍 Borrando carpetas del mapa y dimensiones ($WORLD_NAME)..."
# Borramos la carpeta principal y posibles carpetas separadas de dimensiones (común en Mohist/Forge)
kubectl exec -n $NAMESPACE $POD_NAME -- rm -rf /data/$WORLD_NAME
kubectl exec -n $NAMESPACE $POD_NAME -- rm -rf /data/${WORLD_NAME}_nether
kubectl exec -n $NAMESPACE $POD_NAME -- rm -rf /data/${WORLD_NAME}_the_end

# Limpieza de logs para empezar de cero
echo "📝 Limpiando logs antiguos..."
kubectl exec -n $NAMESPACE $POD_NAME -- rm -rf /data/logs/*

echo "✅ Limpieza completada."
echo "-----------------------------------------------------"

# 5. Validación de GitOps
echo "⚠️  CRÍTICO: El Pod se reiniciará con la configuración actual de tu repositorio."
read -p "¿Confirmas que el YAML en Git tiene la SEED y MODS correctos? (s/n): " confirmacion

if [ "$confirmacion" != "s" ]; then
    echo "⏸️  Proceso pausado. Sube tus cambios a Git y luego ejecuta: 'kubectl rollout restart deployment $DEPLOYMENT -n $NAMESPACE'"
    exit 0
fi

# 6. Reinicio y Aplicación
echo "🔄 Reiniciando el despliegue para generar el nuevo universo..."
kubectl rollout restart deployment $DEPLOYMENT -n $NAMESPACE

echo ""
echo "✨ ¡TEMPORADA RESETEADA CON ÉXITO! ✨"
echo "📡 Monitorea el arranque: kubectl logs -f -n $NAMESPACE -l app.kubernetes.io/instance=$DEPLOYMENT"