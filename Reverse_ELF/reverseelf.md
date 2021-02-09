All files need to have execute permissions, so before launching I set it with `chmod +x file`

#### Crackme1

I use ltrace to read a flag:

```
 ltrace ./crackme1                                                       1 ⨯
__libc_start_main(0x400546, 1, 0x7ffdacb93028, 0x400690 <unfinished ...>
memset(0x7ffdacb92ea0, 'A', 27)                  = 0x7ffdacb92ea0
puts("flag{not_that_kind_of_elf}"flag{not_that_kind_of_elf}
)               = 27
+++ exited (status 0) +++
```



#### Crackme2

This time, ltrace does not show any details, so I check file with `strings` 

```
Usage: %s password
super_secret_password
Access denied.
Access granted.
;*2$"(
GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.9) 5.4.0 20160609
crtstuff.c
__JCR_LIST__
deregister_tm_clones
```

and get password which is hidden.



#### Crackme3

Same as previously, I use `strings`

```
UWVS
[^_]
Usage: %s PASSWORD
malloc failed
ZjByX3kwdXJfNWVjMG5kX2xlNTVvbl91bmJhc2U2NF80bGxfN2gzXzdoMW5nNQ==
Correct password!
Come on, even my aunt Mildred got this one!
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/
;*2$"8
GCC: (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3
```

and get password encoded in base64



#### Crackme4

This time it is hard and we need to use IDA or radare2.

* I run the file `radare2 -d ./crackme4`


```
radare2 -d crackme4          
Process with PID 13456 started...
= attach 13456 13456
bin.baddr 0x00400000
Using 0x400000
asm.bits 64
```

Then type `aaa` to show whole program

```
[0x7f9d74dba090]> aaa
[x] Analyze all flags starting with sym. and entry0 (aa)
[x] Analyze function calls (aac)
[x] Analyze len bytes of instructions for references (aar)
[x] Check for vtables
[TOFIX: aaft can't run in debugger mode.ions (aaft)
[x] Type matching analysis for all functions (aaft)
[x] Propagate noreturn information
[x] Use -AA or aaaa to perform additional experimental analysis.
```

Then `afl` to list all functions

```
[0x7f9d74dba090]> afl
0x00400540    1 41           entry0
0x00400510    1 6            sym.imp.__libc_start_main
0x00400570    4 41           sym.deregister_tm_clones
0x004005a0    4 57           sym.register_tm_clones
0x004005e0    3 28           sym.__do_global_dtors_aux
0x00400600    4 45   -> 42   entry.init0
0x004007d0    1 2            sym.__libc_csu_fini
0x0040062d    4 77           sym.get_pwd
0x004007d4    1 9            sym._fini
0x0040067a    6 156          sym.compare_pwd
0x00400760    4 101          sym.__libc_csu_init
0x00400716    4 74           main
0x004004b0    3 26           sym._init
0x00400530    1 6            loc.imp.__gmon_start__
0x004004e0    1 6            sym.imp.puts
0x004004f0    1 6            sym.imp.__stack_chk_fail
0x00400500    1 6            sym.imp.printf
0x00400520    1 6            sym.imp.strcmp
```

Firstly, we wil check `main` so I type `pdf @main`

`pdf` stands for `print dissasembly function`

```
[0x7f9d74dba090]> pdf @main
            ; DATA XREF from entry0 @ 0x40055d
┌ 74: int main (int argc, char **argv, char **envp);
│           ; var int64_t var_10h @ rbp-0x10
│           ; var int64_t var_4h @ rbp-0x4
│           ; arg int argc @ rdi
│           ; arg char **argv @ rsi
│           0x00400716      55             push rbp
│           0x00400717      4889e5         mov rbp, rsp
│           0x0040071a      4883ec10       sub rsp, 0x10
│           0x0040071e      897dfc         mov dword [var_4h], edi     ; argc
│           0x00400721      488975f0       mov qword [var_10h], rsi    ; argv
│           0x00400725      837dfc02       cmp dword [var_4h], 2
│       ┌─< 0x00400729      741b           je 0x400746
│       │   0x0040072b      488b45f0       mov rax, qword [var_10h]
│       │   0x0040072f      488b00         mov rax, qword [rax]
│       │   0x00400732      4889c6         mov rsi, rax
│       │   0x00400735      bf10084000     mov edi, str.Usage_:__s_password_nThis_time_the_string_is_hidden_and_we_used_strcmp_n ; 0x400810 ; "Usage : %s password\nThis time the string is hidden and we used strcmp\n"
│       │   0x0040073a      b800000000     mov eax, 0
│       │   0x0040073f      e8bcfdffff     call sym.imp.printf         ; int printf(const char *format)
│      ┌──< 0x00400744      eb13           jmp 0x400759
│      │└─> 0x00400746      488b45f0       mov rax, qword [var_10h]
│      │    0x0040074a      4883c008       add rax, 8
│      │    0x0040074e      488b00         mov rax, qword [rax]
│      │    0x00400751      4889c7         mov rdi, rax
│      │    0x00400754      e821ffffff     call sym.compare_pwd
│      │    ; CODE XREF from main @ 0x400744
│      └──> 0x00400759      b800000000     mov eax, 0
│           0x0040075e      c9             leave
└           0x0040075f      c3             
```

There is another function `sym.compare_pwd` which compares two given values so we check it with `pdf @sym.compare_pwd`

```
│           0x004006cf      4889d6         mov rsi, rdx
│           0x004006d2      4889c7         mov rdi, rax
│           0x004006d5      e846feffff     call sym.imp.strcmp         ; int strcmp(const char *s1, const char *s2)
```

It seems like there are two compared arguments: `rdi` and `rax` and then function  `sym.imp.strcmp` is executed. 

Therefore, we should stop it and set a breakpoint at `0x004006d2` 

- first we give an argument `ood "argument"`

```
[0x7f9d74dba090]> ood 'argument'
child received signal 9
Process with PID 13710 started...
= attach 13710 13710
File dbg:///home/kali/Downloads/crackme4  'argument' reopened in read-write mode
13710
```

Then set a breakpoint `db 0x004006d2 `

and finally run program with `dc`

```
[0x7f555571d090]> dc
hit breakpoint at: 0x4006d2
```

So now, let's read `sym.compare_pwd` once again and we see `b` which indicates a breakpoint

```
[0x004006d2]> pdf @sym.compare_pwd
┌ 
│           0x004006d2 b    4889c7         mov rdi, rax
│           0x004006d5      e846feffff     call sym.imp.strcmp         ; int strcmp(const char *s1, const char *s2)
```

Now it is possible to check value of `rdi` which contains a password

```
[0x004006d2]> px @rdi
- offset -       0 1  2 3  4 5  6 7  8 9  A B  C D  E F  0123456789ABCDEF
0x7ffc9d901f50  6d79 5f6d 3072 335f 7365 6375 7233 5f70  my_m0r3_secur3_p
0x7ffc9d901f60  7764 0000 0000 0000 00a1 10e8 54e9 bf1f  wd..........T...
0x7ffc9d901f70  901f 909d fc7f 0000 5907 4000 0000 0000  ........Y.@.....
0x7ffc9d901f80  8820 909d fc7f 0000 0000 0000 0200 0000  . ..............
0x7ffc9d901f90  6007 4000 0000 0000 0a4d 5655 557f 0000  `.@......MVUU...
```


#### Crackme5

There is a similar approach as previously:

`chmod +x crackme5`

Then

`radare2 -d crac` --> `aaa` --> `afl` --> `pdf @main`

We have once again `sym.strcmp_` function

```
0x00400821      488d55d0       lea rdx, [var_30h]
0x00400825      488d45b0       lea rax, [var_50h]
0x00400829      4889d6         mov rsi, rdx
0x0040082c      4889c7         mov rdi, rax
0x0040082f      e8a2feffff     call sym.strcmp_
0x00400834      8945ac         mov dword [var_54h], eax

```
so we need to set a breakpoint before it at `0x0040082c` and which compares `rdi` and `rax`

There is nothing in `rdi` so we will have to check `rsi` in order to find correct value.

We type:

`ood 'random'` to set an argument

```
[0x7fe473ce7090]> ood 'random'
child received signal 9
Process with PID 15749 started...
= attach 15749 15749
File dbg:///home/kali/Downloads/crackme5  'random' reopened in read-write mode
15749
```

`db  0x0040082c` to set a breakpoint and `dc` to run a program

```
0x7f473cf0a090]> db  0x0040082c 
[0x7f473cf0a090]> dc
Enter your input:
password
hit breakpoint at: 0x40082c
```

Now we can view `rdi` which has no value inside

```0x0040082c]> px @rdi
- offset -       0 1  2 3  4 5  6 7  8 9  A B  C D  E F  0123456789ABCDEF
0x7ffcfd241880  0000 ef3c 0000 0000 0000 0000 0000 0000  ...<............
0x7ffcfd241890  1419 24fd fc7f 0000 8d34 feea 0000 0000  ..$......4......
0x7ffcfd2418a0  e854 f33c 477f 0000 a303 4000 0000 0000  .T.<G.....@.....
0x7ffcfd2418b0  e819 24fd fc7f 0000 4019 24fd fc7f 0000  ..$.....@.$.....
0x7ffcfd2418c0  5019 24fd fc7f 0000 e13c f13c 477f 0000  P.$......<.<G...
0x7ffcfd2418d0  0100 0000 0000 0000 a005 ef3c 477f 0000  ...........<G...
0x7ffcfd2418e0  0100 0000 0000 0000 0000 0000 0000 0000  ................
0x7ffcfd2418f0  0100 0000 0000 0000 8051 f33c 477f 0000  .........Q.<G...
0x7ffcfd241900  0000 0000 0000 0000 a005 ef3c 477f 0000  ...........<G...
0x7ffcfd241910  8051 f33c 477f 0000 0000 0000 0100 0000  .Q.<G...........
0x7ffcfd241920  e854 f33c 477f 0000 0000 0000 0000 0000  .T.<G...........
0x7ffcfd241930  0000 0000 0000 0000 0000 0000 0000 0000  ................
0x7ffcfd241940  ffff ffff 0000 0000 00ff 0000 0000 0000  ................
0x7ffcfd241950  384c d33c 477f 0000 0000 ef3c 477f 0000  8L.<G......<G...
0x7ffcfd241960  2f2f 2f2f 2f2f 2f2f 2f2f 2f2f 2f2f 2f2f  ////////////////
0x7ffcfd241970  0000 0000 0000 0000 0000 0000 0000 0000  ................
```

and then `rsi` which contains a string we look for

```
[0x0040082c]> px @rsi
- offset -       0 1  2 3  4 5  6 7  8 9  A B  C D  E F  0123456789ABCDEF
0x7ffcfd241e00  4f66 646c 4453 417c 3374 5862 3332 7e58  OfdlDSA|3tXb32~X
0x7ffcfd241e10  3374 5840 7358 6034 7458 747a 0000 0000  3tX@sX`4tXtz....
0x7ffcfd241e20  201f 24fd fc7f 0000 008a b2f9 43aa deed   .$.........C...
0x7ffcfd241e30  d008 4000 0000 0000 0a1d d53c 477f 0000  ..@........<G...
0x7ffcfd241e40  281f 24fd fc7f 0000 0000 0000 0200 0000  (.$.............
0x7ffcfd241e50  7307 4000 0000 0000 0000 0000 0000 0000  s.@.............
0x7ffcfd241e60  0000 0000 0000 0000 bec6 305c b0f8 b063  ..........0\...c
0x7ffcfd241e70  e005 4000 0000 0000 0000 0000 0000 0000  ..@.............
0x7ffcfd241e80  0000 0000 0000 0000 0000 0000 0000 0000  ................
0x7ffcfd241e90  bec6 1071 7802 499c bec6 1674 9a81 3e9d  ...qx.I....t..>.
0x7ffcfd241ea0  0000 0000 0000 0000 0000 0000 0000 0000  ................
0x7ffcfd241eb0  0000 0000 0000 0000 0000 0000 0000 0000  ................
0x7ffcfd241ec0  281f 24fd fc7f 0000 401f 24fd fc7f 0000  (.$.....@.$.....
0x7ffcfd241ed0  8051 f33c 477f 0000 0000 0000 0000 0000  .Q.<G...........
0x7ffcfd241ee0  0000 0000 0000 0000 e005 4000 0000 0000  ..........@.....
0x7ffcfd241ef0  201f 24fd fc7f 0000 0000 0000 0000 0000   .$.............
[0x0040082c]> 
```

so finally:

```
./crackme5 
Enter your input:
OfdlDSA|3tXb32~X3tX@sX`4tXtz
Good game
```



#### Crackme6

Just like before, I run a file and list all functions and there is also `sym.compare_pwd` 

```
0x7f605d25a090]> pdf @sym.compare_pwd
            ; CALL XREF from main @ 0x40074f
┌ 64: sym.compare_pwd (int64_t arg1);
│           ; var int64_t var_8h @ rbp-0x8
│           ; arg int64_t arg1 @ rdi
│           0x004006d1      55             push rbp
│           0x004006d2      4889e5         mov rbp, rsp
│           0x004006d5      4883ec10       sub rsp, 0x10
│           0x004006d9      48897df8       mov qword [var_8h], rdi     ; arg1
│           0x004006dd      488b45f8       mov rax, qword [var_8h]
│           0x004006e1      4889c7         mov rdi, rax
│           0x004006e4      e894feffff     call sym.my_secure_test
│           0x004006e9      85c0           test eax, eax
│       ┌─< 0x004006eb      750c           jne 0x4006f9
│       │   0x004006ed      bfe8074000     mov edi, str.password_OK    ; 0x4007e8 ; "password OK"
│       │   0x004006f2      e859fdffff     call sym.imp.puts           ; int puts(const char *s)
│      ┌──< 0x004006f7      eb16           jmp 0x40070f
│      │└─> 0x004006f9      488b45f8       mov rax, qword [var_8h]
│      │    0x004006fd      4889c6         mov rsi, rax
│      │    0x00400700      bff4074000     mov edi, str.password___s__not_OK_n ; 0x4007f4 ; "password \"%s\" not OK\n"
│      │    0x00400705      b800000000     mov eax, 0
│      │    0x0040070a      e851fdffff     call sym.imp.printf         ; int printf(const char *format)
│      │    ; CODE XREF from sym.compare_pwd @ 0x4006f7
│      └──> 0x0040070f      c9             leave
└           0x00400710      c3             ret
```

however this time, it has a condition inside called `sym.my_secure_test`

```
[0x7fb1cb569090]> pdf @sym.my_secure_test
            ; CALL XREF from sym.compare_pwd @ 0x4006e4
┌ 340: sym.my_secure_test (int64_t arg1);
│           ; var int64_t var_8h @ rbp-0x8
│           ; arg int64_t arg1 @ rdi
│           0x0040057d      55             push rbp
│           0x0040057e      4889e5         mov rbp, rsp
│           0x00400581      48897df8       mov qword [var_8h], rdi     ; arg1
│           0x00400585      488b45f8       mov rax, qword [var_8h]
│           0x00400589      0fb600         movzx eax, byte [rax]
│           0x0040058c      84c0           test al, al
│       ┌─< 0x0040058e      740b           je 0x40059b
│       │   0x00400590      488b45f8       mov rax, qword [var_8h]
│       │   0x00400594      0fb600         movzx eax, byte [rax]
│       │   0x00400597      3c31           cmp al, 0x31                ; 49
│      ┌──< 0x00400599      740a           je 0x4005a5
│      │└─> 0x0040059b      b8ffffffff     mov eax, 0xffffffff         ; -1
│      │┌─< 0x004005a0      e92a010000     jmp 0x4006cf
│      └──> 0x004005a5      488b45f8       mov rax, qword [var_8h]
│       │   0x004005a9      4883c001       add rax, 1
│       │   0x004005ad      0fb600         movzx eax, byte [rax]
│       │   0x004005b0      84c0           test al, al
│      ┌──< 0x004005b2      740f           je 0x4005c3
│      ││   0x004005b4      488b45f8       mov rax, qword [var_8h]
│      ││   0x004005b8      4883c001       add rax, 1
│      ││   0x004005bc      0fb600         movzx eax, byte [rax]
│      ││   0x004005bf      3c33           cmp al, 0x33                ; 51
│     ┌───< 0x004005c1      740a           je 0x4005cd
│     │└──> 0x004005c3      b8ffffffff     mov eax, 0xffffffff         ; -1
│     │┌──< 0x004005c8      e902010000     jmp 0x4006cf
│     └───> 0x004005cd      488b45f8       mov rax, qword [var_8h]
│      ││   0x004005d1      4883c002       add rax, 2
│      ││   0x004005d5      0fb600         movzx eax, byte [rax]
│      ││   0x004005d8      84c0           test al, al
│     ┌───< 0x004005da      740f           je 0x4005eb
│     │││   0x004005dc      488b45f8       mov rax, qword [var_8h]
│     │││   0x004005e0      4883c002       add rax, 2
│     │││   0x004005e4      0fb600         movzx eax, byte [rax]
│     │││   0x004005e7      3c33           cmp al, 0x33                ; 51
│    ┌────< 0x004005e9      740a           je 0x4005f5
│    │└───> 0x004005eb      b8ffffffff     mov eax, 0xffffffff         ; -1
│    │┌───< 0x004005f0      e9da000000     jmp 0x4006cf
│    └────> 0x004005f5      488b45f8       mov rax, qword [var_8h]
│     │││   0x004005f9      4883c003       add rax, 3
│     │││   0x004005fd      0fb600         movzx eax, byte [rax]
│     │││   0x00400600      84c0           test al, al
│    ┌────< 0x00400602      740f           je 0x400613
│    ││││   0x00400604      488b45f8       mov rax, qword [var_8h]
│    ││││   0x00400608      4883c003       add rax, 3
│    ││││   0x0040060c      0fb600         movzx eax, byte [rax]
│    ││││   0x0040060f      3c37           cmp al, 0x37                ; 55
│   ┌─────< 0x00400611      740a           je 0x40061d
│   │└────> 0x00400613      b8ffffffff     mov eax, 0xffffffff         ; -1
│   │┌────< 0x00400618      e9b2000000     jmp 0x4006cf
│   └─────> 0x0040061d      488b45f8       mov rax, qword [var_8h]
│    ││││   0x00400621      4883c004       add rax, 4
│    ││││   0x00400625      0fb600         movzx eax, byte [rax]
│    ││││   0x00400628      84c0           test al, al
│   ┌─────< 0x0040062a      740f           je 0x40063b
│   │││││   0x0040062c      488b45f8       mov rax, qword [var_8h]
│   │││││   0x00400630      4883c004       add rax, 4
│   │││││   0x00400634      0fb600         movzx eax, byte [rax]
│   │││││   0x00400637      3c5f           cmp al, 0x5f                ; 95
│  ┌──────< 0x00400639      740a           je 0x400645
│  │└─────> 0x0040063b      b8ffffffff     mov eax, 0xffffffff         ; -1
│  │┌─────< 0x00400640      e98a000000     jmp 0x4006cf
│  └──────> 0x00400645      488b45f8       mov rax, qword [var_8h]
│   │││││   0x00400649      4883c005       add rax, 5
│   │││││   0x0040064d      0fb600         movzx eax, byte [rax]
│   │││││   0x00400650      84c0           test al, al
│  ┌──────< 0x00400652      740f           je 0x400663
│  ││││││   0x00400654      488b45f8       mov rax, qword [var_8h]
│  ││││││   0x00400658      4883c005       add rax, 5
│  ││││││   0x0040065c      0fb600         movzx eax, byte [rax]
│  ││││││   0x0040065f      3c70           cmp al, 0x70                ; 112
│ ┌───────< 0x00400661      7407           je 0x40066a
│ │└──────> 0x00400663      b8ffffffff     mov eax, 0xffffffff         ; -1
│ │┌──────< 0x00400668      eb65           jmp 0x4006cf
│ └───────> 0x0040066a      488b45f8       mov rax, qword [var_8h]
│  ││││││   0x0040066e      4883c006       add rax, 6
│  ││││││   0x00400672      0fb600         movzx eax, byte [rax]
│  ││││││   0x00400675      84c0           test al, al
│ ┌───────< 0x00400677      740f           je 0x400688
│ │││││││   0x00400679      488b45f8       mov rax, qword [var_8h]
│ │││││││   0x0040067d      4883c006       add rax, 6
│ │││││││   0x00400681      0fb600         movzx eax, byte [rax]
│ │││││││   0x00400684      3c77           cmp al, 0x77                ; 119
│ ────────< 0x00400686      7407           je 0x40068f
│ └───────> 0x00400688      b8ffffffff     mov eax, 0xffffffff         ; -1
│ ┌───────< 0x0040068d      eb40           jmp 0x4006cf
│ ────────> 0x0040068f      488b45f8       mov rax, qword [var_8h]
│ │││││││   0x00400693      4883c007       add rax, 7
│ │││││││   0x00400697      0fb600         movzx eax, byte [rax]
│ │││││││   0x0040069a      84c0           test al, al
│ ────────< 0x0040069c      740f           je 0x4006ad
│ │││││││   0x0040069e      488b45f8       mov rax, qword [var_8h]
│ │││││││   0x004006a2      4883c007       add rax, 7
│ │││││││   0x004006a6      0fb600         movzx eax, byte [rax]
│ │││││││   0x004006a9      3c64           cmp al, 0x64                ; 100
│ ────────< 0x004006ab      7407           je 0x4006b4
│ ────────> 0x004006ad      b8ffffffff     mov eax, 0xffffffff         ; -1
│ ────────< 0x004006b2      eb1b           jmp 0x4006cf
│ ────────> 0x004006b4      488b45f8       mov rax, qword [var_8h]
│ │││││││   0x004006b8      4883c008       add rax, 8
│ │││││││   0x004006bc      0fb600         movzx eax, byte [rax]
│ │││││││   0x004006bf      84c0           test al, al
│ ────────< 0x004006c1      7407           je 0x4006ca
│ │││││││   0x004006c3      b8ffffffff     mov eax, 0xffffffff         ; -1
│ ────────< 0x004006c8      eb05           jmp 0x4006cf
│ ────────> 0x004006ca      b800000000     mov eax, 0
│ │││││││   ; XREFS: CODE 0x004005a0  CODE 0x004005c8  CODE 0x004005f0  
│ │││││││   ; XREFS: CODE 0x00400618  CODE 0x00400640  CODE 0x00400668  
│ │││││││   ; XREFS: CODE 0x0040068d  CODE 0x004006b2  CODE 0x004006c8  
│ └└└└└└└─> 0x004006cf      5d             pop rbp
└           0x004006d0      c3             ret
[0x7fb1cb569090]> 
```

By going to graphic mode

` VV @ sym.my_secure_test`

we can see that `rax` is compared all the time with some random hex values:

```
 0x00400590      488b45f8       mov rax, qword [var_8h]
│       │   0x00400594      0fb600         movzx eax, byte [rax]
│       │   0x00400597      3c31           cmp al, 0x31  
```
then

```
      ││   0x004005b8      4883c001       add rax, 1
│      ││   0x004005bc      0fb600         movzx eax, byte [rax]
│      ││   0x004005bf      3c33           cmp al, 0x33           
```
and so on.

Finally, we get these values:

`0x31 0x33 0x33 0x37 0x5f 0x70 0x77 0x64`

which decoded in cyberchef give a password:

`1337_pwd`