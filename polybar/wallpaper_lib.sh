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

# Intensidade do desfoque no fundo das telas retrato (sintaxe do ImageMagick).
WALLPAPER_BLUR="${WALLPAPER_BLUR:-0x24}"

_wallpaper_magick() {
    if command -v magick >/dev/null 2>&1; then
        magick "$@"
    elif command -v convert >/dev/null 2>&1; then
        convert "$@"
    else
        return 127
    fi
}

# Monta um único PNG do tamanho da área X inteira e o aplica com feh.
# Cada monitor recebe o tratamento certo:
#   - paisagem: preenchimento normal (igual ao --bg-fill);
#   - retrato : "smart fit" — a imagem inteira ajustada pela largura, sobre um
#               fundo desfocado da própria imagem, evitando o zoom/corte
#               exagerado que o --bg-fill faz numa tela 9:16.
# Retorna !=0 (sem ImageMagick/xrandr ou em erro) para o chamador cair no fallback.
_wallpaper_compose_set() {
    local src=$1
    command -v xrandr >/dev/null 2>&1 || return 1
    command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1 || return 1

    local mons
    mons=$(xrandr --listmonitors 2>/dev/null | tail -n +2)
    [[ -n "$mons" ]] || return 1

    local canvas_w=0 canvas_h=0
    local -a geom=()
    local line token rest w h x y
    while IFS= read -r line; do
        token=$(grep -oE '[0-9]+/[0-9]+x[0-9]+/[0-9]+\+[0-9]+\+[0-9]+' <<<"$line" | head -1)
        [[ -n "$token" ]] || continue
        w=${token%%/*}
        h=${token#*x}; h=${h%%/*}
        rest=${token#*+}
        x=${rest%%+*}
        y=${rest##*+}
        geom+=("$w $h $x $y")
        (( x + w > canvas_w )) && canvas_w=$(( x + w ))
        (( y + h > canvas_h )) && canvas_h=$(( y + h ))
    done <<<"$mons"

    (( ${#geom[@]} )) || return 1

    mkdir -p "$WALLPAPER_WDIR"
    local out="${WALLPAPER_WDIR}/.composite_bg.png"

    local -a cmd=(-size "${canvas_w}x${canvas_h}" xc:black)
    local g
    for g in "${geom[@]}"; do
        read -r w h x y <<<"$g"
        if (( h > w )); then
            cmd+=( '(' \
                     '(' "$src" -resize "${w}x${h}^" -gravity center -extent "${w}x${h}" -blur "$WALLPAPER_BLUR" ')' \
                     '(' "$src" -resize "${w}x${h}" ')' \
                     -gravity center -composite \
                   ')' -geometry "+${x}+${y}" -composite )
        else
            cmd+=( '(' "$src" -resize "${w}x${h}^" -gravity center -extent "${w}x${h}" ')' \
                   -geometry "+${x}+${y}" -composite )
        fi
    done
    cmd+=( "$out" )

    _wallpaper_magick "${cmd[@]}" 2>/dev/null || return 1
    [[ -f "$out" ]] || return 1

    feh --no-fehbg --no-xinerama --bg-tile "$out"
}

wallpaper_apply() {
    local chosen=$1
    [[ -f "$chosen" ]] || return 1
    mkdir -p "$(dirname "$WALLPAPER_STATE")"
    if ! _wallpaper_compose_set "$chosen"; then
        feh --bg-fill "$chosen"
    fi
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
