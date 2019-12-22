---
title: GPG Detailed Explanation
date: 2019-12-01 16:00:00 -08:00
categories:
- Security
layout: post
author: Ted
---

# Page Under Construction


### ### ### CHEAT SHEET ### ### ###

#send an encrypted attachment via linux cli
# Note, you do not need to generate a key on the sending machine.

### Receiever ###

#Check for available entropy before generating keypair
cat /proc/sys/kernel/random/entropy_avail

#Generate Keypair #RSA RSA, #4096, #0, #y, #Real Name, #Email, #Comment, #o
gpg2 --gen-key 

#Show GPG Keys (secring)
gpg2 --list-secret-keys

#Verify fingerprint of key
gpg2 --list-keys --keyid-format LONG --fingerprint

#Export the public key
gpg2 --armor --output mypubkey.gpg --export kirin@example.com

#Copy the public key and provide to the sender. (Can also use an online server to store/retriev this)
scp mypubkey.gpg KirinFuji@example.com:~/

### Sender ###

#Import the recivers public key
gpg2 --import mypubkey.gpg

#Verify fingerprint of key
gpg2 --list-keys --keyid-format LONG --fingerprint

#Encrypt the file
gpg2 --output testresults.txt.gpg --encrypt --recipient kirin@example.com testresults.txt

gpg2 -se -r kirin@example.com testresults.txt

gpg2 -e -u "Sender User Name" -r "Receiver User Name" somefile

gpg2 --edit-key <user@domain>


### ### ### Bob & Alice Linux CLI Example ### ### ###

Bob Generates a Keypair and exports the pubkey:
pub.bob.gpg 
Bob Generates a Hash/Signature of pub.bob.gpg:
pub.bob.gpg.md5 (Extra Security not important)

Alice Generates a Keypair and exports the pubkey
pub.alice.gpg 
Alice Generates a Hash/Signautre of pub.alice.gpg
pub.alice.gpg.md5 (Extra Security not important)

Bob and Alice exchange files.

Bob and Alice use any means of communication that they can trust they are speaking to the real other party.
They verify the fingerprint/hash/signature of eachothers public keys.
During the verification process, they sign eachothers pub keys with eachothers priv keys.

Bob  : gpg2 --edit-key alice@company.com
gpg> fpr
gpg> sign
gpg> y (after verifying with eachother)
gpg> check
gpg> quit

Alice: gpg2 --edit-key bob@company.com
gpg> fpr
gpg> sign
gpg> y (after verifying with eachother)
gpg> check
gpg> quit

Bob and alice no longer have this trusted channel but must communicate.

Bob writes a document:
echo "Hello Alice" > hello-alice.txt 

Bob encrypts the document with Alices public key:
gpg2 --encrypt --output hello-alice.txt.gpg --recipient "alice@company.com" hello-alice.txt

Bob creates a detached signature of the original document with Bobs private key.
gpg2 --local-user "bob@company.com" --output hello-alice.txt.sig --detach-sig hello-alice.txt

Bob sends alice both the following over any means of communication:
hello-alice.txt.sig
hello-alice.txt.gpg

Alice Decrypts the hello-alice.txt.gpg using Alice's private key.
gpg2 --output hello-alice.txt --decrypt hello-alice.txt.gpg

Alice verifys the validity of the sender + message using Bobs public key:
gpg --verify hello-alice.txt.sig hello-alice.txt

Provided both parties private keys have not been compromised,
and the encryption methods used are not vulnerable,
Alice can be quite certain this message got to her in-tact,
exactly as Bob wrote it, and can be confident it was from Bob.

However, this is not perfect , there are still possible security risks and it can get even more secure.

For Example:

### Key integrity Problem ###

-When you distribute your public key, you are 
distributing the public components of your master
and subordinate keys as well as the user IDs.

-Distributing this material alone, however, 
is a security risk since it is possible for
an attacker to tamper with the key.

-The public key can be modified by adding
or substituting keys, or by adding or changing user IDs.

-By tampering with a user ID, the attacker 
could change the user ID's email address
to have email redirected to himself.

-By changing one of the encryption keys, the attacker would also
be able to decrypt the messages redirected to him.

### Key integrity Solution ###

-Using digital signatures is a solution to this problem.

-When data is signed by a private key, the corresponding
public key is bound to the signed data.

-In other words, only the corresponding public key can be
used to verify the signature and ensure that the data has not been modified.

-A public key can be protected from tampering by using its
corresponding private master key to sign the public key components and user IDs,
thus binding the components to the public master key.

-Signing public key components with the corresponding private
master signing key is called self-signing, and a public key that
has self-signed user IDs bound to it is called a certificate.

### Making and verifying signatures ###

-Creating and verifying signatures uses the public/private keypair in an operation different
from encryption and decryption.

-A signature is created using the private key of the signer.

-The signature is verified using the corresponding public key.

-For example, Alice would use her own private key to digitally sign
her latest submission to the Journal of Inorganic Chemistry.

-The associate editor handling her submission would use Alice's public
key to check the signature to verify that the submission indeed came from
Alice and that it had not been modified since Alice sent it.

-A consequence of using digital signatures is that it is difficult to
deny that you made a digital signature since that would imply your private key had been compromised.

However:

-A signed document has limited usefulness.
Other users must recover the original document from the signed version,
and even with clearsigned documents, the signed document must be edited
to recover the original.

-Therefore, there is a third method for signing a document
that creates a detached signature, which is a separate file.

-A detached signature is created using the --detach-sig option.

### Encrypting and decrypting documents ###

A public and private key each have a specific role when encrypting and decrypting documents. A public key may be thought of as an open safe. When a correspondent encrypts a document using a public key, that document is put in the safe, the safe shut, and the combination lock spun several times. The corresponding private key is the combination that can reopen the safe and retrieve the document. In other words, only the person who holds the private key can recover a document encrypted using the associated public key.

The procedure for encrypting and decrypting documents is straightforward with this mental model. If you want to encrypt a message to Alice, you encrypt it using Alice's public key, and she decrypts it with her private key. If Alice wants to send you a message, she encrypts it using your public key, and you decrypt it with your private key.

To encrypt a document the option --encrypt is used. You must have the public keys of the intended recipients. The software expects the name of the document to encrypt as input; if omitted, it reads standard input. The encrypted result is placed on standard output or as specified using the option --output. The document is compressed for additional security in addition to encrypting it.

alice% gpg --output doc.gpg --encrypt --recipient blake@cyb.org doc

The --recipient option is used once for each recipient and takes an extra argument specifying the public key to which the document should be encrypted. The encrypted document can only be decrypted by someone with a private key that complements one of the recipients' public keys. In particular, you cannot decrypt a document encrypted by you unless you included your own public key in the recipient list.

To decrypt a message the option --decrypt is used. You need the private key to which the message was encrypted. Similar to the encryption process, the document to decrypt is input, and the decrypted result is output.

blake% gpg --output doc --decrypt doc.gpg

You need a passphrase to unlock the secret key for
user: "Blake (Executioner) <blake@cyb.org>"
1024-bit ELG-E key, ID 5C8CBD41, created 1999-06-04 (main key ID 9E98BC16)

Enter passphrase: 

Documents may also be encrypted without using public-key cryptography. Instead, you use a symmetric cipher to encrypt the document. The key used to drive the symmetric cipher is derived from a passphrase supplied when the document is encrypted, and for good security, it should not be the same passphrase that you use to protect your private key. Symmetric encryption is useful for securing documents when the passphrase does not need to be communicated to others. A document can be encrypted with a symmetric cipher by using the --symmetric option.

alice% gpg --output doc.gpg --symmetric doc
Enter passphrase: 

