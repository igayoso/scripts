#!/bin/bash

TMPBACKUP="/var/TMPBACKUP"
DATE=`(date '+%Y%m%d')`
FTPHOST=""
FTPUSER=""
FTPPASSWD=""

# backup /var/www
echo "Haciendo backup de /var/www/* ..."
LOCALDIR="/var/www"
REMOTEDIR="wwwdata"
FILENAME="wwwdata_$DATE.tar.gz"
tar zcfP $TMPBACKUP/$FILENAME $LOCALDIR/*

# backup /etc/
echo "Haciendo backup de /etc/* ..."
LOCALDIR="/etc"
REMOTEDIR="etcdata/"
FILENAME="etcdata_$DATE.tar.gz"
tar zcfP $TMPBACKUP/$FILENAME $LOCALDIR/*

# backup mysql data
echo "Haciendo dump backup de mysql..."
USER=""
PASSWD=""
REMOTEDIR="dbdata/"
FILENAME="mysqldump_$DATE.sql.gz"
mysqldump -hlocalhost -u$USER -p$PASSWD -A | gzip > $TMPBACKUP/$FILENAME

# upload to FTP
cd $TMPBACKUP
ftp -inv $FTPHOST << EOT
user $FTPUSER $FTPPASSWD
cd /backups/wwwdata
put wwwdata_$DATE.tar.gz 
cd /backups/etcdata
put etcdata_$DATE.tar.gz
cd /backups/dbdata
put mysqldump_$DATE.sql.gz
bye
EOT

# remote temp backup directory
echo "Borrando temporales locales"
rm $TMPBACKUP/*

# clean old backups
# mount FTP dir
mount /mnt/BACKUP

find /mnt/BACKUP/backups/dbdata -mtime +30 -exec rm {} ';'
find /mnt/BACKUP/backups/wwwdata -mtime +30 -exec rm {} ';'
find /mnt/BACKUP/backups/etcdata -mtime +30 -exec rm {} ';'

# umount
umount /mnt/BACKUP

echo "END"
