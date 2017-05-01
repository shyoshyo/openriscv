.global _start
_start:
	la x2, value

	ori x1, x0, 0x123
	sw x1, (x2)

	ori x1, x0, 0x567
	sc.w x4, x1, (x2)

	lw x3, (x2)

	mv x4, x0
	mv x3, x0

	ori x1, x0, 0x0
	lr.w x1, (x2)
	addi x1, x1, 0x1
	addi x2, x2, 0x8
	sc.w x4, x1, (x2)

	addi x2, x2, -0x8
	lw x3, (x2)

_spin:
	j _spin

value:
	.long 0x0
	.long 0x0
	.long 0x0
	.long 0x0
	.long 0x0
	.long 0x0

