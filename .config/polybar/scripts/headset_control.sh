#!/bin/bash

status=$(headsetcontrol -bc 2> /dev/null)

if [[ $status = "Off" ]]; then
    echo ""
elif [[ $status = "Charging" ]]; then
    echo ""
else
    echo " $status"
fi
