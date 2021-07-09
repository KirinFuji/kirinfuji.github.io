---
title: How criminal hackers get away with  hosting a redirection server
date: 2021-07-09 03:37:00 -07:00
categories:
- Security
tags:
- Ethical Hacking
description: How criminal hackers get away with hosting a redirection server using
  Cloudflare to hide part of their chain of operations. Thus using corporate resources
  for malicious action and personal gain.
blog_category: Security
---

I have tracked down a few phishing campaigns and tried to get them removed from the internet however with one in particular I found out that because of how their redirection chain operates, their middle domain and Cloudflare protected redirection server, is not breaking Cloudflare ToS and according to them: 

**"There is no evidence of phishing using this domain, if you have additional evidence, please provide us so we may investigate further."**

This is just plain wrong. Because of how the policy works, only the final server serving the Phishing content is taken into consideration. 

What this means, is a hacker can buy a VPS with a provider who does not have Phishing in their ToS or serve the website from their basement server and ISP connection in a country where hacking is legal or has less laws or is a gray area.

Then they can buy a second VPS with a more restrictive provider or use Google Cloud or even GitHub Pages and use this server as a redirection server.

They will then use Cloudflare to protect the redirection Domain and server hosting the redirection content. (Protected from being removed by a ToS violation and IP protected by cloudflare passthru/DDoS protection) This content and domain as far as Cloudflare is concerned does not break their ToS and is not being used for malicious purposes. Even if the redirection server is serving JavaScript and HTML code that directly points to and redirects a user to the server hosting the actual Phishing/Malicious content.

Hackers will start by using a link shortening website like bitly, which they will shorten their redirection server link and configure the redirection server in a way where if you don't reach it from the bit.ly link you get served a blank page further hiding the redirection server.

Once you reach the redirection server correctly, it will contain some JavaScript or html to log visitor activity as well as serve code that will redirect incoming users to the real Phishing/Malicious content host example below:

```
<meta http-equiv="refresh" content="0; URL=https://example.com/malicous/url/?pointingto=malicious&phishing=content">
```

Through methods like this criminals literally use corporate resources (Hardware, Network, etc) to host part of their chain of operations and live inside a loophole/grey area of the ToS.

The final malicious domain and server are both hosted in a country where filing an abuse report wont do anything so the actual malicious server cannot be removed, and due to the loophole the redirection content cannot be removed.

Put it all together and they can basically do whatever they want and get away with it.

In my personal opinion, the service providers should want to remove content being used as part of a criminal operation but they don't seem to care.



