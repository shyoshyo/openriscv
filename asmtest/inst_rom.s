.org 0x0
.global _start
_start:
	li x1, 0xff1
	sll x1, x1, 20
	blt x1, x0, _spin
	li x2, 0x123

_spin:
	j _spin
