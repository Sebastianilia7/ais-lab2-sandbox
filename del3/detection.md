# Del 3 — Detection (Suricata OT)

## Syfte
Denna del implementerar IDS-regler för att upptäcka attacker mot OT-nätverket (Modbus TCP) samt tidig rekognosering.

---

## Implementerade regler

### 1. Modbus session detection
- Detects: nya Modbus TCP-sessioner
- sid: 2001000

### 2. Modbus Write Single Register (FC6)
- Detects: ändring av enskilt register (setpoint manipulation)
- sid: 2000006

### 3. Modbus Force Single Coil (FC5)
- Detects: coil manipulation (start/stop av processfunktioner)
- sid: 2000005

### 4. Modbus Write Multiple Registers (FC16)
- Detects: bulk overwrite av processregister (kritisk attack)
- sid: 2000016

---

## 5. Egen regel — OT Recon detection
- Detects: port scanning / rekognosering mot Modbus (502)
- sid: 1000200

Denna regel fångar tidiga steg i attackkedjan innan write-kommandon sker.

---

## Test
Reglerna verifieras genom simulerad attack från komprometterad jump-server som genererar:
- Nmap scan (recon)
- FC5 write
- FC6 register manipulation
- FC16 bulk write

---

## Resultat
Suricata genererar alerts i fast.log för samtliga ovanstående aktiviteter, vilket bekräftar att både rekognosering och payload-baserade attacker detekteras.
