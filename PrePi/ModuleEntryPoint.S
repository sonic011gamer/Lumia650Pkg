#include <AsmMacroIoLib.h>
#include <Library/PcdLib.h>
#include <Chipset/ArmV7.h>

.text
.align 3

#define LoadConstantToReg(Data, Reg) \
    ldr Reg, =Data
    
GCC_ASM_IMPORT (ArmDeInitialize)
GCC_ASM_IMPORT (CEntryPoint)
GCC_ASM_EXPORT (_ModuleEntryPoint)
GCC_ASM_IMPORT (ArmEnableInstructionCache)
GCC_ASM_IMPORT (ArmEnableDataCache)
GCC_ASM_IMPORT (ArmInvalidateTlb)

.global _StackBase 
.global _StackSize

_StackBase:
  .quad FixedPcdGet32(PcdPrePiStackBase)

_StackSize:
  .quad FixedPcdGet32(PcdPrePiStackSize)

_ModuleEntryPoint:
  // check if we're located at expected location
  adr r4, .
  ldr r5, =FixedPcdGet64 (PcdUefiLocation)
  cmp r4, r5
  bne _CopyUEFI
  b _ContinueModuleEntryPoint

_CopyUEFI:
  // find our start address by getting our expected offset, then subtracting it from our actual address
  ldr r6,  =FixedPcdGet64 (PcdUefiLocation)
  sub r5, r5, r6 // r5 now holds offset of ArmPlatformPeiBootAction from start of FD base
  sub r4, r4, r5 // r4 now holds address of actual FD base

  // tweak the return address
  sub r14, r14, r4
  add r14, r14, r6
  ldr r5, =FixedPcdGet64 (PcdFdSize)

  // crap memcpy
_CopyLoop:
  ldr r3, [r4], #16       //Load FD Address into r3 probably with a 16bit offset?
  str r3, [r6], #16       //store into r3 the value from r6, memcpy most likely lol
  subs r5, r5, #16         //substract 16bits from r5?
  bne  _CopyLoop           

_ContinueModuleEntryPoint:

  /* World reset */
  bl ASM_PFX(ArmDeInitialize)

  /* Clear r0 for function calls below */
  mov r0, #0
  mov r1, #0

  bl ASM_PFX(ArmReadMpidr)
  mov r8, r0

  /* First ensure all interrupts are disabled */
  bl ASM_PFX(ArmDisableInterrupts)

  /* Ensure that the MMU and caches are off */
  bl ASM_PFX(ArmDisableCachesAndMmu)
 
  /* Invalide I-Cache */
  bl ASM_PFX(ArmInvalidateInstructionCache)
  
  /* Invalidate TLB */
  bl ASM_PFX(ArmInvalidateTlb)

_SetupExceptionVector:
  LoadConstantToReg (FixedPcdGet32(PcdCpuVectorBaseAddress), r0)
  ldr r1, dead
  mov r2, #0

_FillVectors:
  str     r1, [r0, r2]
  adds    r2, r2, #8      /* Fill every 8 byte */
  cmp     r2, #0x800      /* Vector Table Size */
  bne     _FillVectors
    
_SetupPrimaryCoreStack:
  ldr r0, _StackBase     /* Stack base arg0 */
  ldr r1, _StackSize     /* Stack size arg1 */
  
  add r4, r0, r1
  add sp, r4, #0

_EnableCache: 
  bl ArmInvalidateDataCache
  bl ASM_PFX(ArmEnableInstructionCache)
  bl ASM_PFX(ArmEnableDataCache) 

_PrepareArguments:
	ldr   r1, _StackBase
	ldr   r2, _StackSize

  bl CEntryPoint

_NeverReturn:
  b _NeverReturn

.align 3
dead:  
  b dead 


  