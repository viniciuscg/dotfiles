#!/usr/bin/bash
# ~/.config/polybar/modules/powermenu.sh

# Opções do menu com ícones minimalistas
OPTIONS="  Reiniciar\n  Desligar\n  Hibernar\n󰜺  Cancelar"

SELECTED=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Power" -theme-str 'window {width: 250px;}')

case "$SELECTED" in
    *"Reiniciar")
        CONFIRM=$(echo -e "Sim\nNão" | rofi -dmenu -i -p "Reiniciar?" -theme-str 'window {width: 200px;}')
        if [[ "$CONFIRM" == "Sim" ]]; then
            notify-send -u critical -t 3000 "Sistema" "Reiniciando..."
            sleep 1
            systemctl reboot
        fi
        ;;
    *"Desligar")
        CONFIRM=$(echo -e "Sim\nNão" | rofi -dmenu -i -p "Desligar?" -theme-str 'window {width: 200px;}')
        if [[ "$CONFIRM" == "Sim" ]]; then
            notify-send -u critical -t 3000 "Sistema" "Desligando..."
            sleep 1
            systemctl poweroff
        fi
        ;;
    *"Hibernar")
        CONFIRM=$(echo -e "Sim\nNão" | rofi -dmenu -i -p "Hibernar?" -theme-str 'window {width: 200px;}')
        if [[ "$CONFIRM" == "Sim" ]]; then
            notify-send -t 3000 "Sistema" "Hibernando..."
            sleep 1
            systemctl hibernate
        fi
        ;;
esac