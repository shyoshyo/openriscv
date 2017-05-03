MAKE = make

all: bbl

asm:
	@cd asmtest && $(MAKE)

bbl:
	@cd riskv-pk && $(MAKE)
    
clean:
	@cd asmtest && $(MAKE) clean
