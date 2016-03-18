require ("ina219")

ina219:init()
tmr.alarm(1, 2000, 1, function()
    voltage = ina219:read_voltage()
    current = ina219:read_current()
    power = ina219:read_power()

    print("================")
    print( "Voltage: "..voltage)
    print( "Current: "..current)
    print( "Power: "..power)
    end)
