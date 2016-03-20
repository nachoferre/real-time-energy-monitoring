require ("ina219")

ina_1_adr = 0x40
ina_1 = ina219:new()
ina_1:init(ina_1_adr)
tmr.alarm(1, 2000, 1, function()
	
    voltage = ina_1:read_voltage()
    current = ina_1:read_current()
    power = ina_1:read_power()

    print("================")
    print( "Voltage: "..voltage)
    print( "Current: "..current)
    print( "Power: "..power)
    end)
