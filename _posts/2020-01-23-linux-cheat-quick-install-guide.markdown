---
title: Linux Cheat Quick Install Guide
date: 2020-01-23 21:56:00 -08:00
description: Linux 'cheat' command line utility used to summon cheatsheets similar
  to 'man' but containing brief information and usage examples.
blog_category: Quick Install Guide
---

Linux Cheat is a command line utility designed for linux administrators who often need to remember a set of commands that they use often but not often enough to remember.

## Resources

https://github.com/cheat/cheat/  
https://github.com/cheat/cheat/releases/download/3.3.0/cheat-linux-amd64  
https://github.com/cheat/cheat/releases/download/3.3.0/cheat-linux-arm7  

## Setup
You will need to figure out your os (arm[5,6,7],amd64,etc...). Once figured out right click copy the URL destination for the appropriate release executable from above.

Replace <URL> with aforementioned, copied URL and paste this:
{% highlight shell linenos %}
exec_url="<URL>" ;
mkdir -p ~/bin ; pushd ~/bin &>/dev/null ; wget "$exec_url" ; popd ;
export PATH="$PATH:~/bin"
{% endhighlight %}

All the related files will be in ~/.config/cheat/ and the executable will be in ~/bin.  

Copy paste this entire code-block to quick install cheat and a few sheets:
{% highlight shell linenos %}
mkdir -p ~/.config/cheat ;
mkdir -p ~/.config/cheat/sheets ;
mkdir -p ~/.config/cheat/sheets/personal ;
echo '
editor: nano
colorize: true
style: monokai
formatter: terminal16m
cheatpaths:

  - name: community
    path: ~/.config/cheat/sheets
    tags: [ community ]
    readonly: true

  - name: personal
    path: ~/.config/cheat/sheets/personal
    tags: [ personal ]
    readonly: false
' > ~/.config/cheat/conf.yml ;

pushd ~/.config/cheat/sheets &>/dev/null ;
git clone https://github.com/cheat/cheatsheets.git ;
git clone https://github.com/andrewjkerr/security-cheatsheets.git ;
mv cheatsheets/* . ;
mv security-cheatsheets* . ;
rm -rf cheatsheets ;
rm -rf security-cheatsheets ;
popd &>/dev/null
{% endhighlight %}

## Try it out

Now try running 'cheat tar' or 'cheat 7z' to get familiar. You can run 'cheat --init' to better understand the ~/.config/cheat/conf.yml file.
