# Migrate Recordings and CDRs from VitalPBX to VitalPBX 
On some occasions, the amount of recordings that we have in a VitalPBX makes it impossible to make a backup to transfer it to another server. Even though we can do the backup from the console, there might not be enough space on the hard drive to back it up.
Due to that the best option is to directly copy all the recordings from one server to another. This can be done manually with scp, however we run the risk that for some reason the copy is aborted and we have to start over.

That said, the best option is to use Sync to make the copy, and here we will give you the steps to do it.

## Important note
Before executing this script it is necessary that you make a backup without recordings from your server and restore it on the new server.

## Installation
We install Lsync on the server where we have the recordings

VitalPBX 3 (Centos 7.9)
<pre>
yum install lsyncd
</pre>

VitalPBX 4 (Debian 11)
<pre>
apt-get install lsyncd
</pre>

Create the following for Centos or Debian:
<pre>
mkdir /etc/lsyncd
mkdir /var/log/lsyncd
touch /var/log/lsyncd/lsyncd.log
touch /var/log/lsyncd/lsyncd.status
</pre>

## Create authorization key for the access to remote servers without credentials

<pre>
ssh-keygen -f /root/.ssh/id_rsa -t rsa -N '' >/dev/null
</pre>

<pre>
ssh-copy-id root@remoteserverip
</pre>

<pre>
password: (remote server root’s password)
</pre>

## Script
Now copy and run the following script

VitalPBX 3
<pre>
wget https://raw.githubusercontent.com/VitalPBX/vitalpbx_recording_V3toV4/main/recording3.sh
</pre>

VitalPBX 4
<pre>
wget https://raw.githubusercontent.com/VitalPBX/vitalpbx_recording_V3toV4/main/recording4.sh
</pre>

<pre>
chmod +x recording.sh
</pre>

<pre>
./recording.sh
</pre>

<pre>
************************************************************
*  Welcome to the VitalPBX Recording Replica installation  *
*                All options are mandatory                 *
************************************************************
IP New Server................ > ip_newserver
************************************************************
*                   Check Information                      *
*           Make sure both servers see each other          *
************************************************************
Are you sure to continue with this settings? (yes,no) > yes
</pre>

## Sync Status
This process can take a long time depending on the amount of recordings, you can monitor the process by running the following command:
<pre>
cat /var/log/lsyncd/lsyncd.status
</pre>

## Voicemails

VitalPBX 3 (Centos 7.9)

If you also want to copy Voicemail, you must add the following script to the end of the /etc/lsyncd.conf file.
<pre>
nano /etc/lsyncd.conf
</pre>

<pre>
sync {
		default.rsync,
		source = "/var/spool/asterisk/voicemail",
		target="$ip_newserver:/var/spool/asterisk/voicemail",
		rsync = {
				owner = true,
				group = true
		}
}
</pre>
Change $ip_master to the IP of the new server

VitalPBX 4 (Debian 11)

If you also want to copy Voicemail, you must add the following script to the end of the /etc/lsyncd/lsyncd.conf.lua file.
<pre>
nano /etc/lsyncd/lsyncd.conf.lua
</pre>

<pre>
sync {
		default.rsyncssh,
		source = "/var/spool/asterisk/voicemail",
		host = "$ip_newserver",
		targetdir = "/var/spool/asterisk/voicemail",
		rsync = {
				owner = true,
				group = true
		}
}
</pre>

Change $ip_master to the IP of the new server

And we restart the service
<pre>
systemctl restart lsyncd
</pre>

To see the number of GB to copy:
<pre>
du -sh /var/spool/asterisk/monitor
</pre>

To see what's copied:
<pre>
ssh root@ip_newserver "du -sh /var/spool/asterisk/monitor"
</pre>

To see the progress of the copy, use the following command
<pre>
rsync -ah --progress /var/spool/asterisk/monitor root@ip_newserver:/var/spool/asterisk/monitor
</pre>

## CDRs and Stats
Sometimes the CDR volume is quite large and it is not possible to include it in the backup done through the GUI. In these cases it is recommended to copy the databases from the console as shown below.<br>
First we enter the server where the information is:<br>
Call CDRs
<pre>
mysqldump -u root asterisk > asterisk.sql
</pre>
Call queue statistics - Optional
<pre>
mysqldump -u root stats > stats.sql
</pre>
Now we proceed to copy to a temporary directory on the new server.
<pre>
scp asterisk.sql root@IPNEWSERVER:/tmp/asterisk.sql
</pre>
We connect to the new server and go to the folder where we copied the database backup (/tmp/).
And we proceed to perform the restore
<pre>
mysql mysql -u root <  /tmp/asterisk.sql
</pre>

