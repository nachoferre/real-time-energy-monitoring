# tfg-ina219-power


Los ficheros:
Class.lua
ina219.lua
scritp.lua

Con estos ficheros podemos establecer una conexion con un ina219 a traves de un esp8266 con lua.
Para ello simplemente hemos de cargar en la placa los 3 ficheros y ejecutar el script.lua.

sudo php phpmqtt_input.php&

paginas de configuracion

  Configuracion de mosquito
    http://www.rs-online.com/designspark/electronics/eng/blog/building-distributed-node-red-applications-with-mqtt

  Configuracion node-red y freeboard
    https://primalcortex.wordpress.com/2015/02/25/setting-up-an-iot-frameworkdashboard-with-nodered-moscamosquitto-and-freeboard-io-dashboard/


start mosca
mosca -p 8266 --http-port 9001 -v --credentials /home/nacho/Desktop/tfg-ina219-power/Lua/credentials.json
