---
title: "PGP public key for email encryption"
type: page
draft: false
toc: false
comments: false
date: 2023-01-06T14:22:00+00:00
---

| WARNING |
|---|
| 1. I do *not* guarantee that I will read or respond if I don't know you in person. Otherwise, please get some patience. ⏳ |
| 2. Please read some real [guide](https://help.riseup.net/en/security/message-security/openpgp/best-practices) about PGP before using it. 🙏 |

## keys

🔐 [ed25519](https://mn3m.info/49702b12c12f3ce93d39c787e030ee4c6e36aa35.asc) or  🔐 [RSA](https://mn3m.info/91e33405bb010641e14dfa83155501b67bcdfaa9.asc) (pick one)

## Quick send using your non-Proton email client

TL;DR:

1. Boot any UNIX-like OS, run [Tails](https://tails.boum.org/install/download/index.en.html) or install [GnuPG](https://www.gnupg.org/download/)
2. Download and import my public key into your local keychain
3. Encrypt the message (as text) with the key you just get
4. Send output in your normal email client as plain text (no HTML)

Import key
```bash
K="49702b12c12f3ce93d39c787e030ee4c6e36aa35"
curl -s "https://mn3m.info/$K.asc" | gpg --import
cat << EOF | gpg --trust-model always -evar "$K"
```

Just type your message and end with EOF and press ENTER ⌨ 

```
> Hi there.
> This is my secret message
> EOF
```

Output sample:

```
-----BEGIN PGP MESSAGE-----
...some encrypted data is here...
-----END PGP MESSAGE-----
```

Send me this garbage. Or not. Just be calm. 🙃
