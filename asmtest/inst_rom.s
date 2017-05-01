.global _start
_start:
	/*
	la x2, value
	ori x1, x0, 0x654

	amoswap.w x4, x1, (x2)
	lw x5, (x2)

	amoadd.w x4, x1, (x2)
	lw x5, (x2)

	amoand.w x4, x1, (x2)
	lw x5, (x2)

	amoor.w x4, x1, (x2)
	lw x5, (x2)

	amoxor.w x4, x1, (x2)
	lw x5, (x2)

	amomax.w x4, x1, (x2)
	lw x5, (x2)

	amomin.w x4, x1, (x2)
	lw x5, (x2)

	amomaxu.w x4, x1, (x2)
	lw x5, (x2)

	amominu.w x4, x1, (x2)
	lw x5, (x2)
	*/

	/*
	la x2, value
	ori x1, x0, 0x654

	amoor.w x4, x1, (x2)
	lw x5, (x2)
	*/

	la x2, value
	ori x1, x0, -0x654
 
	# amomax.w x4, x1, (x2)
	# amomin.w x4, x1, (x2)
	# amominu.w x4, x1, (x2)
	# amomaxu.w x4, x1, (x2)
	amoadd.w.aqrl x4, x1, (x2)
	lw x5, (x2)



_spin:
	j _spin

value:
	.long 0x12345678
	.long 0x87654321
	.long 0x0
	.long 0x0
	.long 0x0
	.long 0x0

