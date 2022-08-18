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
verify_errors
printf "Cleaned!\n\n"

printf "Fazendo upload do certificado do mitm para o dispositivo...\n"
mitmweb &>/dev/null &
sleep 2
adb push ~/.mitmproxy/mitmproxy-ca-cert.cer /data/local/tmp/cert-der.crt
verify_errors
printf "Upload concluído!\n\n"

printf "Definindo proxy global no device...\n"
adb shell settings put global http_proxy $HOST_IP:8080
verify_errors
printf "Proxy definido!\n\n"

printf "Inserindo o Frida Server...\n"
adb root
verify_errors
adb push frida-server /data/local/tmp/frida-server
verify_errors
adb shell "chmod 755 /data/local/tmp/frida-server"
verify_errors
adb shell "/data/local/tmp/frida-server --listen 0.0.0.0 &>/dev/null &"
verify_errors
sleep 3
printf "Frida Server inserido!\n\n"

printf "Informe o nome do apk a ser 'escutado': "
read APK_NAME
if [ -z $APK_NAME ]; then echo "Nenhum nome foi informado!"; exit 1; fi
APK_FULLNAME=$(adb shell 'pm list packages -f' | grep -i $APK_NAME | grep -oP "(?<=\=)(\w+\.?)*" | head -1)
verify_errors
if [ -z $APK_FULLNAME ]; then echo "Nenhuma APK encontrada contendo o valor informado!"; exit 1; fi
printf "\nAPK encontrada! -> %s\n\n" "$APK_FULLNAME"

printf "Execuntado script de Repinning..."
frida -U -f $APK_FULLNAME -l bankslayer.js --no-pause
verify_errors
