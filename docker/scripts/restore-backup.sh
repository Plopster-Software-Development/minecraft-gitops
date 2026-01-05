#!/bin/bash
# Script Interactivo de Restauración de Backups
# Escanea carpetas de backups y permite restaurar World y Plugins.

BACKUP_ROOT="/data/Backups"
ESSENTIALS_BACKUPS="/data/Backups/Essentials"

echo "=========================================="
echo "🛡️  ASISTENTE DE RESTAURACIÓN (Restore)  🛡️"
echo "=========================================="
echo "⚠️  ADVERTENCIA: Esto sobrescribirá los datos actuales."
echo "⚠️  Se recomienda detener el servidor antes (rcon-cli stop)."
echo ""

# 1. Listar Backups Disponibles
echo "📂 Buscando backups en $BACKUP_ROOT..."
echo "------------------------------------------"
i=0
declare -a backups

# Buscar Pre-Deploys (Tar.gz)
for f in $(find $BACKUP_ROOT -maxdepth 1 -name "pre-deploy-*.tar.gz" | sort -r | head -n 5); do
    i=$((i+1))
    echo "[$i] [DEPLOY] $(basename $f)"
    backups[$i]=$f
done

# Buscar Essentials Backups (Tar.gz)
for f in $(find $ESSENTIALS_BACKUPS -maxdepth 1 -name "backup-*.tar.gz" 2>/dev/null | sort -r | head -n 5); do
    i=$((i+1))
    echo "[$i] [ESSENTIALS] $(basename $f)"
    backups[$i]=$f
done

if [ $i -eq 0 ]; then
    echo "❌ No se encontraron backups recientes."
    exit 1
fi

echo "------------------------------------------"
read -p "Elige el número del backup a restaurar (1-$i): " selection

file="${backups[$selection]}"

if [ -z "$file" ]; then
    echo "❌ Selección inválida."
    exit 1
fi

echo ""
echo "📦 Backup seleccionado: $file"
echo "⏳ Contenido (resumen):"
tar -tf "$file" | head -n 5
echo "..."
echo ""

read -p "❓ ¿Estás SEGURO de restaurar este backup? (escribe 'SI'): " confirm

if [ "$confirm" != "SI" ]; then
    echo "❌ Cancelado."
    exit 1
fi

echo ""
echo "🚀 Restaurando..."
# Forzamos overwrite (-overwrite) y verbose (-v)
# Descomprimimos en la raíz (/) porque los backups se guardan con rutas absolutas (/data/...)
tar -xzvf "$file" -C /

echo ""
echo "✅ Restauración completada."
echo "🔄 AHORA DEBES REINICIAR EL POD PARA APLICAR CAMBIOS."
echo "   Ejecuta: exit (para salir) y luego reinicia el pod."
