#!/usr/bin/env bash
# Slideshow automático de wallpapers — troca a cada INTERVAL segundos.
# Uso:
#   ./wallpaper_slideshow.sh            # roda em foreground
#   ./wallpaper_slideshow.sh --daemon   # roda em background (cria PID file)
#   ./wallpaper_slideshow.sh --stop     # encerra o daemon

# ── configuração ─────────────────────────────────────────────────────────────
WALLPAPER_DIR="$HOME/.local/share/walls/retro"   # pasta com as imagens
INTERVAL=300                               # segundos entre trocas
SHUFFLE=true                               # true = ordem aleatória
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/wallpaper_lib.sh"

PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/wallpaper_slideshow.pid"

# ── helpers ──────────────────────────────────────────────────────────────────
collect_images() {
    mapfile -t IMGS < <(
        find "$WALLPAPER_DIR" -type f \
            \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
            | sort -u
    )
}

run_slideshow() {
    if [[ ! -d "$WALLPAPER_DIR" ]]; then
        echo "Pasta não encontrada: $WALLPAPER_DIR" >&2
        exit 1
    fi

    collect_images
    if (( ${#IMGS[@]} == 0 )); then
        echo "Nenhuma imagem encontrada em: $WALLPAPER_DIR" >&2
        exit 1
    fi

    idx=0
    while true; do
        if [[ "$SHUFFLE" == true ]]; then
            chosen="${IMGS[RANDOM % ${#IMGS[@]}]}"
        else
            chosen="${IMGS[$idx]}"
            idx=$(( (idx + 1) % ${#IMGS[@]} ))
        fi

        wallpaper_apply "$chosen"
        command -v notify-send &>/dev/null && \
            notify-send -t 3000 "Wallpaper" "$(basename "$chosen")"

        sleep "$INTERVAL"

        # Recarrega a lista caso a pasta tenha mudado durante o sleep
        collect_images
        (( ${#IMGS[@]} == 0 )) && { echo "Pasta ficou vazia, encerrando." >&2; exit 0; }
    done
}

stop_daemon() {
    if [[ -f "$PID_FILE" ]]; then
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" && echo "Slideshow encerrado (PID $pid)."
        else
            echo "Processo $pid não encontrado."
        fi
        rm -f "$PID_FILE"
    else
        echo "Nenhum daemon em execução."
    fi
}

# ── entry point ───────────────────────────────────────────────────────────────
case "${1:-}" in
    --stop)
        stop_daemon
        ;;
    --daemon)
        stop_daemon 2>/dev/null   # encerra instância anterior se houver
        run_slideshow &
        echo $! > "$PID_FILE"
        echo "Slideshow iniciado em background (PID $(cat "$PID_FILE"))."
        ;;
    *)
        run_slideshow
        ;;
esac
