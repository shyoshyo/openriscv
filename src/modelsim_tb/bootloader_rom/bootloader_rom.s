# assume file base == FLASH_START (0x20000000)
.option norvc
.globl __start
__start:
load_elf:
  #addr of elfheader, s0
  li s0, 0x20000000
  #e_magic
  ### LOAD_WORD_I(t1, 0)
    li a0, 0
    jal load_word
    mv t1, a0

  li t0, 0x464C457F
  beq t0, t1, elf_magic_accepted
  j bad

elf_magic_accepted:
  #e_phoff
  ### LOAD_WORD_I(s1, 28)
    li a0, 28
    jal load_word
    mv s1, a0

  #e_phnum
  ### LOAD_WORD_I(s2, 44)
    li a0, 44
    jal load_word
    mv s2, a0

  ### andi s2, s2, 0xFFFF
    sll s2, s2, 16
    srl s2, s2, 16

  #e_entry
  ### LOAD_WORD_I(s3, 24)
    li a0, 24
    jal load_word
    mv s3, a0

next_sec:
  #s1, addr proghdr
  #s4, p_va
  ### LOAD_WORD_R(s4, 8, s1)
    add a0, s1, 8
    jal load_word
    mv s4, a0

  #s5, p_filesz
  ### LOAD_WORD_R(s5, 16, s1)
    add a0, s1, 16
    jal load_word
    mv s5, a0

  #s6, p_offset
  ### LOAD_WORD_R(s6, 4, s1)
    add a0, s1, 4
    jal load_word
    mv s6, a0

  #s7, p_mem
  ### LOAD_WORD_R(s7, 20, s1)
    add a0, s1, 20
    jal load_word
    mv s7, a0

  # beq  s4, zero, goto_next_sec
  # beq  s5, zero, goto_next_sec
  beq  s7, zero, goto_next_sec

#copy from file_base+p_offset to p_va
copy_sec:
  ### LOAD_WORD_R(t0, 0, s6)
    add a0, s6, 0
    jal load_word
    mv t0, a0

  sw t0, 0(s4)
  add s6, s6, 4
  add s4, s4, 4
  add s5, s5, -4
  add s7, s7, -4
  bgtz  s5, copy_sec

  beq   s7, zero, goto_next_sec
memset_zero:
  sw zero, 0(s4)
  add s4, s4, 4
  add s7, s7, -4
  bgtz  s7, memset_zero

goto_next_sec:
  add s1, s1, 32
  add s2, s2, -1
  bgtz s2, next_sec

done:
#jump to kernel
  jr s3

bad:
  j bad

/* off = offset from s0 */

/* load a 32bit word from Flash,  off is byte-addressed */
/* input off = a0, must be 4 bytes aligned */
/* output a0 = s0[a0] */
load_word:
  sll t6, a0, 1
  add t6, s0, t6
  lhu a0, 0(t6)
  lhu t6, 4(t6)
  sll t6, t6, 16
  or  a0, a0, t6
  ret

.org 0x400