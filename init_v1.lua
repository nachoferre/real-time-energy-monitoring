require ("ina219")


-- here we specified the subscriptions the esp has active
function subs()
    m:subscribe("/FreeBoard/sleep", 0, function(conn)
        print("Subscription successful")
        --tmr.delay(1000)

    end)
end

function connection_mqtt()
   -- j = 1
    for j=1,8
    do
        local ina_chip = ina219:new()
        ina_chip:set_adr(ina_adr[j])
        local current = ina_chip:read_current()
        local voltage = ina_chip:read_voltage()
        local power = ina_chip:read_power()
        print(tostring(power))
        print(tostring(voltage))
        print(tostring(current))
        ina_chip = nil
        m:publish("/ESP8266/0/"..tostring(j).."/current",current , 0, 0, function(conn)
            print("Current sent.")
            end)
        m:publish("/ESP8266/0/"..tostring(j).."/voltage",voltage, 0, 0, function(conn)
            print("Voltage sent.")
            end)
        a=m:publish("/ESP8266/0/"..tostring(j).."/power",power, 0, 0, function(conn)
            print("Power sent.")
            end)
   end
    tmr.alarm(3,time_between_sensor_readings*1000, 0, function() connection_mqtt() end)
    --print("Going to deep sleep for "..(time_between_sensor_readings/1000).." seconds")
    --node.dsleep(time_between_sensor_readings*1000)
end

--wifi--
wifi.setmode(wifi.STATION)
--wifi.sta.config("ferreras_wifi","PASS_HERE")
--wifi.sta.config("Android-connection","3sp1n0s23BI2016")
wifi.sta.config("linksys_223","linksys223")
wifi.sta.connect()
connected = false
m = mqtt.Client(mqtt_client_id, 1200000000, mqtt_username, mqtt_password)

tmr.alarm(1, 1000, 1, function()
    if wifi.sta.getip()== nil then
      print("IP unavaiable, Waiting...")
    else
      print("ESP8266 mode is: " .. wifi.getmode())
      print("The module MAC address is: " .. wifi.ap.getmac())
      print("Config done, IP is "..wifi.sta.getip())
      print(wifi.sta.status())


      a = m:connect( mqtt_broker_ip , mqtt_broker_port, 0, function(conn)
          print("Connected to MQTT")
          print("  IP: ".. mqtt_broker_ip)
          print("  Port: ".. mqtt_broker_port)
          print("  Client ID: ".. mqtt_client_id)
          print("  Username: ".. mqtt_username)
          subs()
          connected = true
          tmr.unregister(1)
          end )
    end
end)

m:on("message", function(conn, topic, data)
    print("message recieved. Topic: "..topic)
    if topic == "/FreeBoard/sleep" then
        if type(data) == "string" then
            message = tonumber(message)
            time_between_sensor_readings = data
            print("treated")
        else
            print("Format not accepted")
        end
--new subs to be treated here
    end

end)

--mqtt--
mqtt_broker_ip = "192.168.1.6"
mqtt_broker_port = 8266
mqtt_username = ""
mqtt_password = ""
mqtt_client_id = "esp1-nacho"
time_between_sensor_readings = 100
--node.dsleep(0)

local ina_chip = nil
ina_adr = {0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47}
for j=1,8
do
  ina_chip = ina219:new()
  ina_chip:init(ina_adr[j])
  ina_chip = nil
end

tmr.alarm(3,time_between_sensor_readings, 1, function()
    if connected == true then
        tmr.unregister(3)
        print("starting sends")
        connection_mqtt()
    end
end)
