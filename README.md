# Lab 2: Sandboxes

Docker Compose-sandboxes för Lab 2 i kursen *Nätverks-, OT- & AI-säkerhet* (AIS 2026, Chas Academy).

Det här repot innehåller två lokala sandbox-miljöer som används i lab-guiderna:

| Mapp | Används i | Vad det är |
|------|-----------|-----------|
| [`del2/`](./del2/) | Snabbspår Del 2: Segmentering | Fyra-container nätverkssandbox (attacker, jump-server, historian, mock-PLC) som levereras *medvetet trasig*. Din uppgift: fixa segmenteringen i `docker-compose.yml` så `verify.sh` blir grön. |
| [`del3/`](./del3/) | Snabbspår Del 3: Detektion | PLC + HMI + Suricata IDS + attack-skript (FC5/FC6/FC16). Du utökar regeluppsättningen och bekräftar att dina attacker triggar larm. |

## Krav

- Docker + Docker Compose v2
- Linux / macOS / WSL2 (testat på Ubuntu 22.04 + macOS 14)
- ca 2 GB RAM ledigt

## Snabbstart

```bash
git clone https://github.com/r87-e/ais-lab2-sandboxes.git ~/ais-lab2-sandboxes
cd ~/ais-lab2-sandboxes

# Del 2
cd del2
docker compose up -d
./verify.sh

# Del 3 (separat sandbox)
cd ../del3
docker compose up -d
./verify-detection.sh
```

## Lab-guiderna (huvudinstruktioner)

Hela uppgiftsbeskrivningen, inlämningskrav, och pedagogisk kontext ligger i studentportalen:

- [Snabbspår Del 2: Segmentering](https://web-gilt-three-68.vercel.app/content/week-7-lab2-snabbspar-del2.html)
- [Snabbspår Del 3: Detektion med Suricata](https://web-gilt-three-68.vercel.app/content/week-7-lab2-snabbspar-del3.html)

Det här repot ger dig stacken. Lab-guiderna ger dig uppgiften.

## Template-repo för din inlämning

Skapa din egen inlämningsmapp via [r87-e/ais-lab2-template](https://github.com/r87-e/ais-lab2-template) (klicka *"Use this template"*).

## Stuck?

Skicka en ticket via portalens *"Stöd"*-knapp.
