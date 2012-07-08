#!/bin/bash

KERNEL_DIR=$PWD

RAMDISK_NAME=sc06d_boot_ramdisk

if [ -z ../$RAMDISK_NAME ]; then
  echo "error: $RAMDISK_NAME directory not found"
  exit -1
fi

cd ../$RAMDISK_NAME
if [ ! -n "`git status | grep clean`" ]; then
  echo "error: $RAMDISK_NAME is not clean"
  exit -1
fi
#git checkout ics
cd $KERNEL_DIR

read -p "select build type? [(r)elease/(n)ightly] " BUILD_TYPE
if [ "$BUILD_TYPE" = 'release' -o "$BUILD_TYPE" = 'r' ]; then
  export RELEASE_BUILD=y
else
  unset RELEASE_BUILD
fi

# create release dir＿
RELEASE_DIR=../release/`date +%Y%m%d`
mkdir -p $RELEASE_DIR

# build for boot.img
bash ./build-bootimg.sh a $1
if [ $? != 0 ]; then
  echo 'error: boot.img build fail'
  exit -1
fi
mkdir $RELEASE_DIR
cp -v ./out/bin/* $RELEASE_DIR/
