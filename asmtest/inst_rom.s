.global _start
_start:
	ori x1, x0, 0x123
	ori x2, x0, 0x123

	bge x1, x2, _spin
	ori x3, x0, 0x789
	ori x4, x0, 0x789
	ori x5, x0, 0x789

_spin:
	j _spin

value:
	.long 0x123
