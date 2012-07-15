#!/bin/bash

#./_build.sh recovery $1

KERNEL_DIR=$PWD
BIN_DIR=out/bin
OBJ_DIR=out/obj

INITRAMFS_SRC_DIR=../sc06d_recovery_ramdisk
INITRAMFS_TMP_DIR=/tmp/sc06d_recovery_ramdisk
IMAGE_NAME=recovery

# generate LOCALVERSION
. mod_version
BUILD_LOCALVERSION=$BUILD_RECOVERYVERSION


echo "=====> copy initramfs"
if [ -d $INITRAMFS_TMP_DIR ]; then
  rm -rf $INITRAMFS_TMP_DIR  
fi
cp -a $INITRAMFS_SRC_DIR $(dirname $INITRAMFS_TMP_DIR)
rm -rf $INITRAMFS_TMP_DIR/.git
find $INITRAMFS_TMP_DIR -name .gitignore | xargs rm

# copy zImage
cp ./release-tools/stock-img/recovery.img-kernel.gz $BIN_DIR/kernel
echo "----- Making uncompressed $IMAGE_NAME ramdisk ------"
./release-tools/mkbootfs $INITRAMFS_TMP_DIR > $BIN_DIR/ramdisk-$IMAGE_NAME.cpio
echo "----- Making $IMAGE_NAME ramdisk ------"
./release-tools/minigzip < $BIN_DIR/ramdisk-$IMAGE_NAME.cpio > $BIN_DIR/ramdisk-$IMAGE_NAME.img
echo "----- Making $IMAGE_NAME image ------"
./release-tools/mkbootimg --cmdline "console=null androidboot.hardware=qcom user_debug=31" --kernel $BIN_DIR/kernel  --ramdisk $BIN_DIR/ramdisk-$IMAGE_NAME.img --base 0x80200000 --ramdiskaddr 0x81500000 --output $BIN_DIR/$IMAGE_NAME.img

# create odin image
cd $BIN_DIR
tar cf $BUILD_LOCALVERSION-$IMAGE_NAME-odin.tar $IMAGE_NAME.img
md5sum -t $BUILD_LOCALVERSION-$IMAGE_NAME-odin.tar >> $BUILD_LOCALVERSION-$IMAGE_NAME-odin.tar
mv $BUILD_LOCALVERSION-$IMAGE_NAME-odin.tar $BUILD_LOCALVERSION-$IMAGE_NAME-odin.tar.md5
echo "  $BIN_DIR/$BUILD_LOCALVERSION-$IMAGE_NAME-odin.tar.md5"

# create cwm image
if [ -d tmp ]; then
  rm -rf tmp
fi
mkdir -p ./tmp/META-INF/com/google/android
cp $IMAGE_NAME.img ./tmp/
cp $KERNEL_DIR/release-tools/update-binary ./tmp/META-INF/com/google/android/
sed -e "s/@VERSION/$BUILD_LOCALVERSION/g" $KERNEL_DIR/release-tools/updater-script-$IMAGE_NAME.sed > ./tmp/META-INF/com/google/android/updater-script
cd tmp && zip -rq ../cwm.zip ./* && cd ../
SIGNAPK_DIR=$KERNEL_DIR/release-tools/signapk
java -jar $SIGNAPK_DIR/signapk.jar $SIGNAPK_DIR/testkey.x509.pem $SIGNAPK_DIR/testkey.pk8 cwm.zip $BUILD_LOCALVERSION-$IMAGE_NAME-signed.zip
rm cwm.zip
rm -rf tmp
echo "  $BIN_DIR/$BUILD_LOCALVERSION-$IMAGE_NAME-signed.zip"

cd $KERNEL_DIR
echo ""
echo "=====> BUILD COMPLETE $BUILD_LOCALVERSION-$IMAGE_NAME"
exit 0
