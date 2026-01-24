#!/bin/bash
# ~/.config/polybar/modules/brightness.sh

get_brightness_percent() {
    current=$(brightnessctl get 2>/dev/null || echo "0")
    max=$(brightnessctl max 2>/dev/null || echo "100")
    
    if [ "$max" -eq 0 ]; then
        echo "0"
        return
    fi
    
    # Calculate percentage
    percent=$((current * 100 / max))
    echo "$percent"
}

get_brightness() {
    brightness=$(get_brightness_percent)
    
    if [ "$brightness" -ge 80 ]; then
        icon="󰃠"
    elif [ "$brightness" -ge 60 ]; then
        icon="󰃟"
    elif [ "$brightness" -ge 40 ]; then
        icon="󰃝"
    elif [ "$brightness" -ge 20 ]; then
        icon="󰃞"
    else
        icon="󰃚"
    fi
    
    echo "$icon $brightness%"
}

case "$1" in
    up)
        brightnessctl set +5% > /dev/null 2>&1
        brightness=$(get_brightness_percent)
        notify-send -a "brightness" -h string:x-canonical-private-synchronous:brightness -h int:value:"$brightness" -t 2000 "Brightness" "$brightness%"
        ;;
    down)
        brightnessctl set 5%- > /dev/null 2>&1
        brightness=$(get_brightness_percent)
        notify-send -a "brightness" -h string:x-canonical-private-synchronous:brightness -h int:value:"$brightness" -t 2000 "Brightness" "$brightness%"
        ;;
    *)
        get_brightness
        ;;
esac