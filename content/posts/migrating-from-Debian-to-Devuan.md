---
title: "Migrating from Debian to Devuan"
date: 2017-11-23T17:51:18+03:00
type: post
toc: false
comments: true
categories:
- practice
tags:
- GNU/Linux
- Debian
- Devuan
- systemd
---

How to migrate from Debian to Devuan (fork with sysvinit as default init system and without systemd);

<!--more-->

# Intro

Init system is required to start your OS services in correct order. Due to long period of live UNIX-like systems and due to different tasks for each one [some number of different init systems](https://wiki.gentoo.org/wiki/Comparison_of_init_systems) have appeared. Some of them are very easy to use as end-user, due to lot's of automatic and complex logic. Some of them are very easy to maintain and troubleshoot because of [KISS principle](https://en.wikipedia.org/wiki/KISS_principle) and plain text nature of scripts that are running. Bad thing that very complicated to combine both factors in one init-system and make it reliable and predictable.

If everything work as expected you usually don't need to think about what init system you use, but when problems begins - you understand advantages and disadvantages one init system with compare to another.

Simple factor - possibility to fix your broken system without any access to the Internet - can be critical in some cases.

If you want to use power of GNU/Linux Debian, but don't want systemd as your init system - let's migrate to [Devuan](https://devuan.org/).

Freedom of choice is the best thing from [F/OSS](https://en.wikipedia.org/wiki/Free_and_open-source_software) world.

# First of all

![](/images/migrating-from-Debian-to-Devuan/nohate.jpg)

* I am not "systemd hater";
* I have no reason to blame Lennart Poettering personally not for issues Pulseaudio, not for issues with systemd or systemd itself;
* For my personal opinion, systemd can be good for special cases and in 5 years will be production ready and match for some cases for today, I think; 
* Sysvinit, OpenRC, Upstart, (...) aren't better in generic as init systems; They provide much different way of how init process goes;
* Whether we like or not - currently systemd is widely used on enterprise level and we have to learn how to use it and how it's works. 

This article is not about systemd, but about practice to migrate to Devuan;

# What's wrong with Systemd, for my opinion?

* Systemd have lot's of security bugs;

This one liner will freeze your system and you don't have to be root;

```
while true; do NOTIFY_SOCKET=/run/systemd/notify systemd-notify ""; done

```
(no matter that it can be fixed for now - there are ton's of them)

* Complexity of systemd can be compared with Linux kernel with exception drivers;
* Systemd is huge project;

![](/images/migrating-from-Debian-to-Devuan/systemd-and-linux.png)

* It keep growing and changing;
* Boot time speedup looks not very huge benefit for server or desktop
that's reboots only 3 times per year when security patches installing;
* For any other systemd cons - there are already existing tool that can 
be used if required;
* Nice image that's explains a lot about systemd from emotional point of view:

![](/images/migrating-from-Debian-to-Devuan/s.gif)

## Some other random known issues

* You will no be able to have a [separate /usr mount with systemd](https://freedesktop.org/wiki/Software/systemd/separate-usr-is-broken/);
* [Systemd terminates postgresql 90 sec after start](https://www.postgresql.org/message-id/20160909105014.20024.66435%40wrigleys.postgresql.org)
* [Systemd fallback to google 8.8.8.8 if no resolvers are configured](https://isc.sans.edu/forums/diary/Systemd+Could+Fallback+to+Google+DNS/22516/)
* [CVE2017-1000082 Systemd: if username starts from number it count it as root](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-1000082)
* [systemd shut down your network before it unnmounted remote filesystems](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=873613)
* [systemd-journalctl 100% cpu usage](https://github.com/systemd/systemd/issues/5820)
* upd: [CVE-2019-6454](https://access.redhat.com/security/cve/cve-2019-6454) Insufficient input validation in bus_process_object() resulting in PID 1 crash
( Check systemdsucks twitter for more )

From [eudev anounce](https://lwn.net/Articles/529314/):

```
(...)
If you want to understand the worst case scenario when dealing with
this regression, disable udev and reboot your system. You should have a
virtual terminal with no networking and no X. Should this happen with
systemd-udevd, then you would also have a hung systemd-udevd process
that you cannot kill. Attempts restart systemd-udevd should result in
more hung processes.
(..)
```

* [Mount efivarfs read-only #2402](https://github.com/systemd/systemd/issues/2402)
* [Broken by design: systemd](https://ewontfix.com/14/)


## Are there any modern OS without systemd?

Yes.

* https://sysdfree.wordpress.com/
* https://without-systemd.org/


So... Let's stop with theory let's move to Devuan.


## What will not work as I expect

* ~~Network-manager; (can be replaced with WICD)~~  (FIXED)
* ~~Systemd-Udev; (can be used original Debian or replaced to alternative)~~ UPDATED: replaced by EUDEV

### Before begin

* Create backup of live system;
* Get new version of official manual from [devuan.org](https://devuan.org) site;
* Devuan supports painless migration from Debian or fresh installation; If you have possibility better to choose fresh installation;


### Sources.list before begin

* Disable all other sources in your /etc/sources.list*/* for Debian;
* Devuan repository is not compatible with Debian;
* Enable or disable non-free contrib - as you like (here is enabled)
* Enable source lines if required;

### ASCII sources

for ASCII :
``` 
cat > /etc/apt/sources.d/devuan-ascii.list << EOF
deb     http://auto.mirror.devuan.org/merged ascii main non-free contrib
#deb-src http://auto.mirror.devuan.org/merged ascii main non-free contrib
deb     http://auto.mirror.devuan.org/merged ascii-updates main non-free contrib
#deb-src http://auto.mirror.devuan.org/merged ascii-updates main non-free contrib
deb     http://auto.mirror.devuan.org/merged ascii-proposed-updates main non-free contrib
#deb-src http://auto.mirror.devuan.org/merged ascii-proposed-updates main non-free contrib
deb     http://auto.mirror.devuan.org/merged ascii-security main non-free contrib
#deb-src http://auto.mirror.devuan.org/merged ascii-security main non-free contrib
deb     http://auto.mirror.devuan.org/merged ascii-backports main non-free contrib
#deb-src http://auto.mirror.devuan.org/merged ascii-backports main non-free contrib
EOF

```

### Jessie sources

```
cat > /etc/apt/sources.d/devuan-jessie.list << EOF
deb     http://auto.mirror.devuan.org/merged jessie main non-free contrib
#deb-src http://auto.mirror.devuan.org/merged jessie main non-free contrib
deb     http://auto.mirror.devuan.org/merged jessie-updates main non-free contrib
#deb-src http://auto.mirror.devuan.org/merged jessie-updates main non-free contrib
deb     http://auto.mirror.devuan.org/merged jessie-proposed-updates main non-free contrib
#deb-src http://auto.mirror.devuan.org/merged jessie-proposed-updates main non-free contrib
deb     http://auto.mirror.devuan.org/merged jessie-security main non-free contrib
#deb-src http://auto.mirror.devuan.org/merged jessie-security main non-free contrib
deb     http://auto.mirror.devuan.org/merged jessie-backports main non-free contrib
#deb-src http://auto.mirror.devuan.org/merged jessie-backports main non-free contrib
EOF
```


## Action !!!

```
apt-get update
apt-get install -y --force-yes devuan-keyring
apt-get update
apt-get install -y sysvinit sysvinit-core
apt-get remove --purge --auto-remove systemd
apt-get install -y base-files
apt-get -y dist-upgrade
apt-get -y autoremove --purge
apt-get -y autoclean
```


Additional steps:

```
echo -e '\n\nPackage: *systemd*\nPin: release *\nPin-Priority: -1' >> /etc/apt/preferences.d/systemd
```

## Issues detected:

### Network-manager - not usable without systemd (UPD: - FIXED)

* As expected Network Manager can't be installed due to dependency from systemd; 
To fix this you can install Wicd or configure network, wifi, 3G manually.

```
apt-get install wicd wicd-cli wicd-gtk
```

start:

```
root@host: service wicd start
^D
user@host: nohup wicd-gtk &
```

UPD: From 10/Jan/2018 - was tested - FIXED.


### Cryptdisks stop will hung when reboot/shutdown

To prevent issues with hunging cryptdisk you have to exclude pid of systemd-udev (if you use it) from termination list like this:

```
root@host# cat /usr/local/bin/reboot-1.sh
pgrep udev > /run/sendsigs.omit.d/udev
reboot
```
UPD: From 10/Jan/2018 - was tested - FIXED.


* No other issues were detected yet, but keep eyes on [Devuan bug tracker](https://devuan.org/os/issues)

Will continue testing. 


## URL's:

* [SystemD-biggest-fallacies](https://judecnelson.blogspot.com/2014/09/systemd-biggest-fallacies.html) and [Russian translation](https://www.opennet.ru/base/sys/systemd_myth.txt.html)
* [Upgrade to Devuan documentation](https://devuan.org/os/documentation/dev1fanboy/Upgrade-to-Devuan)
* [eudev - fork of udev-systemd announce](https://lwn.net/Articles/529314/)
* [eudev - fork of udev-systemd official site](https://wiki.gentoo.org/wiki/Eudev)
* [Twitter - systemdsucks (just for fun)](https://twitter.com/systemdsucks)

