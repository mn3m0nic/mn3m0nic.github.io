---
title: "Hello 3d printer"
date: 2020-03-18T01:11:01+03:00
draft: false
type: post
toc: false
comments: true
categories:
- practice
tags:
- cura
- gcode
- 3d-printer
- hardware
---

The first printed model on HIPS filament:

<!--more-->

## Hardware required

* [Creality Ender 3](https://www.creality3dofficial.com/) ~<200$
* Filament (any, but I got HIPS for now) ~35$ for 1kg
* Electricity

## All software required

* GNU/Linux;
* Slicer -> [Cura](https://ultimaker.com/software/ultimaker-cura) ([src](https://github.com/Ultimaker/Cura) [LGPLv3](https://github.com/Ultimaker/Cura/blob/master/LICENSE))

## Parameters

| Parameter | Value |
|----------|------|
| Filament | [HIPS](https://www.matterhackers.com/store/3d-printer-filament/hips-175mm-1kg) (High Impact Polystyrene) |
| Nuzzle | 0.4mm 240 C, first layer=260 |
| Plate | 100 C |
| Infill | 100% (default=20%) |
| Adhesion | YES |
| Weight | 5..8g |
| Filament cost 100% infill | 2,78m ~ 0.28$ |
| Filament cost 20% infill | 1,71m ~ 0.175$ |
| (1) Model | [original](https://www.thingiverse.com/thing:4073670) <br> copy: [star.stl.gz](/files/first-3d-printed/star.stl.gz) [star_tail.stl.gz](/files/first-3d-printed/star_tail.stl.gz)  |
| (2) Slices | [star.gcode.gz](/files/first-3d-printed/star.gcode.gz) |

## Progress

![](/images/first-3d-printed/process.gif)

## Result

2 hours 10 mins later (1 hour 12 mins for default 20% infill) ...

![](/images/first-3d-printed/1.png)

It's a bit overheat artefacts on the tail and star looks a bit dirty, but for the first print it looks OK. :)

