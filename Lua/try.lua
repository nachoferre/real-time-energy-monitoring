require ("ina219")

 --wifi--
 wifi.setmode(wifi.STATION)
 --wifi.sta.config("ferreras_wifi","PASS_HERE")
 --wifi.sta.config("Android-connection","")
 --wifi.sta.config("FUNDASETH1","PASS_HERE")
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
          subs()
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

local ina_chip = nil
ina_adr = {0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47}
i= 0
for j=1,8
do
  ina_chip = ina219:new()
  ina_chip:init(ina_adr[j])
  ina_chip = nil
end

function pub()
    while true do
        if connected == true then
            tmr.alarm(3,time_between_sensor_readings, 0, connection_mqtt)
        end
    end
end
function connection_mqtt()
    local ina_chip = ina219:new()
    ina_chip:init(ina_adr[i])
    local current = ina_chip:read_current()
    local voltage = ina_chip:read_voltage()
    local power = ina_chip:read_power()
    ina_chip = nil
    i = i + 1
    m:publish("ESP8266/0/"..tostring(i).."/current",current , 0, 0, function(conn)
        print("Current sent.")
        end)
    tmr.delay(50)
    m:publish("ESP8266/0/"..tostring(i).."/voltage",voltage, 0, 0, function(conn)
        print("Voltage sent.")
        end)
    tmr.delay(50)
    m:publish("ESP8266/0/"..tostring(i).."/power",power, 0, 0, function(conn)
        print("Power sent.")
        end)
    if i==8 then
      i = 0
    end
    --print("Going to deep sleep for "..(time_between_sensor_readings/1000).." seconds")
    --node.dsleep(time_between_sensor_readings*1000)
end

function subs()
    m:subscribe("FreeBoard/sleep", 0, function(client, topic, message)
        print(message)
        if type(message) == "string" then
            message = tonumber(message)
            time_between_sensor_readings = message
        elseif type(message) == "number" then
            time_between_sensor_readings = message
        else
            print("lo recibido no tiene un formato aceptable")
        end
    end)
end
