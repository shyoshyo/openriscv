.global _start
_start:
	li x1, 0x87213672
	li x2, 0x0
	li x4, 0x80000000
	li x5, -12

	# div x3, x1, x2

	rem x3, x4, x5

_spin:
	j _spin

value:
	.long 0x123
