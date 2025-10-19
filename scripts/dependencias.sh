#!/bin/bash

# Instalar paquetes base
sudo apt install -y git curl wget unzip build-essential cmake zsh htop tmux nano fonts-powerline locate x11vnc btop neofetch

# Instalar librerías X y desarrollo gráfico
sudo apt install -y libx11-dev libxft-dev libxinerama-dev libxcb1-dev libxcb-util0-dev \
libxcb-ewmh-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-xkb-dev \
libxkbcommon-dev libxkbcommon-x11-dev

# Herramientas opcionales
sudo apt install -y feh rofi kitty tilix picom python3 python3-pip python3-venv
