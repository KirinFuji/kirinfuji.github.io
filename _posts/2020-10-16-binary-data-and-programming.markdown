---
title: Binary Data and Programming
date: 2020-10-16 15:24:00 -07:00
categories:
- Security
tags:
- Reverse Engineering
- Python
blog_category: Security
---

## Use case in high level programming.

Often times new programmers jump right into a high level language without really understanding the underlying systems that allow the language to do so much more with so much less.

You may never be in the situation were you have to work with encoding and binary data. Typical situations would be network and protocol analysis, character encoding, file systems, and so much more.

There are many robust systems in place already that handle all this without us even thinking about it.

## Understanding bytes and bits  

A byte is 8 bits, and a bit is a switch that can be either a 0 or a 1 which means each byte has 256 unique combinations of "switch patterns". The basis of an encoding format is to get all the symbols you can represented by as few bytes as possible. Obviously if you break out of English there is many more symbols out there so some encoding schemes eventually start using 2 bytes for a character which jumps to a staggering 65536 unique "switch patterns".

(This can sometimes have an interesting effect in security. For example minecraft had a duplication bug because of the way it handled Unicode characters vs ASCII characters and couldn't compress the data properly which lead to an important file becoming too bloated to save if stuffed full of Unicode characters.)

In other words quoted from user.eng.umd.edu :
"A series of eight bits strung together makes a byte, much as 12 makes a dozen. With 8 bits, or 8 binary digits, there exist 2^8=256 possible combinations."

The way I link to think about it, as that it is all just arbitrary mappings that people building the lower level systems agreed upon. They decided what bit combinations would map to what (Like a character "A" or number "1") and soon standards like ASCII and UTF-8 came about.

For example, in UTF-8 the "!" symbol is actually 21 in hex. The operating system and/or program is going to have the data stored in the form of 21, and also know it is encoded with UTF-8, however when presented to the user it will be UTF-8 decoded into the appropriate symbol.

## Well... Whats the point?

Because raw binary data is at the root of all of this to copy and load data just means to copy and load bits. The programs are simply aware of what order the bits are in and what combination and pattern of bits means what.

## Python example

Because the "print()" function is designed to already decode bytes and print ASCII equivalent I have to show you in hexadecimal. This should be okay though, just remember a byte is 8 bits and hex is base 16.

```
import binascii
string = "Hello World"
byte_String = bytes(string, 'ASCII')
hexlified = binascii.hexlify(byte_String)
print(hexlified)
```
Output:
```
b'48656c6c6f20576f726c64'
```
The "b" at the beginning is python saying this data is in byte form if I didn't use hex, it would have printed "b'Hello World'" because python would have done the work of translating the bytes to ascii.

Now open an Ascii sheet like http://www.asciitable.com/ and you will find the following HEX<->ASCII mapping:
```
48 = H
65 = e
6c = l
6c = l
6f = o
20 = " "
57 = W
6f = o
72 = r
6c = l
64 = d
```
