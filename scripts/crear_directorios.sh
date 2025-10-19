#!/bin/bash
set -e  # Detiene el script si ocurre algún error

CONFIG_DIR="$HOME/.config"
SOURCE_DIR="./config"

echo "[INFO] Verificando directorios..."

# Crear ~/.config si no existe
if [ ! -d "$CONFIG_DIR" ]; then
    mkdir -p "$CONFIG_DIR"
    echo "[INFO] Directorio $CONFIG_DIR creado."
else
    echo "[INFO] Directorio $CONFIG_DIR ya existe."
fi

# Verificar que existan los directorios de origen antes de copiarlos
for dir in bspwm sxhkd; do
    if [ -d "$SOURCE_DIR/$dir" ]; then
        cp -r "$SOURCE_DIR/$dir" "$CONFIG_DIR/"
        chown -R "$USER:$USER" "$CONFIG_DIR/$dir"
        echo "[INFO] Configuración de $dir copiada correctamente."
    else
        echo "[WARN] No se encontró $SOURCE_DIR/$dir — omitido."
    fi
done
