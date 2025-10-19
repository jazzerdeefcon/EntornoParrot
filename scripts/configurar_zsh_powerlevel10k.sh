#!/bin/bash
set -e

echo "[INFO] Configurando ZSH y Powerlevel10k..."

# Instalar ZSH si no está presente
if ! command -v zsh >/dev/null 2>&1; then
    sudo apt install -y zsh
    echo "[INFO] ZSH instalado."
fi

# Cambiar shell por defecto a ZSH
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    chsh -s /usr/bin/zsh
    echo "[INFO] Shell por defecto cambiado a ZSH (se aplicará al reiniciar sesión)."
fi

# Instalar oh-my-zsh si no existe
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[INFO] Instalando oh-my-zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "[INFO] Oh-my-zsh ya está instalado."
fi

# Instalar Powerlevel10k si no existe
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    echo "[INFO] Instalando tema Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
else
    echo "[INFO] Powerlevel10k ya está instalado."
fi

# Copiar configuración personalizada si existe en el repo
if [ -f "./config/zsh/.zshrc" ]; then
    cp "./config/zsh/.zshrc" "$HOME/.zshrc"
    chown "$USER:$USER" "$HOME/.zshrc"
    echo "[INFO] Archivo .zshrc personalizado aplicado."
else
    echo "[WARN] No se encontró ./config/zsh/.zshrc — se usará el predeterminado."
fi

# Copiar configuración de Powerlevel10k si existe
if [ -f "./config/zsh/.p10k.zsh" ]; then
    cp "./config/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
    chown "$USER:$USER" "$HOME/.p10k.zsh"
    echo "[INFO] Configuración de Powerlevel10k copiada."
else
    echo "[WARN] No se encontró ./config/zsh/.p10k.zsh — omitido."
fi

echo "[OK] ZSH y Powerlevel10k configurados correctamente."
