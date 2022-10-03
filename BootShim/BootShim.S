_Head:
	/* Set _Entry address */
	adr		r1, _Payload
	mov		r0, r2
	nop
	nop
	nop
	nop
	nop
	nop
	adr 	r0, _Start
	/* Jump to the real code */
	b		r0

	/* Fake Linux kernel header */

_StackBase:
	/* Text Offset */
	.quad UEFI_BASE

_StackSize:
	/* ARM Magic */
	.byte 0x18, 0x28, 0x6f, 0x01
	/* Image Size */
	.quad UEFI_SIZE
	/* Endianness Flags */
	.byte 0x01, 0x02, 0x3, 0x4

_Start:
	mov		r4, r1
	ldr		r5, _StackBase
	cmp		r4, r5
	beq		_Entry
	ldr		r6,  _StackSize

_CopyLoop:
	ldr		r3, [r4], #16
	str		r3, [r5], #16
	subs	r6, r6, #16
	bne	_CopyLoop
	ldr		r5, _StackBase

_Entry:
	blx		r5

_Dead:
	/* We should never get here */
	b		_Dead

.text
.align 4

_Payload:
	/* Your code will get ran right after this binary */
