#!/usr/bin/env bash
# Configura sudo para que la VPN (openfortivpn) no pida contraseña
# ni requiera terminal. Ejecutar con: sudo ./setup-vpn-nopasswd.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root (sudo)." >&2
    exit 1
fi

USER_NAME="${SUDO_USER:-$USER}"

cat > /etc/sudoers.d/openfortivpn <<EOF
Defaults:${USER_NAME} !requiretty
${USER_NAME} ALL=(ALL) NOPASSWD: /usr/bin/openfortivpn, /usr/bin/pkill
EOF
chmod 440 /etc/sudoers.d/openfortivpn

if ! visudo -c -f /etc/sudoers.d/openfortivpn >/dev/null 2>&1; then
    echo "Error de sintaxis en sudoers, revirtiendo." >&2
    rm -f /etc/sudoers.d/openfortivpn
    exit 1
fi

echo "Sudoers configurado para ${USER_NAME}."
echo "Recuerda que convpn.sh contiene la contraseña de la VPN en texto plano."