#!/bin/bash
set -e

echo "[INFO] Instalando y configurando Batcat y LSD..."

# Instalar bat y lsd si no están
sudo apt install -y bat lsd

# Crear alias persistentes en .zshrc
ZSHRC="$HOME/.zshrc"

# Agregar alias si no existen
if ! grep -q "alias cat=" "$ZSHRC"; then
    echo "alias cat='batcat --style=plain --paging=never'" >> "$ZSHRC"
    echo "[INFO] Alias 'cat' -> 'batcat' agregado."
else
    echo "[INFO] Alias 'cat' ya configurado."
fi

if ! grep -q "alias ls=" "$ZSHRC"; then
    echo "alias ls='lsd --group-dirs=first --color=always'" >> "$ZSHRC"
    echo "alias ll='lsd -l --group-dirs=first --color=always'" >> "$ZSHRC"
    echo "alias la='lsd -la --group-dirs=first --color=always'" >> "$ZSHRC"
    echo "[INFO] Alias para 'ls' y variantes agregados."
else
    echo "[INFO] Alias para 'ls' ya existen."
fi

# Crear carpeta de configuración de lsd
mkdir -p "$HOME/.config/lsd"

# Copiar configuración de lsd si existe
if [ -d "./config/lsd" ]; then
    cp -r ./config/lsd/* "$HOME/.config/lsd/"
    chown -R "$USER:$USER" "$HOME/.config/lsd"
    echo "[INFO] Configuración personalizada de LSD copiada."
else
    echo "[WARN] No se encontró ./config/lsd — se usará la configuración por defecto."
fi

echo "[OK] Batcat y LSD instalados y configurados correctamente."
