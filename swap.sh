#!/bin/bash
SWAP_RESULT=`free -m | grep Swap`
SWAP=$(echo $SWAP_RESULT | awk '{print $2}' )
SWAP_USE=$(echo $SWAP_RESULT | awk '{ print $3 }' )
SWAP_FREE=$(echo $SWAP_RESULT | awk '{ print $4 }' )
SWAP_USEP=`expr $SWAP_USE \* 100 / $SWAP`
MAILTO="@gmail.com"

if [ $SWAP_USEP -ge 20 ]; then
    echo "Swap Usage Alert Total Swap: $SWAP Used: $SWAP_USE ($SEAP_USEP%) Free: $SWAP_FREE" | mail -s "Swap Usage space $SWAP_USEP%" $MAILTO
fi
