#!/bin/bash

cd BootShim
rm BootShim.bin
rm BootShim.elf

make UEFI_BASE=0x80200000 UEFI_SIZE=0x00100000
cd ..
