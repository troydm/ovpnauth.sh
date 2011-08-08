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
	return 1
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
	return 1
fi

log(){
	echo "`date +'%m/%d/%y %H:%M'` - $1" >> $logfile
}

logenv(){
	enviroment="`env | awk '{printf "%s ", $0}'`"
	echo "`date +'%m/%d/%y %H:%M'` - $enviroment" >> $logfile
}

envr="`echo `env``"
userpass=`cat $1`
username=`echo $userpass | awk '{print $1}'`
password=`echo $userpass | awk '{print $2}'`

# computing password md5
password=`md5 $password`
userpass=`cat $conf | grep $username= | awk -F= '{print $2}'`

if [ "$password" = "$userpass" ] 
then
	log "OpenVPN authentication successfull: $username"
	logenv
	return 0
fi

log "OpenVPN authentication failed"
log `cat $1`
logenv
return 1
