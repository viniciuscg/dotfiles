#!/usr/bin/env bash
# Partilhado por next_wallpaper.sh e pick_wallpaper.sh

WALLPAPER_WDIR="${XDG_CONFIG_HOME:-$HOME/.config}/wallpaper"
WALLPAPER_WALLS_ROOT="${DHARMX_WALLS:-$HOME/.local/share/walls}"
WALLPAPER_STATE="${XDG_CONFIG_HOME:-$HOME/.config}/polybar/.wallpaper_state"

WALLPAPER_IMGS=()

wallpaper_collect_imgs() {
    WALLPAPER_IMGS=()
    _wallpaper_append_from "$WALLPAPER_WDIR"
    _wallpaper_append_from "$WALLPAPER_WALLS_ROOT"
}

_wallpaper_append_from() {
    local dir=$1
    [[ -d "$dir" ]] || return 0
    local f
    while IFS= read -r -d '' f; do
        WALLPAPER_IMGS+=("$f")
    done < <(
        find "$dir" \( -name '.git' -o -name '.github' \) -prune -o \
            -type f \( \
                -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \
            \) -print0 2>/dev/null
    )
}

wallpaper_apply() {
    local chosen=$1
    [[ -f "$chosen" ]] || return 1
    mkdir -p "$(dirname "$WALLPAPER_STATE")"
    feh --bg-fill "$chosen"
    mkdir -p "$WALLPAPER_WDIR"
    ln -sf "$chosen" "$WALLPAPER_WDIR/current_wallpaper.jpg"
    export WALLPAPER_CHOICE="$chosen"
    export POLYBAR_WALLPAPER_STATE="$WALLPAPER_STATE"
    python3 <<'PY'
import json, os
with open(os.environ["POLYBAR_WALLPAPER_STATE"], "w") as f:
    json.dump({"path": os.environ["WALLPAPER_CHOICE"]}, f)
PY
}
