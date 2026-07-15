#!/bin/bash

# Define os ícones
ICON_VOL="󰕾"
ICON_MUTE="󰖁"

# Função unificada de linha única
enviar_linha_unica() {
    notify-send -a "Audio" \
        -h string:x-canonical-private-synchronous:volume \
        -h int:transient:1 \
        -t 2000 \
        "$1"
}

case $1 in
    up|down)
        [ "$1" == "up" ] && wpctl set-volume --limit 1.0 @DEFAULT_AUDIO_SINK@ 5%+
        [ "$1" == "down" ] && wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        
        VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
        [ "$VOL" -gt 100 ] && VOL=100
        
        NUM_BOLINHAS=$(( VOL / 5 ))
        ESCALA=""
        for i in {1..20}; do
            [ "$i" -le "$NUM_BOLINHAS" ] && ESCALA="${ESCALA}" || ESCALA="${ESCALA}"
        done
        
        enviar_linha_unica " $ICON_VOL  Volume: $ESCALA ($VOL%)"
        ;;
        
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        IS_MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c "MUTED")
        
        if [ "$IS_MUTED" -eq 1 ]; then
            enviar_linha_unica " $ICON_MUTE  Volume: Mutado"
        else
            VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
            enviar_linha_unica " $ICON_VOL  Volume: $VOL% (Desmutado)"
        fi
        ;;
esac