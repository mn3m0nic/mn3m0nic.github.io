---
title: "Coreboot practical usage lesson 01 [RUS]"
type: post
tags: [ "coreboot", "bios", "linux" ]
tags_weight: 22
categories: ["practice"]
categories_weight: 44
date: 2015-06-26T13:00:00+03:00
---

Testing Coreboot on Thinkpad x201 practical task.

Language: Russian

<!--more-->

| ! WARNING ! |
| ------ |
| * Данная информация была опубликована в Jun/2015 и скорее всего устарела. <br>* На данный момент я только сконвертировал формат и внёс несколько мелких изменений. <br>* Планируется выпуск продолжения с учётом новой информации. Напишите в комментариях если тема Вам интересна что бы ускорить процесс подготовки второй части.<br>* Прошу обратить внимание: автор не несёт ответственности за порчу оборудования и не даёт гарантий работособоности system firmware на вашем оборудовании.<br>* Если вы нашли ошибку или неточность - напишите мне об этом, если не трудно. |


### План

План выступления:

1.  why
2.  internals
3.  howto
4.  demo

### Coreboot – Зачем?

Для чего человеку в 201x году думать о system firmware (System BIOS):\

1.  баги на уровне firmware;
2.  желание расширить возможности firmware;
3.  желание иметь свободную firmware;
4.  security;

![](/images/coreboot-practical-1/bios-bug-0.png)

![](/images/coreboot-practical-1/bios-bug-1.png)


### Coreboot – Зачем?

Что должен сделать System BIOS:

-   инициализировать аппаратное обеспечение;
-   инициализировать нормальную работу SMM и ACPI;
-   предоставить базовые функции для Legacy OS;
-   загрузить ~~ROMBASIC~~ ОС;
-   иногда - предоставить функции собственной ОС UEFI;
-   иногда - предоставить идентификационные данные для некоторых ОС (OEM);
-   иногда - предоставить функции восстановления себя и/или предустановленной ОС;


### Coreboot – Зачем? Сравнение основных BIOS’ов

Основные представители System BIOS для x86:

|  | PC BIOS (legacy)  | (U)EFI | Coreboot/LibreBoot |
|----|------------------|---------|--------------------|
| language | Assembly   |  many | 96% ANSI C, 1% asm - rest shell |
| mode | real  | protected    | protected |
| license | Proprietary | Open partially | GPL |

### Coreboot – Зачем? - Сложность темы:

-   нет подстраховки (no one will catch your exceptions)
-   множество аппаратно-зависимой vendor specific информации\
-   программирование без RAM;
-   программирование без стека;
-   ассемблер, ANSI C;
-   real mode programming;
-   тестирование;


### Coreboot – Зачем? - Некоторые security векторы:

-   System BIOS имеет неограниченный доступ к hardware; 
-   при cold reboot RAM не очищается;
-   код обработчика SMM выплняется на уровне > ядра ОС и НЕ является частью ОС;
-   в env ОС UEFI можно записать из user space;
-   GPU умеет ходить в RAM в обход CPU через DMA;
-   [BadBios](https://www.schneier.com/blog/archives/2013/11/badbios.html)

ADDED 2017/Nov: 

* [Уязвимость в UEFI-прошивках, позволяющая выполнить код в режиме SMM](https://www.opennet.ru/opennews/art.shtml?num=44740)
* [TinkPwn Git repo](https://github.com/Cr4sh/ThinkPwn)
* [Geektimes - bloatware оказалось встроенным в BIOS ноутбуков компани Lenovo](https://geektimes.ru/post/260228/)
* [Wikipedia - known vulnerabilities and Exploits of IntelME](https://en.wikipedia.org/wiki/Intel_Active_Management_Technology#Known_vulnerabilities_and_exploits)

### Coreboot – Зачем?

Решение некоторых секурити проблем:

-   ~~использовать бумагу и печатную машинку, а всю компьютерную технику сжечь~~ 
-   Использовать Свободную firmware;
-   Разрабатывать свободные альтернативы проприетарного
    инициализирующего кода и проприетарных драйверов
-   Развивать идею Secure Linux Boot

### Coreboot – internals

Первые шаги загрузки Coreboot(LINUXBIOS) v0.01 (1999)

1.  перейти в protected mode
2.  скопировать initramfs с GNU/Linux в RAM
3.  jump

### Coreboot – internals

Первые шаги загрузки Coreboot(LINUXBIOS) v0.01 (1999)

![image](/images/coreboot-practical-1/linuxbios1.png)

### Coreboot – internals

Первые шаги загрузки Coreboot(LINUXBIOS) v0.01 (1999)

Плюсы:

-   Busybox with BASH shell in BIOS
-   Protected mode “из коробки”
-   Native Linux file systems support
-   Меньше задач на Coreboot, больше на Linux
-   Меньше задач - меньше кода
-   Меньше кода - меньше багов

### Coreboot – internals

Первые шаги загрузки Coreboot(LINUXBIOS) v0.01 (1999)

Минусы:

-   не работает на “современном” железе из-за Vendor specific условий инициализации RAM, South Bridge
-   не работают PCI устройства из-за необходимости их дополнительно инициализировать

### Coreboot – internals

“Современный” вариант загрузки Coreboot(LINUXBIOS) v3 и v4 для Intel архитектуры x86

1.  переход в Protected Mode
2.  mainboard init 1 (FPU enable, SSE enable, Cache as RAM)
3.  mainboard init 2 (Vendor Specific code, Southbridge, init RAM (ROM stage)
4.  copy decompressed Coreboot in RAM
5.  jump to RAM entry point (start RAM stage)
6.  Initialize console, enumerate devices, ACPI Table, SMM handler (RAM stage)
7.  jump to payload entry

Кратко:

![image](/images/coreboot-practical-1/coreboot-sh1.png)

Исходя из чего, нужно понять, что Coreboot != BIOS/UEFI. 
Он предназначен для загрузки Payload (полезной нагрузки), 
где и будет происходить основная активность (загрузка ОС,
сама ОС и т.д.)


### Coreboot – internals - Payloads

Payloads:

1.  [SeaBIOS](https://www.coreboot.org/SeaBIOS) (old name - ADLO);
2.  [OpenBIOS](https://openbios.info/Welcome_to_OpenBIOS);
3.  OpenFirmware;
4.  GRUB2, FILO;
5.  TianoCore (UEFI);
6.  Etherboot / GPXE / iPXE;
7.  OS as payload: Linux, NetBSD, PLAN9;
8.  Depthcharge, Uboot, Explorer (Chromebooks payloads);
9.  Games: Tint, Invaders;
10. Tests and info: Memtest86, Memtest86+, CoreInfo, nvramcui;
11. Bayou (load menu for multiple payloads);
12. Libpayload;


### Coreboot – internals - example of "Hello world" payload

Own Payload with libpayload:

```c
#include <libpayload.h>

int main(void)
{
    printf("Hello, world!\n");
    halt();
    return 0;
}
        
```


### Coreboot – internals - history

История проекта CoreBoot:\
![image](/images/coreboot-practical-1/coresystems.png)

1.  существует с 1999 года как свободная GPLv2 firmware для кластерных решений (LINUXBIOS);
2.  95,7% - ANSI C, 1,4% - Assembly, rest - C++, Perl, Shell, text files
3.  May/2015 219 new commits per 30 days (7.3 commits/day, 1 commit every 197 mins)
4.  с 2008 называется CoreBoot т.к. может загружать не только Linux, но и BSD и PLAN9
5.  с 2010 разрабатывается для Google для Chrome буков под x86 
6.  http://coreboot.org

### Coreboot – internals - supported hardware

Заявленное поддерживаемое оборудование в CoreBoot v4 на May/2015:

1.  x86, x86\_64, ARM, ARM64, MIPS
2.  61 desktop MB
3.  39 server MB
4.  30 laptop MB (and some Apple)
5.  33 embedded boards
6.  17 Mini-ITX / Micro-ITX / Nano-ITX
7.  7 Set-top-boxes / Thin clients
8.  QEMU
9.  + more

### Coreboot – HowTO - before start

Будет не лишним напомнить:
Автор не несёт ответственности за возможные повреждения оборудования,
упущенную выгоду, ~~разрушенную психику~~ и отсутствие удачи в столь
нелёгком деле;

 ![image](/images/coreboot-practical-1/brick.png)


### Coreboot – HowTO

Что потребуется для установки CoreBoot?

1.  ~~удача~~ найти MB в списке поддерживаемого оборудования;
2.  обновить оригинальный проприетарный BIOS до последней версии;
3.  ROM datasheet и руководство по разборке устройства;
4.  программный программатор - flashrom (иногда работает);
5.  аппаратный программатор (когда не работает программный);
6.  паяльная станция (когда аппаратный нельзя подключить через ISP);
7.  документации по offset для модулей в оригинальном проприетарном BIOS/UEFI;
8.  git, GCC, binutils + некоторые other dependencies;
9.  CoreBoot source code;

### Coreboot – HowTO

Общий алгоритм для установки CoreBoot на устройство:

1.  Прочитать из ПЗУ оригинальный проприетарный System BIOS;
2.  Извлечь жизненно необходимые модули для которых нет свободной замены;
3.  Собрать Coreboot с модулями;
4.  Записать build/coreboot.rom в ПЗУ;

### Coreboot – HowTO

Thinkpad x201 - Разборка и локализация ПЗУ

![image](/images/coreboot-practical-1/thin_diss1.png)

### Coreboot – HowTO

Thinkpad x201 - Разборка и локализация ПЗУ

![image](/images/coreboot-practical-1/thin_diss2.png)

### Coreboot – HowTO

Thinkpad x201 - Разборка и локализация ПЗУ\
MX25L6445E 

![image](/images/coreboot-practical-1/locate_chip.png)


### Coreboot – HowTO

магия извлечения ME.bin и descriptor.bin для Thinkpad x201:\

```bash
dd if=flash.bin of=descriptor.bin count=12288 bs=1M\ 
 iflag=count_bytes
dd if=flash.bin of=me.bin skip=12288 count=5230592\
 bs=1M iflag=count_bytes,skip_bytes
cat /proc/iomem | grep 'Video ROM' | (read m; \ 
m=${m/ :*}; s=${m/-*}; e=${m/*-}; dd if=/dev/mem\
of=vgabios.bin bs=1c skip=$[0x$s] \
count=$[$[0x$e]-$[0x$s]+1]
```


### Coreboot – HowTO

Собираем Coreboot для Thinkpad x201:
важные параметры сборки

```
make menuconfig
```

1.  MX25L6445E
2.  LENOVO x201
3.  ME.bin
4.  descriptor.bin
5.  videorom.bin


### Coreboot – HowTO

```
make
```

![image](/images/coreboot-practical-1/make.png)


### Coreboot – HowTO

Подключение программатора к ПЗУ ноутбка:

![image](/images/coreboot-practical-1/flashing.png)


### Coreboot – HowTO - write in ROM

Запись в ПЗУ:

![image](/images/coreboot-practical-1/write.png)


### Coreboot – demo

![image](/images/coreboot-practical-1/demo.jpg)


### Video

{{< youtube 93ABZhamtQM >}}

### P.S.: REMARKS (исправления)

* 23:43 - "есть ещё один проект который не работает (...) LibreBoot" 

-- Конечно же, LibreBoot, в целом, **работает**, как проект, но тут имеелось в виду, что он не применим конкретно с моим ноутбуком и с железом от Intel over 2010, работающим с использованием IntelME в новых её версиях;
Это важно отметить т.к. есть много другого более старого железа - где [LibreBoot](https://libreboot.org/docs/hardware/#ec-update-on-i945-x60-t60-and-gm45-x200-t400-t500-r400-w500) успешно работает;
-- Так же разработчики LibreBoot [заявляют](https://libreboot.org/docs/), что они не форк CoreBoot "Libreboot is not a fork of coreboot", но судя по ссылкам и документации, а так же коду - проект является форком, хотя настаивать на такой позции я не буду;

* 29:54 - "OLPC - да это LibreBoot (...)"
-- Тут я несу чушь. :( Судя по их [wiki about build](http://wiki.laptop.org/go/Firmware/Building) OLPC firmware к LibreBoot не имеет никакого отношения;

### P.S.: Links (дополнительные ссылки)

* [Hackaday - neutralizing intelME](https://hackaday.com/2016/11/28/neutralizing-intels-management-engine/)
* [SecurityLab - Боремся с дистанционным контролем: как отключить Intel ME](http://www.securitylab.ru/analytics/482547.php?R=1)


### Files

* [Files for x201](https://github.com/mn3m0nic/ffts/tree/master/coreboot/thinkpad/x201)
