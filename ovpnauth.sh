#!/bin/sh

# Config parameters

conf="/jffs/ovpnauth.conf"
logfile="/opt/ovpnauth.log"

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
        sum="`echo "$1" | md5sum | awk '{print $1}'`"
        echo "$sum"
}

md5_nl(){        
        sum="`echo -n "$1" | md5sum | awk '{print $1}'`"
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

envr="`echo `env``"
userpass=`cat $1`
username=`echo $userpass | awk '{print $1}'`
password=`echo $userpass | awk '{print $2}'`

# computing password md5
thehash=`md5 $password`
thehash_no_newline=`md5_nl $password`

userpass=`cat $conf | grep $username= | awk -F= '{print $2}'`

if [ \( "$thehash" = "$userpass" \) -o \( "$thehash_no_newline" = "$userpass" \) ] 
then
	log "OpenVPN authentication successfull: $username"
	logenv
	exit 0
fi

log "OpenVPN authentication failed"
log `cat $1`
logenv
exit 1
