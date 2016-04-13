require ("ina219")

 --wifi--
 wifi.setmode(wifi.STATION)
 --wifi.sta.config("ferreras_wifi","PASS_HERE")
 wifi.sta.config("Android-connection","3sp1n0s23BI2016")
 wifi.sta.connect()
 connected = false
 tmr.alarm(1, 1000, 1, function()
 if wifi.sta.getip()== nil then
    print("IP unavaiable, Waiting...")
 else
    print("ESP8266 mode is: " .. wifi.getmode())
    print("The module MAC address is: " .. wifi.ap.getmac())
    print("Config done, IP is "..wifi.sta.getip())
    print(wifi.sta.status())

    m = mqtt.Client("nacho", 120, mqtt_username, mqtt_password)
    m:connect( mqtt_broker_ip , mqtt_broker_port, 0, function(conn)
        print("Connected to MQTT")
        print("  IP: ".. mqtt_broker_ip)
        print("  Port: ".. mqtt_broker_port)
        print("  Client ID: ".. mqtt_client_id)
        print("  Username: ".. mqtt_username)
        connected = true
        tmr.stop(1)
        end )
    end
end)

--mqtt--
mqtt_broker_ip = "192.168.43.247"
mqtt_broker_port = 8266
mqtt_username = "ina219"
mqtt_password = "ESP8266"
mqtt_client_id = "ina"
time_between_sensor_readings = 6000
--node.dsleep(0)

ina_list = {}
ina_adr = {0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47}
j= 0
for i=1,8
do
  ina_list[i] = ina219:new()
  ina_list[i]:init(ina_adr[i])
end

tmr.alarm(2, 5000, 1, function()
    if connected == false then
        print("Awaiting for connection....")
    else
        connection_mqtt()
    end
end)

function connection_mqtt()

    for i=1,8 do
        current = ina_list[i]:read_current()
        voltage = ina_list[i]:read_voltage()
        power = ina_list[i]:read_power()
        print(tostring(current))
        m:publish("ESP8266/0/"..tostring(i).."/1",current , 0, 0, function(conn)
            print("Current sent.")
            end)
        m:publish("ESP8266/0/"..tostring(i).."/2",voltage, 0, 0, function(conn)
            print("Voltage sent.")
            end)
        m:publish("ESP8266/0/"..tostring(i).."/3",power, 0, 0, function(conn)
            print("Power sent.")
            end)
    end
    print("Going to deep sleep for "..(time_between_sensor_readings/1000).." seconds")
    --node.dsleep(time_between_sensor_readings*1000)

end
