# Reflektion — Lab 2 Del 4

OT-säkerhet skiljer sig från IT genom att processer kan påverka fysisk verklighet. I denna labb såg jag att en enkel nätverksåtkomst till en jump-server kan leda till manipulation av PLC-värden.

Det mest realistiska momentet var attackkedjan: reconnaissance → exploit → manipulation. Det speglar riktiga OT-attacker.

Om jag skulle säkra en riktig PLC skulle jag börja med:
1. MFA och hård accesskontroll på jump-server
2. Segmentering mellan IT/OT med strikt policy
3. Övervakning av Modbus-kommandon i realtid

Det svåraste att försvara mot är legitima protokoll som används illvilligt, eftersom trafiken ofta ser “normal” ut.
