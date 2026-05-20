"""HMI poller — emulates a Node-RED-style FC3 poll every 1s, like the real range."""
import time

from pymodbus.client import ModbusTcpClient

PLC_HOST = "mock-plc"
PLC_PORT = 502
POLL_INTERVAL = 1.0

client = ModbusTcpClient(PLC_HOST, port=PLC_PORT, timeout=2)

# Wait for the PLC to be ready
for attempt in range(20):
    if client.connect():
        break
    print(f"[HMI] waiting for PLC ({attempt})...", flush=True)
    time.sleep(1)
else:
    raise SystemExit("[HMI] could not connect to PLC after 20s")

print(f"[HMI] polling {PLC_HOST}:{PLC_PORT} FC3 HR0..3 every {POLL_INTERVAL}s", flush=True)

while True:
    try:
        rr = client.read_holding_registers(address=0, count=4, slave=1)
        if hasattr(rr, "isError") and rr.isError():
            print(f"[HMI] modbus error: {rr}", flush=True)
        else:
            sp, tl, ps, cl = rr.registers[:4]
            print(f"[HMI] SP={sp} TL={tl} PS={ps} CL={cl}", flush=True)
    except Exception as e:
        print(f"[HMI] exception: {e}", flush=True)
        try:
            client.close()
            client.connect()
        except Exception:
            pass
    time.sleep(POLL_INTERVAL)
