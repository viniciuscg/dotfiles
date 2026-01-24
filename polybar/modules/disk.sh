#!/usr/bin/bash
# ~/.config/polybar/modules/disk.sh

STATE_FILE="$HOME/.config/polybar/.disk_state"
DEFAULT_DEVICE="/"
DEVICES=("/" "/home" "/boot/efi")

get_next_device() {
    local current="$1"
    for i in "${!DEVICES[@]}"; do
        if [[ "${DEVICES[$i]}" == "$current" ]]; then
            local next_idx=$(( (i + 1) % ${#DEVICES[@]} ))
            echo "${DEVICES[$next_idx]}"
            return
        fi
    done
    echo "${DEVICES[0]}"
}

get_prev_device() {
    local current="$1"
    for i in "${!DEVICES[@]}"; do
        if [[ "${DEVICES[$i]}" == "$current" ]]; then
            local prev_idx=$(( (i - 1 + ${#DEVICES[@]}) % ${#DEVICES[@]} ))
            echo "${DEVICES[$prev_idx]}"
            return
        fi
    done
    echo "${DEVICES[-1]}"
}

case "${1:-}" in
    --next)
        current=$(cat "$STATE_FILE" 2>/dev/null || echo "$DEFAULT_DEVICE")
        next=$(get_next_device "$current")
        echo "$next" > "$STATE_FILE"
        notify-send -a "disk" -t 2000 "Disco" "Alternado para $next"
        ;;
    --prev)
        current=$(cat "$STATE_FILE" 2>/dev/null || echo "$DEFAULT_DEVICE")
        prev=$(get_prev_device "$current")
        echo "$prev" > "$STATE_FILE"
        notify-send -a "disk" -t 2000 "Disco" "Alternado para $prev"
        ;;
    *)
        DEVICE=$(cat "$STATE_FILE" 2>/dev/null || echo "$DEFAULT_DEVICE")
        
        # Verifica se o device está montado
        if ! mountpoint -q "$DEVICE" 2>/dev/null && [[ "$DEVICE" != "/" ]]; then
            DEVICE="$DEFAULT_DEVICE"
            echo "$DEVICE" > "$STATE_FILE"
        fi
        
        # Pega informações do disco
        DISK_INFO=$(df -h "$DEVICE" 2>/dev/null | tail -1)
        if [[ -z "$DISK_INFO" ]]; then
            DEVICE="/"
            DISK_INFO=$(df -h / | tail -1)
        fi
        
        USED=$(echo "$DISK_INFO" | awk '{print $3}')
        TOTAL=$(echo "$DISK_INFO" | awk '{print $2}')
        
        # Ícone simples
        echo "󰋊 $USED/$TOTAL"
        ;;
esac