#!/bin/bash
# Script de Reinicio de Estado (Reset State)
# ADVERTENCIA: BORRA PROGRESO DE JUGADORES (Homes, Money, Jobs, Teams)
# NO BORRA: Inventarios de Jugadores, Construcciones (Region), ni el Mapa.

echo "⚠️⚠️⚠️ INICIANDO RESETEO DE ESTADO ⚠️⚠️⚠️"
echo "Esto borrará Homes, Warps, Dinero, Clanes y Reclamaciones."
echo "Tienes 5 segundos para cancelar (Ctrl+C)..."
sleep 5

echo "1. Limpiando Essentials UserData (Homes/Money/Kits)..."
rm -rf /data/plugins/Essentials/userdata/*
rm -rf /data/plugins/Essentials/warps/*

echo "2. Limpiando Base de Datos de AuthMe (Registros)..."
rm -f /data/plugins/AuthMe/authme.db

echo "3. Limpiando LuckPerms (Permisos)..."
rm -rf /data/plugins/LuckPerms/*

echo "4. Limpiando FTB Teams/Chunks (Clanes y Claims)..."
rm -rf /data/world/data/ftbteams/*
rm -f /data/world/serverconfig/ftbchunks-world.snbt

echo "5. Limpiando Jobs y otros plugins..."
rm -f /data/plugins/Jobs/*.sqlite.db
rm -rf /data/plugins/VotingPlugin/Data/*

echo "✅ Limpieza completada."
echo "Ahora REINICIA el servidor para aplicar cambios."
