#!/bin/bash
curdir="$PWD"
git clone https://github.com/Tianocore/edk2.git -b stable/202011 --depth=1 --recursive ../edk2
export PACKAGES_PATH=$PWD/../edk2:$PWD/../:$PWD
cd ../edk2
make -C BaseTools/
. edksetup.sh
cd ..
GCC5_ARM_PREFIX=arm-linux-gnueabihf- build -a ARM -p ../Lumia650Pkg/Lumia650.dsc -t GCC5 -j$(nproc) -s -n 0
cd $curdir
./build_boot_images.sh

