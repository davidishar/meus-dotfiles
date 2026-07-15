#!/bin/bash

# 1. Pega a porcentagem atual ANTES de qualquer coisa
ATUAL=$(brightnessctl -m | awk -F, '{print $4}' | tr -d '%')

# 2. Extrai apenas o número do argumento (tira os sinais de + e -)
PASSO=${1//[!0-9]/}

# 3. Calcula o novo brilho na memória
if [[ "$1" == *"-"* ]]; then
    NOVO=$(( ATUAL - PASSO ))
    [ "$NOVO" -lt 5 ] && NOVO=5
else
    NOVO=$(( ATUAL + PASSO ))
    [ "$NOVO" -gt 100 ] && NOVO=100
fi

# 4. Aplica o brilho na tela
brightnessctl set "${NOVO}%"

# 5. Monta a barra de bolinhas
NUM_BOLINHAS=$(( NOVO / 5 ))
ESCALA=""
for i in {1..20}; do
    [ "$i" -le "$NUM_BOLINHAS" ] && ESCALA="${ESCALA}" || ESCALA="${ESCALA}"
done

# 6. Dispara a notificação em linha única
notify-send -a "Monitor" \
    -h string:x-canonical-private-synchronous:brilho \
    -h int:transient:1 \
    -t 2000 \
    " 󰃠  Brilho: $ESCALA ($NOVO%)"