#include <AsmMacroIoLib.h>
#include <Library/PcdLib.h>
#include <Chipset/ArmV7.h>

#define LoadConstantToReg(Data, Reg) \
  ldr  Reg, =Data

.text
.align 3

GCC_ASM_IMPORT (CEntryPoint)
GCC_ASM_IMPORT (ArmWriteCpacr)
GCC_ASM_IMPORT (ArmEnableInstructionCache)
GCC_ASM_IMPORT (ArmEnableDataCache)
GCC_ASM_IMPORT (ArmInvalidateTlb)

GCC_ASM_EXPORT (_ModuleEntryPoint)

.global _StackBase 
.global _StackSize
.global _SecondaryCpuStackSize
.global _MpParkBase

_StackBase:
  .quad FixedPcdGet32(PcdPrePiStackBase)

_StackSize:
  .quad FixedPcdGet32(PcdPrePiStackSize)

_SecondaryCpuStackSize:
  .quad FixedPcdGet32(SecondaryCpuStackSize)

_MpParkBase:
  .quad FixedPcdGet64(SecondaryCpuMpParkRegionBase)

_ModuleEntryPoint:
  mov r0, #0
  bl ASM_PFX(ArmReadMpidr)

  /* Keep the CPU index in r8 */
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
  /* Each entry is 8 bytes, vector table size is 0x800 per core */
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
  /* r0 = _StackBase and r1 = _StackSize */
	ldr   r1, _StackBase
	ldr   r2, _StackSize

  // Move sec startup address into a data register
  // Ensure we're jumping to FV version of the code (not boot remapped alias)
  ldr   r4, =ASM_PFX(CEntryPoint)

  // Jump to PrePiCore C code
  //    r0 = MpId
  //    r1 = UefiMemoryBase
  //    r2 = StacksBase
  blx   r4

.align 3
dead:  
  b dead                      /* We should never get here */
