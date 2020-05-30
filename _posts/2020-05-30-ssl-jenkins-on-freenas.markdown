---
title: Jenkins on FreeNAS11 w/ SSL
date: 2020-05-30 08:38:00 -07:00
categories:
- Service Hosting
tags:
- Service Hosting
author: Kirin
description: A walk-through of how to setup a Jenkins server with ssl (nginx reverse
  proxy) running in a FreeNAS jail. SSL Certificate obtained through LetsEncrypt.
blog_category: Service Hosting
---

## Setting up Jenkins on FreeNAS with SSL using lets encrypt (manual)

This is a rough outline of the process. I missed a few steps like creating the nginx/log directory that matches my nginx.conf and possibly others.

Because you will be going between FreeNAS/HTTP FreeNAS/SSH AnotherLinuxBox/SSH I will place a heading based on what box you should be in.

### FreeNAS/HTTP

\1. Setup your FreeNas Box (ZFS Pools Etc).

\2. Install the Jenkins Plugin.

\3. Enable the SSH service with root login.

\4. SSH into your FreeNas Box as root.

### FreeNAS/SSH/nas

\5. Run the following (jls) and obtain your Jail ID (JID).
```
    root@nas1[~]# jls
       JID  IP Address      Hostname                      Path
        16                  jenkins                       /mnt/ZFS_00/iocage/jails/jenkins/root
```
\6. Run the following `jexec <JID> tcsh` to spawn a shell.
```
    root@nas1[~]# jexec 16 tcsh
    root@jenkins:/ #
```

### FreeNAS/SSH/Jenkins

\7. Change directory:
   `cd /usr/local/etc/nginx/`

\8. Install dependencies:
   `pkg install openssl nano`

### AnotherLinuxBox/SSH

\9. For this part your going to need a machine that allows you to run certbot because for whatever reason it would spit out its not supported on this system. I SSH'd into a linux box and `sudo yum install certbot`.

\10. Run the following `certbot certonly --manual -d jenkins.yourdomain.net` when it says "Press ENTER to continue." DONT DO IT.

```
    [root@linuxbox ~]# certbot certonly --manual -d jenkins.yourdomain.net
    Saving debug log to /var/log/letsencrypt/letsencrypt.log
    Plugins selected: Authenticator manual, Installer None
    Obtaining a new certificate
    Performing the following challenges:
    http-01 challenge for jenkins.yourdomain.net
    
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    NOTE: The IP of this machine will be publicly logged as having requested this
    certificate. If you're running certbot in manual mode on a machine that is not
    your server, please ensure you're okay with that.
    
    Are you OK with your IP being logged?
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    (Y)es/(N)o: Y
    
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Create a file containing just this data:
    
    i_asdfsdgdfgsdfasdasdasdasfasd.-asdasdasdasdasdasdasdasdasd
    
    And make it available on your web server at this URL:
    
    http://jenkins.yourdomain.net/.well-known/acme-challenge/i_asdasdasdasdasdasdasdasd
    
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Press Enter to Continue (DONT!)
```

### FreeNAS/SSH/Jenkins

\11. Back in the Jenkins Jail shell & For your convenience grab [nginx.conf.lets.encrypt.chal.txt](/uploads/nginx.conf.lets.encrypt.chal.txt) and make it the live nginx.conf. (This is going to respond back with the answer to the challenge for anyone who goes to this specific url.)

\12. Edit it so that the values of lines 43 & 44 represent what the certbot prompt showed you.

```
                    #Lets Encrypt Challenge
                    location /.well-known/acme-challenge/i_asdasdasdasdasdasdasdasd {
                            return 200 "i_asdfsdgdfgsdfasdasdasdasfasd.-asdasdasdasdasdasdasdasdasd";
                    }
```

\13. Restart nginx `service nginx restart`

### Your Network

\14. Setup port forwards or whatever networking you need to so that the PUBLIC INTERNET can reach jenkins.yourdomain.net/.well-known/acme-challenge/i_asdasdasdasdasdasdasdasd on your exact jenkins build here.

(Don't worry this is at most temporary for 5 minutes.)

\15. Test step 14 with https://reqbin.com/curl  
`curl http://jenkins.yourdomain.net/.well-known/acme-challenge/i_asdasdasdasdasdasdasdasd`  

\16. You should get back `i_asdfsdgdfgsdfasdasdasdasfasd.-asdasdasdasdasdasdasdasdasd`

### AnotherLinuxBox/SSH

\17. If all went well, go back to and press ENTER!

```
    Waiting for verification...
    Cleaning up challenges
    
    IMPORTANT NOTES:
     - Congratulations! Your certificate and chain have been saved at:
       /etc/letsencrypt/archive/jenkins.yourdomain.net/fullchain.pem
       Your key file has been saved at:
       /etc/letsencrypt/archive/jenkins.yourdomain.net/privkey.pem
       Your cert will expire on 2020-08-28. To obtain a new or tweaked
       version of this certificate in the future, simply run certbot
       again. To non-interactively renew *all* of your certificates, run
       "certbot renew"
     - If you like Certbot, please consider supporting our work by:
    
       Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
       Donating to EFF:                    https://eff.org/donate-le
```

### Your Network

Feel free to take down any networking or forwarding you did now if this is not going to be a public Jenkins

### FreeNAS/SSH/Jenkins

\18. Back in the Jenkins Jail now. Move the certificates (I used 2 WinSCP sessions to copy the certs from AnotherLinuxBox to FreeNAS) you just generated from your linuxbox@/etc/letsencrypt/archive/jenkins.yourdomain.net/ to your JenkinsJail@/usr/local/etc/nginx/ssl

```
    root@jenkins:/usr/local/etc/nginx/ssl # ls
    cert1.pem chain1.pem fullchain1.pem privkey1.pem
```

\19. while in the /usr/local/etc/nginx/ssl directory, run this to generate the dhparam4096.pem:
`openssl dhparam -out dhparam4096.pem 4096`

\20. Grab the nginx.conf over at [nginx.conf.txt](/uploads/nginx.conf.txt)

\21. Ctrl\+h replace `jenkins.yourdomain.net` with whatever your host is gonna be. Make sure it resolves to the IP of your Jenkins Jail.

\22. Write your edited `nginx.conf` to `/usr/local/etc/nginx/nginx.conf`

\23. Restart nginx `service nginx restart`

\24. Test it out! That should be it!? (I may have forgotten something!!)