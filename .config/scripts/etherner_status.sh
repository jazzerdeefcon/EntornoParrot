#!/bin/sh

# Detectar la interfaz activa con IP
interface=$(ip route | awk '/default/ {print $5}' | head -n1)

# Obtener la IP de la interfaz
ip_addr=$(ip -4 addr show "$interface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Imprimir formato para Polybar
echo "%{F#2495e7}󰈀 %{F#ffffff}${ip_addr}%{u-}"
