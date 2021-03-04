# EASY

<br />
<br />

#### 1. Scanning

```
nmap -A -T4 10.10.163.83                                              
Starting Nmap 7.91 ( https://nmap.org ) at 2021-02-21 04:51 EST
Verbosity Increased to 1.
Stats: 0:00:42 elapsed; 0 hosts completed (1 up), 1 undergoing Service Scan
Service scan Timing: About 83.33% done; ETC: 04:52 (0:00:08 remaining)
Completed Service scan at 04:52, 90.11s elapsed (6 services on 1 host)
NSE: Script scanning 10.10.163.83.
Initiating NSE at 04:52
Completed NSE at 04:53, 11.78s elapsed
Initiating NSE at 04:53
Completed NSE at 04:53, 1.11s elapsed
Initiating NSE at 04:53
Completed NSE at 04:53, 0.00s elapsed
Nmap scan report for 10.10.163.83
Host is up (0.087s latency).
Not shown: 994 closed ports
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 f7:75:95:c7:6d:f4:92:a0:0e:1e:60:b8:be:4d:92:b1 (RSA)
|   256 a2:11:fb:e8:c5:c6:f8:98:b3:f8:d3:e3:91:56:b2:34 (ECDSA)
|_  256 72:19:b7:04:4c:df:18:be:6b:0f:9d:da:d5:14:68:c5 (ED25519)
80/tcp   open  http    Apache httpd 2.4.29 ((Ubuntu))
| http-methods: 
|_  Supported Methods: GET POST OPTIONS HEAD
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Apache2 Ubuntu Default Page: It works
8000/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
| http-methods: 
|_  Supported Methods: GET POST
| http-robots.txt: 1 disallowed entry 
|_/vbcms
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: VeryBasicCMS - Home
8001/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
| http-methods: 
|_  Supported Methods: GET HEAD POST OPTIONS
|_http-server-header: Apache/2.4.29 (Ubuntu)
| http-title: My Website
|_Requested resource was /?page=home.php
8002/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
| http-methods: 
|_  Supported Methods: GET POST
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Learn PHP
9999/tcp open  abyss?
| fingerprint-strings: 
|   FourOhFourRequest, GetRequest, HTTPOptions: 
|     HTTP/1.0 200 OK
|     Date: Sun, 21 Feb 2021 09:51:28 GMT
|     Content-Length: 0
|   GenericLines, Help, Kerberos, LDAPSearchReq, LPDString, RTSPRequest, SIPOptions, SSLSessionReq, TLSSessionReq, TerminalServerCookie: 
|     HTTP/1.1 400 Bad Request
|     Content-Type: text/plain; charset=utf-8
|     Connection: close
|_    Request
```

There is `/8000/vbcms` available with a login page, so logically I should try to run hydra and look for password as `admin`. 

This time, it happens that `admin:admin` is a correct pair, so no bruteforcing is needed :)

<br />

#### 2. VBCMS - SERV1

once I'm logged in, there are three sections, each one can be modified, so it's an easy way to insert there a reverse shell and log in to a machine directly.

I edit About Us and fill in with pentest monkey's reverse shell, save it, run netcat and open site in a browser. I am in.

First hint leads to a file with a flag encoded in base64, which is in `/usr/games/fortune`

```
┌──(kali㉿kali)-[~/Documents/CTFTOOLS]
└─$ echo "VEhNe05HSTROems0T0dJM01ERTRORFV6TldZd05qTXlaalkxfQo=" | base64 -d > serv1
```
after decoding I get:                                               

```
┌──(kali㉿kali)-[~/Documents/CTFTOOLS]
└─$ cat serv1       
THM{NGI4Nzk4OGI3MDE4NDUzNWYwNjMyZjY1}
```

and after entering in Hackerrank gives another to enter on THM:

`BACK2THM{a77bc034424d18cc07567eb79c5e205c}`

<br />

#### 3. SERV 2 flag

I check hint which says to open `/var/lib/rary` which gives:

`THM{Bet_You're_Glad_This_Is_Not_A_Hash}`

and typed in Hackerrank:

`BACK2THM{84c31ff2c6f1b3b793fb919dc19ebbb7}`

<br />

#### 4. SERV3 flag

Same story as previously.

#### 5. SERV4 flag

Once again, all is in a hint:

```
$ cat /var/www/serv4/index.php
THM{YmNlODZjN2I2ZDEwM2FlMDA5Y2RiYzZh}
```

#### 6. ROOT

First of all I was trying to seach for `utmp` exploit and it lead me to `tmux`, however it was a rabbit hole.

The real solution is very simple. Our user is a part of `utmp` group so I thought about searching files which belong to that group and got three:

```
$ find / -type f -group utmp 2>/dev/null
/usr/lib/x86_64-linux-gnu/utempter/utempter
/var/log/btmp
/run/utmp
```

One of them has root's pass:

```
serv1@web-serv:/$ cat /var/log/btmp
cat /var/log/btmp
)	ssh:nottyrootZjc2ZWEx192.168.1.142ǯ*
```

which is `Zjc2ZWEx`

<br />

Therefore, I su root and read a flag:

```
root@web-serv:/# cat /root/root.txt
cat /root/root.txt
THM{OWQyMGRlNWM0NjYzN2NmM2MxMDNkODgx}
```
from H1

`BACK2THM{ff315ec593432fb5d85726c34530c5c6}`
