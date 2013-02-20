#!/bin/bash
if [ -n "$1" ]; then
   if [ -e "$1" ]; then
      growisofs -use-the-force-luke=dao -use-the-force-luke=break:2086912 -dvd-compat -speed=2 -Z /dev/dvdrw=$1
   else
      echo "ERROR: El nombre de la imagen a grabar no existe o es incorrecto."
   fi
else
   echo "ERROR: No has indicado el nombre de la imagen a grabar."
fi
