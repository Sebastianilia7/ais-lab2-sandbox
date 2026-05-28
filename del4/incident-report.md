# ICS-CERT Incidentrapport — Lab 2 Del 4

## 1. Sammanfattning
- Incident: Modbus-baserad OT-manipulation från komprometterad jump-server
- Allvarlighetsgrad: Hög
- Påverkade system: PLC (172.31.50.10)
- Status: Hanterad i labbmiljö

## 2. Tidslinje
- Attack startade: (fyll i från Del 3)
- Detektion: Suricata alerts (SID 2000005/2000006/2000016)
- Containment: jump-server isolerades från OT
- Recovery: Setpoint återställd till 5000

## 3. Påverkan
- Processvärden manipulerades temporärt
- Ingen permanent påverkan i labb

## 4. Åtgärder
- Network isolation av jump-server
- Återställning via historian
- Evidence insamlat från logs

## 5. Lessons learned
- OT kräver försiktig containment
- Jump-server är kritisk attackvektor
- Saknad autentisering i Modbus är en risk
