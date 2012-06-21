#!/bin/bash

MAILTO="@gmail.com"

apt-get update 1> /dev/null
if [ -z "`apt-get dist-upgrade -dy | grep "0 actualizados"`" ] && [ -z "`apt-get dist-upgrade -dy | grep "0 upgraded" `" ];then
        apt-get dist-upgrade -dy | mail -s "Upgrade packets at $HOSTNAME" $MAILTO
fi
