# Migrate Recordings from VitalPBX 3 to VitalPBX 4
On some occasions, the amount of recordings that we have in a VitalPBX makes it impossible to make a backup to transfer it to another server. Even though we can do the backup from the console, there might not be enough space on the hard drive to back it up.
Due to that the best option is to directly copy all the recordings from one server to another. This can be done manually with scp, however we run the risk that for some reason the copy is aborted and we have to start over.

That said, the best option is to use Sync to make the copy, and here we will give you the steps to do it.

## Important note
Before executing this script it is necessary that you make a backup without recordings from your server and restore it on the new server.

## Installation
We install Lsync on the server where we have the recordings

<pre>
apt-get install lsyncd
</pre>

Create the following:
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

<pre>
wget https://raw.githubusercontent.com/VitalPBX/vitalpbx_recording_V3toV4/main/recording.sh
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
IP New Server................ > remoteserverip
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

## Voice Mails
If you also want to copy the Voicemail, you must add the following script in the recordings.sh file.

<pre>
nano /etc/lsyncd/
</pre>

<pre>
sync {
		default.rsyncssh,
		source = "/var/spool/asterisk/monitor",
		host = "$ip_master",
		targetdir = "/var/spool/asterisk/monitor",
		rsync = {
				owner = true,
				group = true
		}
}
</pre>

