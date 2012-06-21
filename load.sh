#!/bin/bash
LOADAVG=`uptime | awk '{print $10}'`
MAILTO="@gmail.com"
THISLOADAVG=`echo $LOADAVG|awk -F \. '{print $1}'`

if [ "$THISLOADAVG" -ge "25" ]; then
        top -bn 1 | mail -s "Load Average $LOADAVG ($THISLOADAVG)" $MAILTO
fi
