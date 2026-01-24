#!/usr/bin/bash
# ~/.config/polybar/modules/memory.sh

MEM_INFO=$(free -h | grep Mem)
USED=$(echo "$MEM_INFO" | awk '{print $3}')
TOTAL=$(echo "$MEM_INFO" | awk '{print $2}')

echo "󰍛 $USED/$TOTAL"