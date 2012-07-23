#!/bin/bash

BINDIR=./out/AOSP/bin

NOSU=$1

if [ "$NOSU" = "nosu" ]; then
#  adb push $BINDIR/boot.img /tmp/boot.img
  adb push $BINDIR/boot.img /data/local/tmp/boot.img
#  adb shell "cat /tmp/boot.img > /dev/block/platform/msm_sdcc.1/by-name/boot"
  adb shell "cat /data/local/tmp/boot.img > /dev/block/platform/msm_sdcc.1/by-name/boot"
  adb shell "rm /tmp/boot.img"
  adb shell "sync;sync;sync;sleep 2; reboot"
else
  adb push $BINDIR/boot.img /data/local/tmp/boot.img
  adb shell su -c "cat /data/local/tmp/boot.img > /dev/block/platform/msm_sdcc.1/by-name/boot"
  adb shell su -c "rm /data/local/tmp/boot.img"
  adb shell su -c "sync;sync;sync;sleep 2; reboot"
fi
