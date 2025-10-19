#!/bin/sh
# vpn_status.sh - Detecta interfaces VPN y muestra IP en Polybar solo si hay conexión

# Lista de posibles interfaces VPN
VPN_INTERFACES="tun0 wg0"

# Inicializamos variable de salida vacía
OUTPUT=""

for iface in $VPN_INTERFACES; do
    if /sbin/ifconfig "$iface" >/dev/null 2>&1; then
        IP=$(/sbin/ifconfig "$iface" | grep "inet " | awk '{print $2}')
        OUTPUT="%{F#1bbf3e}󰆧 %{F#ffffff}$IP%{u-}"
        break
    fi
done

# Mostrar solo si hay conexión VPN
echo "$OUTPUT"
