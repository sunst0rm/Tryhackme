# IP
```
10.10.125.71
```

Whole point of today's exercise is to find out additional directory which is hidden and which enables us to login. 
We are encouraged to use gobuster and afterwards wfuzz

# Given the URL "http://shibes.xyz/api.php", what would the entire wfuzz command look like to query the "breed" parameter using the wordlist "big.txt" (assume that "big.txt" is in your current directory)

```
wfuzz -c -z file,big.txt http://shibes.xyz/api.php?breed=FUZZ
```

# Use GoBuster to find the API directory. What file is there?

```
site-log.php
```

# Fuzz the date parameter on the file you found in the API directory. What is the flag displayed in the correct post?

Basically we type a command to find out a correct payload

```
THM{D4t3_AP1}
```
