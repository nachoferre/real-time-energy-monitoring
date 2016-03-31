 --wifi--
 wifi.setmode(wifi.STATION)
 --wifi.sta.config("ferreras_wifi","3sp1n0s23BI2016")
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
mqtt_broker_port = 1883
mqtt_username = ""
mqtt_password = ""
mqtt_client_id = "ina"
time_between_sensor_readings = 60

power = 1
current = 2
voltage = 3

tmr.alarm(2, 1000, 1, function()
    if connected == false then
        print("Awaiting for connection....")
    else
        connection_mqtt()
    end
end)

function connection_mqtt()
    print("  IP: ".. mqtt_broker_ip)
    print("  Port: ".. mqtt_broker_port)
    print("  Client ID: ".. mqtt_client_id)
    print("  Username: ".. mqtt_username)
    cur,pwr,vol=false,false,false
    if i == 100 then
        tmr.stop(2)
    end
    m:publish("ESP8266/current",(current / 10), 0, 0, function(conn)
                print("Current sent.")
                cur = true
        end)
    m:publish("ESP8266/voltage",(voltage / 10), 0, 0, function(conn)
                print("Voltage sent.")
                vol = true
        end)
    m:publish("ESP8266/power",(power / 10), 0, 0, function(conn)
                print("Power sent.")
                pwr = true         
        end)  
    if cur and pwr and vol then
        i = i + 1
        print("Going to deep sleep for "..(time_between_sensor_readings/1000).." seconds") 
        node.dsleep(time_between_sensor_readings*1000)
    else
        print("There has been a problem in the mqtt process")
        print("Current: ".. tostring(cur))
        print("Voltage: ".. tostring(vol))
        print("Power: ".. tostring(pwr))
    end
end


