#!/bin/bash
set -e

echo "[INFO] Instalando BSPWM y SXHKD..."

# Instalar si no están presentes
sudo apt install -y bspwm sxhkd

# Asegurar permisos de ejecución para los scripts de bspwm
if [ -f "$HOME/.config/bspwm/bspwmrc" ]; then
    chmod +x "$HOME/.config/bspwm/bspwmrc"
    echo "[INFO] Permisos aplicados a bspwmrc."
fi

if [ -f "$HOME/.config/sxhkd/sxhkdrc" ]; then
    chmod +x "$HOME/.config/sxhkd/sxhkdrc"
    echo "[INFO] Permisos aplicados a sxhkdrc."
fi

# Crear entrada de autostart si usas startx
if [ ! -f "$HOME/.xinitrc" ]; then
    echo "exec bspwm" > "$HOME/.xinitrc"
    echo "[INFO] Archivo ~/.xinitrc creado para iniciar BSPWM."
else
    echo "[INFO] ~/.xinitrc ya existe, no modificado."
fi

echo "[OK] BSPWM y SXHKD instalados y configurados correctamente."
