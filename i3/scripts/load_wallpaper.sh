#!/bin/bash
# Load wallpaper from Polybar state file

STATE_FILE="$HOME/.config/polybar/.wallpaper_state"
DEFAULT_WALLPAPER="$HOME/.config/wallpaper/wallpaper.jpg"

if [ -f "$STATE_FILE" ]; then
    # Extract path from JSON state file
    WALLPAPER_PATH=$(python3 -c "import json; f=open('$STATE_FILE'); d=json.load(f); print(d.get('path', '')); f.close()" 2>/dev/null)
    
    if [ -n "$WALLPAPER_PATH" ] && [ -f "$WALLPAPER_PATH" ]; then
        feh --bg-scale "$WALLPAPER_PATH"
        exit 0
    fi
fi

# Fallback to default wallpaper if state file doesn't exist or path is invalid
if [ -f "$DEFAULT_WALLPAPER" ]; then
    feh --bg-scale "$DEFAULT_WALLPAPER"
fi

