require ("ina219")

ina219:init()--TODO poder usar mas de un objeto para poder comunicar con multiples ina
tmr.alarm(1, 2000, 1, function()
    voltage = ina219:read_voltage()
    current = ina219:read_current()
    power = ina219:read_power()

    print("================")
    print( "Voltage: "..voltage)
    print( "Current: "..current)
    print( "Power: "..power)
    end)
