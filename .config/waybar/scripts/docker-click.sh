#!/usr/bin/env bash
# Detecta doble click y abre lazydocker en un terminal.
STAMP=/tmp/waybar-docker-click-ts
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
    if command -v kitty >/dev/null 2>&1; then
        setsid kitty -e lazydocker >/dev/null 2>&1 &
    elif command -v foot >/dev/null 2>&1; then
        setsid foot lazydocker >/dev/null 2>&1 &
    elif command -v alacritty >/dev/null 2>&1; then
        setsid alacritty -e lazydocker >/dev/null 2>&1 &
    elif command -v wezterm >/dev/null 2>&1; then
        setsid wezterm start -- lazydocker >/dev/null 2>&1 &
    else
        setsid xterm -e lazydocker >/dev/null 2>&1 &
    fi
    disown 2>/dev/null || true
    exit 0
fi

echo "$now" > "$STAMP"
