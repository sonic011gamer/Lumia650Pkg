#!/bin/bash

cat ./BootShim/BootShim.bin ../edk2/Build/Lumia650-ARM/DEBUG_GCC5/FV/MSM8909_EFI.fd ./ImageResources/dummykernel > ./ImageResources/bootpayload.bin
gzip -c < ./ImageResources/bootpayload.bin > ./ImageResources/bootpayload.bin.gz
cat ./ImageResources/bootpayload.bin.gz huawei-y560.dtb > ./ImageResources/uefi.img
