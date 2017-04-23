#!/bin/sh

# Config parameters

conf="/usr/local/etc/ovpnauth.conf"
logfile="/var/log/ovpnauth.log"

# End of config parameters

if [ "$1" = "" ] || [ "$1" = "help" ]
then
	echo "ovpnauth.sh v0.1 - OpenVPN sh authentication script with simple user db"
	echo "                   for use withauth-user-pass-verify via-file option"
	echo ""
	echo "help - prints help"
	echo "md5 password - to compute password md5 checksum"
	exit 1
fi

md5(){
        echo "$1.`uname -n`" > /tmp/$$.md5calc
        sum="`md5sum /tmp/$$.md5calc | awk '{print $1}'`"
        rm /tmp/$$.md5calc
        echo "$sum"
}

if [ "$1" = "md5" ]
then
        echo `md5 $2`
	exit 1
fi

log(){
	echo "`date +'%m/%d/%y %H:%M'` - $1" >> $logfile
}

logenv(){
	enviroment="`env | awk '{printf "%s ", $0}'`"
	echo "`date +'%m/%d/%y %H:%M'` - $enviroment" >> $logfile
}
password=`md5 $2`
userpass=`cat $conf | grep ^$1= | awk -F= '{print $2}'`
if [ "$password" = "$userpass" ] 
then
	log "OpenVPN authentication successfull: $username"
	logenv
	exit 0
fi

log "OpenVPN authentication failed: $username"
logenv
exit 1
