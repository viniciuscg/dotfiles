#!/usr/bin/env bash
# Controla Spotify (scratchpad ou normal) via MPRIS; senão outro playerctl; senão mpc.
cmd="${1:?usage: music_ctl.sh prev|next|toggle}"

has_spotify() {
    playerctl -l 2>/dev/null | grep -qx spotify
}

has_any_mpris() {
    [[ -n "$(playerctl -l 2>/dev/null | head -1)" ]]
}

case "$cmd" in
    prev)
        if has_spotify; then playerctl -p spotify previous
        elif has_any_mpris; then playerctl previous
        else mpc prev 2>/dev/null || true
        fi
        ;;
    next)
        if has_spotify; then playerctl -p spotify next
        elif has_any_mpris; then playerctl next
        else mpc next 2>/dev/null || true
        fi
        ;;
    toggle)
        if has_spotify; then playerctl -p spotify play-pause
        elif has_any_mpris; then playerctl play-pause
        else mpc toggle 2>/dev/null || true
        fi
        ;;
    *)
        exit 1
        ;;
esac
