.long 0x0
.long 0x0
.long 0x0
.long 0x00001020
.long 0x0
.long 0x0
.long 0x0
.long 0x0
.ascii "platform {\n"
.ascii "  vendor shyoshyo;\n"
.ascii "  arch reiko;\n"
.ascii "};\n"
.ascii "rtc {\n"
.ascii "  addr 0x40000000;\n"
.ascii "};\n"
.ascii "ram {\n"
.ascii "  0 {\n"
.ascii "    addr 0x80000000;\n"
.ascii "    size 0xf0000000;\n"
.ascii "  };\n"
.ascii "};\n"
.ascii "uart {\n"
.ascii "  0 {\n"
.ascii "    addr 0xbfd003f8;\n"
.ascii "    reiko reiko_>w<;\n"
.ascii "  };\n"
.ascii "};\n"
.ascii "core {\n"
.ascii "  0 {\n"
.ascii "    0 {\n"
.ascii "      isa rv32ima;\n"
.ascii "      timecmp 0x40000008;\n"
.ascii "      ipi 0x40001000;\n"
.ascii "    };\n"
.ascii "  };\n"
.ascii "};\n"
.byte 0x0

.org 0x3f0
