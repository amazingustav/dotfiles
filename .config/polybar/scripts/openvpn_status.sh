#!/bin/sh

openvpn_status=$(pgrep -a openvpn$)

if [[ $openvpn_status = "" ]]; then
    echo ""
else
    echo ""
fi
