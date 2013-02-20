#!/bin/bash
TOTALDATESTART=$(date +"%s")

#CONFIGURATION
MYSQLCONNORI='-uuser -ppassw0rd --database=db --host=mysql.us-east-1.rds.amazonaws.com'
MYSQLCONNDES='-uroot -ps3cr3t --database=db --host=localhost'
LIMIT=10000000
TMP=/tmp
DATABASE="db"
DIR="/mnt/mysql/data/$DATABASE"

#FUNCTIONS
function structure {
  DATESTARTSTRUCTURE=$(date +"%s")
  mkdir $TMP/$DATABASE
  for TABLE in `mysql $MYSQLCONNORI -e "SHOW TABLES;" | egrep "$TABLES2GET"`
  do
    echo "Exporting $DATABASE.$TABLE table structure..."
    mysqldump $MYSQLCONNORI --no-data --skip-add-drop-table --databases $DATABASE --table $TABLE > $TMP/$DATABASE/$TABLE.sql
    echo "Importing $DATABASE.$TABLE table structure..."
    mysql $MYSQLCONNDES $DATABASE < $TMP/$DATABASE/$TABLE.sql
  done
  DATEEND=$(date +"%s")
  DATEDIFFSTRUCTURE=$(($DATEEND-$DATESTARTSTRUCTURE))
}

function export {
  DATESTARTEXPORT=$(date +"%s")
  TOTAL=`mysql $MYSQLCONNORI -e "SHOW TABLES;" | egrep "$TABLES2GET" | wc -l`
  i=0
  for TABLE in `mysql $MYSQLCONNORI -e "SHOW TABLES;" | egrep "$TABLES2GET"`
  do
    OFFSET=0
    OLDLINES=0
    NEWLINES=1
    echo "Starting dump... $TABLE ($i/$TOTAL)"
    while [ $OFFSET -lt 150000000 ]
    do
      echo "Processing $NEWLINES..."
      if [ $OLDLINES -eq $NEWLINES ]
      then
        break
      fi
      mysql $MYSQLCONNORI --default-character-set=utf8 --skip-column-names --batch -e "SELECT * FROM $TABLE LIMIT $LIMIT OFFSET $OFFSET" | sed 's/NULL/\\N/g' >> $DIR/$TABLE.data
      OLDLINES=$NEWLINES
      NEWLINES=`cat $DIR/$TABLE.data | wc -l`
      OFFSET=$(($OFFSET + $LIMIT))
    done
    echo "$TABLE... Dump finished"
    i=$(($i + 1))
  done

  DATEEND=$(date +"%s")
  DATEDIFFEXPORT=$(($DATEEND-$DATESTARTEXPORT))
}

function import {
  DATESTARTIMPORT=$(date +"%s")
  TOTAL=`ls $DIR/$TABLES2GET_*.data | wc -l`
  i=0
  cd $DIR
  for TABLE in `ls *.data | egrep "$TABLES2GET" | sed -e s/.data//g`
  do
    if [ `cat $TABLE.data | wc -l` -gt 1000000 ]
    then
      echo "Splitting $TABLE.data..."
      split -l 1000000 $TABLE.data splittable_
      echo "Starting import... $TABLE ($i/$TOTAL)"
      for NEWTABLE in `ls splittable_*`
      do
        mysql $MYSQLCONNDES -e "LOAD DATA INFILE \"$NEWTABLE\" INTO TABLE $TABLE CHARACTER SET UTF8 FIELDS TERMINATED by \"\t\"";
        i=$(($i + 1))
      done
      echo "$TABLE... Import finished"
      rm splittable_*
    else
      echo "Starting import... $TABLE ($i/$TOTAL)"
      mysql $MYSQLCONNDES -e "LOAD DATA INFILE \"$TABLE.data\" INTO TABLE $TABLE CHARACTER SET UTF8 FIELDS TERMINATED by \"\t\"";
      echo "$TABLE... Import finished"
      i=$(($i + 1))
    fi
  done

  DATEEND=$(date +"%s")
  DATEDIFFIMPORT=$(($DATEEND-$DATESTARTIMPORT))
}


#OPTIONS
OPTION=$1
case "$OPTION" in
  before)
    TABLES2GET="table|other_table|last_table"
    structure
    export
    import
    echo "Created structure database in $(($DATEDIFFSTRUCTURE / 60)) minutes and $(($DATEDIFFSTRUCTURE % 60)) seconds."
    echo "Importing finished in $(($DATEDIFFIMPORT / 60)) minutes and $(($DATEDIFFIMPORT % 60)) seconds."
    echo "Dumping finished in $(($DATEDIFFEXPORT / 60)) minutes and $(($DATEDIFFEXPORT % 60)) seconds."
  ;;
  after)
    TABLES2GET="wildcardtable_"
    structure
    export
    import
    echo "Created structure database in $(($DATEDIFFSTRUCTURE / 60)) minutes and $(($DATEDIFFSTRUCTURE % 60)) seconds."
    echo "Export finished in $(($DATEDIFFEXPORT / 60)) minutes and $(($DATEDIFFEXPORT % 60)) seconds."
    echo "Import finished in $(($DATEDIFFIMPORT / 60)) minutes and $(($DATEDIFFIMPORT % 60)) seconds."
  ;;
  cleanfiles)
    #TODO
    rm -rf $TMP/$DATABASE*
    rm $DIR/*.data
  ;;
  cleandatabase)
    mysql $MYSQLCONNDES -e "DROP DATABASE $DATABASE; CREATE DATABASE $DATABASE;"
  ;;
  *)
    exit
  ;;
esac

DATEEND=$(date +"%s")
DATEDIFF=$(($DATEEND-$TOTALDATESTART))
echo "FINISHED!!!!!! $(($DATEDIFF / 60)) minutes and $(($DATEDIFF % 60)) seconds elapsed."
