#!/bin/bash

INITRAMFS_SRC_DIR=../sc06d_boot_ramdisk

if [ ! -e ./release-tools/bmp2splash/bmp2splash ]; then
    echo "make bmp2splash..."
    make -C ./release-tools/bmp2splash
fi

echo "generate splash image from $1..."
./release-tools/bmp2splash/bmp2splash $1 > $INITRAMFS_SRC_DIR/initlogo.rle
if [ $? != 0 ]; then
   exit -1
fi
