---
title: "Hard disk drive firmware upgrade using hdparm"
date: 2015-09-25T14:00:00+03:00
type: post
toc: false
categories: ["practice"]
tags: ["hardware","firmware","HDD", "update"]
---

How to update hard disk firmware using hdparm;

<!--more-->

## Intro

There are not so many ways how to update firmware on a hard disk drive using Free Software / Open Source solutions.


Because of the proprietary nature of hard disk drives development (not only firmware) vendors usually just put some proprietary blob into Windows executable file or create a bootable ISO or USB flash image with FreeDOS and some binaries that will autostart after you create this bootable device and boot from it.
From this image, you usually can extract firmware files themselves.

There is also an alternative way with [hdparm](http://sourceforge.net/projects/hdparm/).

In my case, these were files with LOD extension but it's can be any type in another case.

1. Extracting firmware from ISO or from USB image;
2. Using hdparm flash this image to your device;

## Action

| WARNING |
|---|
| This action is potentially very destructive. Don't do it on an important live hard disk! |

```
hdparm --yes-i-know-what-i-am-doing --please-destroy-my-drive --fwdownload ../GRCC4H6H.LOD /dev/sdb
```

Done ok.

The only thing - it was required to reboot the disk controller to make it work again after the flashing was done.

## Diffs of hdparm before and after

```
$ cat diffs_hdparms 
--- hdparm_before	2015-09-25 03:38:58.984526236 +0300
+++ hdparm_after 	2015-09-25 03:42:32.228525461 +0300
@@ -4,7 +4,7 @@
 ATA device, with non-removable media
 	Model Number:       ST3000DM001-9YN166                      
 	Serial Number:      nnnnnnnn
-	Firmware Revision:  CC4B    
+	Firmware Revision:  CC4H    
 	Transport:          Serial, SATA Rev 3.0
 Standards:
 	Used: unknown (minor revision code 0x0029)
```



