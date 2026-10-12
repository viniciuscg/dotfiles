#!/bin/bash

# Cores embutidas (%{F…}) na paleta "Dirt" (ver theme/palette.sh)

battery=""
for b in /sys/class/power_supply/BAT* /sys/class/power_supply/bat*; do
    [ -e "$b" ] && battery=$(basename "$b") && break
done

if [ -z "$battery" ]; then
    echo ""
    exit 0
fi

capacity=$(cat /sys/class/power_supply/$battery/capacity 2>/dev/null || echo "0")
status=$(cat /sys/class/power_supply/$battery/status 2>/dev/null || echo "Unknown")

ACCENT='%{F#d4be98}'
GREEN='%{F#9a9c62}'
RED='%{F#a85050}'
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
