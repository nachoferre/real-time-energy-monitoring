require'Class'
ina219 = {
    id = 0,
    address = 0x41,
    calibration_reg = 0x05,
    power_reg = 0x03,
    voltage_reg = 0x02,
    current_reg = 0x04,
    sda = 6,
    scl = 5,
    current_num = 7.142857,
    power_num = 0.357142
    }
local ina219_mt = Class(ina219)

    function ina219:showdata()
        voltage = ina219:read_voltage()
        current = ina219:read_current()
        power = ina219:read_power()

        print("================")
        print( "Voltage: "..voltage)
        print( "Current: "..current)
        print( "Power: "..power)
    end

    function ina219:init(adr)
    	ina219.address = adr
        i2c.setup(self.id, self.sda, self.scl, i2c.SLOW)
    	i2c.start(self.id)
    	i2c.address( self.id, self.address, i2c.TRANSMITTER )
    	number = i2c.write(self.id,self.calibration_reg)
    	print("Written "..number)
    	number = i2c.write(self.id,0x16)
    	print("Written "..number)
    	number = i2c.write(self.id,0xDB)
    	print("Written "..number)
    	i2c.stop(self.id)
    end

    function ina219:read_voltage()
        i2c.start(self.id)
        i2c.address(self.id, self.address, i2c.TRANSMITTER)
        i2c.write(self.id,self.voltage_reg)
        i2c.stop(self.id)

        i2c.start(self.id)
        i2c.address(self.id, self.address, i2c.RECEIVER)
        number=i2c.read(self.id, 2) -- read 16bit val
        i2c.stop(self.id)

        h,l = string.byte(number,1,2)
        result = h*256 + l
        result = bit.rshift(result, 3) * 4
        --print(result)

        return result
    end

    function ina219:read_current()
        i2c.start(self.id)
        i2c.address(self.id, self.address, i2c.TRANSMITTER)
        i2c.write(self.id,self.current_reg)
        i2c.stop(self.id)

        i2c.start(self.id)
        i2c.address(self.id, self.address, i2c.RECEIVER)
        number=i2c.read(self.id, 2) -- read 16bit val
        i2c.stop(self.id)

        h,l = string.byte(number,1,2)
        result = h*256 + l
        --print(result)

        return result / self.current_num
    end

    function ina219:read_power()
        i2c.start(self.id)
        i2c.address(self.id, self.address, i2c.TRANSMITTER)
        i2c.write(self.id,self.power_reg)
        i2c.stop(self.id)

        i2c.start(self.id)
        i2c.address(self.id, self.address, i2c.RECEIVER)
        number=i2c.read(self.id, 2) -- read 16bit val
        i2c.stop(self.id)

        h,l = string.byte(number,1,2)
        result = h*256 + l
        --print(result)

        return result / self.power_num
    end
    
return ina219;
