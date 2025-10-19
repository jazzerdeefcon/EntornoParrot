#!/bin/bash
set -e

# Verificar e instalar Picom si no está
if ! command -v picom >/dev/null 2>&1; then
    echo "[INFO] Picom no encontrado, instalando..."
    sudo apt install -y picom
else
    echo "[INFO] Picom ya está instalado."
fi

CONFIG_DIR="$HOME/.config/picom"

# Crear directorio si no existe
mkdir -p "$CONFIG_DIR"

# Copiar configuración
if [ -f "./config/picom/picom.conf" ]; then
    cp "./config/picom/picom.conf" "$CONFIG_DIR/"
    chown $USER:$USER "$CONFIG_DIR/picom.conf"
    echo "[INFO] Configuración de Picom copiada correctamente."
else
    echo "[WARN] No se encontró ./config/picom/picom.conf — se usará la configuración por defecto."
fi

# Añadir lanzamiento automático en bspwmrc
BSPWMRC="$HOME/.config/bspwm/bspwmrc"
if [ -f "$BSPWMRC" ] && ! grep -q "picom &" "$BSPWMRC"; then
    echo "picom &" >> "$BSPWMRC"
    echo "[INFO] Picom configurado para iniciar automáticamente con bspwm."
fi

echo "[OK] Picom configurado correctamente."
