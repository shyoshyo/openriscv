// define RV32 for 32 bits, or ISA is 64 bits
`define RV32

//全局
`define RstEnable 1'b0
`define RstDisable 1'b1

`define ZeroWord 32'h00000000

`define WriteEnable 1'b1
`define WriteDisable 1'b0

`define ReadEnable 1'b1
`define ReadDisable 1'b0

`define AluOpBus 7:0
`define AluSelBus 2:0

`define InstValid 1'b0
`define InstInvalid 1'b1

`define Stop 1'b1
`define NoStop 1'b0

`define InDelaySlot 1'b1
`define NotInDelaySlot 1'b0

`define Branch 1'b1
`define NotBranch 1'b0

`define InterruptAssert 1'b1
`define InterruptNotAssert 1'b0

`define TrapAssert 1'b1
`define TrapNotAssert 1'b0

`define OverflowAssert 1'b1
`define OverflowNotAssert 1'b0

`define True_v 1'b1
`define False_v 1'b0

`define ChipEnable 1'b1
`define ChipDisable 1'b0

// 清空流水线
`define Flush 1'b1
// 不清空流水线
`define NoFlush 1'b0

// code for inst.
`define EXE_OP_IMM       7'b0010011
`define EXE_ADDI         3'b000
`define EXE_SLLI         3'b001
`define EXE_SLTI         3'b010
`define EXE_SLTIU        3'b011
`define EXE_XORI         3'b100
`define EXE_SRLI_SRAI    3'b101
`define EXE_ORI          3'b110
`define EXE_ANDI         3'b111

`define EXE_LUI          7'b0110111
`define EXE_AUIPC        7'b0010111

`define EXE_OP           7'b0110011
`define EXE_ADD_SUB_MUL  3'b000
`define EXE_SLL_MULH     3'b001
`define EXE_SLT_MULHSU   3'b010
`define EXE_SLTU_MULHU   3'b011
`define EXE_XOR_DIV      3'b100
`define EXE_SRL_SRA_DIVU 3'b101
`define EXE_OR_REM       3'b110
`define EXE_AND_REMU     3'b111

`define EXE_JAL          7'b1101111
`define EXE_JALR         7'b1100111

`define EXE_BRANCH       7'b1100011
`define EXE_BEQ          3'b000
`define EXE_BNE          3'b001
`define EXE_BLT          3'b100
`define EXE_BGE          3'b101
`define EXE_BLTU         3'b110
`define EXE_BGEU         3'b111

`define EXE_LOAD         7'b0000011
`define EXE_LB           3'b000
`define EXE_LH           3'b001
`define EXE_LW           3'b010
`define EXE_LBU          3'b100
`define EXE_LHU          3'b101

`define EXE_STORE        7'b0100011
`define EXE_SB           3'b000
`define EXE_SH           3'b001
`define EXE_SW           3'b010

`define EXE_MISC_MEM     7'b0001111
`define EXE_FENCE        3'b000
`define EXE_FENCE_I      3'b001

`define EXE_SYSTEM       7'b1110011
`define EXE_ECALL_EBREAK_URET_SRET_HRET_MRET \
                         3'b000
    `define EXE_ECALL    12'b000000000000
    `define EXE_EBREAK   12'b000000000001
    `define EXE_URET     12'b000000000010
    `define EXE_SRET     12'b000100000010
    `define EXE_HRET     12'b001000000010
    `define EXE_MRET     12'b001100000010
`define EXE_CSRRW        3'b001
`define EXE_CSRRS        3'b010
`define EXE_CSRRC        3'b011
`define EXE_CSRRWI       3'b101
`define EXE_CSRRSI       3'b110
`define EXE_CSRRCI       3'b111

`define EXE_AMO          7'b0101111
`define EXE_AMO_W        3'b010
`define EXE_LR           5'b00010
`define EXE_SC           5'b00011
`define EXE_AMOSWAP      5'b00001
`define EXE_AMOADD       5'b00000
`define EXE_AMOXOR       5'b00100
`define EXE_AMOAND       5'b01100
`define EXE_AMOOR        5'b01000
`define EXE_AMOMIN       5'b10000
`define EXE_AMOMAX       5'b10100
`define EXE_AMOMINU      5'b11000
`define EXE_AMOMAXU      5'b11100
 
//AluSel
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_SHIFT 3'b010
`define EXE_RES_MOVE 3'b011
`define EXE_RES_ARITHMETIC 3'b100
`define EXE_RES_MUL 3'b101
`define EXE_RES_JUMP_BRANCH 3'b110
`define EXE_RES_LOAD_STORE 3'b111

`define EXE_RES_NOP 3'b000

//AluOp
/* EXE_RES_LOGIC */
`define EXE_OR_OP    8'b00100101
`define EXE_AND_OP   8'b00100100
`define EXE_XOR_OP  8'b00100110

/* EXE_RES_SHIFT */
`define EXE_SLL_OP  8'b01111100
`define EXE_SRL_OP  8'b00000010
`define EXE_SRA_OP  8'b00000011

/* EXE_RES_MOVE */
`define EXE_MOVZ_OP  8'b00001010
`define EXE_MOVN_OP  8'b00001011

`define EXE_TLBWI_OP 8'b01100001
`define EXE_TLBWR_OP 8'b01100010

`define EXE_CSRRW_OP 8'b01011000
`define EXE_CSRRS_OP 8'b01011001
`define EXE_CSRRC_OP 8'b01011010

/* EXE_RES_ARITHMETIC */
`define EXE_SLT_OP  8'b00101010
`define EXE_SLTU_OP  8'b00101011  
`define EXE_ADD_OP  8'b00100000
`define EXE_SUB_OP  8'b00100010

/* EXE_RES_MUL */
`define EXE_MUL_OP  8'b00011000
`define EXE_MULH_OP  8'b00011001
`define EXE_MULHSU_OP  8'b10101001
`define EXE_MULHU_OP  8'b10100110

`define EXE_DIV_OP  8'b00011010
`define EXE_DIVU_OP  8'b00011011
`define EXE_REM_OP  8'b10101000
`define EXE_REMU_OP  8'b10101010

/* EXE_RES_JUMP_BRANCH */
`define EXE_JAL_OP  8'b01010000

/* EXE_RES_LOAD_STORE */
`define EXE_LB_OP  8'b11100000
`define EXE_LBU_OP  8'b11100100
`define EXE_LH_OP  8'b11100001
`define EXE_LHU_OP  8'b11100101
`define EXE_LW_OP  8'b11100011
`define EXE_LR_OP  8'b11110000
`define EXE_SB_OP  8'b11101000
`define EXE_SH_OP  8'b11101001
`define EXE_SW_OP  8'b11101011
`define EXE_SC_OP  8'b11111000
`define EXE_AMOSWAP_W_OP      8'b01000001
`define EXE_AMOADD_W_OP       8'b01000000
`define EXE_AMOXOR_W_OP       8'b01000100
`define EXE_AMOAND_W_OP       8'b01001100
`define EXE_AMOOR_W_OP        8'b01001000
`define EXE_AMOMIN_W_OP       8'b01110000
`define EXE_AMOMAX_W_OP       8'b01010100
`define EXE_AMOMINU_W_OP      8'b01111001
`define EXE_AMOMAXU_W_OP      8'b01011100

/* EXE_RES_NOP */
`define EXE_NOP_OP 8'b00000000


//通用寄存器regfile
`ifdef RV32
	`define RegBus 31:0
	`define RegWidth 32
	`define RegSel 3:0
	`define DoubleRegBus 63:0
	`define DoubleRegWidth 64
	`define HighRegBus 63:32
	`define PhyAddrBus 33:0

	`define MinusOne 32'hffff_ffff
	`define SCSucceed 32'h0
	`define SCFail 32'h1
`else
	`define RegBus 63:0
	`define RegWidth 64
	`define RegSel 7:0
	`define DoubleRegBus 127:0
	`define DoubleRegWidth 128
	`define HighRegBus 127:64
	`define PhyAddrBus 49:0

	`define MinusOne 64'hffff_ffff_ffff_ffff
	`define SCSucceed 64'h0
	`define SCFail 64'h1
`endif

`define InstBus 31:0

`define RegAddrBus 4:0
`define RegNum 32
`define RegNumLog2 5

`define ZeroRegAddr 5'b00000
`define NOPRegAddr 5'b00000

`define WishboneAddrBus 31:0
`define WishboneDataBus 31:0
`define WishboneSelBus 3:0

//除法div
`define DivFree 2'b00
`define DivByZero 2'b01
`define DivOn 2'b10
`define DivEnd 2'b11
`define DivResultReady 1'b1
`define DivResultNotReady 1'b0
`define DivStart 1'b1
`define DivStop 1'b0

// 中斷源
`define IntSourceBus 5:0

// 異常類型
`define ExceptionTypeBus 31:0
/*
`define Exception_IRQ_S_SOFT    1
`define Exception_IRQ_H_SOFT    2
`define Exception_IRQ_M_SOFT    3
`define Exception_IRQ_S_TIMER   5
`define Exception_IRQ_H_TIMER   6
`define Exception_IRQ_M_TIMER   7
`define Exception_IRQ_S_EXT     9
`define Exception_IRQ_H_EXT     10
`define Exception_IRQ_M_EXT     11
*/
`define Exception_INST_MISALIGNED      0
`define Exception_INST_ACCESS_FAULT    1
`define Exception_INST_ILLEGAL         2
`define Exception_BREAK                3
`define Exception_LOAD_MISALIGNED      4
`define Exception_LOAD_ACCESS_FAULT    5
`define Exception_STORE_MISALIGNED     6
`define Exception_STORE_ACCESS_FAULT   7
`define Exception_ECALL_FROM_U         8
`define Exception_ECALL_FROM_S         9
`define Exception_ECALL_FROM_H         10
`define Exception_ECALL_FROM_M         11
`define Exception_ERET_FROM_U          12
`define Exception_ERET_FROM_S          13
`define Exception_ERET_FROM_H          14
`define Exception_ERET_FROM_M          15
`define Exception_FENCEI               21

`define CSR_mcause_INST_MISALIGNED      {1'b0, 31'd0}
`define CSR_mcause_INST_ACCESS_FAULT    {1'b0, 31'd1}
`define CSR_mcause_INST_ILLEGAL         {1'b0, 31'd2}
`define CSR_mcause_BREAK                {1'b0, 31'd3}
`define CSR_mcause_LOAD_MISALIGNED      {1'b0, 31'd4}
`define CSR_mcause_LOAD_ACCESS_FAULT    {1'b0, 31'd5}
`define CSR_mcause_STORE_MISALIGNED     {1'b0, 31'd6}
`define CSR_mcause_STORE_ACCESS_FAULT   {1'b0, 31'd7}
`define CSR_mcause_ECALL_FROM_U         {1'b0, 31'd8}
`define CSR_mcause_ECALL_FROM_S         {1'b0, 31'd9}
`define CSR_mcause_ECALL_FROM_H         {1'b0, 31'd10}
`define CSR_mcause_ECALL_FROM_M         {1'b0, 31'd11}



// Privilege
`define PRV_M   2'h3
`define PRV_H   2'h2
`define PRV_S   2'h1
`define PRV_S_1 1'h1
`define PRV_U   2'h0
`define PRV_U_1 1'h0

// CSR Wirte
`define CSRWriteTypeBus  1:0
`define CSRWriteDisable  2'h0
`define CSRWrite         2'h1
// `define CSRSet           2'h2
// `define CSRClear         2'h3

//CSR 寄存器地址
`define CSRAddrBus 11:0
/* User Trap Setup */
`define CSR_ustatus 12'h000
`define CSR_uie 12'h004
`define CSR_utvec 12'h005
/* User Trap Handling */
`define CSR_uscratch 12'h040
`define CSR_uepc 12'h041
`define CSR_ucause 12'h042
`define CSR_ubadaddr 12'h043
`define CSR_uip 12'h044
/* User Floating-Point CSRs */
`define CSR_fflags 12'h001
`define CSR_frm 12'h002
`define CSR_fcsr 12'h003
/* User Counter/Timers */
`define CSR_cycle 12'hC00
`define CSR_time 12'hC01
`define CSR_instret 12'hC02
`define CSR_hpmcounter3 12'hC03
`define CSR_hpmcounter4 12'hC04
`define CSR_hpmcounter31 12'hC1F
`define CSR_cycleh 12'hC80
`define CSR_timeh 12'hC81
`define CSR_instreth 12'hC82
`define CSR_hpmcounter3h 12'hC83
`define CSR_hpmcounter4h 12'hC84
`define CSR_hpmcounter31h 12'hC9F
/* Supervisor Trap Setup */
`define CSR_sstatus 12'h100
`define CSR_sedeleg 12'h102
`define CSR_sideleg 12'h103
`define CSR_sie 12'h104
`define CSR_stvec 12'h105
/* Supervisor Trap Handling */
`define CSR_sscratch 12'h140
`define CSR_sepc 12'h141
`define CSR_scause 12'h142
`define CSR_sbadaddr 12'h143
`define CSR_sip 12'h144
/* Supervisor Protection and Translation */
`define CSR_sptbr 12'h180
/* Hypervisor Trap Setup */
`define CSR_hstatus 12'h200
`define CSR_hedeleg 12'h202
`define CSR_hideleg 12'h203
`define CSR_hie 12'h204
`define CSR_htvec 12'h205
/* Hypervisor Trap Handling */
`define CSR_hscratch 12'h240
`define CSR_hepc 12'h241
`define CSR_hcause 12'h242
`define CSR_hbadaddr 12'h243
`define CSR_hip 12'h244
/* Hypervisor Protection and Translation */
// 0x28X TBD TBD TBD.
/* Machine Information Registers */
`define CSR_mvendorid 12'hF11
`define CSR_marchid 12'hF12
`define CSR_mimpid 12'hF13
`define CSR_mhartid 12'hF14
/* Machine Trap Setup */
`define CSR_mstatus 12'h300
`define CSR_misa 12'h301
`define CSR_medeleg 12'h302
`define CSR_mideleg 12'h303
`define CSR_mie 12'h304
`define CSR_mtvec 12'h305
/* Machine Trap Handling */
`define CSR_mscratch 12'h340
`define CSR_mepc 12'h341
`define CSR_mcause 12'h342
`define CSR_mbadaddr 12'h343
`define CSR_mip 12'h344
/* Machine Protection and Translation */
`define CSR_mbase 12'h380
`define CSR_mbound 12'h381
`define CSR_mibase 12'h382
`define CSR_mibound 12'h383
`define CSR_mdbase 12'h384
`define CSR_mdbound 12'h385
/* Machine Counter/Timers */
`define CSR_mcycle 12'hB00
`define CSR_minstret 12'hB02
`define CSR_mhpmcounter3 12'hB03
`define CSR_mhpmcounter4 12'hB04
`define CSR_mhpmcounter31 12'hB1F
`define CSR_mcycleh 12'hB80
`define CSR_minstreth 12'hB82
`define CSR_mhpmcounter3h 12'hB83
`define CSR_mhpmcounter4h 12'hB84
`define CSR_mhpmcounter31h 12'hB9F
/* Machine Counter Setup */
`define CSR_mucounteren 12'h320
`define CSR_mscounteren 12'h321
`define CSR_mhcounteren 12'h322
`define CSR_mhpmevent3 12'h323
`define CSR_mhpmevent4 12'h324
`define CSR_mhpmevent31 12'h33F
/* Debug/Trace Registers (shared with Debug Mode) */
`define CSR_tselect 12'h7A0
`define CSR_tdata1 12'h7A1
`define CSR_tdata2 12'h7A2
`define CSR_tdata3 12'h7A3
/* Debug Mode Registers */
`define CSR_dcsr 12'h7B0
`define CSR_dpc 12'h7B1
`define CSR_dscratch 12'h7B2


`define CSR_mtvec_addr_bus 31:2
`define CSR_mepc_addr_bus 31:2

`define CSR_medeleg_bus 11:0
`define CSR_mideleg_bus 11:0

/* mstatus */
`define CSR_mstatus_vm_bus 28:24
`define CSR_mstatus_vm_Mbare 5'h0
`define CSR_mstatus_vm_Sv32 5'h8
`define CSR_mstatus_vm_Sv39 5'h9
`define CSR_mstatus_vm_Sv48 5'h10

`define CSR_mstatus_fs_bus 14:13
`define CSR_mstatus_fs_Off 2'h0
`define CSR_mstatus_fs_Initial 2'h1
`define CSR_mstatus_fs_Clean 2'h2
`define CSR_mstatus_fs_Dirty 2'h3
`ifdef RV32
	`define CSR_mstatus_sd_bus 31:31
`else
	`define CSR_mstatus_sd_bus 63:63
`endif
`define CSR_mstatus_mpp_bus 12:11
`define CSR_mstatus_hpp_bus 10:9
`define CSR_mstatus_spp_bus 8:8

`define CSR_mstatus_mpie_bus 7:7
`define CSR_mstatus_hpie_bus 6:6
`define CSR_mstatus_spie_bus 5:5
`define CSR_mstatus_upie_bus 4:4

`define CSR_mstatus_mie_bus 3:3
`define CSR_mstatus_hie_bus 2:2
`define CSR_mstatus_sie_bus 1:1
`define CSR_mstatus_uie_bus 0:0

/* mip */
`define CSR_mip_usip_bus 0:0
`define CSR_mip_ssip_bus 1:1
`define CSR_mip_hsip_bus 2:2
`define CSR_mip_msip_bus 3:3

`define CSR_mip_utip_bus 4:4
`define CSR_mip_stip_bus 5:5
`define CSR_mip_htip_bus 6:6
`define CSR_mip_mtip_bus 7:7

`define CSR_mip_ueip_bus 8:8
`define CSR_mip_seip_bus 9:9
`define CSR_mip_heip_bus 10:10
`define CSR_mip_meip_bus 11:11


/*
fcsr
fflags
mbadaddr
mcause
medeleg
mepc
mhartid
mideleg
mie
mip
misa
mscounteren
mscratch
mstatus
mtvec
mucounteren
sbadaddr
scause
sepc
sie
sptbr
stvec

sbadaddr
scause
sepc
sie
sptbr
sscratch
sstatus
stvec
*/




//`define StartInstAddr    32'hbfc0_0000
`define StartInstAddr    32'h8000_0000 // TODO: fix me

//wishbone FSM
`define WB_IDLE 2'b00
`define WB_BUSY 2'b01
`define WB_WAIT_FOR_FLUSHING 2'b10
`define WB_WAIT_FOR_STALL 2'b11

