#### 1. Download Challenge.Chellenge

#### 2. Run in with `ltrace` and enter any string you like

```
ltrace ./Challenge.Challenge 
printf("Insert your username: ")                 = 22
__isoc99_scanf(0x5592e19cd01b, 0x7ffe8d1e4820, 0, 0Insert your username: hello
) = 1
strcpy(0x7ffe8d1e4790, "hello")                  = 0x7ffe8d1e4790
strcmp("hello", "AGB6js5d9dkG7")                 = 39
puts("\nAuthentication Error"
Authentication Error
)                   = 22
exit(0 <no return ...>
+++ exited (status 0) +++
```

Program gives error, however we see `strcmp` which is a C funtion which compares string we entered with one which will give us flag.

So we run `Challenge.Challenge` once again but this time entering string we found `AGB6js5d9dkG7`

```                                                                        
┌──(kali㉿kali)-[~/Downloads]
└─$ ./Challenge.Challenge 
Insert your username: AGB6js5d9dkG7

Welcome
THM{65235128496}                                                                                
┌──(kali㉿kali)-[~/Downloads]
```

and get a flag.