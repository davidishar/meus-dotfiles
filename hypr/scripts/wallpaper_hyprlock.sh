#!/bin/bash

# 1. Garante que a pasta de cache existe
mkdir -p "$HOME/.cache"

# 2. Pega o caminho do wallpaper direto do config do Waypaper
# (O 'eval echo' serve para converter o ~/ em /home/david/)
RAW_PATH=$(grep '^wallpaper =' ~/.config/waypaper/config.ini | cut -d ' ' -f 3)
WALLPAPER=$(eval echo "$RAW_PATH")

# 3. Cria o link simbólico que o hyprlock vai ler
ln -sf "$WALLPAPER" "$HOME/.cache/current_wallpaper.png"