#!/bin/bash
set -e
set -o pipefail

# Eliminar claves antiguas
sudo rm -f /etc/apt/keyrings/parrot.gpg
sudo rm -f /etc/apt/trusted.gpg.d/parrot-archive-keyring.gpg

# Descargar e instalar nueva keyring
wget https://deb.parrot.sh/parrot/pool/main/p/parrot-archive-keyring/parrot-archive-keyring_2024.12_all.deb
sudo dpkg -i parrot-archive-keyring_2024.12_all.deb

# Limpiar y crear archivo de repositorios
sudo rm -f /etc/apt/sources.list.d/parrot.list
sudo touch /etc/apt/sources.list.d/parrot.list

# Agregar repositorios correctamente
echo "deb [signed-by=/usr/share/keyrings/parrot-archive-keyring.gpg] https://deb.parrot.sh/parrot lory main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list.d/parrot.list
echo "deb [signed-by=/usr/share/keyrings/parrot-archive-keyring.gpg] https://deb.parrot.sh/direct/parrot lory-security main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list.d/parrot.list
echo "deb [signed-by=/usr/share/keyrings/parrot-archive-keyring.gpg] https://deb.parrot.sh/parrot lory-backports main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list.d/parrot.list

# Hacer backup del archivo de repositorios
sudo mv /etc/apt/sources.list.d/parrot.list /etc/apt/sources.list.d/parrot.list.bak

# Limpiar y actualizar nuevamente
sudo apt clean
sudo apt update
sudo apt full-upgrade
