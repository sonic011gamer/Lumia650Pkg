#include <Library/BaseLib.h>
#include <Library/PlatformMemoryMapLib.h>

static ARM_MEMORY_REGION_DESCRIPTOR_EX gDeviceMemoryDescriptorEx[] = {
    /*                                                    EFI_RESOURCE_ EFI_RESOURCE_ATTRIBUTE_        ARM_REGION_ATTRIBUTE_
    MemBase,   MemSize,   MemLabel(32 Char.), BuildHob, ResourceType, ResourceAttribute, MemoryType, CacheAttributes */

    /* DDR Regions */
    {0x80000000, 0x00010000, "HLOS 0",           AddMem, SYS_MEM, SYS_MEM_CAP, Conv,   WRITE_BACK},
    {0x80010000, 0x00014000, "DBI Dump",         NoHob,  MMAP_IO, INITIALIZED, Conv,   NS_DEVICE},
    {0x80024000, 0x001DC000, "HLOS 1",           AddMem, SYS_MEM, SYS_MEM_CAP, Conv,   WRITE_BACK},
    {0x80200000, 0x00100000, "UEFI FD",          AddMem, SYS_MEM, SYS_MEM_CAP, BsCode, WRITE_BACK},
    {0x80300000, 0x00040000, "MPPark Code",      AddMem, MEM_RES, UNCACHEABLE, RtCode, UNCACHED_UNBUFFERED},
    {0x80340000, 0x00040000, "HLOS 2",           AddMem, SYS_MEM, SYS_MEM_CAP, BsData, UNCACHED_UNBUFFERED},
    {0x80380000, 0x00001000, "FBPT Payload",     AddMem, SYS_MEM, SYS_MEM_CAP, RtData, UNCACHED_UNBUFFERED},
    {0x80381000, 0x00004000, "DBG2",             AddMem, SYS_MEM, SYS_MEM_CAP, LdData, UNCACHED_UNBUFFERED},
    {0x80385000, 0x00001000, "Capsule Header",   AddMem, SYS_MEM, SYS_MEM_CAP, RtData, UNCACHED_UNBUFFERED},
    {0x80386000, 0x00003000, "TPM Control Area", AddMem, SYS_MEM, SYS_MEM_CAP, RtData, UNCACHED_UNBUFFERED},
    {0x80389000, 0x00001000, "UEFI Info Block",  AddMem, SYS_MEM, SYS_MEM_CAP, RtData, UNCACHED_UNBUFFERED},
    {0x8038A000, 0x00004000, "Reset Data",       AddMem, SYS_MEM, SYS_MEM_CAP, RtData, UNCACHED_UNBUFFERED},
    {0x8038E000, 0x00072000, "Reser. Uncached0", AddMem, SYS_MEM, SYS_MEM_CAP, BsData, UNCACHED_UNBUFFERED},
    {0x80400000, 0x00800000, "Display Reserved", AddMem, MEM_RES, WRITE_THROUGH, MaxMem, WRITE_THROUGH},
    {0x80C00000, 0x00040000, "UEFI Stack",       AddMem, SYS_MEM, SYS_MEM_CAP, BsData, WRITE_BACK},
    {0x80C40000, 0x00010000, "CPU Vectors",      AddMem, SYS_MEM, SYS_MEM_CAP, BsCode, WRITE_BACK},
    {0x80C50000, 0x000B0000, "Reser. Cached 0",  AddMem, SYS_MEM, SYS_MEM_CAP, BsData, WRITE_BACK},
    {0x80D00000, 0x03300000, "HLOS 3",           AddMem, SYS_MEM, SYS_MEM_CAP, BsData, WRITE_BACK},
    {0x84000000, 0x03900000, "HLOS 4",           AddMem, SYS_MEM, SYS_MEM_CAP, Conv,   WRITE_BACK},
    {0x87900000, 0x00300000, "TZ Apps",          AddMem, SYS_MEM, SYS_MEM_CAP, Reserv, NS_DEVICE},
    {0x87C00000, 0x000E0000, "MPSS_EFS / SBL",   AddMem, SYS_MEM, SYS_MEM_CAP, Reserv, NS_DEVICE},
    {0x87CE0000, 0x00020000, "ADSP_EFS",         AddMem, SYS_MEM, SYS_MEM_CAP, Reserv, NS_DEVICE},
    {0x87D00000, 0x00100000, "SMEM",             AddMem, MEM_RES, UNCACHEABLE, Reserv, UNCACHED_UNBUFFERED},
    {0x87E00000, 0x00080000, "HLOS 5",           AddMem, SYS_MEM, SYS_MEM_CAP, Conv,   WRITE_BACK},
    {0x87E80000, 0x00180000, "TZ QSEE",          AddMem, SYS_MEM, SYS_MEM_CAP, Reserv, NS_DEVICE},
    {0x88000000, 0x06F00000, "PIL_REGION",       AddMem, SYS_MEM, SYS_MEM_CAP, Reserv, NS_DEVICE},
    {0x8EF00000, 0x01100000, "HLOS 6",           AddMem, SYS_MEM, SYS_MEM_CAP, Conv,   WRITE_BACK},
    {0x90000000, 0x30000000, "HLOS 7",           AddMem, SYS_MEM, SYS_MEM_CAP, Conv,   WRITE_BACK},
    //------------- Other Memory Regions ------
    {0x08600000, 0x00004000, "IMEM Boot Base",   NoHob,  SYS_MEM, INITIALIZED, Conv,   NS_DEVICE},
    {0x08600000, 0x00001000, "IMEM Cookie Base", AddDev, MMAP_IO, INITIALIZED, Conv,   NS_DEVICE},
    //------------- Register Regions ----------
    {0x00001000, 0x00070000, "REG 1",           AddDev, MMAP_IO,  UNCACHEABLE, MmIO,   NS_DEVICE},
    {0x00300000, 0x00200000, "REG 2",           AddDev, MMAP_IO,  UNCACHEABLE, MmIO,   NS_DEVICE},
    {0x00700000, 0x00D00000, "REG 3",           AddDev, MMAP_IO,  UNCACHEABLE, MmIO,   NS_DEVICE},
    {0x01400000, 0x00C00000, "REG 4",           AddDev, MMAP_IO,  UNCACHEABLE, MmIO,   NS_DEVICE},
    {0x02000000, 0x01C00000, "REG 5",           AddDev, MMAP_IO,  UNCACHEABLE, MmIO,   NS_DEVICE},
    {0x07800000, 0x00100000, "REG 6",           AddDev, MMAP_IO,  UNCACHEABLE, MmIO,   NS_DEVICE},
    {0x0B000000, 0x00800000, "REG 7",           AddDev, MMAP_IO,  UNCACHEABLE, MmIO,   NS_DEVICE},
    {0x0C428000, 0x00008000, "REG 8",           AddDev, MMAP_IO,  UNCACHEABLE, MmIO,   NS_DEVICE},

    /* Terminator for MMU */
    { 0, 0, "Terminator", 0, 0, 0, 0, 0}};

ARM_MEMORY_REGION_DESCRIPTOR_EX *GetPlatformMemoryMap()
{
  return gDeviceMemoryDescriptorEx;
}