#!/bin/bash
# Saída curta; Wi‑Fi via device ligado.

trim() { printf '%s' "${1//$'\r'/}"; }

while IFS=: read -r dev type state; do
    dev=$(trim "$dev"); type=$(trim "$type"); state=$(trim "$state")
    [[ "$type" == "wifi" && "$state" == "connected" ]] || continue
    conn=$(nmcli -g GENERAL.CONNECTION device show "$dev" 2>/dev/null | head -1 | tr -d '\r')
    ssid="${conn:-wifi}"
    sig=$(nmcli -g WIFI.SIGNAL device show "$dev" 2>/dev/null | head -1 | tr -d '\r')
    [[ "$sig" =~ ^[0-9]+$ ]] || sig=""
    short=$(printf '%.12s' "$ssid")
    [[ ${#ssid} -gt 12 ]] && short="${short}…"
    if [[ -n "$sig" ]]; then
        echo "󰤨 ${short} ${sig}%"
    else
        echo "󰤨 ${short}"
    fi
    exit 0
done < <(nmcli -t -f DEVICE,TYPE,STATE device 2>/dev/null)

while IFS=: read -r dev type state; do
    type=$(trim "$type"); state=$(trim "$state")
    if [[ "$type" == "ethernet" && "$state" == "connected" ]]; then
        echo "󰈀 eth"
        exit 0
    fi
done < <(nmcli -t -f DEVICE,TYPE,STATE device 2>/dev/null)

echo "󰤭"
