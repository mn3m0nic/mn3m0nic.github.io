---
title: "Review attack surface on Telegram example"
date: 2023-01-07T00:00:00+03:00
type: post
comments: true
categories: ["thoughts"]
tags: ["security", "threat-modeling"]
---

It's been a while since I wrote something here...
Let's dig an iceberg of "security in general" again.

This is a very brief review that is using Telegram mobile application, which connects through the mobile network to a remote server, just as an example.
The attack surface may be different for you, but it can still contain the same basic elements (not always).

1. Application layer (Telegram app) 
2. Libraries
3. OS + backups
4. Device + GSM stack
6. Network layers
7. API service + some backend
8. Third-party services

{{< figure src="/images/security-attack-surface-telegram/1.png" position="center" caption="1. List of possible targets" >}}

# attack in a real-case scenario

There are a lot of theoretical directions, but, most likely, an attack scenario will be selected based on:

1. Complexity (physical access) - it must be as low as possible;
2. Low cost;

{{< figure src="/images/security-attack-surface-telegram/2.png" position="center" caption="2. Three main directions" >}}

## most likely...

1. Attack by performing physical backup and forensic tools on the dump ( CelleBrite, etc );
2. Attack on your account (SIM clone, linked hidden device, legit C2 backdoor implant, etc.); 
3. Collecting data about you using open source (OSINT);

Other methods are also available, but the cost will increase, which means they are less likely will be used. 💰

# Remediation

TL;DR:

1. Use a trustworthy vendor with their security department and install all security patches (updates);
2. Use a password manager with a strong master password;
3. Enable MFA, not on a mobile phone if possible;
4. Don't do anything stupid, such as clicking on suspicious links or posting your personal data in public chat, public profile, etc.
5. If this is not what you do for a living, hire(ask) someone experienced enough to consult you - on how to protect according to your threat model; 
May be double check this with some other expert;

{{< figure src="/images/security-attack-surface-telegram/rw.png" position="center" >}}

This is all.

But...

If this is not enough for you... :)

## :: Before you start

{{< figure src="/images/security-attack-surface-telegram/5.png" alt="https://twitter.com/thegrugq/status/864023197145944064" position="center" >}}

1. There is no such thing as "absolute security";
2. Not a point to be reached. It's a vector to be followed.
3. Security is always in context according to your threat model
5. Your threat model, most likely, is *not* my threat model;
6. This is not the guide, but just some hints;
7. Don't do anything illegal; Most likely you will be caught;

{{< figure src="/images/security-attack-surface-telegram/0.png" position="center" >}}

## :: Backups - make them exist and be secure

1. Make backups of your critical data;
2. Test your backups - how they can be recovered;
3. Test them again, from time to time. Recovery of damaged encrypted data can be much harder than you may think;
3. Keep backups in a secure, trusted location (more than one);
4. Make backups always encrypted with strong encryption and a strong passphrase;
5. Store on physical media in a secure location only part of the modified decryption key for backup for recovery, as a hint to recreate the original key;
6. Backup volumes should not be available from the target system for listing (no mounted backup volumes, or available for writing AWs S3 buckets);

{{< figure src="/images/security-attack-surface-telegram/6.png" position="center" >}}

This is a bad idea:

```
root@some-serer-123 $ ls -lah /mnt/backups
... listing backups ...
```
In this case, a compromised server can be used to destroy the data and backups simultaneously.

## :: Devices :: use trustworthy

1. Avoid using backdoored, corporate hardware for any personal task; [button phones backdoors(rus)](https://habr.com/ru/post/575626/)
2. Avoid installing any third-party untrusted software;
3. Avoid giving your physical device to anyone, even for a short period;
4. If your device has been stolen and returned - perform ["Reset to factory settings"](https://support.google.com/android/answer/6088915?hl=en)
5. Reset to factory settings can help, and in some cases - can't. Just copy the data and forget about this device;
6. Avoid plugging in your device in an unknown system or charging port and or using an unknown charging cable;
7. Use separate devices, virtual machines, and networks for different activities (if possible)
8. Avoid using "compromised" by hardware vulnerabilities devices;

{{< figure src="/images/security-attack-surface-telegram/verify.png" position="center" >}}


## :: Security patches :: Install them

1. Enable and always install all security patches for your OS and apps;
2. If there is some software "X" which is not supported by the relevant OS version or works slowly - consider buying a separate network-isolated device just for running this "X" unsupported software (or use it in a virtual machine, if possible);
3. Consider using Security focused OS: 

* [GrapheneOS](https://grapheneos.org/) as smartphone Android replacement;
* [Qubes](https://www.qubes-os.org/) or [Subgraph](https://subgraph.com/) as desktop
* [Tails](https://tails.boum.org/) as a Read-only LIVE OS
* or just use regular OpenBSD, DragonflyBSD, or GNU/Linux if you know what you are doing :)

{{< figure src="/images/security-attack-surface-telegram/osupd.png" position="center" >}}

## :: Passwords :: use Password Manager

1. Use a password manager (such as keepassxc) to generate strong passwords
2. Use different passwords for each system
3. Avoid using your personal data, phone number, date of birth, name of family members, pets, etc.
4. Dictionary words should be avoided (such as @apple123)
5. Avoid common keyboard sequences (such as "qwerty")

These are all bad passwords:

```
!QAZ2wsx#EDC4rfv
mysecretpassword0*
7ujMko0admin
7ujMko0vizxv
LFL870206
5172980a
north33
1terry
11moneys
34babie
edward59
teamochapa
24a.24a
44--------44
1234567890
000---11
8688851a
1100a
8688851
```
{{< figure src="/images/security-attack-surface-telegram/pass.png" position="center" >}}

## :: Account recovery :: Check your recovery

1. Check account recovery - how you will recover your account without knowing your password;
2. Set the actual password instead of answering "Your pet name". Answer "WHwiWHI0-1@%%" may be a good pet name.
3. Keep answers for your secret questions in a secure place;

{{< figure src="/images/security-attack-surface-telegram/recovery.png" position="center" >}}

## :: Password manager :: master password

1. Set *a strong* master password for a password manager
2. Keep a paper copy(?) of part of the password to recall it when you forget it;
3. You can encrypt or modify the master password stored on a physical copy or store it in a big bunch of garbage;

{{< figure src="/images/security-attack-surface-telegram/master.png" position="center" >}}

## :: Passwords - compromised

1. Check your accounts logins for being compromised
( Example: https://haveibeenpwned.com/ ). If it was detected leaked database with your e-mail in it

## :: Linked devices

1. Inspect all of your linked devices for your account;
2. Disable unused(or lost) linked devices;
3. Check for active sessions - reset your password if you see any anomalous activity;

## :: Two-factor authentication

1. Enable two-factor authentication;
2. If feasible, use a different device for the second factor;
3. GSM mobile number is *a bad* idea for recovery or second factor as SIM card can be cloned;

{{< figure src="/images/security-attack-surface-telegram/mfa.png" position="center" >}}

## :: Don't use VPN for security

1. As it was [said](https://gist.github.com/joepie91/5a9909939e6ce7d09e29) multiple times - VPN can protect from some vectors, but, most likely, you making things worse by letting someone to monitor your activity or perform direct connections to your devices on opened ports;

## :: Web application instead of installed

1. Using web application instead of installed app can reduce attack surface;

{{< figure src="/images/security-attack-surface-telegram/3.png" position="center" >}}

## :: Ending :: Conclusion ::

Just go outside to the forest (or Park or etc) and breathe in with some fresh air.
When you walk through trees, think about the worst-case scenario.

For my opinion, if you have found yourself as a person who need to know about information security to protect your physical life - it is something terribly wrong is going on (unless you are a spy :) ).
May be the problem can be solved using different method, not using information security best practices, by relocation to another country.

{{< figure src="/images/security-attack-surface-telegram/t.png" position="center" >}}


One more thing... To protect the information, when you don't have enough resources, there are two more ways:

1. Destroy it and never tell anyone(if this is available);
2. Make it public;

Just remove yourself from the equation;
Before you do anything - think about the consequences twice.

{{< figure src="/images/security-attack-surface-telegram/cat.png" position="center" >}}

Thank you for reading. Have a nice day ^__^
