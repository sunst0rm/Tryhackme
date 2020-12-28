# IP
```10.10.222.150```

# What is the name of the cookie used for authentication?

We can see by opening a console that `Name` of wanted cookie is 

`auth`

# In what format is the value of this cookie encoded?

We get a value with letters and numbers with total combinations of 16 so it is base16, called in other way

`hexadecimal`

# Having decoded the cookie, what format is the data stored in?

We can decode a cookie e.g using Cyberchef which transform hex to ascii andgives 
```{"company":"The Best Festival Company", "username":"jarek"}```

Such format is called JavaScript Object Notation, so the answer is:

`json`

# What is the value of Santa's cookie?

We see that for authentification, we only need a username, so let's replace mine to `santa` and transform it back to hexadecimal.

`7b22636f6d70616e79223a22546865204265737420466573746976616c20436f6d70616e79222c2022757365726e616d65223a2273616e7461227d`

# What is the flag you're given when the line is fully active?

After refreshing a website, activating all sections I get a flag

`THM{MjY0Yzg5NTJmY2Q1NzM1NjBmZWFhYmQy}`