#!/usr/bin/bash
# ~/.config/polybar/modules/powermenu.sh

OPTIONS="  Reiniciar\n  Desligar\n  Hibernar\n  Cancelar"

SELECTED=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Power Menu" -theme-str 'window {width: 300px;}')

case "$SELECTED" in
    *"Reiniciar")
        CONFIRM=$(echo -e "Sim\nNão" | rofi -dmenu -i -p "Confirmar reiniciar?")
        if [[ "$CONFIRM" == "Sim" ]]; then
            systemctl reboot
        fi
        ;;
    *"Desligar")
        CONFIRM=$(echo -e "Sim\nNão" | rofi -dmenu -i -p "Confirmar desligar?")
        if [[ "$CONFIRM" == "Sim" ]]; then
            systemctl poweroff
        fi
        ;;
    *"Hibernar")
        CONFIRM=$(echo -e "Sim\nNão" | rofi -dmenu -i -p "Confirmar hibernar?")
        if [[ "$CONFIRM" == "Sim" ]]; then
            systemctl hibernate
        fi
        ;;
    *)
        exit 0
        ;;
esac
