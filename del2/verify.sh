#!/usr/bin/env bash
# Lab 2 — Del 2 Sandbox — Segmentation verifier
# Runs 6 connectivity checks against the running compose stack.
# Each check has an expected outcome (ALLOW or BLOCK). Returns
# exit-code 0 if every actual outcome matches expectation.

set -u

GREEN="\033[32m"; RED="\033[31m"; YEL="\033[33m"; DIM="\033[2m"; RST="\033[0m"

CHECKS_TOTAL=0
CHECKS_OK=0
CHECKS_FAIL=0

# Usage: run_check <description> <from-container> <expected ALLOW|BLOCK> <test-command>
run_check() {
  local desc="$1"
  local from="$2"
  local expected="$3"
  shift 3

  CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

  # docker exec returns 0 if the test inside succeeded (= ALLOW), non-zero on failure (= BLOCK).
  if docker exec "$from" "$@" >/dev/null 2>&1; then
    actual="ALLOW"
  else
    actual="BLOCK"
  fi

  if [ "$actual" = "$expected" ]; then
    printf "  ${GREEN}✓ OK${RST}     %-60s ${DIM}(expected %s, got %s)${RST}\n" "$desc" "$expected" "$actual"
    CHECKS_OK=$((CHECKS_OK + 1))
  else
    printf "  ${RED}✗ BROKEN${RST} %-60s ${YEL}(expected %s, got %s)${RST}\n" "$desc" "$expected" "$actual"
    CHECKS_FAIL=$((CHECKS_FAIL + 1))
  fi
}

# Sanity: are the containers running?
for c in lab2-attacker lab2-historian lab2-jump lab2-plc; do
  if ! docker ps --format '{{.Names}}' | grep -q "^${c}$"; then
    echo -e "${RED}Container '${c}' is not running.${RST} Run: docker compose up -d"
    exit 2
  fi
done

echo ""
echo "════════════════════════════════════════════════════════════════════"
echo " Lab 2 Del 2 — Segmentation verifier"
echo "════════════════════════════════════════════════════════════════════"
echo ""

# ─── Illegitimate flows (should be BLOCKed after fix) ────────────
echo " Illegitima vägar — får INTE gå igenom:"
run_check "attacker (IT) → mock-plc:502 (OT)"        lab2-attacker BLOCK nc -z -w 2 mock-plc 502
run_check "mock-plc (OT) → internet (1.1.1.1:53)"    lab2-plc      BLOCK nc -z -w 2 1.1.1.1 53

# ─── Legitimate flows (should be ALLOWed) ────────────────────────
echo ""
echo " Legitima vägar — SKA fungera:"
run_check "attacker (IT) → jump-server:22 (DMZ)"     lab2-attacker ALLOW nc -z -w 2 jump-server 22
run_check "jump-server (DMZ) → mock-plc:502 (OT)"    lab2-jump     ALLOW nc -z -w 2 mock-plc 502
run_check "historian (DMZ) → mock-plc:502 (OT)"      lab2-historian ALLOW nc -z -w 2 mock-plc 502
run_check "historian (DMZ) → internet (1.1.1.1:53)"  lab2-historian ALLOW nc -z -w 2 1.1.1.1 53

echo ""
echo "════════════════════════════════════════════════════════════════════"
if [ "$CHECKS_FAIL" -eq 0 ]; then
  printf " ${GREEN}Alla %d kontroller OK${RST} — segmenteringen är korrekt.\n" "$CHECKS_TOTAL"
  echo " Spara denna output till del2/verify-output.txt"
  echo "════════════════════════════════════════════════════════════════════"
  exit 0
else
  printf " ${YEL}%d av %d kontroller misslyckades.${RST}\n" "$CHECKS_FAIL" "$CHECKS_TOTAL"
  echo " Justera docker-compose.yml och kör ./verify.sh igen."
  echo "════════════════════════════════════════════════════════════════════"
  exit 1
fi
