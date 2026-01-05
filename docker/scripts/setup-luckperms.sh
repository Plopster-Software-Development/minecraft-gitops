#!/bin/bash
# Script de Configuración Automática de LuckPerms
# Crea Grupos, Asigna Permisos y Kits automáticamente.

echo "👑 Configurando LuckPerms..."

# Función auxiliar para ejecutar comandos de LP
function lp {
    rcon-cli "lp $1"
}

# 1. Crear Grupos
echo "   --> Creando grupos..."
lp "creategroup default"       # Viajero
lp "creategroup elite"         # Equivalente a VIP
lp "creategroup realeza"       # Equivalente a MVP
lp "creategroup reylegendario" # Equivalente a Rey/Leyenda
lp "creategroup moderador"
lp "creategroup administrador"

# 2. Configurar Herencias (Inheritance)
echo "   --> Configurando jerarquía..."
lp "group elite parent add default"
lp "group realeza parent add elite"
lp "group reylegendario parent add realeza"
lp "group moderador parent add reylegendario"
lp "group administrador parent add moderador"

# 3. Permisos Básicos (VIAJERO - Default)
echo "   --> Asignando permisos VIAJERO..."
lp "group default meta setprefix \"&7[Viajero] &f\""
lp "group default permission set essentials.spawn true"
lp "group default permission set essentials.home true"
lp "group default permission set essentials.sethome true"
lp "group default permission set essentials.tpa true"
lp "group default permission set essentials.tpaccept true"
lp "group default permission set essentials.tpdeny true"
lp "group default permission set essentials.warp true"
lp "group default permission set essentials.warp.list true"
lp "group default permission set essentials.kit true"
lp "group default permission set essentials.kits.inicio true"
lp "group default permission set essentials.kits.comida true"
lp "group default permission set essentials.kits.minero true"
lp "group default permission set essentials.kits.bloques true"
lp "group default permission set ftbteams.use true"
lp "group default permission set ftbchunks.use true"

# 4. Permisos ELITE (Teal/Cyan)
echo "   --> Asignando permisos ELITE..."
lp "group elite meta setprefix \"&f&l⚡ &#43C6AC&k*&r &#43C6AC[Elite] &#43C6AC&k*&r &#43C6AC\""
lp "group elite permission set essentials.kits.vip true" # Mapeado al kit VIP
lp "group elite permission set essentials.fly true"
lp "group elite permission set essentials.hat true"
lp "group elite permission set essentials.workbench true"
lp "group elite permission set essentials.sethome.multiple.elite true"

# 5. Permisos REALEZA (Purple/Pink)
echo "   --> Asignando permisos REALEZA..."
lp "group realeza meta setprefix \"&f&l⚜️ &#8A2387&k;&r &#8A2387[Realeza] &#E94057&k;&r &#E94057\""
lp "group realeza permission set essentials.kits.mvp true" # Mapeado al kit MVP
lp "group realeza permission set essentials.enderchest true"
lp "group realeza permission set essentials.feed true"
lp "group realeza permission set essentials.heal true"
lp "group realeza permission set essentials.sethome.multiple.realeza true"

# 6. Permisos REY LEGENDARIO (Gold/Fire)
echo "   --> Asignando permisos REY LEGENDARIO..."
lp "group reylegendario meta setprefix \"&f&l⚔️ &#FDC830&k!&r &#FDC830&l[Rey Legendario] &#F37335&k!&r &#F37335\""
lp "group reylegendario permission set essentials.kits.leyenda true"
lp "group reylegendario permission set essentials.kits.rey true"
lp "group reylegendario permission set essentials.god true"
lp "group reylegendario permission set essentials.repair true"
lp "group reylegendario permission set essentials.sethome.multiple.unlimited true"
lp "group reylegendario permission set essentials.fly.safelogin true"

# 7. Permisos MODERADOR (Emerald)
echo "   --> Asignando permisos MODERADOR..."
lp "group moderador meta setprefix \"&f&l🛡️ &#11998e&k:&r &#11998e[Mod] &#38ef7d&k:&r &#38ef7d\""
lp "group moderador permission set essentials.kick true"
lp "group moderador permission set essentials.tempban true"
lp "group moderador permission set essentials.mute true"
lp "group moderador permission set essentials.jail true"
lp "group moderador permission set essentials.invsee true"

# 8. Permisos ADMINISTRADOR (Red/Crimson)
echo "   --> Asignando permisos ADMINISTRADOR..."
lp "group administrador permission set * true"
lp "group administrador meta setprefix \"&f&l👑 &#ED213A&k|&r &#ED213A[Admin] &#93291E&k|&r &#93291E\""

echo "✅ Configuración de LuckPerms completada con éxito."
