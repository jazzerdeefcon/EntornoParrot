#!/bin/bash
set -e

echo "[INFO] Configurando Polybar..."

# Crear carpeta si no existe
if [ ! -d "$HOME/.config/polybar" ]; then
    mkdir -p "$HOME/.config/polybar"
    echo "[INFO] Directorio ~/.config/polybar creado."
fi

# Copiar configuración desde el repo si existe
if [ -d "./config/polybar" ]; then
    cp -r ./config/polybar/* "$HOME/.config/polybar/"
    chown -R "$USER:$USER" "$HOME/.config/polybar"
    echo "[INFO] Configuración de Polybar copiada correctamente."
else
    echo "[WARN] No se encontró ./config/polybar — se usará la configuración por defecto."
fi

# Dar permisos de ejecución a scripts personalizados
if [ -d "$HOME/.config/polybar" ]; then
    find "$HOME/.config/polybar" -type f -name "*.sh" -exec chmod +x {} \;
    echo "[INFO] Scripts de módulos de Polybar marcados como ejecutables."
fi

# Crear script de lanzamiento si no existe
LAUNCH="$HOME/.config/polybar/launch.sh"
if [ ! -f "$LAUNCH" ]; then
    cat <<'EOF' > "$LAUNCH"
#!/bin/bash
# Cierra instancias previas
killall -q polybar

# Esperar a que terminen
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Lanzar barras definidas en la configuración
polybar example &
EOF
    chmod +x "$LAUNCH"
    echo "[INFO] Script launch.sh creado."
fi

# Integrar Polybar en bspwmrc (si no está ya)
BSPWMRC="$HOME/.config/bspwm/bspwmrc"
if [ -f "$BSPWMRC" ] && ! grep -q "polybar/launch.sh" "$BSPWMRC"; then
    echo "$HOME/.config/polybar/launch.sh &" >> "$BSPWMRC"
    echo "[INFO] Polybar agregada al inicio de bspwmrc."
else
    echo "[INFO] Polybar ya está configurada en bspwmrc o archivo no encontrado."
fi

echo "[OK] Polybar configurada y lista para desplegar."
