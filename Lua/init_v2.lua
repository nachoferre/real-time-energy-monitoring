require ("ina219")


-- here we specified the subscriptions the esp has active
function subs()
    m:subscribe("/Node-Red/sleep", 0, function(conn)
        print("Subscription successful")
    end)
    m:subscribe("/Node-Red/current_enable", 0, function(conn)
        print("Subscription successful")
    end)
    m:subscribe("/Node-Red/power_enable", 0, function(conn)
        print("Subscription successful")
    end)
    m:subscribe("/Node-Red/voltage_enable", 0, function(conn)
        print("Subscription successful")
    end)
end

function connection_mqtt()
   -- j = 1
   t = {}
   for j=1,8
   do
        local ina_chip = ina219:new()
        local current = -1
        local power = -1
        local voltage = -1
        ina_chip:set_adr(ina_adr[j])
        if current_enable[i] == true then
            current = ina_chip:read_current()
        elseif voltage_enable[i] == true then
            voltage = ina_chip:read_voltage()
        elseif power_enable[i] == true then
            power = ina_chip:read_power()
        end
        t["ina-"..tostring(j)] = {}
        t["ina-"..tostring(j)]["current"] = current
        t["ina-"..tostring(j)]["power"] = power
        t["ina-"..tostring(j)]["voltage"] = voltage
   end
   ok, json = pcall(cjson.encode, t)
   if ok then
       m:publish("/ESP8266/0/",json , 0, 0, function(conn)
           print("Whole data sent.")
           end)
   else
       json = pcall(cjson.encode, t)
       m:publish("/ESP8266/0/",json , 0, 0, function(conn)
           print("Whole data sent.")
           end)
    end
   tmr.alarm(3,time_between_sensor_readings*1000, 0, function() connection_mqtt() end)
    --print("Going to deep sleep for "..(time_between_sensor_readings/1000).." seconds")
    --node.dsleep(time_between_sensor_readings*1000)
end

--wifi--
wifi.setmode(wifi.STATION)
--wifi.sta.config("ferreras_wifi","PASS_HERE")
wifi.sta.config("Android-connection","3sp1n0s23BI2016")
--wifi.sta.config("linksys_223","linksys223")
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
    if topic == "/Node-Red/sleep" then
        if type(data) == "string" then
            message = tonumber(message)
            time_between_sensor_readings = data
            print("treated")
        else
            print("Format not accepted")
        end
--new subs to be treated here
    elseif topic == "/Node-Red/power_enable" then
        if type(data) == "string" then
            message = tonumber(message)
            if power_enable[message] then
                power_enable[message] = false
            else
                power_enable[message] = true
            end
            print("treated")
        else
            print("Format not accepted")
        end
    elseif topic == "/Node-Red/current_enable" then
        if type(data) == "string" then
            message = tonumber(message)
            if current_enable[message] then
                current_enable[message] = false
            else
                current_enable[message] = true
            end
            print("treated")
        else
            print("Format not accepted")
        end
    elseif topic == "/Node-Red/voltage_enable" then
        if type(data) == "string" then
            message = tonumber(message)
            if voltage_enable[message] then
                voltage_enable[message] = false
            else
                voltage_enable[message] = true
            end
            print("treated")
        else
            print("Format not accepted")
        end
    end

end)

--mqtt--
mqtt_broker_ip = "192.168.43.247"
mqtt_broker_port = 8266
mqtt_username = ""
mqtt_password = ""
mqtt_client_id = "esp1-nacho"
time_between_sensor_readings = 100
--node.dsleep(0)

local ina_chip = nil
ina_adr = {0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47}
current_enable = {true, true, true, true, true, true, true}
power_enable = {true, true, true, true, true, true, true}
voltage_enable = {true, true, true, true, true, true, true}
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
