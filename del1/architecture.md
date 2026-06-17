# Del 1 — OT-arkitektur (ICS/SCADA)

## Översikt
Systemet är en simulerad OT-miljö med PLC, HMI, jump-server och IDS (Suricata). Kommunikation sker främst via Modbus TCP.

---

## Purdue Model (anpassad)

**Level 0–1 (Process/Field)**
- Simulerad process (tank/chemical system i PLC)
- I/O styrs via Modbus register

**Level 2 (Control)**
- PLC (mock-plc)
- Port: 502 (Modbus TCP)

**Level 3 (Operations)**
- HMI (Node-RED / poller)
- Historian (loggning av processdata)

**Level 3.5 (DMZ)**
- Jump-server (SSH bastion)
- IP: 172.31.50.99

**Level 4–5 (IT / Attack surface)**
- Attacker container
- Administration sker via jump-server

---

## Nätverk
- OT subnet: 172.31.50.0/24
- PLC: 172.31.50.10
- Jump-server: 172.31.50.99

---

## Protokoll
- Modbus TCP (port 502)
- SSH (port 22 via jump-server)

---

## Attack surface
- Öppen Modbus utan autentisering
- SSH jump-server (credential-based access)
- Ingen encryption mellan OT-noder
- PLC saknar auth/logging

---

## Risk
Den största risken är att en komprometterad jump-server ger direkt skrivaccess till PLC-register vilket kan påverka fysiska processer.
