#!/bin/bash
set -e

# Configuración mínima de Nano
NANORC="$HOME/.nanorc"

# Crear o actualizar .nanorc con la opción mouse
if [ -f "$NANORC" ]; then
    # Verificar si ya existe la línea
    if ! grep -q "^set mouse" "$NANORC"; then
        echo "set mouse" >> "$NANORC"
        echo "[INFO] 'set mouse' agregado a ~/.nanorc"
    fi
else
    echo "set mouse" > "$NANORC"
    echo "[INFO] ~/.nanorc creado con 'set mouse'"
fi

chown $USER:$USER "$NANORC"
echo "[OK] Nano configurado con soporte de mouse."
