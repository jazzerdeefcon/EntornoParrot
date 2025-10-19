#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# setup.sh - Orquestador principal para EntornoParrot
# Ejecutar desde la raíz del repo: ./setup.sh
# ------------------------------------------------------------

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPTS_DIR="$REPO_ROOT/scripts"
CONFIG_SRC="$REPO_ROOT/.config"    # tu .config en el repo
SYSTEM_DIR="$REPO_ROOT/system"
USR_DIR="$REPO_ROOT/usr"

# timestamp para backups
TS="$(date +%Y%m%d%H%M%S)"

info(){ printf "\e[1;34m[INFO]\e[0m %s\n" "$*"; }
warn(){ printf "\e[1;33m[WARN]\e[0m %s\n" "$*"; }
ok(){ printf "\e[1;32m[OK]\e[0m %s\n" "$*"; }

# -------------------------
# Funciones auxiliares
# -------------------------
run_if_exists() {
    local script="$1"
    if [ -x "$script" ]; then
        info "Ejecutando $script"
        "$script"
    elif [ -f "$script" ]; then
        info "Ejecutando $script con bash"
        bash "$script"
    else
        warn "Script $script no encontrado — se omite."
    fi
}

copy_config_dir() {
    # copy a directory from repo .config to $HOME/.config/<name>
    local name="$1"
    if [ -d "$CONFIG_SRC/$name" ]; then
        info "Copiando $name -> \$HOME/.config/$name"
        mkdir -p "$HOME/.config"
        # remove existing target if it's a symlink to avoid surprises, but BACKUP first
        if [ -e "$HOME/.config/$name" ]; then
            cp -a "$HOME/.config/$name" "$HOME/.config/${name}.bak.$TS" 2>/dev/null || true
            info "Backup creado: ~/.config/${name}.bak.$TS"
        fi
        rm -rf "$HOME/.config/$name"
        cp -r "$CONFIG_SRC/$name" "$HOME/.config/"
        chown -R "$USER:$USER" "$HOME/.config/$name"
        ok "Copiado $name"
    else
        warn "No existe $CONFIG_SRC/$name — se omite."
    fi
}

install_local_bin_from_repo() {
    # copia script desde repo scripts/ al ~/.local/bin y lo hace ejecutable
    local repo_script="$1"
    local dst_name="$2" # nombre final
    mkdir -p "$HOME/.local/bin"
    if [ -f "$repo_script" ]; then
        cp "$repo_script" "$HOME/.local/bin/$dst_name"
        chmod +x "$HOME/.local/bin/$dst_name"
        ok "Instalado $dst_name en ~/.local/bin"
    else
        warn "$repo_script no existe, omito instalación en ~/.local/bin"
    fi
}

# -------------------------
# INICIO
# -------------------------
info "Iniciando setup desde: $REPO_ROOT"

# 0) Recomendar ejecutar con bash si no es así
if [ -z "${BASH_VERSION:-}" ]; then
    warn "No parece que estés ejecutando con bash; ejecutar 'bash ./setup.sh' si hay errores."
fi

# 1) Ejecutar scripts preparatorios (repos y dependencias)
run_if_exists "$SCRIPTS_DIR/repos.sh"
run_if_exists "$SCRIPTS_DIR/dependencias.sh"

# 2) Crear ~/.config y copiar configs básicos si es necesario
mkdir -p "$HOME/.config"
ok "Directorio ~/.config existe"

# si tienes script crear_directorios.sh, lo ejecutamos (él copia bspwm/sxhkd)
run_if_exists "$SCRIPTS_DIR/crear_directorios.sh"

# Si no existió ese script, hacemos copia por carpeta (fall back)
if [ ! -d "$HOME/.config/bspwm" ] && [ -d "$CONFIG_SRC/bspwm" ]; then
    copy_config_dir "bspwm"
fi
if [ ! -d "$HOME/.config/sxhkd" ] && [ -d "$CONFIG_SRC/sxhkd" ]; then
    copy_config_dir "sxhkd"
fi

# 3) Instalar/configurar bspwm/sxhkd (si tienes scripts)
run_if_exists "$SCRIPTS_DIR/instalar_bspwm_sxhkd.sh"
run_if_exists "$SCRIPTS_DIR/configurar_sxhkd.sh"

# 4) Polybar / Picom / Rofi / Kitty / Fuentes
# primero copia config polybar si existe
if [ -d "$CONFIG_SRC/polybar" ]; then
    copy_config_dir "polybar"
fi

run_if_exists "$SCRIPTS_DIR/install_polybar_config.sh"
run_if_exists "$SCRIPTS_DIR/configurar_polybar.sh"

# picom
run_if_exists "$SCRIPTS_DIR/configurar_picom.sh"

# rofi
run_if_exists "$SCRIPTS_DIR/configurar_rofi.sh"

# kitty & fuentes & feh (script opcional)
run_if_exists "$SCRIPTS_DIR/configurar_fuentes_kitty_feh.sh"

# 5) Editor (nano) y shell (zsh + powerlevel10k)
run_if_exists "$SCRIPTS_DIR/configurar_nano.sh"
run_if_exists "$SCRIPTS_DIR/configurar_zsh_powerlevel10k.sh"

# 6) Utils terminal (batcat, lsd)
run_if_exists "$SCRIPTS_DIR/configurar_batcat_lsd.sh"

# 7) Scripts de Polybar: show_target, vpn_status, ethernet_status, etc.
# Si tienes show_target.sh y manage_target.sh en scripts, instalalos en ~/.local/bin o en .config
if [ -f "$SCRIPTS_DIR/manage_target.sh" ]; then
    install_local_bin_from_repo "$SCRIPTS_DIR/manage_target.sh" "manage_target.sh"
fi

# Para show_target, este script se usa desde polybar; copiarlo al dir correcto si existe
if [ -f "$SCRIPTS_DIR/show_target.sh" ]; then
    mkdir -p "$HOME/.config/polybar/scripts"
    cp "$SCRIPTS_DIR/show_target.sh" "$HOME/.config/polybar/scripts/show_target.sh"
    chmod +x "$HOME/.config/polybar/scripts/show_target.sh"
    chown "$USER:$USER" "$HOME/.config/polybar/scripts/show_target.sh"
    ok "show_target instalado en ~/.config/polybar/scripts/"
fi

# vpn_status opcional
if [ -f "$SCRIPTS_DIR/vpn_status.sh" ]; then
    mkdir -p "$HOME/.config/polybar/scripts"
    cp "$SCRIPTS_DIR/vpn_status.sh" "$HOME/.config/polybar/scripts/vpn_status.sh"
    chmod +x "$HOME/.config/polybar/scripts/vpn_status.sh"
    chown "$USER:$USER" "$HOME/.config/polybar/scripts/vpn_status.sh"
    ok "vpn_status instalado en ~/.config/polybar/scripts/"
fi

# ethernet_status if exists
if [ -f "$SCRIPTS_DIR/ethernet_status.sh" ]; then
    mkdir -p "$HOME/.config/polybar/scripts"
    cp "$SCRIPTS_DIR/ethernet_status.sh" "$HOME/.config/polybar/scripts/ethernet_status.sh"
    chmod +x "$HOME/.config/polybar/scripts/ethernet_status.sh"
    chown "$USER:$USER" "$HOME/.config/polybar/scripts/ethernet_status.sh"
    ok "ethernet_status instalado en ~/.config/polybar/scripts/"
fi

# 8) Asegurar permisos ejecutables para cualquier .sh dentro de ~/.config
info "Asegurando permisos ejecutables para .sh en ~/.config"
if [ -d "$HOME/.config" ]; then
    find "$HOME/.config" -type f -name "*.sh" -exec chmod +x {} \; || true
fi

# 9) Manejo de archivos en system/ (dotfiles como .zshrc y .p10k.zsh)
info "Aplicando dotfiles desde $SYSTEM_DIR (si existen)"
if [ -d "$SYSTEM_DIR" ]; then
    # .zshrc
    if [ -f "$SYSTEM_DIR/.zshrc" ]; then
        if [ -f "$HOME/.zshrc" ]; then
            cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$TS" || true
            info "Backup de ~/.zshrc -> ~/.zshrc.bak.$TS"
        fi
        cp "$SYSTEM_DIR/.zshrc" "$HOME/.zshrc"
        chown "$USER:$USER" "$HOME/.zshrc"
        ok "~/.zshrc actualizado desde repo"
    fi

    # .p10k.zsh
    if [ -f "$SYSTEM_DIR/.p10k.zsh" ]; then
        if [ -f "$HOME/.p10k.zsh" ]; then
            cp "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.bak.$TS" || true
            info "Backup de ~/.p10k.zsh -> ~/.p10k.zsh.bak.$TS"
        fi
        cp "$SYSTEM_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
        chown "$USER:$USER" "$HOME/.p10k.zsh"
        ok "~/.p10k.zsh actualizado desde repo"
    fi
else
    warn "$SYSTEM_DIR no existe — omito dotfiles"
fi

# 10) Manejo de usr/ -> installer (burpsuite-launcher) y fuentes
info "Instalando binarios/fuentes desde $USR_DIR (si existen)"

if [ -f "$USR_DIR/bin/burpsuite-launcher" ]; then
    info "Instalando burpsuite-launcher en /usr/local/bin (requiere sudo)"
    sudo cp "$USR_DIR/bin/burpsuite-launcher" /usr/local/bin/burpsuite-launcher
    sudo chmod 755 /usr/local/bin/burpsuite-launcher
    ok "burpsuite-launcher instalado en /usr/local/bin"
fi

if [ -d "$USR_DIR/share/fonts/truetype" ]; then
    FONT_DST="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DST"
    info "Copiando fuentes a $FONT_DST"
    cp -r "$USR_DIR/share/fonts/truetype/"* "$FONT_DST/" || warn "No se copiaron fuentes (tal vez inexistentes)"
    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$FONT_DST" || warn "fc-cache falló al actualizar"
        ok "Fuentes instaladas y cache actualizada"
    else
        warn "fc-cache no disponible; instala fontconfig si quieres actualizar cache"
    fi
fi

# 11) Final: - dar permisos a launch.sh si existe
if [ -f "$HOME/.config/polybar/launch.sh" ]; then
    chmod +x "$HOME/.config/polybar/launch.sh" || true
fi

# 12) Mensaje final
ok "Instalación y configuración completadas (es posible que algunas acciones requieran sudo)."

cat <<EOF

Siguientes pasos recomendados:

  - Si cambiaste ~/.zshrc, reinicia la sesión o ejecuta:
      source ~/.zshrc

  - Asegúrate de que ~/.local/bin esté en tu PATH:
      export PATH="\$HOME/.local/bin:\$PATH"    # añadir en tu .zshrc si hace falta

  - Para verificar Polybar / bspwm:
      - Inicia sesión en X (startx o gestor de sesiones)
      - O ejecuta manualmente:
          ~/.config/polybar/launch.sh

  - Backups realizados (si existían):
      ~/.zshrc.bak.$TS
      ~/.p10k.zsh.bak.$TS

EOF

exit 0
