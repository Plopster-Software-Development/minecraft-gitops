#!/bin/bash

# --- CONFIGURACIÓN ---
NAMESPACE="minecraft"
DEPLOYMENT="survival-server-minecraft"
BACKUP_PATH="/data/Backups/Essentials"
DATE=$(date +%Y%m%d_%H%M%S)

echo "🚀 Iniciando proceso de reseteo del mundo 'Astralis'..."

# 1. Obtener el nombre del Pod
POD_NAME=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/instance=survival-server-minecraft -o jsonpath="{.items[0].metadata.name}")

if [ -z "$POD_NAME" ]; then
    echo "❌ ERROR: No se encontró el Pod de Minecraft. ¿Está el servidor encendido?"
    exit 1
fi

echo "📦 Trabajando sobre el Pod: $POD_NAME"

# 2. Backup de seguridad (Pre-wipe)
echo "📂 Creando backup total del mundo antiguo..."
kubectl exec -n $NAMESPACE $POD_NAME -- tar -czf /data/Backups/FULL_SERVER_$DATE.tar.gz --exclude=/data/Backups /data
echo "✅ Backup guardado en: /data/Backups/FULL_SERVER_$DATE.tar.gz"

# 3. Limpieza de datos
echo "💰 Reseteando datos de jugadores (Economía y Homes de Essentials)..."
kubectl exec -n $NAMESPACE $POD_NAME -- rm -rf /data/plugins/Essentials/userdata

echo "🎒 Limpiando inventarios físicos y estadísticas..."
kubectl exec -n $NAMESPACE $POD_NAME -- rm -rf /data/world/playerdata
kubectl exec -n $NAMESPACE $POD_NAME -- rm -rf /data/world/stats

echo "🧹 Borrando carpeta 'world' (mapa, nether, end y serverconfig)..."
kubectl exec -n $NAMESPACE $POD_NAME -- rm -rf /data/world

# 4. Aviso de GitOps
echo "⚠️  RECUERDA: Asegúrate de haber subido tu nuevo 'minecraft-values.yaml' con la nueva SEED y MODS a tu repositorio."
read -p "¿Has actualizado ya tu YAML de GitOps? (s/n): " confirmacion

if [ "$confirmacion" != "s" ]; then
    echo "⏸️  Proceso pausado. Sube tus cambios a Git y luego reinicia el Pod manualmente."
    exit 0
fi

# 5. Reinicio del servidor
echo "🔄 Reiniciando el despliegue para aplicar cambios y generar nuevo mundo..."
kubectl rollout restart deployment $DEPLOYMENT -n $NAMESPACE

echo "✨ ¡PROCESO COMPLETADO! ✨"
echo "Monitoriza el arranque con: kubectl logs -f -n $NAMESPACE $POD_NAME"