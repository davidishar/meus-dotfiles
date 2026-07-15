#!/bin/bash

# Busca a info do spotify_player
# O 2>/dev/null joga fora mensagens de erro do playerctl
song_info=$(playerctl -p spotify_player metadata --format '{{title}}     {{artist}}' 2>/dev/null)

# Se a variável estiver vazia (player fechado ou pausado), imprime NADA
# Se tiver algo, imprime a música. Isso mata o "Sample Text"
if [ -z "$song_info" ]; then
    echo ""
else
    echo "$song_info"
fi