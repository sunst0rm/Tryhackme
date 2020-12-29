# ROOM'S NAME
`nmap`

## IP
`10.10.0.49`






## TASK 2 - Introduction

### What networking constructs are used to direct traffic to the right application on a server?
`ports`


### How many of these are available on any network-enabled computer?
`65535`


### [Research] How many of these are considered "well-known"? (These are the "standard" numbers mentioned in the task)
`1024`




## TASK 3 - Nmap switches

### What is the first switch listed in the help menu for a 'Syn Scan' (more on this later!)?
`-sS`


### Which switch would you use for a "UDP scan"?
`-sU`


### If you wanted to detect which operating system the target is running on, which switch would you use?
`-O`


### Nmap provides a switch to detect the version of the services unning on the target. What is this switch?
`-sV`


### The default output provided by nmap often does not provide enough information for a pentester. How would you increase the verbosity?
`-v-`


### Verbosity level one is good, but verbosity level two is better! How would you set the verbosity level to two?
(Note: it's highly advisable to always use at least this option)
`-vv`


### What switch would you use to save the nmap results in three major formats?
`-oA`

```
-oA basename (Output to all formats)
           As a convenience, you may specify -oA basename to store scan results in normal, XML,
           and grepable formats at once. They are stored in basename.nmap, basename.xml, and
           basename.gnmap, respectively. As with most programs, you can prefix the filenames
           with a directory path, such as ~/nmaplogs/foocorp/ on Unix or c:\hacking\sco on
           Windows.
```


### What switch would you use to save the nmap results in a "normal" format?
`-oN`


### A very useful output format: how would you save results in a "grepable" format?
`-oG`

### Agressive mode
`-A`

```
  This option enables additional advanced and aggressive options. Presently this
           enables OS detection (-O), version scanning (-sV), script scanning (-sC) and
           traceroute (--traceroute).
```

### How would you set the timing template to level 5?
`-T5`


### How would you tell nmap to only scan port 80?
`-p 80`


### How would you tell nmap to scan ports 1000-1500?
`-p 1000-1500`

### How would you tell nmap to scan all ports?
`-p-`


### How would you activate a script from the nmap scripting library (lots more on this later!)?
`--script`


### How would you activate all of the scripts in the "vuln" category?
`--script=vuln`





## TASK 5 - TCP Connect Scans 

### Which RFC defines the appropriate behaviour for the TCP protocol?
`RFC 793`


### If a port is closed, which flag should the server send back to indicate this?
`RST`




## TASK 6 - SYN Scans 

###  There are two other names for a SYN scan, what are they?
`stealth, half-open`

### Can Nmap use a SYN scan without Sudo permissions (Y/N)?
`no`



## TASK 7 - UDP Scans  

### If a UDP port doesn't respond to an Nmap scan, what will it be marked as? 
`open|filtered`


### When a UDP port is closed, by convention the target should send back a "port unreachable" message. Which protocol would it use to do so?
`icmp`

## TASK 8 - NULL, FIN and Xmas 

###  Which of the three shown scan types uses the URG flag?
`xmas`


### Why are NULL, FIN and Xmas scans generally used?
`firewall evasion`


### Which common OS may respond to a NULL, FIN or Xmas scan with a RST for every port?
`microsoft windows`

## TASK 9 - ICMP Network Scanning 

###  How would you perform a ping sweep on the 172.16.x.x network (Netmask: 255.255.0.0) using Nmap? (CIDR notation)
`nmap -sn 172.16.0.0/16`


## TASK 10 - Overview 

```
There are many categories available. Some useful categories include:

    safe:- Won't affect the target
    intrusive:- Not safe: likely to affect the target
    vuln:- Scan for vulnerabilities
    exploit:- Attempt to exploit a vulnerability
    auth:- Attempt to bypass authentication for running services (e.g. Log into an FTP server anonymously)
    brute:- Attempt to bruteforce credentials for running services
    discovery:- Attempt to query running services for further information about the network (e.g. query an SNMP server).

```

###  What language are NSE scripts written in?
`lua`


### Which category of scripts would be a very bad idea to run in a production environment?
`intrusive`


## TASK 11 - Working with the NSE scripts

### What optional argument can the `ftp-anon.nse`script take?
`maxlist`

## TASK 12 - Searching for Scripts 

### What is the filename of the script which determines the underlying OS of the SMB server?
`smb-os-discovery.nse`


### Read through this script. What does it depend on?
`smb-brute`

/usr/share/nmap/scripts/smb-os-discovery.nse

## TASK 13 - Firewall Evasion 

###  Which simple (and frequently relied upon) protocol is often blocked, requiring the use of the -Pn switch?
`-Pn`

### [Research] Which Nmap switch allows you to append an arbitrary length of random data to the end of packets?
`-data-length`

### TASK 14 - Practical

### Does the target (MACHINE_IP)respond to ICMP (ping) requests (Y/N)?
`no`

### Perform an Xmas scan on the first 999 ports of the target -- how many ports are shown to be open or filtered?
`999`

### There is a reason given for this -- what is it?
`no response`


### Perform a TCP SYN scan on the first 5000 ports of the target -- how many ports are shown to be open?
`5`


### Deploy the ftp-anon script against the box. Can Nmap login successfully to the FTP server on port 21? (Y/N)
`y`




