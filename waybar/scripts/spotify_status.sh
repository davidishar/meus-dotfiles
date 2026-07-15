#!/bin/bash

# O loop infinito mantém o script rodando e enviando dados para o Waybar
while true; do
    if hyprctl clients | grep -q spotify_terminal; then
        echo '{"text": "", "class": "active"}'
    else
        echo '{"text": "", "class": "inactive"}'
    fi
    
    # Atualiza a cada 1 segundo
    sleep 1
done