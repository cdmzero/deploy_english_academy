#! /bin/bash

clear

gitv=$(git --version) 

git=$?

docv=$(docker --version) 

docker=$?


comprobacion="$((docker + git))"

if [ $comprobacion -eq 0 ]; 
 then 

    while :
        do
            clear
                echo "________________________________________________________" 
                echo "________________________________________________________" 
                echo ""
                echo "Menu despliegue APP English School Value"
                echo "________________________________________________________" 
                echo "________________________________________________________" 
                echo ""
                echo ""
                echo "1. Desplegar aplicacion"
                echo ""
                echo "2. Ver Contenedores Activos"
                echo ""
                echo "3. Parar/iniciar contenedores"
                echo ""
                echo "4. Borrar APP"
                echo ""
                echo "5. Salir"
                echo ""
                echo "________________________________________________________" 
                echo "________________________________________________________" 
                echo ""
                echo ""
                echo "Docker Ver____ ${docv:15} "
                echo "Github Ver____ ${gitv:12} " 
                echo "" 
                echo ""
                echo -n "Seleccione una opcion [1 - 5] -----> "
                read opcion
                case $opcion in

                1)  if [ -d src ]
                    then
                    echo Ahora mismo el proyecto esta instalado
                    echo ""
                    echo ""
                    echo ""
                    echo ""
                    echo -n "Pulse cualquier tecla para continuar..."
                    read
                    else
                    echo ""
                    echo ""
                    echo "Comprobando los requerimientos de la implementacion"
                    echo "Espere un momento por favor . . ."

                        pingv=$(ping -c 3 8.8.8.8 > /dev/null 2>&1) 
                        ping=$?

                        if [ $ping -eq 0 ]
                        echo "Arrancando entorno para implementar la aplicacion:";
                        then
                            docker-compose up --build -d
                                if [ $? -eq 0  ]
                                    then
                                            git clone https://github.com/cdmzero/english_academy.git src
                                            chmod -R 777 src/ env
                                            cp env .env
                                            echo ""
                                            docker-compose stop > /dev/null 2>&1
                                            docker-compose start
                                            echo ""
                                            echo "Importando BD espere un momento..."
                                            sleep 25
                                            docker exec -i mysql mysql -uroot -psecret laravel_master < src/database.sql
                                            cp -R .env src/
                                            echo ""
                                            echo ""
                                            
                                            echo "Implementacion realizada con exito"
                                            echo ""
                                    else
                                    echo  ¡ERROR! Ha ocurrido un problema mientras se levantaba Docker Compose
                                    echo ""
                                    fi
                        else
                        echo "¡ERROR! Comprueba que la conexion a internet esta bien configurada"
                        fi

                        echo -n "Pulse cualquier tecla para continuar..."
                        read
                    fi
                    ;;
                2) clear
                    echo "Contenedores Activos"
                    echo ""
                    echo ""

                    var=$(docker ps | wc -l)
                
                    if [ $var -le 1 ]
                    then
                    echo "No hay ningun contenedor activo"

                    else
                    docker ps
                    fi
                    echo " "
                    echo " "
                    echo -n "Pulse cualquier tecla para continuar..."
                    read 

                ;;   
                3) echo "Parar/iniciar contenedores"
                    var=$(docker ps | wc -l)
                
                    if [ $var -le 2 ]
                    then
                        docker-compose stop > /dev/null 2>&1
                        docker-compose start
                        if [ $? -ne 0 ]
                        then echo "ERROR. Debes implementar la APP antes de nada"
                        fi

                    else
                        docker-compose stop 
                        if [ $? -ne 0 ]
                        then echo "ERROR. Debes tener arrancado Docker"
                        fi
                    fi
                    echo " "
                    echo " "
                    echo -n "Pulse cualquier tecla para continuar..."
                    read 
                ;;
                4) echo "Matando Contenedores y borrando APP"

                rm -r src     > /dev/null 2>&1
                rm -r mysql   > /dev/null 2>&1
                if [ $? -eq 0 ] 
                then
                    docker-compose kill
                    docker-compose down
                else
                echo " No hay nada que eliminar "
                fi
                    echo -n "Pulse cualquier tecla para continuar..."
                    read

                ;;
                5)
                    clear 

                var=$(docker ps | wc -l)
                
                if [ $var -le 1 ]
                then
                    echo "Cualquier aportacion o sugerencia"
                    echo ""
                    echo "REPO  ------> https://github.com/cdmzero " 
                    echo "EMAIl ------> jose.funez.clase@gmail.com" 
                    echo ""
                    echo "Gracias y ¡hasta otra!";
                    exit ;
                else
                            while :
                                do
                                clear
                                docker ps

                                echo -n "¿Deseas parar los contenedores antes de salir S/N?"
                                read salir

                                    case $salir in

                                    S|s)    
                                            docker-compose stop
                                            echo "Listo. Hasta pronto.  "
                                            exit
                
                                    ;;

                                    N|n)
                                        
                                            echo "Listo. Hasta pronto.  "
                                            exit
                                    ;;

                                    *)      echo -n "Seleciona una opcion valida"
                                            read 

                                    ;;
                                
                                    esac
                                done

                fi
                ;;
                *) echo "Opcion invalida"
                echo "Pulse cualquier tecla para continuar..."
                read
                ;;
                esac
                done
else
clear
echo "" 
echo "------*--------------------*------------------*-------------*----------*"
echo "Faltan estos servicios para poder efectuar la implementacion"
echo "-*--------*-----------*---------------*----------------*---------*------"
    if [ "$git" -ne "0" ]; then
     echo "" 
     echo ¡ERROR! debes descargar Github-bash para tu SO en este enlace https://git-scm.com/downloads
     echo ""
    fi
    if [ "$docker" -ne "0" ]; then
    echo ""
     echo ¡ERROR! debes descargar Docker para tu SO en este enlace https://www.docker.com/get-started
    echo ""
    fi
fi