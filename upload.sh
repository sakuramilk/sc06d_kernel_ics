#!/bin/bash

adb push ./out/bin/boot.img /data/local/tmp/boot.img
adb shell su -c "cat /data/local/tmp/boot.img > /dev/block/platform/msm_sdcc.1/by-name/boot"
adb shell su -c "rm /data/local/tmp/boot.img"
adb shell su -c "sync;sync;sync;sleep 2; reboot"

