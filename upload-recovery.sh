#!/bin/bash

adb push ./out/bin/recovery.img /data/local/tmp/recovery.img
adb shell su -c "cat /data/local/tmp/recovery.img > /dev/block/platform/msm_sdcc.1/by-name/recovery"
adb shell su -c "rm /data/local/tmp/recovery.img"
adb shell su -c "sync;sync;sync;sleep 2; reboot"
