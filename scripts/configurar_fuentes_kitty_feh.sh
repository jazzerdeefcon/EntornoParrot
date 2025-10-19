#!/bin/bash
set -e

echo "[INFO] Configurando fuentes, Kitty y Feh..."

# Crear carpetas si no existen
if [ ! -d "$HOME/.config/kitty" ]; then
    mkdir -p "$HOME/.config/kitty"
    echo "[INFO] Directorio ~/.config/kitty creado."
fi

# Copiar configuración de kitty si existe en el repo
if [ -d "./config/kitty" ]; then
    cp -r "./config/kitty/"* "$HOME/.config/kitty/"
    chown -R "$USER:$USER" "$HOME/.config/kitty"
    echo "[INFO] Configuración de Kitty copiada correctamente."
else
    echo "[WARN] No se encontró ./config/kitty — omitido."
fi

# Instalar fuentes extra si se necesitan
echo "[INFO] Instalando fuentes recomendadas..."
sudo apt install -y fonts-firacode fonts-jetbrains-mono fonts-noto-color-emoji fonts-font-awesome

# Configurar fondo de pantalla por defecto (si existe el archivo)
if [ -f "./config/feh/default.jpg" ]; then
    mkdir -p "$HOME/Pictures"
    cp "./config/feh/default.jpg" "$HOME/Pictures/"
    feh --bg-scale "$HOME/Pictures/default.jpg"
    echo "[INFO] Fondo de pantalla aplicado con Feh."
else
    echo "[WARN] No se encontró ./config/feh/default.jpg — omitido."
fi

echo "[OK] Fuentes, Kitty y Feh configurados correctamente."
