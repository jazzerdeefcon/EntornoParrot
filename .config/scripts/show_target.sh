#!/bin/sh
# show_target.sh - Muestra target (IP + nombre) para Polybar - Solo lectura

TARGET_FILE="$HOME/.config/bin/target"

# Si no existe o está vacío -> "No target"
if [ ! -f "$TARGET_FILE" ] || [ ! -s "$TARGET_FILE" ]; then
    printf "%%{F#e51d0b}󰓾 %%{u-}%%{F#ffffff} No target\n"
    exit 0
fi

# Leer IP y nombre (evitar word split)
ip_address="$(awk '{print $1}' "$TARGET_FILE")"
machine_name="$(awk '{print $2}' "$TARGET_FILE")"

# Salida formateada para Polybar
if [ -n "$ip_address" ] && [ -n "$machine_name" ]; then
    printf "%%{F#e51d0b}󰓾 %%{F#ffffff}%s%%{u-} - %s\n" "$ip_address" "$machine_name"
else
    printf "%%{F#e51d0b}󰓾 %%{u-}%%{F#ffffff} No target\n"
fi
