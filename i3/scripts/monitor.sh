#!/usr/bin/env bash

PRIMARY=""
PORTRAIT_MONITOR="DP-1-6"
LAPTOP_MONITOR="eDP-1"

if xrandr | grep -q "DP-1-5 connected"; then
  PRIMARY="DP-1-5"
elif xrandr | grep -q "^HDMI-1 connected"; then
  PRIMARY="HDMI-1"
elif xrandr | grep -q "^eDP-1 connected"; then
  PRIMARY="eDP-1"
fi

if [ -n "$PRIMARY" ]; then
  xrandr --output "$PRIMARY" --primary --auto
fi

# Keep the View 27 (DP-1-6) in portrait on the left side.
if [ -n "$PRIMARY" ] && [ "$PRIMARY" != "$PORTRAIT_MONITOR" ] && xrandr | grep -q "^${PORTRAIT_MONITOR} connected"; then
  PORTRAIT_MODE="$(xrandr | awk -v mon="$PORTRAIT_MONITOR" '
    $1 == mon { in_block=1; next }
    in_block && $0 ~ /\*/ { print $1; exit }
    in_block && $1 ~ /^[A-Za-z0-9-]+$/ { in_block=0 }
  ')"

  if [ -n "$PORTRAIT_MODE" ]; then
    xrandr --output "$PORTRAIT_MONITOR" --mode "$PORTRAIT_MODE" --rotate normal --right-of "$PRIMARY" --scale 1x1
  else
    xrandr --output "$PORTRAIT_MONITOR" --auto --rotate normal --right-of "$PRIMARY" --scale 1x1
  fi
fi

# Avoid output overlap: keep laptop panel to the right of the primary monitor.
if [ -n "$PRIMARY" ] && [ "$PRIMARY" != "$LAPTOP_MONITOR" ] && xrandr | grep -q "^${LAPTOP_MONITOR} connected"; then
  xrandr --output "$LAPTOP_MONITOR" --auto --rotate normal --left-of "$PRIMARY"
fi

# Reapply wallpaper after layout changes to avoid stretched/misaligned backgrounds.
if [ -x "$HOME/.config/i3/scripts/load_wallpaper.sh" ]; then
  "$HOME/.config/i3/scripts/load_wallpaper.sh"
fi
