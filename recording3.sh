#!/bin/bash
# This code is the property of VitalPBX LLC Company
# License: Proprietary
# Date: 20-May-2023
# VitalPBX Recording Replica with Lsync
#
set -e
function jumpto
{
    label=$start
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}

echo -e "\n"
echo -e "************************************************************"
echo -e "*  Welcome to the VitalPBX Recording Replica installation  *"
echo -e "*                All options are mandatory                 *"
echo -e "************************************************************"

filename="config.txt"
if [ -f $filename ]; then
	echo -e "config file"
	n=1
	while read line; do
		case $n in
			1)
				ip_master=$line
  			;;
		esac
		n=$((n+1))
	done < $filename
	echo -e "IP New Server............ > $ip_master"	
fi

while [[ $ip_master == '' ]]
do
    read -p "IP New Server............. > " ip_master 
done 

echo -e "************************************************************"
echo -e "*                   Check Information                      *"
echo -e "*           Make sure both servers see each other          *"
echo -e "************************************************************"
while [[ $veryfy_info != yes && $veryfy_info != no ]]
do
    read -p "Are you sure to continue with this settings? (yes,no) > " veryfy_info 
done

if [ "$veryfy_info" = yes ] ;then
	echo -e "************************************************************"
	echo -e "*                Starting to run the scripts               *"
	echo -e "************************************************************"
else
    	exit;
fi

cat > config.txt << EOF
$ip_master
EOF

echo -e "************************************************************"
echo -e "*             Configure Sync in Old Server                 *"
echo -e "************************************************************"

cat > /etc/lsyncd.conf << EOF
----
-- User configuration file for lsyncd.
--
-- Simple example for default rsync.
--
settings {
		logfile    = "/var/log/lsyncd/lsyncd.log",
		statusFile = "/var/log/lsyncd/lsyncd-status.log",
		statusInterval = 20,
		nodaemon   = true,
		insist = true,
}

sync {
		default.rsync,
		source="/var/spool/asterisk/monitor",
		target="$ip_master:/var/spool/asterisk/monitor",
		rsync={
				owner = true,
				group = true
		}
}
EOF

systemctl enable lsyncd.service
systemctl restart lsyncd.service

echo -e "************************************************************"
echo -e "* Record Replication has started, this process can take a  *"
echo -e "* long time depending on the number of recordings, you can *"
echo -e "* monitor the process by running the following command:    *"
echo -e "*           cat /var/log/lsyncd/lsyncd.status              *"
echo -e "************************************************************"
