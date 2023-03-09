// ARM Platform support for bootstrapping LK

	.set CTRL_M_BIT,     (1 << 0)
	.set CTRL_C_BIT,     (1 << 2)
	.set CTRL_B_BIT,     (1 << 7)
	.set CTRL_I_BIT,     (1 << 12)
	.set CACHE_LINE,	64

	.section "s_ArmDeInitialize", "ax"
	GCC_ASM_EXPORT (ArmDeInitialize)
	GCC_ASM_EXPORT (ArmRelocateFirmware)

ArmRelocateFirmware:
	// check if we're located at expected location
	adr	r4, .
	ldr	r5, =ArmRelocateFirmware
	cmp	r4, r5
	bne	_CopyUEFI
	bx lr

	_CopyUEFI:
	// find our start address by getting our expected offset, then subtracting it from our actual address
	ldr	r6, =FixedPcdGet64 (PcdFdBaseAddress)
	sub	r5, r5, r6 // r5 now holds offset of _ModuleEntryPoint from start of FD base
	sub	r4, r4, r5 // r4 now holds address of actual FD base
	// tweak return address

	//note: r14 is lr; gcc5 doesn't have the alias
	sub	r14, r14, r4
	add	r14, r14, r6
	ldr	r5, =FixedPcdGet64 (PcdFdSize)

	//ugly memcpy
	_CopyLoop:
	ldr	r2, [r4], #4
	ldr	r3, [r4], #4
	str	r2, [r6], #4
	str	r3, [r6], #4
	subs	r5, r5, #4
	bne	_CopyLoop
	bx lr

ArmDeInitialize:
	// Disable Branch Prediction
	mrc     p15, 0, r0, c1, c0, 0
	bic     r0, r0, #0x00000800
	mcr     p15, 0, r0, c1, c0, 0
	dsb
	isb

	// Enter critical section: disable interrupt
	cpsid   if
	isb

	// CLean, invalidate and disable data-cache
	dsb
	mrc		p15, 1, R6, c0, c0, 1			// Read CLIDR
	ands	R3, R6, #0x7000000				// Mask out all but Level of Coherency (LoC)
	mov		R3, R3, LSR #23					// Cache level value (naturally aligned)
	beq		Finished
	mov		R10, #0

Loop1:
	add		R2, R10, R10, LSR #1			// Work out 3xcachelevel
	mov		R12, R6, LSR R2					// bottom 3 bits are the Cache type for this level
	and		R12, R12, #7					// get those 3 bits alone
	cmp		R12, #2
	blt		Skip							// no cache or only instruction cache at this level
	mcr		p15, 2, R10, c0, c0, 0			// write the Cache Size selection register (CSSELR) // OR in 1 for Instruction
	isb										// isb to sync the change to the CacheSizeID reg
	mrc		p15, 1, R12, c0, c0, 0			// reads current Cache Size ID register (CCSIDR)
	and		R2, R12, #7					// extract the line length field
	add		R2, R2, #4						// add 4 for the line length offset (log2 16 bytes)
	ldr		R4, =0x3FF
	ands	R4, R4, R12, LSR #3				// R4 is the max number on the way size (right aligned)
	clz		R5, R4							// R5 is the bit position of the way size increment
	ldr		R7, =0x00007FFF
	ands	R7, R7, R12, LSR #13			// R7 is the max number of the index size (right aligned)

Loop2:
	mov		R9, R4							// R9 working copy of the max way size (right aligned)

Loop3:
	orr		R0, R10, R9, LSL R5				// factor in the way number and cache number into R11
	orr		R0, R0, R7, LSL R2				// factor in the index number

	// ArmCleanInvalidateDataCacheEntryBySetWay
	mcr     p15, 0, r0, c7, c14, 2			// Clean and Invalidate this line

	subs	R9, R9, #1						// decrement the way number
	bge		Loop3
	subs	R7, R7, #1						// decrement the index
	bge		Loop2

Skip:
	add		R10, R10, #2					// increment the cache number
	cmp		R3, R10
	bgt		Loop1

Finished:
	dsb

	// Invalidate I-Cache
	mcr     p15, 0, R0, c7, c5, 0			// Invalidate entire instruction cache
	dsb
	isb

	// Turn off MMU, I-Cache, D-Cache
	mrc		p15, 0, r0, c1, c0, 0           // Get control register
	bic		r0, r0, #CTRL_C_BIT             // Disable D Cache
	bic		r0, r0, #CTRL_I_BIT             // Disable I Cache
	bic		r0, r0, #CTRL_M_BIT             // Disable MMU
	mcr		p15, 0, r0, c1, c0, 0           // Write control register
	dsb
	isb

	// Flush TLB
	mov     r0, #0
	mcr     p15, 0, r0, c8, c7, 0
	mcr     p15, 0, R9, c7, c5, 6			// BPIALL Invalidate Branch predictor array. R9 == NoOp
	dsb
	isb

	// Return
	bx		lr
