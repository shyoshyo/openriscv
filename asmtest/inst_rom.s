.org 0x0
.global _start
_start:

/*
	lui  x1, 0x123
	CSRW mscratch, x1
	CSRR x3, mscratch
	lui x1, 0x10000
	CSRS mscratch, x1
*/

/*
	lui x2, 0x12345
	lui x3, 0x54321
	CSRRW x3, mscratch, x2
	add x2, x2, 0x1
	CSRRW x3, mscratch, x2
	mv x4, x3
*/

	nop
	nop
	nop
	auipc x3, 0x0
	lui x4, 0x54321
	ori x4, x4, 0x137
	sw x4, 0x14(x3)
	nop
	lui x2, 0x12345
	lw x1, 0x14(x3)

/*
	ori x1, x0, 0x300
	lw x2, 0x4(x1)
	lh x2, 0x4(x1)

	lb x2, 0xc(x1)
	j .L2

	li x31, 0x12345678
	sw x31, 0x380(x0)

.L2:
	lh x2, 0xc(x1)
	j .L3

	li x31, 0x12345679
	sw x31, 0x380(x0)

.L3:
	lw x2, 0xc(x1)
	j .L4

	li x31, 0x12345677
	sw x31, 0x380(x0)

.L4:
	lbu x2, 0xc(x1)
	lhu x2, 0xc(x1)

	ori x1, x0, 0x400
	lb x2, -0x100(x1)

	lw x2, 0x308(x0)
	ori x1, x0, 0xffffffff
	sb x1, 0x308(x0)
	lw x2, 0x308(x0)
	sh x1, 0x308(x0)
	lw x2, 0x308(x0)
	sw x1, 0x308(x0)
	lw x2, 0x308(x0)

	lw x4, 0x380(x0)
*/

_spin:
	j _spin

.org 0x300
	.long 0x12345678
	.long 0x87654321
	.long 0x726ecdbd
	.long 0xfedcbafe

.org 0x380
	.long 0x12345
