---
title: "[Linux] [BD-R] Wrong bytes per sector on a burned BD-R media"
date: 2024-01-29T00:56:00+03:00
draft: false
type: post
toc: false
categories: ["practice"]
tags: ["GNU/Linux","BD-R","UDF"]
---

Wrong bytes per sector on a burned BD-R media.

## When this issue happens

I made a stupid mistake to to put default 512 bytes per sector or wrong block size for UDF filesystem which I burned to Blue ray disk with physical block in 2048 bytes long.
It makes impossible to mount the partition as driver rely only on physical block size and just ignore bs=512.

TL;DR:

```
losetup -f /dev/sr0
mount /dev/loop0 -t udf /mnt/
```

<!--more-->

## How it looks


When you try to mount you receive an error "No partition found" as correction positioning to partition with wrong bytes per sector is not possible.

```
mount /dev/sr0 /mnt/cdrom

[] UDF-fs: warning (device sr0): udf_load_vrs: No anchor found
[] UDF-fs: Scanning with blocksize 2048 failed
[] UDF-fs: warning (device sr0): udf_load_vrs: No anchor found
[] UDF-fs: Scanning with blocksize 4096 failed
[] UDF-fs: warning (device sr0): udf_fill_super: No partition found (1)
```

Check info about UDF partition, here in Warning section you could see exact reason why it is happening.

```
~# udfinfo /dev/sr0
udfinfo: Warning: Disk logical sector size (2048) does not match UDF block size (512)
...
blocksize=512
...
```

One more way to check this, but using different tool:

```
~# blkid -p /dev/sr0 | tr ' ' '\n' | egrep 'BLOCK|TYPE'
BLOCK_SIZE="512"
TYPE="udf"
```

Playing with [mount options for UDF](https://docs.kernel.org/5.10/filesystems/udf.html) like bs=512 dosn't work as it is not supported in recent version of driver

It's just ignored. same mount -t udf -o novrs,bs=512 /dev/sr0 /mnt/cdrom/

```
## in some cases it may work to pass the block size
mount -t udf -o bs=512 /dev/sr0 /mnt
mount -t udf -o bs=1024 /dev/sr0 /mnt
mount -t udf -o bs=2048 /dev/sr0 /mnt
mount -t udf -o bs=4096 /dev/sr0 /mnt
```

Values except 2048 and 4096 were just ignored with "Bad block size".

```
[] UDF-fs: warning (device sr0): udf_load_vrs: Bad block size
[] UDF-fs: warning (device sr0): udf_load_vrs: Bad block size
```

{{< figure src="/images/meme-qw.jpg" position="center" >}}

## Fix

You can map your 2048 bytes per sector device to loop device with 512 bytes per sector.

```
losetup -f /dev/sr0 # fix 512-2048 mistake
```

Than you can work with new device /dev/loop0 as your BD-R device with 512 bytes per sector mapping (default).


```
##if encrypted
#cryptsetup luksOpen /dev/loop0 d1
mount -t udf -o ro/dev/loop0 /mnt/cdrom/
cd /mnt/cdrom/
/mnt/cdrom# ls -lah
total 94G
drwxr-xr-x 2 root root 1.7K Jan 28 00:48  .
drwxr-xr-x 6 root root 4.0K Jan 28 00:22  ..

(files exist there :)
```

{{< figure src="/images/meme-yes.jpg" position="center" >}}

I am happy I don't have to burn another 100GB BD-R for the same data.

To check bytes per sector size:

```
blockdev --getss /dev/sr0
2048
```
```
cat /sys/class/block/sr0/queue/physical_block_size
2048
```
Sometimes hdparm -I can be also used.

## More reading

- https://github.com/JElchison/format-udf/issues/13#issuecomment-302904564
- https://wiki.linuxquestions.org/wiki/Block_devices_and_block_sizes
- https://wiki.gentoo.org/wiki/CD/DVD/BD_Writing
- [UDF2.6](http://www.osta.org/specs/pdf/udf260.pdf)
- https://github.com/pali/udftools/issues/43 more about media types
