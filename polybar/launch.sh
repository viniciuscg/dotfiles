#!/usr/bin/env bash
killall -q polybar 2>/dev/null || true
while pgrep -u "$(id -u)" -x polybar >/dev/null; do sleep 0.2; done

CFG="${HOME}/.config/polybar/config.ini"
[[ -f "$CFG" ]] || { echo "polybar: falta $CFG"; exit 1; }

run_bar() {
  MONITOR="${1:-}" polybar -c "$CFG" main &
}

if command -v xrandr >/dev/null 2>&1; then
  mapfile -t outs < <(xrandr --query | awk '/ connected/{print $1}')
  if [[ ${#outs[@]} -eq 0 ]]; then
    run_bar ""
  else
    for m in "${outs[@]}"; do
      run_bar "$m"
    done
  fi
else
  run_bar ""
fi
