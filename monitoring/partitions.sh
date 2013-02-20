#!/bin/bash
PARTITIONS_DISK_THRESHOLD=95
MAILTO="@gmail.com"


OUT=$(df -l | awk 'int($5) > '$PARTITIONS_DISK_THRESHOLD' { print $NF }')
if [ ! -z "$OUT" ];     then
	echo -e "Local disks almost full (>${PARTITIONS_DISK_THRESHOLD}%):\n$OUT" | mail -s "Local disks almost full (>${PARTITIONS_DISK_THRESHOLD}%)" $MAILTO
fi

