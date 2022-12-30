## @file
#
#  Copyright (c) 2011-2015, ARM Limited. All rights reserved.
#  Copyright (c) 2014, Linaro Limited. All rights reserved.
#  Copyright (c) 2015 - 2016, Intel Corporation. All rights reserved.
#  Copyright (c) 2018, Bingxing Wang. All rights reserved.
#
#  SPDX-License-Identifier: BSD-2-Clause-Patent
#
##

################################################################################
#
# Defines Section - statements that will be processed to create a Makefile.
#
################################################################################
[Defines]
  PLATFORM_NAME                  = Lumia650
  PLATFORM_GUID                  = b6325ac2-9f3f-4b1d-b129-ac7b35ddde60
  PLATFORM_VERSION               = 0.1
  DSC_SPECIFICATION              = 0x00010005
  OUTPUT_DIRECTORY               = Build/Lumia650-$(ARCH)
  SUPPORTED_ARCHITECTURES        = ARM
  BUILD_TARGETS                  = DEBUG|RELEASE
  SKUID_IDENTIFIER               = DEFAULT
  FLASH_DEFINITION               = Lumia650Pkg/Lumia650.fdf
  SECURE_BOOT_ENABLE             = TRUE
  USE_PHYSICAL_TIMER             = TRUE
  USE_SCREEN_FOR_SERIAL_OUTPUT   = 0
  USE_MEMORY_FOR_SERIAL_OUTPUT   = 0
  SEND_HEARTBEAT_TO_SERIAL       = 0

[BuildOptions.common]
  GCC:*_*_ARM_CC_FLAGS = -DSILICON_PLATFORM=8909

[PcdsFixedAtBuild.common]
  # Platform-specific
  gArmTokenSpaceGuid.PcdSystemMemorySize|0x40000000        # 1GB Size

  # SMBIOS
  gLumiaFamilyPkgTokenSpaceGuid.PcdSmbiosSystemModel|"Lumia 650"
  gLumiaFamilyPkgTokenSpaceGuid.PcdSmbiosSystemRetailModel|"RM-1152"
  gLumiaFamilyPkgTokenSpaceGuid.PcdSmbiosSystemRetailSku|"RM-1152"
  gLumiaFamilyPkgTokenSpaceGuid.PcdSmbiosBoardModel|"Lumia 650"

  # Simple FrameBuffer
  gLumiaFamilyPkgTokenSpaceGuid.PcdMipiFrameBufferWidth|720
  gLumiaFamilyPkgTokenSpaceGuid.PcdMipiFrameBufferHeight|1280
  gLumiaFamilyPkgTokenSpaceGuid.PcdMipiFrameBufferPixelBpp|32

  gQcomPkgTokenSpaceGuid.SynapticsXMax|720
  gQcomPkgTokenSpaceGuid.SynapticsYMax|1280

[PcdsDynamicDefault.common]
  gEfiMdeModulePkgTokenSpaceGuid.PcdVideoHorizontalResolution|720
  gEfiMdeModulePkgTokenSpaceGuid.PcdVideoVerticalResolution|1280
  gEfiMdeModulePkgTokenSpaceGuid.PcdSetupVideoHorizontalResolution|720
  gEfiMdeModulePkgTokenSpaceGuid.PcdSetupVideoVerticalResolution|1280
  gEfiMdeModulePkgTokenSpaceGuid.PcdSetupConOutRow|160
  gEfiMdeModulePkgTokenSpaceGuid.PcdSetupConOutColumn|36

!include QcomPkg/QcomPkg.dsc.inc
!include LumiaFamilyPkg/LumiaFamily.dsc.inc
!include LumiaFamilyPkg/Frontpage.dsc.inc