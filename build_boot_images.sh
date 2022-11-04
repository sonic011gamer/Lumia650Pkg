#!/bin/bash

gzip -c < ../edk2/Build/Lumia650-ARM/DEBUG_GCC5/FV/MSM8909_EFI.fd >MSM8909_UEFI.fd.gz
skales-mkbootimg --kernel MSM8909_UEFI.fd.gz --dt ImageResources/huawei-y560.dtb --ramdisk ImageResources/empty --base 0x80000000 --pagesize 2048 --cmdline "androidboot.hardware=qcom msm_rtb.filter=0x3F ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 earlyprintk androidboot.selinux=permissive" --output ./ImageResources/uefi.img