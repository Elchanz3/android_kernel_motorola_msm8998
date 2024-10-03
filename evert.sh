#!/bin/bash

export PLATFORM_VERSION=14
export ANDROID_MAJOR_VERSION=u
export ARCH=arm64
export SEC_BUILD_CONF_VENDOR_BUILD_OS=14
export CDIR="$(pwd)"
export AK3="/home/chanz22/Documentos/GitHub/android_kernel_motorola_msm8998/AnyKernel3"

# PNY version
export EXTRA=-v0.1-clang-18

mkdir builds-evert

export OUT_DIR="/home/chanz22/Documentos/GitHub/android_kernel_motorola_msm8998/out"

DATE_START=$(date +"%s")

make O=out PNY_evert_defconfig

make O=out -j8

IMAGE="$OUT_DIR/arch/arm64/boot/Image.gz-dtb"

if [[ -f "$IMAGE" ]]; then
    KERNELZIP="PNY_Kernel"

    cp "$OUT_DIR"/arch/arm64/boot/Image.gz-dtb "$AK3"/Image.gz-dtb
    # Create the AnyKernel package
    (cd "AnyKernel3" && zip -r9 "$KERNELZIP" .) || error_exit "Error creating the AnyKernel package"

    mv "$KERNELZIP" "$CDIR"/builds-evert/PNY.zip

fi

    DATE_END=$(date +"%s")
    DIFF=$(($DATE_END - $DATE_START))

    echo -e "\nCompilation completed successfully. Elapsed time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.\n"
