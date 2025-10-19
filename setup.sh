#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# setup.sh - Orquestador principal para EntornoParrot
# Ejecutar desde la raíz del repo: ./setup.sh
# ------------------------------------------------------------

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPTS_DIR="$REPO_ROOT/scripts"
CONFIG_SRC="$REPO_ROOT/config"    # Nota: tú usas ./config en los scripts anteriores
SYSTEM_DIR="$REPO_ROOT/system"
USR_DIR="$REPO_ROOT/usr"

# Helper: timestamp para backups
TS="$(date +%Y%m%d%H%M%S)"

info(){ printf "\e[1;34m[INFO]\e[0m %s\n" "$*"; }
warn(){ printf "\e[1;33m[WARN]\e[0m %s\n" "$*"; }
ok(){ printf "\e[1;32m[OK]\e[0m %s\n" "$*"; }

# 0) Comprobación mínima
if [ ! -d "$SCRIPTS_DIR" ]; then
    warn "No encontré $SCRIPTS_DIR — asegúrate de estar en la raíz del repo."
fi

# 1) Ejecutar scripts preparatorios (si existen), en orden seguro
# Cada script ya comprueba instalaciones y copia configs
run_if_exists(){
    local script="$1"
    if [ -x "$script" ]; then
        info "Ejecutando $script"
        "$script"
    elif [ -f "$script" ]; then
        info "Ejecutando $script (con sh)"
        bash "$script"
    else
        warn "Script $script no encontrado — se omite."
    fi
}

# Si tienes repos.sh y dependencias.sh, típicamente quieres ejecutar repos y dependencias primero
run_if_exists "$SCRIPTS_DIR/repos.sh"
run_if_exists "$SCRIPTS_DIR/dependencias.sh"

# 2) Crear ~/.config y copiar configs principales (crear_directorios.sh lo hace, lo llamamos)
run_if_exists "$SCRIPTS_DIR/crear_directorios.sh"

# 3) Instalar / configurar bspwm, sxhkd, polybar, picom, rofi, kitty, etc.
# Llamar a los scripts modulares que creaste (si existen)
run_if_exists "$SCRIPTS_DIR/instalar_bspwm_sxhkd.sh" || true
run_if_exists "$SCRIPTS_DIR/configurar_sxhkd.sh" || true

# Polybar / Picom / Rofi / Kitty / Fonts / Nano / ZSH etc
run_if_exists "$SCRIPTS_DIR/install_polybar_config.sh"    # copia polybar
run_if_exists "$SCRIPTS_DIR/configurar_polybar.sh"
run_if_exists "$SCRIPTS_DIR/configurar_picom.sh"
run_if_exists "$SCRIPTS_DIR/configurar_rofi.sh"
run_if_exists "$SCRIPTS_DIR/configurar_fuentes_kitty_feh.sh" || true
run_if_exists "$SCRIPTS_DIR/configurar_nano.sh"
run_if_exists "$SCRIPTS_DIR/configurar_zsh_powerlevel10k.sh" || true
run_if_exists "$SCRIPTS_DIR/configurar_batcat_lsd.sh" || true

# 4) Instalar helpers de usuario: manage_target.sh -> ~/.local/bin
info "Instalando helpers de usuario en \$HOME/.local/bin"
mkdir -p "$HOME/.local/bin"
if [ -f "$SCRIPTS_DIR/manage_target.sh" ]; then
    cp "$SCRIPTS_DIR/manage_target.sh" "$HOME/.local/bin/manage_target.sh"
    chmod +x "$HOME/.local/bin/manage_target.sh"
    ok "manage_target instalado en ~/.local/bin/manage_target.sh"
else
    warn "manage_target.sh no encontrado en $SCRIPTS_DIR"
fi

# 5) Asegurar que todos los .sh dentro de ~/.config (copiados) sean ejecutables
info "Marcando scripts .sh dentro de ~/.config como ejecutables (si existen)"
if [ -d "$HOME/.config" ]; then
    find "$HOME/.config" -type f -name "*.sh" -exec chmod +x {} \; || true
fi

# 6) Manejo de archivos en system/ (dotfiles como .zshrc y .p10k.zsh)
info "Aplicando dotfiles desde $SYSTEM_DIR (si existen) con backup seguro"
if [ -d "$SYSTEM_DIR" ]; then
    # .zshrc
    if [ -f "$SYSTEM_DIR/.zshrc" ]; then
        if [ -f "$HOME/.zshrc" ]; then
            cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$TS"
            info "Backup de ~/.zshrc -> ~/.zshrc.bak.$TS"
        fi
        cp "$SYSTEM_DIR/.zshrc" "$HOME/.zshrc"
        chown "$USER:$USER" "$HOME/.zshrc"
        ok "~/.zshrc actualizado desde repo"
    fi

    # .p10k.zsh
    if [ -f "$SYSTEM_DIR/.p10k.zsh" ]; then
        if [ -f "$HOME/.p10k.zsh" ]; then
            cp "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.bak.$TS"
            info "Backup de ~/.p10k.zsh -> ~/.p10k.zsh.bak.$TS"
        fi
        cp "$SYSTEM_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
        chown "$USER:$USER" "$HOME/.p10k.zsh"
        ok "~/.p10k.zsh actualizado desde repo"
    fi
else
    warn "$SYSTEM_DIR no existe — omito dotfiles"
fi

# 7) Manejo de usr/ -> instalar launcher y fuentes
info "Instalando binarios/fuentes desde $USR_DIR (si existen)"

# 7a) instalador de burpsuite-launcher -> /usr/local/bin (requiere sudo)
if [ -f "$USR_DIR/bin/burpsuite-launcher" ]; then
    info "Instalando burpsuite-launcher en /usr/local/bin (se requiere sudo)"
    sudo cp "$USR_DIR/bin/burpsuite-launcher" /usr/local/bin/burpsuite-launcher
    sudo chmod 755 /usr/local/bin/burpsuite-launcher
    ok "burpsuite-launcher instalado en /usr/local/bin"
fi

# 7b) instalar fuentes user-local (~/.local/share/fonts)
if [ -d "$USR_DIR/share/fonts/truetype" ]; then
    FONT_DST="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DST"
    info "Copiando fuentes a $FONT_DST"
    cp -r "$USR_DIR/share/fonts/truetype/"* "$FONT_DST/" || warn "No se copiaron fuentes (tal vez inexistentes)"
    # actualizar cache de fuentes
    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$FONT_DST" || warn "fc-cache falló al actualizar"
        ok "Fuentes instaladas en $FONT_DST y cache actualizada"
    else
        warn "fc-cache no disponible; instala fontconfig si quieres actualizar cache"
    fi
fi

# 8) Limpieza: asegurarse que launch.sh de polybar y scripts tengan permisos
if [ -f "$HOME/.config/polybar/launch.sh" ]; then
    chmod +x "$HOME/.config/polybar/launch.sh" || true
fi
if [ -d "$HOME/.config/polybar/scripts" ]; then
    find "$HOME/.config/polybar/scripts" -type f -name "*.sh" -exec chmod +x {} \; || true
fi

# 9) Mensaje final
ok "Instalación y configuración completadas (posible que algunas acciones requieran sudo)."
cat <<EOF

Siguientes pasos recomendados:

  - Si cambiaste .zshrc, reinicia la sesión o ejecuta:
      source ~/.zshrc

  - Si quieres que ~/.local/bin esté en tu PATH automáticamente, añade en tu .zshrc:
      export PATH="\$HOME/.local/bin:\$PATH"

  - Para verificar Polybar / bspwm:
      - Inicia sesión en X (startx o gestor de sesiones)
      - O ejecuta manualmente:
          ~/.config/polybar/launch.sh

  - Si algo falló, revisa la salida de este script y los backups en:
      ~/.zshrc.bak.$TS
      ~/.p10k.zsh.bak.$TS

EOF
