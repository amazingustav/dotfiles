#!/bin/bash

function verify_errors {
        if [ $? -ne "0" ]; then
                printf "\n\n### CÓDIGO DE ERRO -> %s ###\n\n" "$?";
                exit 1;
        fi
}

printf "Obtendo endereço IP e porta do dispositivo...\n"
DEVICE_IP=$(adb devices | grep -oP '(\d{1,3}\.){3}\d{1,3}\:\d{1,5}' | head -1)
verify_errors
if [ -z $DEVICE_IP ]; then echo "Nenhum IP de Device encontrado!"; exit 1; fi
printf "Endereço obtido! -> %s\n\n" "$DEVICE_IP"

printf "Obtendo endereço IP e porta do host...\n"
HOST_INTERFACE=$(ifconfig | grep -oP "wlp\w*(?=\:)" | head -1)
if [ -z $HOST_INTERFACE ]; then echo "Nenhuma interface de rede encontrada!"; exit 1; fi
HOST_IP=$(ifconfig $HOST_INTERFACE | grep -oP '(\d{1,3}\.){3}\d{1,3}' | head -1)
if [ -z $HOST_IP ]; then echo "Nenhum IP de host encontrado!"; exit 1; fi
verify_errors
printf "Endereço obtido! -> %s\n\n" "$HOST_IP"

printf "Conectando...\n"
adb connect $DEVICE_IP
verify_errors
printf "Conectado!\n\n"

printf "Limpando temporários...\n"
fuser -k 8080/tcp
fuser -k 8081/tcp
adb shell settings delete global http_proxy
adb shell "pkill frida-server"
adb shell "if [ -d '/data/local/tmp' ]; then rm -rf /data/local/tmp/*; fi"
adb disconnect
verify_errors
printf "Cleaned!\n\n"

exit 0
