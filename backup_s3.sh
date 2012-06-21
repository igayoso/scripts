#!/bin/bash

PATH_BACKUP="/mnt/backup/"
S3_BUCKET=""
MONTH=`date +"%m"`
YEAR=`date +"%Y"`
TODAY=`date -I`

# mount backup 
s3fs backup /mnt/backups/

# mysql
BACKUP_NAME="mysql_data"

mkdir -p $PATH_BACKUP$BACKUP_NAME/$YEAR/$MONTH/
mysqldump -u -p --skip-lock-tables --all-databases | gzip -9 > $PATH_BACKUP$BACKUP_NAME/$YEAR/$MONTH/$BACKUP_NAME-$TODAY.sql.gz

# www data
BACKUP_NAME="www_data"
LOCALDIR="/var/www/"

mkdir -p $PATH_BACKUP$BACKUP_NAME/$YEAR/$MONTH/
tar zcfP $PATH_BACKUP$BACKUP_NAME/$YEAR/$MONTH/$BACKUP_NAME-$TODAY.tar.gz $LOCALDIR/*

# conf
BACKUP_NAME="conf_files"
LOCALDIR="/etc/"

mkdir -p $PATH_BACKUP$BACKUP_NAME/$YEAR/$MONTH/
tar zcfP $PATH_BACKUP$BACKUP_NAME/$YEAR/$MONTH/$BACKUP_NAME-$TODAY.tar.gz $LOCALDIR/*

# umount backup
umount /mnt/backups/

