#!/usr/bin/bash

STATE_FILE="$HOME/.config/polybar/.disk_state"
DEFAULT_DEVICE="/"

DEVICES=("/" "/home" "/boot/efi")

get_next_device() {
    local current="$1"
    local found=0
    for i in "${!DEVICES[@]}"; do
        if [[ "${DEVICES[$i]}" == "$current" ]]; then
            found=1
            local next_idx=$(( (i + 1) % ${#DEVICES[@]} ))
            echo "${DEVICES[$next_idx]}"
            return
        fi
    done
    echo "${DEVICES[0]}"
}

get_prev_device() {
    local current="$1"
    local found=0
    for i in "${!DEVICES[@]}"; do
        if [[ "${DEVICES[$i]}" == "$current" ]]; then
            found=1
            local prev_idx=$(( (i - 1 + ${#DEVICES[@]}) % ${#DEVICES[@]} ))
            echo "${DEVICES[$prev_idx]}"
            return
        fi
    done
    echo "${DEVICES[-1]}"
}

arg="${1:-}"
case "$arg" in
  --next)
    current=$(cat "$STATE_FILE" 2>/dev/null || echo "$DEFAULT_DEVICE")
    next=$(get_next_device "$current")
    echo "$next" > "$STATE_FILE"
    notify-send "Disk: Switched to $next" 2>/dev/null || true
    exit 0
    ;;
  --prev)
    current=$(cat "$STATE_FILE" 2>/dev/null || echo "$DEFAULT_DEVICE")
    prev=$(get_prev_device "$current")
    echo "$prev" > "$STATE_FILE"
    notify-send "Disk: Switched to $prev" 2>/dev/null || true
    exit 0
    ;;
  *)
    DEVICE=$(cat "$STATE_FILE" 2>/dev/null || echo "$DEFAULT_DEVICE")
    
    if ! mountpoint -q "$DEVICE" 2>/dev/null && [[ "$DEVICE" != "/" ]]; then
        DEVICE="$DEFAULT_DEVICE"
        echo "$DEVICE" > "$STATE_FILE"
    fi
    
    DISK_INFO=$(df -h "$DEVICE" 2>/dev/null | tail -1)
    
    if [[ -z "$DISK_INFO" ]]; then
        DEVICE="/"
        DISK_INFO=$(df -h / | tail -1)
    fi
    
    USED=$(echo "$DISK_INFO" | awk '{print $3}')
    TOTAL=$(echo "$DISK_INFO" | awk '{print $2}')
    PERCENT=$(echo "$DISK_INFO" | awk '{print $5}' | tr -d '%')
    
    if [[ $PERCENT -lt 50 ]]; then
        COLOR="%{F#98C379}"
    elif [[ $PERCENT -lt 75 ]]; then
        COLOR="%{F#D19A66}"
    else
        COLOR="%{F#E06C75}"
    fi
    
    ICON="󰋊 "
    FORMAT="$COLOR$ICON$USED/$TOTAL"
    
    echo "$FORMAT"
    ;;
esac
