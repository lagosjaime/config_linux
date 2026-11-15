#!/usr/bin/env bash
# Doble click en el modulo VPN de waybar: conecta/desconecta la VPN.
STAMP=/tmp/waybar-vpn-click-ts
now=$(date +%s%N)

double=0
if [[ -f "$STAMP" ]]; then
    last=$(cat "$STAMP" 2>/dev/null)
    if [[ "$last" =~ ^[0-9]+$ ]]; then
        diff=$(( (now - last) / 1000000 ))
        if (( diff < 400 )); then
            double=1
        fi
    fi
fi

if (( double == 1 )); then
    rm -f "$STAMP"
    VPN_SCRIPT="/home/lagosjaime/Desarrollo/config_linux/convpn.sh"

    if pgrep -x openfortivpn >/dev/null 2>&1; then
        # Desconectar
        sudo pkill -x openfortivpn >/dev/null 2>&1
    else
        # Conectar en background (sin terminal)
        nohup bash "$VPN_SCRIPT" >/tmp/waybar-vpn.log 2>&1 &
    fi
    disown 2>/dev/null || true
    exit 0
fi

echo "$now" > "$STAMP"