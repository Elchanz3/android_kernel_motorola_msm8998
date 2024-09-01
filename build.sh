#!/bin/bash

clear

# Variables
DIR=`readlink -f .`;
PARENT_DIR=`readlink -f ${DIR}/..`;

DEFCONFIG_NAME=lineageos_evert_defconfig
CHIPSET_NAME=sdm630
VARIANT=evert
ARCH=arm64
VERSION=FireX_${VARIANT}_v0.1
LOG_FILE=compilation.log

echo "cleaning before start..."
rm -rf out
make mrproper
echo "done.."
mkdir out

BUILD_CROSS_COMPILE=/home/chanz22/tc/aarch64-linux-android-4.9-master/bin/aarch64-linux-android-
KERNEL_LLVM_BIN=/home/chanz22/tc/clang-5657785-9.0/bin/clang
CLANG_TRIPLE=aarch64-linux-gnu-

echo "starting compilation..."

DATE_START=$(date +"%s")

make O=out ARCH=arm64 CC=$KERNEL_LLVM_BIN $DEFCONFIG_NAME
make O=out ARCH=arm64 \
	CROSS_COMPILE=$BUILD_CROSS_COMPILE CC=$KERNEL_LLVM_BIN \
	CLANG_TRIPLE=$CLANG_TRIPLE -j12 2>&1 |tee ../$LOG_FILE

# remove a previous kernel image
rm $IMAGE &> /dev/null

IMAGE="out/arch/arm64/boot/Image.gz-dtb"
if [[ -f "$IMAGE" ]]; then
        KERNELZIP="$VERSION.zip"
	rm AnyKernel3/zImage > /dev/null 2>&1
	rm AnyKernel3/*.zip > /dev/null 2>&1
	mv $IMAGE AnyKernel3/Image.gz-dtb
	cd AnyKernel3
	zip -r9 $KERNELZIP .
	
	DATE_END=$(date +"%s")
	DIFF=$(($DATE_END - $DATE_START))

	echo -e "\nTime elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.\n"
fi
