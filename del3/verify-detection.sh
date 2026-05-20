#!/usr/bin/env bash
# Lab 2 Del 3 — Detection verifier
# Runs three Modbus attacks from inside jump-server, then greps fast.log
# for the expected Suricata rule SIDs.

set -u

GREEN="\033[32m"; RED="\033[31m"; YEL="\033[33m"; DIM="\033[2m"; RST="\033[0m"
LOG="./suricata-logs/fast.log"

# Sanity: required containers running?
for c in lab3-plc lab3-hmi lab3-jump lab3-suricata; do
  if ! docker ps --format '{{.Names}}' | grep -q "^${c}$"; then
    echo -e "${RED}Container '${c}' is not running.${RST} Run: docker compose up -d --build"
    exit 2
  fi
done

# Wait for Suricata to be fully initialized
echo "Waiting 8s for Suricata to finish loading rules..."
sleep 8

# Truncate the log so we only count fresh alerts
: > "$LOG" 2>/dev/null || true

echo ""
echo "════════════════════════════════════════════════════════════════════"
echo " Lab 2 Del 3 — Detection verifier"
echo "════════════════════════════════════════════════════════════════════"
echo ""
echo "Triggering attacks from jump-server..."
docker exec lab3-jump python3 /scripts/attack-fc6.py  >/dev/null 2>&1 || true
sleep 1
docker exec lab3-jump python3 /scripts/attack-fc5.py  >/dev/null 2>&1 || true
sleep 1
docker exec lab3-jump python3 /scripts/attack-fc16.py >/dev/null 2>&1 || true

# Give Suricata a moment to write
sleep 3

echo ""
echo " Checking $LOG for alerts..."
echo ""

CHECKS_TOTAL=0
CHECKS_OK=0

check() {
  local desc="$1" sid="$2"
  CHECKS_TOTAL=$((CHECKS_TOTAL+1))
  if grep -q "\[1:$sid:" "$LOG" 2>/dev/null; then
    printf "  ${GREEN}✓ FIRED${RST}  %-44s ${DIM}sid:%s${RST}\n" "$desc" "$sid"
    CHECKS_OK=$((CHECKS_OK+1))
  else
    printf "  ${RED}✗ MISS${RST}   %-44s ${YEL}sid:%s — not in fast.log${RST}\n" "$desc" "$sid"
  fi
}

check "FC6  Write Single Register"      2000006
check "FC5  Force Single Coil"          2000005
check "FC16 Write Multiple Registers"   2000016
check "New Modbus TCP session"          2001000

echo ""
echo "════════════════════════════════════════════════════════════════════"
if [ "$CHECKS_OK" -eq "$CHECKS_TOTAL" ]; then
  printf " ${GREEN}Alla %d detektioner OK${RST} — Suricata-reglerna fungerar.\n" "$CHECKS_TOTAL"
  echo " Spara fast.log + relevant del av eve.json som bevis i del3/."
  echo "════════════════════════════════════════════════════════════════════"
  exit 0
else
  FAIL=$((CHECKS_TOTAL - CHECKS_OK))
  printf " ${YEL}%d av %d detektioner saknas${RST}\n" "$FAIL" "$CHECKS_TOTAL"
  echo " Felsök: docker logs lab3-suricata 2>&1 | tail -40"
  echo "════════════════════════════════════════════════════════════════════"
  exit 1
fi
