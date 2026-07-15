#!/bin/bash

SIGNAL=8

if [ "$1" = "toggle" ]; then
    # Checa se o widget do Eww está aberto
    if eww active-windows | grep -q "lastfm_bg"; then
        # DESLIGA
        killall glava 2>/dev/null
        eww close lastfm_bg letras_bg
    else
        # LIGA
        glava &
        eww open lastfm_bg
        eww open letras_bg
    fi
    
    # Dá tempo para o Eww atualizar seu estado interno antes de avisar a Waybar
    sleep 0.2
    
    # Atualiza a Waybar
    pkill -RTMIN+$SIGNAL waybar
    exit
fi

# --- Status para Waybar ---
if eww active-windows | grep -q "lastfm_bg"; then
    echo '{"text": "", "tooltip": "Widgets: Ligados", "class": "active"}'
else
    echo '{"text": "", "tooltip": "Widgets: Desligados", "class": "inactive"}'
fi