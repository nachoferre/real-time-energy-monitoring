--- MQTT ---
mqtt_broker_ip = "192.168.1.66"     
mqtt_broker_port = 1883
mqtt_username = ""
mqtt_password = ""
mqtt_client_id = ""

--- WIFI ---
wifi_SSID = "AndroidAP"
wifi_password = "tatopillo12"
-- wifi.PHYMODE_B 802.11b, More range, Low Transfer rate, More current draw
-- wifi.PHYMODE_G 802.11g, Medium range, Medium transfer rate, Medium current draw
-- wifi.PHYMODE_N 802.11n, Least range, Fast transfer rate, Least current draw 
wifi_signal_mode = wifi.PHYMODE_N

client_ip="192.168.1.45"
client_netmask="255.255.255"
client_gateway="192.168.1.1"

--- INTERVAL ---
-- In milliseconds. Remember that the sensor reading, 
-- reboot and wifi reconnect takes a few seconds
time_between_sensor_readings = 60000

--################
--# END settings #
--################

-- Setup MQTT client and events
m = mqtt.Client(client_id, 120, mqtt_username, mqtt_password)
power = 0
current = 0
voltage = 0

-- Connect to the wifi network
wifi.setmode(wifi.STATION) 
--wifi.setphymode(wifi_signal_mode)
wifi.sta.config(wifi_SSID, wifi_password)
wifi.sta.connect()

if client_ip ~= "" then
    wifi.sta.setip({ip=client_ip,netmask=client_netmask,gateway=client_gateway})
    print("aaa")
end

i = 0
tmr.alarm(0, 100, 1, function() loop() end)

function loop() 
    if wifi.sta.status() == 5 then
        -- Stop the loop
        tmr.stop(0)

        m:connect( mqtt_broker_ip , mqtt_broker_port, 0, function(conn)
            print("Connected to MQTT") 
            tmr.alarm(2, 100, 1, function() connection_mqtt() end)        
        end )
        
    else
        print("Connecting...")
        print(wifi.sta.status())
    end
end        


function connection_mqtt()
    print("  IP: ".. mqtt_broker_ip)
    print("  Port: ".. mqtt_broker_port)
    print("  Client ID: ".. mqtt_client_id)
    print("  Username: ".. mqtt_username)
    cur,pwr,vol=false,false,false
    if i = 100 then
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
    if cur && pwr && vol then
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
