#!/bin/bash
set -e

CONFIG_DIR="$HOME/.config/sxhkd"

# Crear directorio si no existe
mkdir -p "$CONFIG_DIR"

# Copiar configuración personalizada si existe
if [ -f "./config/sxhkd/sxhkdrc" ]; then
    cp "./config/sxhkd/sxhkdrc" "$CONFIG_DIR/"
    chown $USER:$USER "$CONFIG_DIR/sxhkdrc"
    echo "[INFO] Configuración de SXHKD copiada correctamente."
else
    echo "[WARN] No se encontró ./config/sxhkd/sxhkdrc — se usará la configuración por defecto."
fi

# Verificar si SXHKD está instalado
if ! command -v sxhkd >/dev/null 2>&1; then
    echo "[INFO] SXHKD no encontrado, instalando..."
    sudo apt install -y sxhkd
else
    echo "[INFO] SXHKD ya está instalado."
fi

# Opcional: reiniciar SXHKD si ya está corriendo
if pgrep -x sxhkd >/dev/null; then
    pkill -HUP sxhkd
    echo "[INFO] SXHKD reiniciado para aplicar la nueva configuración."
fi

echo "[OK] SXHKD listo y configurado."
