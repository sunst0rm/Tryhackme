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


## TASK 4 - [Scan Types] Overview 





