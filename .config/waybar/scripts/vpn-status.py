#!/usr/bin/env python3
import json
import subprocess
import sys


def run(cmd):
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=5)
    except Exception:
        return None


# Detectar si openfortivpn esta corriendo
res = run(["pgrep", "-x", "openfortivpn"])
procs = []
if res is not None and res.returncode == 0:
    # obtener detalles de los procesos encontrados
    det = run(["pgrep", "-af", "openfortivpn"])
    if det is not None and det.returncode == 0:
        for line in det.stdout.strip().splitlines():
            if line.strip() and "pgrep" not in line:
                procs.append(line.strip())

connected = len(procs) > 0

# Intentar obtener interfaz/IP asignada
iface = ""
ip = ""
if connected:
    ipres = run(["ip", "-4", "-o", "addr", "show"])
    if ipres is not None and ipres.returncode == 0:
        for line in ipres.stdout.splitlines():
            parts = line.split()
            # busca interfaces ppp/tun/forti
            if len(parts) >= 4 and any(k in parts[1] for k in ("ppp", "tun", "forti")):
                iface = parts[1]
                ip = parts[3].split("/")[0] if len(parts) > 3 else ""
                break

if connected:
    text = "\uf023 on"
    tooltip = "VPN conectada"
    if iface:
        tooltip += f"\nInterfaz: {iface}"
    if ip:
        tooltip += f"\nIP: {ip}"
    if procs:
        tooltip += "\n\nProceso:"
        for p in procs:
            tooltip += f"\n\u2022 {p}"
    out = {"text": text, "tooltip": tooltip, "class": "connected", "alt": "connected"}
else:
    out = {
        "text": "\uf09c off",
        "tooltip": "VPN desconectada\nDoble click para conectar",
        "class": "disconnected",
        "alt": "disconnected",
    }

print(json.dumps(out, ensure_ascii=False))