.global _start
_start:
	li x1, 0x12345123
	csrw mtvec, x1
	csrr x2, mtvec

_spin:
	j _spin

value:
	.long 0x12345678
	.long 0x87654321
	.long 0x0
	.long 0x0
	.long 0x0
	.long 0x0

