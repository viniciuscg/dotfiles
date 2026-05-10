#!/bin/bash
# Ícone play/pause: Spotify > playerctl > mpc

icon_pause="󰏤"
icon_play="󰐊"

if playerctl -l 2>/dev/null | grep -qx spotify; then
    [[ "$(playerctl -p spotify status 2>/dev/null)" == "Playing" ]] && echo "$icon_pause" || echo "$icon_play"
elif playerctl status &>/dev/null; then
    [[ "$(playerctl status 2>/dev/null)" == "Playing" ]] && echo "$icon_pause" || echo "$icon_play"
elif mpc status 2>/dev/null | grep -q '\[playing\]'; then
    echo "$icon_pause"
else
    echo "$icon_play"
fi
