#!/bin/bash
# install_polybar_config.sh
set -e

CONFIG_DIR="$HOME/.config"

# Crear ~/.config si no existe
mkdir -p "$CONFIG_DIR"

# Copiar Polybar
cp -r ./config/polybar "$CONFIG_DIR/"
chown -R $USER:$USER "$CONFIG_DIR/polybar"

# Hacer ejecutable launch.sh
chmod +x "$CONFIG_DIR/polybar/launch.sh"

# Hacer ejecutables todos los scripts .sh dentro de scripts y subdirectorios
find "$CONFIG_DIR/polybar/scripts" -type f -name "*.sh" -exec chmod +x {} \;

echo "[OK] Polybar lista y scripts preparados."
