#!/usr/bin/env bash
# Popup de calendário — São Paulo + nomes em inglês.
#
# • CALENDAR_BACKEND=auto: «rofi» + tema ~/.config/rofi/calendar.rasi (se rofi, python3 e tema existirem).
#   Caso contrário: «yad» (GTK) se existir. Assim as alterações ao .rasi aplicam-se ao clicar na data.
# • Forçar: CALENDAR_BACKEND=yad | rofi
# • Tema escuro do yad: CALENDAR_GTK_THEME=Adwaita-dark (ou Outros GTK inst.)

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin${PATH:+:$PATH}"

_env_from_ancestors() {
  local key="$1" ppid="${PPID:-}"
  local v=""
  while [[ "${ppid:-0}" -gt 1 ]]; do
    [[ -r "/proc/$ppid/environ" ]] || break
    v=$(tr '\0' '\n' < "/proc/$ppid/environ" | grep "^${key}=" | head -1 | cut -d= -f2-)
    [[ -n "$v" ]] && { printf '%s' "$v"; return 0; }
    ppid=$(awk '/^PPid:/{print $2}' "/proc/$ppid/status" 2>/dev/null)
  done
  return 1
}

[[ -z "${DISPLAY:-}" ]] && DISPLAY="$(_env_from_ancestors DISPLAY)" && export DISPLAY
[[ -z "${DISPLAY:-}" ]] && export DISPLAY=:0

[[ -z "${XAUTHORITY:-}" ]] && XAUTHORITY="$(_env_from_ancestors XAUTHORITY)" && export XAUTHORITY
[[ -z "${XAUTHORITY:-}" && -f "${HOME:-}/.Xauthority" ]] && export XAUTHORITY="${HOME}/.Xauthority"

HOME="${HOME:-$(getent passwd "$(id -nu)" 2>/dev/null | cut -d: -f6)}"
THEME="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/calendar.rasi"
if [[ ! -f "$THEME" ]]; then
  _cal_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [[ -f "$_cal_here/../rofi/calendar.rasi" ]]; then
    THEME="$_cal_here/../rofi/calendar.rasi"
  fi
fi

export TZ=America/Sao_Paulo

_pick_lc_time_en() {
  local avail
  avail=$(locale -a 2>/dev/null) || true
  if echo "$avail" | grep -qiE '^en_US\.(utf8|UTF-8)$'; then
    echo "$avail" | grep -qx 'en_US.UTF-8' && { export LC_TIME=en_US.UTF-8; export LANG=en_US.UTF-8; return; }
    echo "$avail" | grep -qx 'en_US.utf8' && { export LC_TIME=en_US.UTF-8; export LANG=en_US.UTF-8; return; }
  fi
  echo "$avail" | grep -qx 'C.UTF-8' && { export LC_TIME=C.UTF-8; return; }
  export LC_TIME=C
}
_pick_lc_time_en

# ── yad: calendário GTK (navegação, dia seleccionável, semanas) ──────────────
run_yad_calendar() {
  command -v yad >/dev/null 2>&1 || return 1

  local day month year
  readarray -t _parts < <(TZ=America/Sao_Paulo python3 - <<'PY'
try:
    from zoneinfo import ZoneInfo
    from datetime import datetime
    n = datetime.now(ZoneInfo("America/Sao_Paulo"))
except ImportError:
    import os, time
    os.environ["TZ"] = "America/Sao_Paulo"
    time.tzset()
    from datetime import datetime
    n = datetime.now()
print(n.day)
print(n.month - 1)
print(n.year)
PY
)
  day="${_parts[0]}"
  month="${_parts[1]}"
  year="${_parts[2]}"

  local gtk_theme="${CALENDAR_GTK_THEME:-Adwaita-dark}"
  local w="${CALENDAR_YAD_WIDTH:-420}"
  local h="${CALENDAR_YAD_HEIGHT:-360}"

  GTK_THEME="$gtk_theme" \
    yad --calendar \
      --day="$day" --month="$month" --year="$year" \
      --width="$w" --height="$h" --fixed \
      --title=" " \
      --on-top --sticky --skip-taskbar \
      --mouse \
      --close-on-unfocus \
      --show-weeks \
      --date-format="%a %d %b %Y" \
      >/dev/null 2>&1
  return $?
}

# ── rofi: mês actual só leitura (fallback leve) ─────────────────────────────
run_rofi_calendar() {
  local ROFI
  ROFI="$(command -v rofi 2>/dev/null)"
  [[ -z "$ROFI" && -x /usr/bin/rofi ]] && ROFI=/usr/bin/rofi

  local ROFI_EXTRA=()
  "$ROFI" -help 2>&1 | grep -q -- '-monitor' && ROFI_EXTRA=(-monitor focused)

  if [[ -z "$ROFI" ]]; then
    notify-send "Calendário" "rofi não encontrado."
    exit 1
  fi

  if [[ ! -f "$THEME" ]]; then
    notify-send "Calendário" "Tema em falta: $THEME"
    exit 1
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    notify-send "Calendário" "Instala python3 (fallback rofi)."
    exit 1
  fi

  TZ=America/Sao_Paulo python3 - <<'PY' | "$ROFI" -dmenu -i -theme "$THEME" "${ROFI_EXTRA[@]}" -no-custom -p ""
import calendar
import locale
import os
import sys
from datetime import datetime

try:
    from zoneinfo import ZoneInfo
    _tz = ZoneInfo("America/Sao_Paulo")
    now = datetime.now(_tz)
except ImportError:
    os.environ["TZ"] = "America/Sao_Paulo"
    import time; time.tzset()
    now = datetime.now()

for name in ("en_US.UTF-8", "en_US.utf8", "C.UTF-8", "C"):
    try:
        locale.setlocale(locale.LC_TIME, name)
        break
    except locale.Error:
        continue

CELL = 7


def main():
    today = now.day
    y, m = now.year, now.month
    grid_w = 7 * CELL
    title = datetime(y, m, 1).strftime("%B %Y")
    if len(title) > grid_w:
        title = datetime(y, m, 1).strftime("%b %Y")
    names = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    header = "".join(f"{n:^{CELL}}" for n in names)
    lines = [title.center(grid_w), "", header]
    for week in calendar.monthcalendar(y, m):
        row = ""
        for d in week:
            if d == 0:
                row += " " * CELL
            elif d == today:
                cell = f"[{d}]"
                row += f"{cell:^{CELL}}"
            else:
                row += f"{d:^{CELL}}"
        lines.append(row)
    for ln in lines:
        print(ln)


if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:
        try:
            sys.stdout.close()
        except BrokenPipeError:
            pass
        raise SystemExit(0)
PY
}

# ── entrada ─────────────────────────────────────────────────────────────────
backend="${CALENDAR_BACKEND:-auto}"

case "$backend" in
  yad)
    run_yad_calendar || run_rofi_calendar
    ;;
  rofi)
    run_rofi_calendar
    ;;
  auto)
    if command -v rofi >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1 && [[ -f "$THEME" ]]; then
      run_rofi_calendar
    elif command -v yad >/dev/null 2>&1; then
      run_yad_calendar || true
    else
      run_rofi_calendar
    fi
    ;;
  *)
    if command -v rofi >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1 && [[ -f "$THEME" ]]; then
      run_rofi_calendar
    elif command -v yad >/dev/null 2>&1; then
      run_yad_calendar || true
    else
      run_rofi_calendar
    fi
    ;;
esac
