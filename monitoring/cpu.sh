#!/bin/bash
CPULOAD=`top -b -n 1 |grep -i "Cpu" | cut -d ',' -f1 | tr -d 'us'  | tr -d ' (Cp):' | sed -e s/^0+// |grep % |tr -d '%' | head -n1 | awk '{ print int($1) }'`
MAILTO="@gmail.com"

if [ "$CPULOAD" -gt "75" ]; then
        top -bn 1 | mail -s "High CPU load average: $CPULOAD%" $MAILTO
fi
