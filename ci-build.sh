#!/bin/bash
curdir="$PWD"
git clone https://github.com/Tianocore/edk2.git -b stable/202011 --depth=1 --recursive ../edk2
export PACKAGES_PATH=$PWD/../edk2:$PWD/../:$PWD
export WORKSPACE=$PWD/workspace
cd ../edk2
make -C BaseTools/
. edksetup.sh
cd ..
GCC5_ARM_PREFIX=arm-linux-gnueabihf- build -a ARM -p ../Lumia650Pkg/Lumia650.dsc -t GCC5 -j$(nproc) -s -n 0
cd $curdir
gzip -c < workspace/Build/Lumia650-ARM/DEBUG_GCC5/FV/MSM8909_EFI.fd >MSM8909_UEFI.fd.gz
skales-mkbootimg --kernel MSM8909_UEFI.fd.gz --dt ImageResources/huawei-y560.dtb --ramdisk ImageResources/empty --base 0x80000000 --pagesize 2048 --cmdline "androidboot.hardware=qcom msm_rtb.filter=0x3F ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 earlyprintk androidboot.selinux=permissive" --output ImageResources/uefi.img
