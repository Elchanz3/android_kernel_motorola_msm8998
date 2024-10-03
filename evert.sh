#!/bin/bash

export PLATFORM_VERSION=14
export ANDROID_MAJOR_VERSION=u
export ARCH=arm64
export SEC_BUILD_CONF_VENDOR_BUILD_OS=14
export CDIR="$(pwd)"
export AK3="$PWD/AnyKernel3"
export CLANG_DIR=$PWD/toolchain/neutron_19
export CCACHE=ccache

# PNY version
export EXTRA=-v0.1-clang-19

mkdir builds-evert

# Check if toolchain exists
if [ ! -f "$CLANG_DIR/bin/clang-19" ]; then
    echo "-----------------------------------------------"
    echo "Toolchain not found! Downloading..."
    echo "-----------------------------------------------"
    rm -rf $CLANG_DIR
    mkdir -p $CLANG_DIR
    pushd toolchain/neutron_19 > /dev/null
    bash <(curl -s "https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman") -S=latest
    echo "-----------------------------------------------"
    echo "Patching toolchain..."
    echo "-----------------------------------------------"
    bash <(curl -s "https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman") --patch=glibc
    echo "-----------------------------------------------"
    echo "Cleaning up..."
    popd > /dev/null
fi

# Install some dependencies to compile kernel (ubuntu 24.10)

sudo apt update
sudo apt install build-essential libncurses-dev bison flex libssl-dev bc fakeroot cpio xz-utils git kmod clang gcc-aarch64-linux-gnu zip -y

MAKE_ARGS="
LLVM=1 \
LLVM_IAS=1 \
ARCH=arm64 \
CCACHE=$CCACHE \
O=out
"

export OUT_DIR="$PWD/out"

DATE_START=$(date +"%s")

make ${MAKE_ARGS} PNY_evert_defconfig

make ${MAKE_ARGS} -j$CORES || abort

IMAGE="$OUT_DIR/arch/arm64/boot/Image.gz-dtb"

if [[ -f "$IMAGE" ]]; then
    KERNELZIP="PNY_Kernel.zip"

    cp "$OUT_DIR"/arch/arm64/boot/Image.gz-dtb "$AK3"/Image.gz-dtb
    # Create the AnyKernel package
    (cd "AnyKernel3" && zip -r9 "$KERNELZIP" .) || error_exit "Error creating the AnyKernel package"

    mv "$KERNELZIP" "$CDIR"/builds-evert/PNY.zip

fi

    DATE_END=$(date +"%s")
    DIFF=$(($DATE_END - $DATE_START))

    echo -e "\nCompilation completed successfully. Elapsed time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.\n"
