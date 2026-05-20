# Lab 2 — Del 2 Sandbox

Minimal Docker Compose-sandbox för Del 2 av Lab 2 (IT/OT-nätverkssegmentering).

Sandboxen levereras **medvetet trasig** — `attacker`-containern är dual-homed på både IT- och OT-nätverken, vilket betyder att den kan nå PLC:n direkt. Din uppgift är att fixa segmenteringen.

## Vad som ingår

Fyra containrar (alla baserade på `alpine:3.20`):

| Container | Roll | Pre-broken nätverk | Förväntat nätverk efter fix |
|---|---|---|---|
| `attacker` | IT-zon angripare (kali-lite) | `it` + `ot` ⚠️ | `it` |
| `historian` | DMZ-historian som läser produktionsdata | `dmz` + `ot` | `dmz` + `ot` |
| `jump-server` | Bastion (audited path från IT → OT) | `it` + `dmz` + `ot` | `it` + `dmz` + `ot` |
| `mock-plc` | Mock Modbus-server (port 502) | `ot` | `ot` |

Tre Docker-nätverk:
- `it`   — 172.30.10.0/24 (IT-zonen)
- `dmz`  — 172.30.20.0/24 (mellanzonen / SCADA-historian)
- `ot`   — 172.30.50.0/24 (OT-zonen / PLC + HMI) — **`internal: true`** (ingen internet-egress)

## Snabbstart

```bash
cd infra/lab2-del2-sandbox
docker compose up -d
./verify.sh
```

Direkt efter `up` ska `verify.sh` visa **1 BROKEN-rad** (attacker → mock-plc). Det är meningen. Din uppgift är att få samtliga rader att bli OK.

## Vad du gör

Följ `web-content/week-7-lab2-snabbspar-del2.html` (Snabbspår Del 2) — där guidas du genom:

1. Inspektera nuvarande (trasiga) tillstånd
2. Identifiera segmenteringsbrist (attacker dual-homed)
3. Korrigera `docker-compose.yml` så `attacker` bara ligger på `it`
4. Säkerställ att `jump-server` är enda vägen från DMZ till OT
5. Kör `verify.sh` igen för bevis att segmenteringen håller

## verify.sh

Skriptet testar samtliga kombinationer:

| Från → Till | Förväntat |
|---|---|
| attacker → mock-plc:502 | BLOCK (illegitimt — IT får ej nå OT direkt) |
| attacker → jump-server:22 | ALLOW (bastion-ingången är OK från IT) |
| jump-server → mock-plc:502 | ALLOW (bastion → PLC är legitimt) |
| historian → mock-plc:502 | ALLOW (DMZ-historian läser produktionsdata) |
| mock-plc → internet | BLOCK (OT får inte tala ut mot Internet) |
| historian → internet | ALLOW (DMZ får synka tid, hämta uppdateringar) |

Skriptet returnerar exit-kod 0 om alla kontroller stämmer, annars exit-kod 1.

## Städa upp

```bash
docker compose down -v
```

## Vill du se en working solution?

`solutions/` är gitignored. När du är klar (eller vill jämföra) — be Erkan om referenslösningen, eller jämför din `docker-compose.yml` med kraven ovan.
