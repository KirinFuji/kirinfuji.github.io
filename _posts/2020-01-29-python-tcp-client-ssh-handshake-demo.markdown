---
title: Python TCP Client - SSH Handshake Demo
date: 2020-01-29 23:41:00 -08:00
permalink: "/posts/python-tcp-client"
categories:
- Ethical Hacking
tags:
- python
description: Python TCP Client with some basic functions and small ssh handshake demo.
blog_category: Ethical Hacking
---

## Summary

I wrote this small snippet as a demo of how some of the layers work in the OSI Model. To demo how a tcp connection is a 2 way communication channel between machines, once opened the applications on each machine send data back and forth.

## Layer 3/4
First a tcp 3 way handshake on port 22 (SYN), (SYN, ACK), (ACK):  
I defined the tcp_connect function for this. The majority of the connection code is being handled by the 'socket' library making this extremely simple.

## Layer 7
Then we need to be able to send data and capture what our data gets responded to. I defined the tcp_io function for this. It sends our data as part of the data payload portion of the packets so we essentially have direct access to the application examining our data on the other side of the tcp connection. The programmers hopefully took care of things like crashing because of malformed or intentionally corrupt data. If we send what the application is expecting we will typically get a response.

In this example I created a simple if-then logic to see if the data we get back starts with 'SSH-2.0-' and if we do then we send back 'SSH_MSG_KEXDH_INIT' which is part of the SSH protocol handshake. This data is being sent and received over the same initial tcp connection we opened.

### Sending Bogus data to see what happens
If you grab the code and set it to port 22 and use -d and enter some bogus data, say 'asdasdasd' to my surprise instead of just hanging up on us with a TCP RST packet, they politely told us the data we sent was invalid and kept the connection open:
```
python basic-tcp-client.py -t myvps.example.com -p 22 -d 'asdasdasd'
Target Details: 
Host is: myvps.example.com
Port is: 22
Data sent: 
asdasdasd
Response is: 
SSH-2.0-OpenSSH_8.0p1 Debian-4

Data sent: 
SSH_MSG_KEXDH_INIT

Response is: 
Invalid SSH identification string.
```

### TCP RST generated due to application data we sent.
I wanted them to hang up so this time lets send them 2 sets of incorrect data. I modified the program slightly so if we receive 'Invalid SSH' we will ask again, essentially creating a loop. It didn't take very long though, they sent a TCP RST as soon as we made an attempt to start a second key exchange:
```
Target Details: 
Host is: myvps.example.com
Port is: 22
Data sent: 
%!@%^(!)#&)SSH_MSG_KEX_INIT%\r\nfjosfu08ue230193w12@$@Q#%2q34!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
Response is: 
SSH-2.0-OpenSSH_8.0p1 Debian-4

Data sent: 
SSH_MSG_KEXDH_INIT

Response is: 
Invalid SSH identification string.

Data sent: 
SSH_MSG_KEX_INIT

socket.error: [Errno 104] Connection reset by peer
```

### Correct SSH Handshake
And just as an example of the beginnings a correct response for the SSH handshake:
```
python basic-tcp-client.py -t myvps.example.com -p 22 -d 'SSH-2.0-OpenSSH_8.0p1 Debian-4'
Target Details: 
Host is: myvps.example.com
Port is: 22
Data sent: 
SSH-2.0-OpenSSH_8.0p1 Debian-4
Response is: 
SSH-2.0-OpenSSH_8.0p1 Debian-4

Data sent: 
SSH_MSG_KEXDH_INIT

Response is: 
4�n�Z�-�⹍��curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group14-sha256,diffie-hellman-group14-sha1Arsa-sha2-512,rsa-sha2-256,ssh-rsa,ecdsa-sha2-nistp256,ssh-ed25519lchacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.comlchacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com�umac-64-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha1-etm@openssh.com,umac-64@openssh.com,umac-128@openssh.com,hmac-sha2-256,hmac-sha2-512,hmac-sha1�umac-64-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha1-etm@openssh.com,umac-64@openssh.com,umac-128@openssh.com,hmac-sha2-256,hmac-sha2-512,hmac-sha1none,zlib@openssh.comnone,zlib@openssh.com
```

## Code  
{% highlight python %}

#!/usr/bin/python

import sys, getopt, socket, ssl

    # Start Variable Setup #

def main(argv):
    target = ''
    port = ''
    data = ''
    try:
        opts, args = getopt.getopt(argv,"ht:p:d:",["host=","port=","data="])
    except getopt.GetoptError:
        print 'basic-tcp-client.py -t <host> -p <port> -d <data>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'basic-tcp-client.py -t <host> -p <port> -d <data>'
            sys.exit()
        elif opt in ("-t", "--host"):
            target = arg
        elif opt in ("-p", "--port"):
            port = arg
        elif opt in ("-d", "--data"):
            data = arg    
        
    target_host = target
    target_port = int(port)
    
    # Check to see if the user did not input data. Send default http get if not.
    if data != '':
        target_data = data
    else:
        target_data = ("GET / HTTP/1.1\r\nHost: " + target_host + "\r\n\r\n")
        print "No data detected, using HTTP GET as default."     

    # End Variable Setup #
    # Start Function/Object Setup #
    
    # Create Socket Object
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)    
    
    def tcp_connect(dst_host,dst_port):
        # Connect to the target host on target port
        client.connect((dst_host,dst_port))

    def tcp_io(io_data):
        client.send(io_data)
        response = client.recv(4096)  
        return(response)
    
    # End Function/Object Setup #
    
    # Example payload to send:
    # python basic-tcp-client.py -t <target_host> -p 22 -d 'SSH-2.0-OpenSSH_8.0p1 Debian-4'
    
    print 'Target Details: '    
    print 'Host is: ' + target    
    print 'Port is: ' + port
        
    tcp_connect(target_host,target_port)    
    response = tcp_io(target_data)
    
    print 'Data sent: \r\n' + target_data
    print('Response is: \r\n' + response)
    
    if response.startswith('SSH-2.0-'):
       print 'Data sent: \r\n' + "SSH_MSG_KEXDH_INIT\r\n"
       response = tcp_io("SSH_MSG_KEXDH_INIT\r\n")
       print('Response is: \r\n' + response)

if __name__ == "__main__":
    main(sys.argv[1:])

{% endhighlight %}