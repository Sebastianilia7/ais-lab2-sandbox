# Lab 2 — Del 3 Sandbox

Suricata IDS-sandbox för Del 3 av Lab 2. Bygger vidare på Del 2:s
Purdue-segmentering men lägger på en riktig **Modbus TCP-PLC** + **HMI-poller**
+ **Suricata** som sniffar OT-bryggan.

## Komponenter

| Container | Roll | Nätverk |
|---|---|---|
| `lab3-plc` | pymodbus-server, holding registers 0–3 + coils 0–1 | `ot` |
| `lab3-hmi` | HMI-poller, FC3 var sekund (legit baseline-trafik) | `ot` |
| `lab3-attacker` | IT-zon angripare, kan **inte** nå PLC:n direkt | `it` |
| `lab3-historian` | DMZ-historian, läser produktionsdata | `dmz`+`ot` |
| `lab3-jump` | Bastion + lab-pivot för attacker (sshd + pymodbus) | `it`+`dmz`+`ot` |
| `lab3-suricata` | IDS, sniffar `br-lab3-ot` via af-packet | host |

## Snabbstart

```bash
cd infra/lab2-del3-sandbox
docker compose up -d --build       # första gången bygger 3 lokala images
docker compose ps                  # 6 containrar ska vara Up
docker logs -f lab3-hmi            # bekräfta att HMI:n pollar PLC:n
./verify-detection.sh              # kör attackerna, kolla att alerts fyrar
```

Första `up --build` tar ca 1–2 minuter pga `pip install pymodbus`. Sen är det
cachat och snabbt.

## Vad sandbox testar

`verify-detection.sh` kör tre attacker från jump-servern (simulerar en
kompromissad bastion) och kontrollerar att Suricata loggat varje SID:

| Attack | Modbus FC | Suricata SID |
|---|---|---|
| `attack-fc6.py` | FC6 Write Single Register | 2000006 |
| `attack-fc5.py` | FC5 Force Single Coil | 2000005 |
| `attack-fc16.py` | FC16 Write Multiple Registers | 2000016 |
| (TCP SYN på 502) | — | 2001000 (nya sessioner) |

## Vad studenten gör

Följ `web/content/week-7-lab2-snabbspar-del3.html`. Steg i korthet:

1. Boota stacken, läs Suricata-reglerna i `rules/ot.rules`
2. Skicka första attacken från jump-server → läs `suricata-logs/fast.log`
3. Skriv egna 1–2 rules (t.ex. variant som larmar på *specifika*
   registervärden, eller på nya rules för FC8 Diagnostics)
4. Triggra alla attacker, kör verifyern
5. Skriv `del3/detection.md` + spara fast.log + eve.json som bevis

## Felsökning

```bash
# Suricata startar inte
docker logs lab3-suricata 2>&1 | tail -40

# Hittar inte br-lab3-ot
ip link show br-lab3-ot           # Linux/Colima VM
# Säkerställ att compose-projektet heter lab2-del3-sandbox
# (om du klonat repot i annan path, bridge-namnet är fast via driver_opts)

# Alerts triggas inte
# 1. kontrollera modbus app-layer enabled:
grep -A3 'modbus:' suricata.yaml
# 2. kolla att Suricata faktiskt ser PLC-trafik:
docker logs lab3-suricata 2>&1 | grep -i "packets:" | tail -5

# Modbus parser packetloss?
# Suricata startar paus-buffrat — vänta 8s innan attacker triggas (verify gör det)
```

## Städa upp

```bash
docker compose down -v --rmi local
sudo rm -rf suricata-logs        # genereras med root inifrån containern
```

## Solution

`solutions/` är gitignored. Innehåller exempel på 2–3 extra Suricata-regler
som studenter kan rikta sig efter för VG-fördjupning.
