#!/bin/bash
# Conecta la VPN Forti (sin pedir contraseña interactiva)
LOG=/tmp/waybar-vpn.log
CERT_FILE="/home/lagosjaime/Desarrollo/config_linux/vpn-trusted-cert"

if [ ! -r "$CERT_FILE" ]; then
    echo "No se puede leer $CERT_FILE" >"$LOG"
    exit 1
fi

TRUSTED_CERT="$(tr -d '[:space:]' < "$CERT_FILE")"

sudo openfortivpn vp.gilco.cl:11443 \
    -u jlagos \
    -p 'fuentes25' \
    --trusted-cert "$TRUSTED_CERT" >"$LOG" 2>&1
rc=$?

if [ $rc -ne 0 ]; then
    swaynag -m "VPN: error al conectar (código $rc)" \
            -b "Ver log" "kitty -e sh -c 'tail -n 40 $LOG; read -p \"Enter para cerrar\"'" \
            2>/dev/null &
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "VPN" "Error al conectar (código $rc). Ver $LOG" 2>/dev/null || true
    fi
fi

exit $rc