#!/bin/bash

cat ./BootShim/BootShim.bin ../edk2/Build/Lumia650-ARM/DEBUG_GCC5/FV/MSM8909_EFI.fd ./ImageResources/dummykernel > ./ImageResources/bootpayload.bin

python3 ./ImageResources/mkbootimg.py \
  --kernel ./ImageResources/bootpayload.bin \
  --ramdisk ./ImageResources/dummykernel \
  -o ./ImageResources/uefi.img \
  --pagesize 2048 \
  --header_version 0 \
  --cmdline "" \
  --dtb ./ImageResources/huawei-y560.dtb \
  --base 0x0 \
  --os_version 7.1.1 \
  --os_patch_level 2022-10-02 \
