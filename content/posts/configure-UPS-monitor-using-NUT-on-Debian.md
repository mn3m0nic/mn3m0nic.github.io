---
title: "Configure UPS monitor using NUT on Debian"
date: 2017-11-16T13:23:54+03:00
draft: false
type: post
toc: false
categories: ["practice"]
tags: ["bash","GNU/Linux","hardware","UPS"]
---

Quick steps to configure UPS on Debian 8 (jessie).

<!--more-->

### Connect UPS to Server

1. Recommended shutdown server and disable power before connect if it's RS-232(COM port);
2. Check correct device path from "dmesg" output;

### Install

1. Required to install nut-client, nut-server
2. For collecting data into RRD database we also need to install Collectd with [NUT plugin](https://collectd.org/wiki/index.php/Plugin:NUT);

```bash
sudo -i
aptitude update; aptitude install nut-client nut-server collectd
```

```bash
dpkg -l | egrep "nut-|collectd" | awk '{ if ($1=="ii"); print $3"\t"$2}' 
5.4.1-6+deb8u1	collectd
5.4.1-6+deb8u1	collectd-core
5.4.1-6+deb8u1	collectd-utils
5.4.1-6+deb8u1	libcollectdclient1
2.7.2-4	nut-client
2.7.2-4	nut-server
```

## Configure

Configure NUT server - first.
If it will not work anything else - is not important :)
Check your serial port path and replace /dev/ttyS0 if it's different.

```bash
cat >> /etc/nut/ups.conf << EOF
[ups]

        driver = blazer_ser
        port = /dev/ttyS0
        desc = "my server1 ups"
EOF
```
If you are using USB connection than change "driver" variable also with path.


## Testing 

Testing NUT-server by starting plugin binary manually:

```bash
root@server:~# /lib/nut/blazer_ser -a ups 
Network UPS Tools - Megatec/Q1 protocol serial driver 1.56 (2.7.2)
Duplicate driver instance detected! Terminating other driver!
Supported UPS detected with megatec protocol
Vendor information unavailable
No values provided for battery high/low voltages in ups.conf

Using 'guestimation' (low: 10.400000, high: 13.000000)!
Battery runtime will not be calculated (runtimecal not set)

```

Data returned OK.
If you see error with connection - check file /dev/ttyS0 permissions.

```
ls -lah /dev/ttyS0 
crw-rw---- 1 root nut 4, 64 Nov 16 14:43 /dev/ttyS0
```

If after all you still see error - try different port.


Configure UPSD with minimal options:

```bash
echo "LISTEN 127.0.0.1 3493" >> /etc/nut/upsd.conf
service ups-monitor restart
```

Check UPSD is listening local interface only and is up:

```bash
$ netstat -tnlp | grep ups
tcp        0      0 127.0.0.1:3493          0.0.0.0:*               LISTEN      4585/upsd
```

Configure NUT client:
```bash
echo "MODE=standalone" >>  /etc/nut/nut.conf 
```


## Testing 

Testing NUT-client connection to NUT-server

```bash
root@server:~# upsc ups
Init SSL without certificate database
battery.charge: 100
battery.voltage: 13.40
battery.voltage.high: 13.00
battery.voltage.low: 10.40
battery.voltage.nominal: 12.0
device.type: ups
driver.name: blazer_ser
driver.parameter.pollinterval: 2
driver.parameter.port: /dev/ttyS0
driver.version: 2.7.2
driver.version.internal: 1.56
input.current.nominal: 2.0
input.frequency: 49.9
input.frequency.nominal: 50
input.voltage: 222.3
input.voltage.fault: 221.8
input.voltage.nominal: 220
output.voltage: 222.3
ups.beeper.status: enabled
ups.delay.shutdown: 30
ups.delay.start: 180
ups.load: 22
ups.status: OL
ups.temperature: 25.0
ups.type: offline / line interactive
```


## Configure RRD database

Let's configure NUT plugin for collectd

```bash
cat >> /etc/collectd/collectd.conf.d/nut.conf << EOF
LoadPlugin nut
<Plugin nut>
        UPS "ups@localhost:3493"
</Plugin>
service collectd restart
```


Check new files created with RRD database data:

```bash
root@server:~# ls -1 /var/lib/collectd/rrd/server/nut-ups/
frequency-input.rrd
percent-charge.rrd
percent-load.rrd
temperature-ups.rrd
voltage-battery.rrd
voltage-input.rrd
voltage-output.rrd
```

Options about UPS actions can be checked here:
```bash
egrep -v "^#|^$" /etc/nut/upsmon.conf 
MINSUPPLIES 1
SHUTDOWNCMD "/sbin/shutdown -h +0"
POLLFREQ 5
POLLFREQALERT 5
HOSTSYNC 15
DEADTIME 15
POWERDOWNFLAG /etc/killpower
RBWARNTIME 43200
NOCOMMWARNTIME 300
FINALDELAY 5
```


Now we can open this database using GUI or via web-collectd Frontend:

![](/images/configure-UPS-monitor-using-NUT-on-Debian/charge.png)

![](/images/configure-UPS-monitor-using-NUT-on-Debian/frequency.png)

![](/images/configure-UPS-monitor-using-NUT-on-Debian/load.png)

![](/images/configure-UPS-monitor-using-NUT-on-Debian/voltage.png)


## Additional Links

* [Archwiki UPS APC](https://wiki.archlinux.org/index.php/APC_UPS)
* [NUT official site](http://networkupstools.org/index.html)
* [nut.conf details](http://networkupstools.org/docs/man/nut.conf.html)
* [ups.conf details](http://networkupstools.org/docs/man/ups.conf.html)
* [upsmon.conf details](http://networkupstools.org/docs/man/upsmon.conf.html)

