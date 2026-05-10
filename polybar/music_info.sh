#!/usr/bin/env bash
# Título: Spotify primeiro, depois outro MPRIS, depois mpc.

title=""
if playerctl -l 2>/dev/null | grep -qx spotify; then
    title=$(playerctl -p spotify metadata --format "{{title}}" 2>/dev/null || true)
fi
if [[ -z "$title" ]] && playerctl metadata title &>/dev/null; then
    title=$(playerctl metadata title 2>/dev/null || true)
fi
if [[ -z "$title" ]]; then
    title=$(mpc --format "%title%" current 2>/dev/null || true)
fi
[[ -z "$title" ]] && title="No music"
printf '%s' "$title" | head -c 35
