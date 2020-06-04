# Sintaxis
Diagrama:


En el anexo II se muestra la configuración interna de los componentes descritos en el diagrama además de una demo de funcionamiento*



Anfitrión:

Para poder comenzar con el despliegue de la APP necesitamos tener instalador los paquetes / programas de Docker y Github que indico a continuación dependiendo de tu SO.

Linux 18 , 19 & 20

Docker
Apt-get update
Apt-get install docker.io
Apt-get install docker-compose

Github
Apt-get install git




Mac os X Catalina

Docker
https://docs.docker.com/docker-for-mac/install/

Github
https://git-scm.com/download/mac


Windows 10

Docker
https://docs.docker.com/docker-for-windows/install/

Github
https://git-scm.com/download/win


Si vamos a instalar Docker en una maquina virtual Windows aquí muestro algunos puntos importantes a tener en cuenta:

	Activar Hiper-V en Windows 10(desactivar,reiniciar y activar si tenemos problemas con Docker)

 

	Debemos tener una cuenta en Docker HUB (es gratis) para loguearnos y arrancar el Shell Script


	Debemos cambiar el DNS interno de Docker a 8.8.8.8

 



Desplegar APP en cualquiera de los anfitriones.

1.	Descargamos las herramientas anteriormente descritas dependiendo de nuestro SO

2.	Descargamos el siguiente archivo localmente de mi repositorio

https://github.com/cdmzero/deploy_english_academy


3.	Abrimos un terminal en la carpeta descargada del repositorio. 
(En Windows botón derecho en la carpeta  y Git-bash here) 





4.	Damos los permisos de ejecución

-	chmod a+x init_app.sh


5.	Elegimos la opción 1 Desplegar aplicación.

 


6.	Si todo ha salido bien debemos poder entrar mediante el puerto 8080 y loguearnos normal.

7.	Para acceder ponemos la siguiente dirección en el navegadorLocalhost:8080

Para hacer login.
User	

admin 

jose@jose.com

pruebaprueba


teacher	

lora@lora.com

pruebaprueba
  

Shell Script:

Este script al arrancarse nos pregunta 4 opciones básicas.

	Implementar la aplicación

Esta opción montará los micro servicios (Php, Mysql, Nginx, PhpMyadmin) base necesarios para la implementación de la aplicación directamente extraída de nuestra versión mas reciente publicada en GitHub.


	Ver contenedores activos

Nos muestras los contendores activos

	Parar/Iniciar contenedores

Arranca los servicios si están parados o los para si están iniciados

	Borrar aplicación

Borra todo el proyecto de nuestro equipo y elimina los micro
servicios creados por Docker.

Docker-Comose.yml
version: '3.1'
	

	networks: // Definimos la red compartida por los diferentes servicios que levantaremos 
	  laravel:
	

	services: Definimos los servicios a levantar
	  
	  nginx: //sevidor web 
	    image: nginx:stable-alpine. # que cree el contenedor con la ultima imagen estable de NGINX
	    container_name: nginx.  # nombre del contenedor generado
	    ports:
	      - "8080:8080 # la primera cifra representa los puertos de la maquina anfitriona por la que se conectará al contenedor y la segunda los puertos de contenedor por los que se podrá atacar al servicio
	      # En el archivo nginx/default esta declarado conjuntamente por este puerto(8080)en especifico
	    volumes: #Montamos los volúmenes para asociar ficheros del anfitrión con el contenedor
	      - ./src:/var/www/html #la carpeta del anfitrión será la equivalente a la carpeta publica de NGINX
	      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf #la carpeta del anfitrión donde marcamos todos los parámetros del servidor la asociamos a la carpeta de configuración del contenedor
	    depends_on: #Si alguno de estos servicios no se levanta este tampoco
	      - php
	      - mysql
	      - phpmyadmin
	    networks:
	      - laravel
	

	  mysql:
	    image: mysql:5.7.29
	    container_name: mysql
	    restart: unless-stopped
	    tty: true
	    volumes:
	      - ./mysql:/var/lib/mysql
	    ports:
	      - "3306:3306"
	    environment: #Aqui definimos las variables de entorno asociados a este conotenedor mysql
	    #Estos parámetros coinciden a su vez archivo .env de laravel también
	      MYSQL_DATABASE: laravel_master
	      MYSQL_USER: homestead
	      MYSQL_PASSWORD: secret
	      MYSQL_ROOT_PASSWORD: secret
	      SERVICE_TAGS: dev
	      SERVICE_NAME: mysql
	    networks:
	      - laravel
	

	  phpmyadmin:
	    image: phpmyadmin/phpmyadmin
	    container_name: php_my_admin
	    ports:
	      - "8181:80"
	    environment: #Aqui apuntamos al nombre del contenedor que contiene mysql
	      PMA_HOST: mysql 
	      MYSQL_USERNAME: homestead
	      MYSQL_ROOT_PASSWORD: secret
	    networks:
	      - laravel
	

	

	  php:
	    build.   #En esta línea marcamos el punto de partida para construir php y atacamos al dockerfile   
	      context: .
	      dockerfile: Dockerfile. #en el docker file montaremos la imagen y todo el entorno por separado para configurarlo con NGINX
	    container_name: php 
	    volumes:
	      - ./src:/var/www/html.  
	    ports:
	      - "9000:9000".    
	    networks:
	      - laravel



Dockerfile


FROM php:7.2-fpm-alpine

WORKDIR /var/www/html  # Aqui hacemos un enlace simbólico al volumen montado previamente definido en el servicio

RUN docker-php-ext-install pdo pdo_mysql #Instalamos las extensiones necesarias para que funcione correctamente PHP 



Para que funcione todo correctamente y el servidor web atienda peticiones de clientes y por debajo trabaje con PHP debemos añadir estas líneas al archivo default de nginx previamente declarado en el volumen del servicio de NGINX

/nginx/default.conf

	server {
	    listen 8080; #puerto de escucha del contenedor
	    index index.php index.html;
	    server_name localhost;
	    error_log  /var/log/nginx/error.log;
	    access_log /var/log/nginx/access.log;
	    root /var/www/html/public;
	

	    location / {
	        try_files $uri $uri/ /index.php?$query_string;
	    }
	

	    location ~ \.php$ {. #variables de entorno necesarias para el correcto funcionamiento de PHP en el servidor
	        try_files $uri =404;
	        fastcgi_split_path_info ^(.+\.php)(/.+)$;
	        fastcgi_pass php:9000;
	        fastcgi_index index.php;
	        include fastcgi_params;
	        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
	        fastcgi_param PATH_INFO $fastcgi_path_info;
	    }
	}

