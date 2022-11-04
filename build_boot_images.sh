#!/bin/bash

cat ../edk2/Build/Lumia650-ARM/DEBUG_GCC5/FV/MSM8909_EFI.fd > ./ImageResources/bootpayload.bin
gzip -c < ./ImageResources/bootpayload.bin > ./ImageResources/bootpayload.bin.gz
cat ./ImageResources/bootpayload.bin.gz ./ImageResources/huawei-y560.dtb >> ./ImageResources/Image.gz-dtb
mkbootimg --kernel ./ImageResources/Image.gz-dtb --ramdisk ./ImageResources/dummykernel --base 0x80000000 --pagesize 2048 -o ./ImageResources/uefi.img
