#!/bin/bash
# Próximo wallpaper (clique direito na polybar).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=wallpaper_lib.sh
source "${SCRIPT_DIR}/wallpaper_lib.sh"

wallpaper_collect_imgs
if (( ${#WALLPAPER_IMGS[@]} == 0 )); then
    notify-send "Wallpaper" "Sem imagens em ${WALLPAPER_WDIR} ou ${WALLPAPER_WALLS_ROOT}"
    exit 1
fi

mapfile -t imgs < <(printf '%s\n' "${WALLPAPER_IMGS[@]}" | sort -u)
n=${#imgs[@]}

current=""
if [[ -f "$WALLPAPER_STATE" ]]; then
    current=$(python3 -c "import json; print(json.load(open('$WALLPAPER_STATE')).get('path',''))" 2>/dev/null || true)
fi
if [[ -z "$current" || ! -f "$current" ]]; then
    cur="${WALLPAPER_WDIR}/current_wallpaper.jpg"
    if [[ -L "$cur" ]] || [[ -f "$cur" ]]; then
        current=$(readlink -f "$cur" 2>/dev/null || echo "$cur")
    fi
fi

idx=-1
for i in "${!imgs[@]}"; do
    [[ "${imgs[$i]}" == "$current" ]] && idx=$i && break
done

next=$(( (idx + 1) % n ))
chosen="${imgs[$next]}"

wallpaper_apply "$chosen"
notify-send "Wallpaper" "$(basename "$chosen")"
