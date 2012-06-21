
#!/bin/sh
# Script that checks whether apache is still up, and if not:
# - added some tunnings
# -- igayoso, 20120521
# - e-mail the last bit of log files
# - kick some life back into it
# -- Thomas, 20050606

PATH=/bin:/usr/bin
THEDIR=/tmp/apache-watchdog
EMAIL=@gmail.com
mkdir -p $THEDIR

if ( wget --timeout=5 -q -P $THEDIR http://url )
then
    # we are up
    touch ~/.apache-was-up
else
    # down! but if it was down already, don't keep spamming
    if [[ -f ~/.apache-was-up ]]
    then
        # write a nice e-mail
        echo -n "apache crashed at " > $THEDIR/mail
        date >> $THEDIR/mail
        echo >> $THEDIR/mail
        echo "Access log:" >> $THEDIR/mail
        tail -n 30 /var/log/apache2/access.log >> $THEDIR/mail
        echo >> $THEDIR/mail
        echo "Error log:" >> $THEDIR/mail
        tail -n 30 /var/log/apache2/error.log >> $THEDIR/mail
        echo >> $THEDIR/mail
        # kick apache
        echo "Now kicking apache..." >> $THEDIR/mail
        /etc/init.d/apache2 stop >> $THEDIR/mail 2>&1
        killall -9 apache2 >> $THEDIR/mail 2>&1
        /etc/init.d/apache2 start >> $THEDIR/mail 2>&1
        # send the mail
        echo >> $THEDIR/mail
        echo "Good luck troubleshooting!" >> $THEDIR/mail
        mail -s "apache-watchdog: apache crashed" $EMAIL < $THEDIR/mail
        rm ~/.apache-was-up
    fi
fi

rm -rf $THEDIR

