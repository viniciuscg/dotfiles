#!/bin/bash

# Cores embutidas (%{F…}) para combinar com o tema branco da barra

battery=$(ls /sys/class/power_supply/ 2>/dev/null | grep -i "bat" | head -1)

if [ -z "$battery" ]; then
    echo ""
    exit 0
fi

capacity=$(cat /sys/class/power_supply/$battery/capacity 2>/dev/null || echo "0")
status=$(cat /sys/class/power_supply/$battery/status 2>/dev/null || echo "Unknown")

ACCENT='%{F#e8e8e8}'
GREEN='%{F#98c379}'
RED='%{F#e06c75}'
CLR='%{F-}'

if [ "$status" = "Charging" ]; then
    if [ "$capacity" -ge 90 ]; then icon="󰂅"
    elif [ "$capacity" -ge 70 ]; then icon="󰂈"
    elif [ "$capacity" -ge 50 ]; then icon="󰂆"
    elif [ "$capacity" -ge 30 ]; then icon="󰂄"
    else icon="󰢜"
    fi
    echo "${GREEN}${icon} ${capacity}%${CLR}"
elif [ "$status" = "Full" ]; then
    echo "${GREEN}󰁹 Full${CLR}"
else
    if [ "$capacity" -ge 90 ]; then icon="󰂂"
    elif [ "$capacity" -ge 70 ]; then icon="󰂀"
    elif [ "$capacity" -ge 50 ]; then icon="󰁾"
    elif [ "$capacity" -ge 30 ]; then icon="󰁼"
    elif [ "$capacity" -ge 15 ]; then icon="󰁺"
    else icon="󰂃"
    fi
    if [ "$capacity" -le 15 ]; then
        notify-send -u critical "Battery Low" "Battery at $capacity%!"
        echo "${RED}${icon} ${capacity}%${CLR}"
    else
        echo "${ACCENT}${icon} ${capacity}%${CLR}"
    fi
fi
