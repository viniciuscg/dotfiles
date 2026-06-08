#!/bin/bash
# Load wallpaper from Polybar state file (com smart fit por monitor).
# Reusa wallpaper_lib.sh para recompor o fundo conforme o layout atual de
# monitores — importante após mudanças de xrandr (ver i3/scripts/monitor.sh).

STATE_FILE="$HOME/.config/polybar/.wallpaper_state"
DEFAULT_WALLPAPER="$HOME/.config/wallpaper/wallpaper.jpg"
LIB="$HOME/.config/polybar/wallpaper_lib.sh"

target=""
if [ -f "$STATE_FILE" ]; then
    # Extract path from JSON state file
    target=$(python3 -c "import json; print(json.load(open('$STATE_FILE')).get('path',''))" 2>/dev/null)
fi

# Fallback to default wallpaper if state file doesn't exist or path is invalid
if [ -z "$target" ] || [ ! -f "$target" ]; then
    target="$DEFAULT_WALLPAPER"
fi
[ -f "$target" ] || exit 0

if [ -f "$LIB" ]; then
    # shellcheck source=/dev/null
    . "$LIB"
    wallpaper_apply "$target"
else
    feh --bg-fill "$target"
fi
