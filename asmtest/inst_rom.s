.global _start
_start:
	lw x1, value
	beqz x1, _spin

	li x3, 0x123
	nop
	nop
	nop


_spin:
	j _spin

value:
	.long 0x123
