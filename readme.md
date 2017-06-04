OpenRISCV: an open RISC-V processor
=========================================

About
---------

This is an OpenRISCV processor. The ISA implemented by this RISC-V processor is
RV32IMA.

This processor implementation can be tested or run on:
  
  - modelsim
  - ThinPAD
  - de2i (under construction)

How to use
---------


modelsim
------------------
The modelsim working directory is located at `./modelsim`.

The modelsim project file is also located at `./modelsim`.  `./asmTest` can assemble program to binary instructions, which is acceptable as modelsim simulation input.

`riscv-pk` is the Berkeley Boot Loader, `bbl`, which is a
supervisor execution environment for tethered RISC-V systems.  It is
designed to host the bbl-ucore port. For more details, visit https://git.net9.org/shyoshyo/riscv-pk

board
------------------
`./src` is the basic HDL implementation of RISC-V processor.

`./src/cpu` is the common HDL design. `./src/de2i` `./src/ThinPAD` `./src/modelsim` is for specific development board/simulation environment.

For ThinPAD, there is the main Xilinx ISE project file in  `./src/ThinPAD/openriscv`