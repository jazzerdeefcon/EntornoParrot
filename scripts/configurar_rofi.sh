#!/bin/bash
set -e

# Verificar e instalar Rofi si no está
if ! command -v rofi >/dev/null 2>&1; then
    echo "[INFO] Rofi no encontrado, instalando..."
    sudo apt install -y rofi
else
    echo "[INFO] Rofi ya está instalado."
fi

CONFIG_DIR="$HOME/.config/rofi"

# Crear directorio si no existe
mkdir -p "$CONFIG_DIR"

# Copiar configuración
if [ -d "./config/rofi" ]; then
    cp -r ./config/rofi/* "$CONFIG_DIR/"
    chown -R $USER:$USER "$CONFIG_DIR"
    echo "[INFO] Configuración de Rofi copiada correctamente."
else
    echo "[WARN] No se encontró ./config/rofi — se usará la configuración por defecto."
fi

echo "[OK] Rofi configurado correctamente."
