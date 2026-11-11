#!/usr/bin/env python3
import json
import subprocess
import sys


def run(cmd):
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=5)
    except Exception:
        return None


info = run(["docker", "info"])
if info is None or info.returncode != 0:
    out = {
        "text": "\uf308 off",
        "tooltip": "Docker no esta corriendo",
        "class": "stopped",
        "alt": "stopped",
    }
    print(json.dumps(out, ensure_ascii=False))
    sys.exit(0)

res = run(["docker", "ps", "--format", "{{.Names}}\t{{.Status}}\t{{.Image}}"])
lines = []
if res is not None and res.returncode == 0:
    lines = [l for l in res.stdout.strip().splitlines() if l.strip()]

count = len(lines)
text = f"\uf308 {count}"

if count == 0:
    tooltip = "Docker corriendo\nSin contenedores activos"
else:
    tooltip = f"Contenedores activos ({count}):"
    for l in lines:
        parts = l.split("\t")
        name = parts[0] if len(parts) > 0 else ""
        status = parts[1] if len(parts) > 1 else ""
        image = parts[2] if len(parts) > 2 else ""
        tooltip += f"\n\u2022 {name} \u2014 {status} ({image})"

out = {
    "text": text,
    "tooltip": tooltip,
    "class": "running" if count > 0 else "idle",
    "alt": "running",
}
print(json.dumps(out, ensure_ascii=False))
