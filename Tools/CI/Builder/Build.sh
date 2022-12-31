#!/bin/bash
# Travis CI builder
#
# Copyright 2018, Bingxing Wang. <uefi-oss-projects@imbushuo.net>
# All rights reserved.
#

# Export AArch64 Tools prefix on CI
export GCC5_AARCH64_PREFIX=/opt/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-elf/bin/aarch64-elf-
export GCC5_ARM_PREFIX=arm-linux-gnueabihf-
# Export BUILDALL flags
export BUILDALL=1

# Go to EDK2 workspace
cd ..
cd edk2

# Start build
echo "Start build..."
. rundbbuild.sh --650 --development

# Check if we have both FD ready
if [ ! -f Build/Lumia650-ARM/DEBUG_GCC5/FV/MSM8909_EFI.fd ]; then
    echo "Unable to find build artifacts."
    exit 1
fi
