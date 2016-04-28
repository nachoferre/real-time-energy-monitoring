Real-Time Energy Monitoring
===========================
Este proyecto esta siendo desarrollado como trabajo de fin de grado para mi ultimo año de Ingeniaria de computadores en la Universidad Complutense de Madrid.


##Introducción
El proyecto tiene como objetivo lacreacion de un sistema de monitorizacion de energia. Para ello usamos los siguientes recursos hardware:
* ina219
* NodeMCU ESP8266 con Lua
* Raspberry Pi 2B

Para que la implementacion de este sistema sea los mas intuitiva y sencilla posible usaos los siguientes recursos software:
* Node-red
* Mosca
* MongoDB
* Freeboard


## Instalación
Para la instalación de todo el sistema necesitaremos nodejs, se recomienda una version 0.12 o superior.

#### Node-red
Ejecutamos el siguiente comando en home:
```bash
~$  sudo npm install -g --unsafe-perm node-red
```
Una vez instalado nos vamos al directorio de node-red y ejecutamos los siguientes comandos para instalar los nodos necesarios para conectarse con freeboard y con MongoDB.
```bash
~$  sudo npm install node-red-contrib-freeboard
~$  sudo npm install node-red-node-mongodb
```

#### Mosca
Mosca es el broker que vamos a utilizar para el manejo de los mensajes MQTT que vamos a utilizar en nuestro sistema.
En home ejecutamos:
```bash
~$  sudo npm install mosca bunyan -g
```
Bunyan es un addon que permite visualizar los logs de mosca de manera mucho mas guiada y comoda.

#### MongoDB
Mongo es el servidor que utilizaremos para la persistencia, este se puede cambiar por cualquier otro en Node-red.
```bash
~$  sudo apt-get install -i mongodb
```
#### Freeboard
Freeboard no requiere instalacion especifica ya que lo hemos instalado con el paquete del node-red-contrib-freeboard

## Ejecución
Para ejecutar hemos de cargar los archivos del repositorio en el ESP8266. Para ello usamos el [ESPlorer](http://esp8266.ru/esplorer/).
Despues hemos de levantar node-red y mosca respectivamente, en terminales separadas
```bash
~$  node-red
```
```bash
~$  mosca -p 8266 --very-verbose | bunyan
```
Para acceder a freeboard nos vamos a la siguiente url
[freeboard](http://127.0.0.1:1880/freeboard). La configuracion de los flujos de node-red apareceran como entradas en freeboard. Mas adelante se añadiran los archivos de flujo y el dashboard de freeboard para su completo uso.
