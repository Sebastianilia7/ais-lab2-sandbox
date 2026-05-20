"""
Mock water-treatment PLC — speaks Modbus TCP on :502.

Holding registers:
  HR0 = Setpoint        (default 5000)
  HR1 = TankLevel       (default 3000, drifts toward Setpoint)
  HR2 = PumpSpeed       (default 0)
  HR3 = ChlorineLevel   (default 500, drifts down)

Coils:
  CO0 = DosingValve     (False)
  CO1 = Alarm           (False)

This is a stand-in for what students saw on the real OT range
(ot.socksfirst.uk). Same register map. Process loop is a thread
that nudges TankLevel toward Setpoint so HMI shows live values.
"""
import asyncio
import threading
import time

from pymodbus.datastore import (
    ModbusSequentialDataBlock,
    ModbusServerContext,
    ModbusSlaveContext,
)
from pymodbus.server import StartAsyncTcpServer


def process_loop(context):
    """Background: drift TankLevel toward Setpoint, drift ChlorineLevel down."""
    slave = context[0]
    fx_hr = 3  # function code for holding registers in the datastore
    fx_co = 1  # coils
    while True:
        sp = slave.getValues(fx_hr, 0, count=1)[0]
        tl = slave.getValues(fx_hr, 1, count=1)[0]
        cl = slave.getValues(fx_hr, 3, count=1)[0]

        # nudge TankLevel toward Setpoint
        if tl < sp:
            tl = min(tl + 50, sp)
            slave.setValues(fx_hr, 2, [80])  # PumpSpeed
        elif tl > sp:
            tl = max(tl - 30, sp)
            slave.setValues(fx_hr, 2, [0])
        else:
            slave.setValues(fx_hr, 2, [0])
        slave.setValues(fx_hr, 1, [tl])

        # Chlorine drifts down
        cl = max(cl - 5, 0)
        if cl < 300:
            slave.setValues(fx_co, 0, [True])  # DosingValve on
            cl = min(cl + 20, 700)
        else:
            slave.setValues(fx_co, 0, [False])
        slave.setValues(fx_hr, 3, [cl])

        # Alarm if TankLevel overshoots Setpoint by > 2000
        alarm = tl > (sp + 2000)
        slave.setValues(fx_co, 1, [bool(alarm)])

        time.sleep(2)


async def main():
    hr_block = ModbusSequentialDataBlock(0, [5000, 3000, 0, 500] + [0] * 96)
    co_block = ModbusSequentialDataBlock(0, [False] * 10)
    slave = ModbusSlaveContext(hr=hr_block, co=co_block, zero_mode=True)
    context = ModbusServerContext(slaves=slave, single=True)

    threading.Thread(target=process_loop, args=(context,), daemon=True).start()

    print("Mock PLC listening on 0.0.0.0:502 (Modbus TCP)", flush=True)
    await StartAsyncTcpServer(context=context, address=("0.0.0.0", 502))


if __name__ == "__main__":
    asyncio.run(main())
