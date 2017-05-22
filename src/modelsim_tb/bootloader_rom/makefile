GCC_PREFIX = riscv32-unknown-linux-gnu-
CC = $(GCC_PREFIX)as
LD = $(GCC_PREFIX)ld
OBJCOPY = $(GCC_PREFIX)objcopy
OBJDUMP = $(GCC_PREFIX)objdump
GDB = $(GCC_PREFIX)gdb

all: bootloader_rom.v bootloader_rom.om

%.o: %.s
	$(CC) $< -o $@
%.om: %.o rom.ld
	$(LD) -T rom.ld $< -o $@
%.bin: %.om
	$(OBJCOPY) -O binary $<  $@
Bin2Mem: Bin2Mem.c
	gcc $< -o $@
%.v: %.bin Bin2Mem
	./Bin2Mem -f $< -o $@

clean:
	rm -f *.o *.om *.bin *.data *.mif *.v *.asm Bin2Mem
