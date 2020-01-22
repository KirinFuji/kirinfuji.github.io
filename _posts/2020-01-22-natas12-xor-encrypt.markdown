---
title: Natas12 xor_encrypt
date: 2020-01-22 00:35:00 -08:00
categories:
- Security
tags:
- Ethical Hacking
---

### Explanation

I was trying out the Natas wargame now that I know more about web application penetration testing and came across this level that was significantly more challenging then the first 11 levels.

They give you the source code to the page but redact the xor_encrypt key however we have available both a ciphertext and plaintext that are related.

I modified the function just by adding a second value to the function instead of it using a hard coded key.

We can get the key by running the function by using the base64 decoded cookie as the key and json encoded, hard-coded default plaintext, that was available in the source code.

The key ends up being 'qw8J'. Just to verify I ciphered the plain text using the key and got the same cipher text and took my cookie and deciphered it getting the same plain text.

Finally we create our payload with the 'showpassword' variable set to 'yes' instead of 'no' and edit our cookie and refresh the page to get the password for Natas 12.

### Code

{% highlight php linenos %}
<?

$plaintext = array( "showpassword"=>"no", "bgcolor"=>"#ffffff");
$ciphertext = base64_decode('ClVLIh4ASCsCBE8lAxMacFMZV2hdVVotEhhUJQNVAmhSEV4sFxFeaAw=');
$foundkey = 'qw8J';
$payload = array( "showpassword"=>"yes", "bgcolor"=>"#ffffff");

function xor_encrypt($in,$keyin) {
    $key = $keyin;
    $text = $in;
    $outText = '';

    for($i=0;$i<strlen($text);$i++) {
    $outText .= $text[$i] ^ $key[$i % strlen($key)];
    }

    return $outText;
}

print("xor_encrypt-Key: ".xor_encrypt(json_encode($plaintext),$ciphertext)."\n");
print("Ciphered-Cookie: ".base64_encode(xor_encrypt(json_encode($plaintext),$foundkey))."\n");
print("Deciphered-Cookie: ".xor_encrypt($ciphertext,$foundkey)."\n");
print("Payload-Cookie: ".base64_encode(xor_encrypt(json_encode($payload),$foundkey))."\n");

?>

{% endhighlight %}

### Output

```
xor_encrypt-Key: qw8Jqw8Jqw8Jqw8Jqw8Jqw8Jqw8Jqw8Jqw8Jqw8Jq
Ciphered-Cookie: ClVLIh4ASCsCBE8lAxMacFMZV2hdVVotEhhUJQNVAmhSEV4sFxFeaAw=
Deciphered-Cookie: {"showpassword":"no","bgcolor":"#ffffff"}
Payload-Cookie: ClVLIh4ASCsCBE8lAxMacFMOXTlTWxooFhRXJh4FGnBTVF4sFxFeLFMK
```