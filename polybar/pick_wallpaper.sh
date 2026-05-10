#!/bin/bash
# Rofi: pastas + ficheiro no rótulo; índice no fim (TAB). Esquerdo na polybar.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=wallpaper_lib.sh
source "${SCRIPT_DIR}/wallpaper_lib.sh"

wallpaper_rofi_label() {
    local p=$1
    local canon walls wdir
    canon="$(readlink -f "$p" 2>/dev/null || printf '%s' "$p")"
    walls="$(readlink -f "$WALLPAPER_WALLS_ROOT" 2>/dev/null || printf '%s' "$WALLPAPER_WALLS_ROOT")"
    wdir="$(readlink -f "$WALLPAPER_WDIR" 2>/dev/null || printf '%s' "$WALLPAPER_WDIR")"
    walls="${walls%/}"
    wdir="${wdir%/}"
    if [[ "$canon" == "$walls"/* ]]; then
        printf '%s' "${canon#$walls/}"
    elif [[ "$canon" == "$wdir"/* ]]; then
        printf 'cfg/%s' "${canon#$wdir/}"
    else
        basename "$canon"
    fi
}

wallpaper_collect_imgs
if (( ${#WALLPAPER_IMGS[@]} == 0 )); then
    notify-send "Wallpaper" "Sem imagens. Usa ~/.config/wallpaper ou clone dharmx/walls."
    exit 1
fi

mapfile -t imgs < <(printf '%s\n' "${WALLPAPER_IMGS[@]}" | sort -u)

pick=$(
    for i in "${!imgs[@]}"; do
        p="${imgs[$i]}"
        label="$(wallpaper_rofi_label "$p")"
        (( ${#label} > 96 )) && label="…${label: -93}"
        printf '%s\t%s\n' "$label" "$i"
    done | rofi -dmenu -i -matching fuzzy -p "Wallpaper " \
        -display-columns 1 \
        -display-column-separator $'\t' \
        -theme ~/.config/rofi/wallpaper.rasi \
        2>/dev/null || true
)
[[ -z "$pick" ]] && exit 0

idx=$(printf '%s' "$pick" | awk -F'\t' '{print $NF}')
[[ "$idx" =~ ^[0-9]+$ ]] || exit 0
(( idx >= 0 && idx < ${#imgs[@]} )) || exit 0

wallpaper_apply "${imgs[$idx]}"
notify-send "Wallpaper" "$(wallpaper_rofi_label "${imgs[$idx]}")"
