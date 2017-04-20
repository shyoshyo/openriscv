.org 0x0
.global _start
_start:
	ori x0, x0, 0x123
	ori x1, x0, 0x100
	ori x1, x1, 0x020
	ori x1, x1, 0x400
	ori x1, x1, 0x044
	ori x2, x1, 0
	ori x3, x1, 1


_first_inst:
	j _start
