#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
#PS1='[\u@\h \W]\$ '

# --- THEME ---

GB_Green="\[\e[38;5;142m\]"  # Verde musgo
GB_Yellow="\[\e[38;5;214m\]" # Amarelo ouro
GB_Aqua="\[\e[38;5;108m\]"   # Ciano acinzentado / Água
GB_Red="\[\e[38;5;167m\]"    # Vermelho tijolo / Terroso
GB_Text="\[\e[38;5;223m\]"   # Prata / Pergaminho
G_Reset="\[\e[0m\]"
G_Bold="\[\e[1m\]"

if [ "$EUID" -ne 0 ]; then
    # Usuário normal: Nome em verde, diretório em amarelo e o $ em cor de pergaminho
    export PS1="${G_Bold}${GB_Green}\u${G_Reset} ${GB_Yellow}\w${G_Reset} ${GB_Text}\$${G_Reset} "
else
    # Root: Alerta em vermelho
    export PS1="${G_Bold}${GB_Red}ROOT${G_Reset} ${GB_Yellow}\w${G_Reset} ${GB_Red}\$${G_Reset} "
fi

trap 'echo -ne "\e[0m"' DEBUG

alias t="~/tools.sh"

# --- FASTFETCH ALIAS ---
alias fastfetch='fastfetch --logo-type auto --logo-width 32 --logo "$(find ~/lastfm_covers_cache -type f | shuf -n 1)"'

# Mostra o fastfetch apenas se NÃO estivermos no TTY1 (o tty do boot/autologin)
if [[ $(tty) != "/dev/tty1" ]]; then
    fastfetch
fi