#!/bin/bash

gzip -c < ../edk2/Build/Lumia650-ARM/DEBUG_GCC5/FV/MSM8909_EFI.fd >./ImageResources/uefi.img
cat ./ImageResources/huawei-y560.dtb >>./ImageResources/uefi.img