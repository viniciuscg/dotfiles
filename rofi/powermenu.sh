#!/usr/bin/env bash
# ⏻ Menu de energia. Sem argumento abre no canto (polybar); com --center abre
# no meio da tela (Mod+Shift+e).
set -u

theme="$HOME/.config/rofi/topmenu.rasi"
[[ "${1:-}" == "--center" ]] && theme="$HOME/.config/rofi/powermenu.rasi"

chosen=$(printf '%s\n' "󰌾  Bloquear" "󰍃  Sair do i3" "󰜉  Reiniciar" "󰐥  Desligar" |
  rofi -dmenu -i -p "Energia" -theme "$theme")

case "$chosen" in
*Bloquear) ~/.config/i3/scripts/lock.sh ;;
*Sair*) i3-msg exit ;;
*Reiniciar) systemctl reboot ;;
*Desligar) systemctl poweroff ;;
esac
