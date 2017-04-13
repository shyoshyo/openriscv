ifndef CROSS_COMPILE
CROSS_COMPILE = riscv64-unknown-elf-
endif
CC = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
GDB = $(CROSS_COMPILE)gdb

OBJECTS = inst_rom.o

export	CROSS_COMPILE

# ********************
# Rules of Compilation
# ********************

all: inst_rom.om inst_rom.bin inst_rom.asm inst_rom.data ../modelsim/inst_rom.data

%.o: %.s
	@$(CC) $< -o $@
inst_rom.om: ram.ld $(OBJECTS)
	@$(LD) -T ram.ld $(OBJECTS) -o $@
inst_rom.bin: inst_rom.om
	@$(OBJCOPY) -O binary $<  $@
inst_rom.asm: inst_rom.om
	@$(OBJDUMP) -D $< > $@
inst_rom.data: inst_rom.bin Bin2Mem
	@./Bin2Mem -f $< -o $@
Bin2Mem: Bin2Mem.c
	@gcc $< -o $@
../modelsim/inst_rom.data: inst_rom.data
	@cp $< $@

spike_prog.om: spike.ld $(OBJECTS)
	@$(LD) -T spike.ld $(OBJECTS) -o $@
debug: spike_prog.om
	@spike --gdb-port=12345 -H $< &
	@sleep 2
	@$(GDB) -x gdbinit
	@killall spike 


clean:
	@rm -f *.o *.om *.bin *.data *.mif *.asm Bin2Mem
