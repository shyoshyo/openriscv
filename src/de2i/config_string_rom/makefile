
CC = as
LD = ld
OBJCOPY = objcopy
OBJDUMP = objdump
GDB = gdb

all: config_string_rom.v

%.o: %.s
	$(CC) $< -o $@
%.bin: %.o
	$(OBJCOPY) -O binary $<  $@
Bin2Mem: Bin2Mem.c
	gcc $< -o $@
%.v: %.bin Bin2Mem
	./Bin2Mem -f $< -o $@

clean:
	rm -f *.o *.om *.bin *.data *.mif *.v *.asm Bin2Mem