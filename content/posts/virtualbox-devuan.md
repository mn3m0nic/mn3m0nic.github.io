---
title: "fix Virtualbox on Devuan ASCII"
date: 2018-04-23T10:00:00+03:00
type: post
comments: true
categories: ["practice"]
tags: ["devuan", "virtualbox", "patch"]
---

### When this patch is required

* When you are using GNU/Linux Devuan v 2 (ASCII), latest (for 2018-04-23) OS provided kernel 4.15.0-0.bpo.2-amd64 and Virtualbox 5.1 (which was latest for ASCII available from devuan repo at moment when this was written)

### Why this patch is required

* Because some of Linux kernel function names changed and DKMS vboxdrv rebuild step, which compile new kernel module for VirtualBox, will permanentny fail with compile errors;

### What you will see without patch

* VirtualBox will fail to start as there are no kernel module;
* VirtualBox kernel module will fail to compile;

```
STDERR: The provider 'virtualbox' that was requested to back the machine
'default' is reporting that it isn't usable on this system. The
reason is shown below:

VirtualBox is complaining that the installation is incomplete. Please
run `VBoxManage --version` to see the error message which should contain
instructions on how to fix this error.
`
```

### Check all vboxdrv modules

```
find /lib/modules/* -name 'vboxdrv*'
```


### Possible workarounds:

* Install VirtualBox 5.2 or later from non OS distro source, but from [official site](https://www.virtualbox.org/wiki/Linux_Downloads);

### Source of patch

* https://www.virtualbox.org/pipermail/vbox-dev/2017-December/014885.html
* https://www.virtualbox.org/pipermail/vbox-dev/attachments/20171202/8606bf99/attachment.bin

### Appling patch

```
D=virtualbox51-dev-test1
mkdir $D
cd $D
apt-get install linux-headers-$(uname -r)
apt-get source virtualbox
#sudo apt-get build-dep virtualbox
cd virtualbox*
wget -O debian/patches/38-4.15.patch http://www.virtualbox.org/pipermail/vbox-dev/attachments/20171202/8606bf99/attachment.bin
echo "38-4.15.patch" >> debian/patches/series
#Build
dpkg-buildpackage -us -uc -d
cd ..
ls -1 *.deb
#Install:
dpkg -i *.deb
```

### Rebuild vboxdrv kernel module

```
##Install headers if they are not installed yet
#apt-get install linux-headers-$(uname -r)
/etc/init.d/vboxdrv setup
##OR 
#dpkg-reconfigure virtualbox-dkms
```

### Testing

```
$ VBoxManage --version
5.1.30_Devuanr118389
$ uname -r
4.15.0-0.bpo.2-amd64
```

