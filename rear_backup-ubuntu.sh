#!/bin/bash

#THIS SYSTEM DETAILS

HOSTNAME=<YOUR SYSTEM HOSTNAME>
IPADDRESS=<YOUR SYSTEM IP ADDRESS
NO_OF_CPU=<YOUR SYSTEM CPU CORE>
RAM_SIZE=<YOUR SYSTEM RAM SIZE>
HDD_SIZE=<YOUR SYSTEM HDD SIZE ex 60GB,30GB>


#BACKU SERVER DETAILS

BACKUP_SRV_IP=192.168.7.22
BACKUP_PATH=/rear-backup 

#MAIL SETTINGS

SMTP_HOST=apmosys.icewarpcloud.in
SMTP_PORT=587
SMTP_AUTH_MAILID='admin@apmosys.com'
SMTP_AUTH_PASSWD='<MAIL PASSWORD>'
SENDER_MAILID='admin@apmosys.com'
RECEIVER_MAILID='mohamed.rafik@apmosys.com'


log_file=/var/log/rear/$HOSTNAME.log

find /var/tmp/rear* -type d -ctime +1 -exec rm -rf {} \;
echo "*********************************************************" > /tmp/output.txt
echo "$HOSTNAME Rear Backup successfully done"  >> /tmp/output.txt
echo "*********************************************************" >> /tmp/output.txt
echo "Starting $HOSTNAME rear backup at `date` ..........."  >> /tmp/output.txt

/usr/sbin/rear -v -d mkbackup #> /dev/null
if [ $? -eq 0 ];
then
echo "" >> /tmp/output.txt
echo "$HOSTNAME Rear Backup completed successfully  at `date`" >> /tmp/output.txt
echo "" >> /tmp/output.txt
echo "Backup distination : nfs://$BACKUP_SRV_IP$BACKUP_PATH "  >> /tmp/output.txt
echo "$HOSTNAME Congiration : Server IP address = $IPADDRESS,  Number of cpu = $NO_OF_CPU, Ram Size = $RAM_SIZE, Harddisk Size = $HDD_SIZE" >> /tmp/output.txt

cat /tmp/output.txt |/usr/bin/s-nail -s "$HOSTNAME  Rear Backup Successufly"   -S smtp-use-starttls -S ssl-verify=ignore -S smtp-auth=login  -S smtp=smtp://$SMTP_HOST:$SMTP_PORT -S from="$SENDER_MAILID" -S smtp-auth-user=$SMTP_AUTH_MAILID -S smtp-auth-password=$SMTP_AUTH_PASSWD -S nss-config-dir=/etc/pki/nssdb/  $RECEIVER_MAILID
exit 1

else
echo "$HOSTNAME  Rear Backup failed at `date`" >> /tmp/output.txt
echo   >> /tmp/output.txt
echo "************************************************************"  >> /tmp/output.txt
echo "Find below error log:"  >> /tmp/output.txt
tail -n 100 $log_file >> /tmp/output.txt
#mail
cat /tmp/output.txt |/usr/bin/s-nail -s " $HOSTNAME  Rear Backup Failed"   -S smtp-use-starttls -S ssl-verify=ignore -S smtp-auth=login  -S smtp=smtp://$SMTP_HOST:$SMTP_PORT -S from="$SENDER_MAILID" -S smtp-auth-user=$SMTP_AUTH_MAILID -S smtp-auth-password=$SMTP_AUTH_PASSWD -S nss-config-dir=/etc/pki/nssdb/  $RECEIVER_MAILID
exit 1 # this code means OK
fi
