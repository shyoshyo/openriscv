.org 0x0
.global _start
_start:
	ori x3, x0, 0x80
	sll x3, x3, 24
	ori x2, x0, 0x1
	ori x2, x0, 0x2

	j .L1
	ori x2, x0, 0x7ff

.s1:
	ori x2, x0, 0x223
	j .s1
	ori x2, x0, 0x321

.org 0x30
.L1:
	ori x2, x0, 0x3

	jal .L2
	ori x2, x0, 0x321
	ori x2, x0, 0x456

.org 0x50
.L2:
	ori x2, x0, 0x4
	beq x3, x3, .L3

.L22:
	ori x2, x0, 0x6
	ori x2, x0, 0x7
	ori x2, x0, 0x8
	ori x2, x0, 0x9
	bgt x2, x0, .L4
	ori x2, x0, 0xaa


.org 0x90
.L3:
	ori x2, x0, 0x5
	bge x2, x0, .L22
	ori x2, x0, 0x3

.org 0x200
.L4:
	ori x2, x0, 0xa
	bgez x3, .L3
	ori x2, x0, 0xb
	ori x2, x0, 0xc
	ori x2, x0, 0xd
	ori x2, x0, 0xe
	ori x2, x0, 0xf
	blt x3, x0, .L5
	ori x2, x0, 0xff
	ori x2, x0, 0xff
	ori x2, x0, 0xff

.org 0x500
.L5:
	ori x2, x0, 0x20
	bgeu x3, x0, .L6
	ori x2, x0, 0xff
.L6:
	blez x2, .L2
	ori x2, x0, 0x21
	ori x2, x0, 0x22
	ori x2, x0, 0x23
	bltz x3, .L7
	ori x2, x0, 0x3ff
	ori x2, x0, 0x5ff

.org 0x800
.L7:
	ori x2, x0, 0x23
	nop
	nop

	jal x4, .L8
	ori x2, x0, 0x327
.L8:
	nop
	nop

	



	

/*
	ori x2, x0, 0xFF
	sll x2, x2, 24
	slt x2, x2, x0
	sltu x2, x2, x0
	slti x2, x2, 0xFFFFF800
	sltiu x2, x2, 0xFFFFF800
	slti x2, x2, 0x700
	sltiu x2, x2, 0x700
	lui x2, 0x223
*/

/*
	ori x2, x0, 0x80
	sll x2, x2, 24
	ori x2, x2, 0x010

	ori x2, x0, 0x80
	sll x2, x2, 24
	ori x2, x2, 0x001

	ori x3, x0, 0x000
	add x3, x2, x2
	
	ori x3, x0, 0x000
	sub x3, x2, x3
	sub x3, x2, x2

	addi x3, x3, 2
	ori x3, x0, 0x000
	addi x3, x3, 0xFFFFF800
*/

/*
	lui x2, 0x04040
	ori x2, x2, 0x404

	ori x7, x0, 0x7
	ori x5, x0, 0x5
	ori x8, x0, 0x8

	nop

	sll x2, x2, 8
	sll x2, x2, x7
	srl x2, x2, 8
	srl x2, x2, x5

	nop
	nop
	sll x2, x2, 19
	nop
	sra x2, x2, 16
	sra x2, x2, x8
*/
_spin:
	j _spin
