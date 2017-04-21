//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2014 leishangwen@163.com                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// Module:  ex
// File:    ex.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: 执行阶段
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module ex(

	input wire rst_n,
	
	// 送到执行阶段的信息
	input wire[`AluOpBus] aluop_i,
	input wire[`AluSelBus] alusel_i,
	input wire[`RegBus] reg1_i,
	input wire[`RegBus] reg2_i,
	input wire[`RegBus] imm_i,
	input wire[`RegAddrBus] wd_i,
	input wire wreg_i,
	input wire[`InstBus] inst_i,

	// 已经检测到的异常和指令地址及其是否合法
	input wire[`ExceptionTypeBus] excepttype_i,
	input wire[`RegBus] current_inst_address_i,
	input wire not_stall_i,

	// HILO 模块给出的 HI、LO 寄存器的值
	input wire[`RegBus] hi_i,
	input wire[`RegBus] lo_i,

	//回写阶段的指令是否要写HI、LO，用于检测HI、LO的数据相关
	input wire[`RegBus] wb_hi_i,
	input wire[`RegBus] wb_lo_i,
	input wire wb_whilo_i,
	
	//访存阶段的指令是否要写HI、LO，用于检测HI、LO的数据相关
	input wire[`RegBus] mem_hi_i,
	input wire[`RegBus] mem_lo_i,
	input wire mem_whilo_i,
	
	// 暂停，上一次 ex 得到的结果
	input wire[`DoubleRegBus] hilo_temp_i,
	input wire[1:0] cnt_i,
	input wire div_started_i,

	// 除法模块给的结果
	input wire[`DoubleRegBus] div_result_i,
	input wire div_ready_i,

	// 是否在延迟槽中、以及link address
	input wire[`RegBus] link_address_i,
	input wire is_in_delayslot_i,

	/*
	//访存阶段的指令是否要写csr，用来检测数据相关
	input wire mem_csr_reg_we,
	input wire[`CSRAddrBus] mem_csr_reg_write_addr,
	input wire[`RegBus] mem_csr_reg_data,
	
	//回写阶段的指令是否要写csr，用来检测数据相关
	input wire wb_csr_reg_we,
	input wire[`CSRAddrBus] wb_csr_reg_write_addr,
	input wire[`RegBus] wb_csr_reg_data,
	*/

	//csr
	input wire[`CSRWriteTypeBus] csr_reg_we_i,
	input wire[`RegBus] csr_reg_data_i,

	// TLB 提供的物理地址
	input wire[`RegBus] mem_phy_addr_i,
	input wire data_tlb_r_miss_exception_i,
	input wire data_tlb_w_miss_exception_i,
	input wire data_tlb_mod_exception_i, 

	//向下一流水级传递，用于写csr中的寄存器
	output wire[`CSRWriteTypeBus] csr_reg_we_o,
	output wire[`CSRAddrBus] csr_reg_write_addr_o,
	output wire[`RegBus] csr_reg_data_o,
	output reg csr_write_tlb_index_o,
	output reg csr_write_tlb_random_o,

	// 是否写寄存器，以及寄存器的地址和要写的值
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
	output reg[`RegBus] wdata_o,
	
	// 是否写入 hi, lo, 要写入的值
	output reg[`RegBus] hi_o,
	output reg[`RegBus] lo_o,
	output reg whilo_o,

	// 暂停，下一次 ex 需要的结果
	output reg[`DoubleRegBus] hilo_temp_o,
	output reg[1:0] cnt_o,
	output reg div_started_o,

	// 发送给除法器的请求
	output reg[`RegBus] div_opdata1_o,
	output reg[`RegBus] div_opdata2_o,
	output reg div_start_o,
	output reg signed_div_o,

	// 为加载、存储指令准备的，
	// 内存的写使能和使能是为了虚实地址转换而粗略计算的，不见得是最后的答案
	// 最后如果使能确实是开的话，则这里必须要是开，写使能也是如此
	output wire[`AluOpBus] aluop_o,
	output wire[`RegBus] mem_addr_o,
	output reg mem_we_o,
	output reg mem_ce_o,
	output wire[`RegBus] reg2_o,
	
	// 新检测出的异常类型
	output wire[`ExceptionTypeBus] excepttype_o,
	// 当前指令是否在延迟槽中
	output wire is_in_delayslot_o,
	// 当前指令地址以及其是否合法
	output wire[`RegBus] current_inst_address_o,
	output wire not_stall_o,


	// 告诉 MEM 阶段的物理地址
	output wire[`RegBus] mem_phy_addr_o,
	output wire data_tlb_r_miss_exception_o,
	output wire data_tlb_w_miss_exception_o,
	output wire data_tlb_mod_exception_o, 

	output reg stallreq
);
	reg[`RegBus] logicout;
	reg[`RegBus] shiftout;
	reg[`RegBus] moveout;

	reg[`RegBus] arithout;
	reg[`DoubleRegBus] multiout;

	// 自陷异常
	reg trapassert;
	// 溢出异常
	reg ovassert;

	// exceptiontype
	//   0   machine check   TLB write that conflicts with an existing entry
	//   1-8 外部中斷         Assertion of unmasked HW or SW interrupt signal.
	// . 9   adEl            Fetch address alignment error.
	// . 10  TLBL            Fetch TLB miss, Fetch TLB hit to page with V=0 (inst)
	// . 11  syscall
	// . 12  RI              無效指令 Reserved Instruction
	// * 13  ov              溢出
	// * 14  trap
	//   15  AdEL            Load address alignment error,  
	//   16  adES            Store address alignment error.
	//                       User mode store to kernel address.
	//   17  TLBL            Load TLB miss,  (4Kc core). (data)
	//   18  TLBS            Store TLB miss
	//   19  TLB Mod         Store to TLB page with D=0
	// . 20  ERET
	// . 21  FENCE.I
	assign excepttype_o = {excepttype_i[31:15], trapassert, ovassert, excepttype_i[12:0]};

	assign is_in_delayslot_o = is_in_delayslot_i;
	assign current_inst_address_o = current_inst_address_i;
	assign not_stall_o = not_stall_i;

	/***********************************************************/

	// logic op
	always @ (*)
		if(rst_n == `RstEnable)
			logicout <= `ZeroWord;
		else
			case (aluop_i)
				`EXE_OR_OP: logicout <= reg1_i | reg2_i;
				`EXE_AND_OP: logicout <= reg1_i & reg2_i;
				`EXE_XOR_OP: logicout <= reg1_i ^ reg2_i;
				default: logicout <= `ZeroWord;
			endcase
	
	/***********************************************************/

	// shift op
	always @ (*)
		if(rst_n == `RstEnable)
			shiftout <= `ZeroWord;
		else
			case (aluop_i)
				`EXE_SLL_OP: shiftout <= reg1_i << reg2_i[4:0];
				`EXE_SRL_OP: shiftout <= reg1_i >> reg2_i[4:0];
				`EXE_SRA_OP: shiftout <= $signed(reg1_i) >>> reg2_i[4:0];
				default: shiftout <= `ZeroWord;
			endcase

	/***********************************************************/

	// arithmetic op
	wire reg1_lt_reg2;
	wire [`RegBus] reg2_i_mux;
	wire [`RegBus] result_sum;

	assign reg2_i_mux = 
			(
				aluop_i == `EXE_SUB_OP || aluop_i == `EXE_TLT_OP || aluop_i == `EXE_TGE_OP 
			) ? ((~reg2_i) + 1'b1) : reg2_i;

	assign result_sum = reg1_i + reg2_i_mux;

	assign reg1_lt_reg2 =
			(aluop_i == `EXE_SLT_OP || aluop_i == `EXE_TLT_OP || aluop_i == `EXE_TGE_OP) ? 
				($signed(reg1_i) < $signed(reg2_i)) : (reg1_i < reg2_i);

	always @ (*)
		if(rst_n == `RstEnable)
			arithout <= `ZeroWord;
		else
			case (aluop_i)
				`EXE_SLT_OP, `EXE_SLTU_OP:
					arithout <= reg1_lt_reg2;

				`EXE_ADD_OP, `EXE_SUB_OP:
					arithout <= result_sum;

				default: arithout <= `ZeroWord;
			endcase
	
	/***********************************************************/

	// trap op
	always @ (*)
		if(rst_n == `RstEnable)
			trapassert <= `TrapNotAssert;
		else
		begin
			trapassert <= `TrapNotAssert;
			case (aluop_i)
				`EXE_TEQ_OP:
					if(reg1_i == reg2_i) trapassert <= `TrapAssert;
					
				`EXE_TGE_OP, `EXE_TGEU_OP:
					if(~reg1_lt_reg2) trapassert <= `TrapAssert;
					
				`EXE_TLT_OP, `EXE_TLTU_OP:
					if(reg1_lt_reg2) trapassert <= `TrapAssert;
					
				`EXE_TNE_OP:
					if(reg1_i != reg2_i) trapassert <= `TrapAssert;
					
				default:
					trapassert <= `TrapNotAssert;
			endcase
		end


	reg[`RegBus] HI;
	reg[`RegBus] LO;
	
	// HI、LO 寄存器数据旁路
	// 得到最新的HI、LO寄存器的值，此处要解决指令数据相关问题
	always @ (*) begin
		if(rst_n == `RstEnable) begin
			{HI, LO} <= {`ZeroWord, `ZeroWord};
		end else if(mem_whilo_i == `WriteEnable) begin
			{HI, LO} <= {mem_hi_i, mem_lo_i};
		end else if(wb_whilo_i == `WriteEnable) begin
			{HI, LO} <= {wb_hi_i, wb_lo_i};
		end else begin
			{HI, LO} <= {hi_i, lo_i};			
		end
	end
	
	

	// move op
	always @ (*)
		if(rst_n == `RstEnable)
			moveout <= `ZeroWord;
		else
			case (aluop_i)
				`EXE_MFHI_OP: moveout <= HI;
				`EXE_MFLO_OP: moveout <= LO;

				`EXE_MOVZ_OP, `EXE_MOVN_OP:
					moveout <= reg1_i;
				
				`EXE_CSRRW_OP, `EXE_CSRRS_OP, `EXE_CSRRC_OP:
					moveout <= csr_reg_data_i;

				default: moveout <= `ZeroWord;
			endcase

	// multi op
	wire [`DoubleRegBus] opdata1_mult;
	wire [`DoubleRegBus] opdata2_mult;
	wire [`DoubleRegBus] result_mul;

	assign opdata1_mult = 
		(
			aluop_i == `EXE_MULT_OP || 
			aluop_i == `EXE_MADD_OP || 
			aluop_i == `EXE_MSUB_OP
		) ? {{32{reg1_i[31]}}, reg1_i} : {`ZeroWord, reg1_i};

	assign opdata2_mult = 
		(
			aluop_i == `EXE_MULT_OP || 
			aluop_i == `EXE_MADD_OP || 
			aluop_i == `EXE_MSUB_OP
		) ? {{32{reg2_i[31]}}, reg2_i} : {`ZeroWord, reg2_i};

	assign result_mul = opdata1_mult * opdata2_mult;
	
	always @ (*)
		if(rst_n == `RstEnable)
			multiout <= {`ZeroWord, `ZeroWord};
		else 
			multiout <= result_mul;

	// madd op, msub op
	reg [`DoubleRegBus]madd_msub_out;
	reg stallreq_for_madd_msub;

	always @ (*)
		if(rst_n == `RstEnable)
		begin
			hilo_temp_o <= {`ZeroWord, `ZeroWord};
			cnt_o <= 2'b00;
			stallreq_for_madd_msub <= `NoStop;
			madd_msub_out <= {`ZeroWord, `ZeroWord};
		end
		else
		begin
			case(aluop_i)
				`EXE_MADD_OP, `EXE_MADDU_OP:
				begin
					if(cnt_i == 2'b00)
					begin
						hilo_temp_o <= multiout;
						cnt_o <= 2'b01;
						madd_msub_out <= {`ZeroWord, `ZeroWord};
						stallreq_for_madd_msub <= `Stop;
					end
					else if(cnt_i == 2'b01)
					begin
						hilo_temp_o <= hilo_temp_i + {HI, LO};
						cnt_o <= 2'b10;
						madd_msub_out <= hilo_temp_i + {HI, LO};
						stallreq_for_madd_msub <= `NoStop;
					end
					else
					begin
						hilo_temp_o <= hilo_temp_i;
						cnt_o <= 2'b10;
						madd_msub_out <= hilo_temp_i;
						stallreq_for_madd_msub <= `NoStop;
					end
				end

				`EXE_MSUB_OP, `EXE_MSUBU_OP:
				begin
					if(cnt_i == 2'b00)
					begin
						hilo_temp_o <= multiout;
						cnt_o <= 2'b01;
						madd_msub_out <= {`ZeroWord, `ZeroWord};
						stallreq_for_madd_msub <= `Stop;
					end
					else if(cnt_i == 2'b01)
					begin
						hilo_temp_o <= {HI, LO} - hilo_temp_i;
						cnt_o <= 2'b10;
						madd_msub_out <= {HI, LO} - hilo_temp_i;
						stallreq_for_madd_msub <= `NoStop;
					end
					else
					begin
						hilo_temp_o <= hilo_temp_i;
						cnt_o <= 2'b10;
						madd_msub_out <= hilo_temp_i;
						stallreq_for_madd_msub <= `NoStop;
					end
				end

				default:
				begin
					hilo_temp_o <= {`ZeroWord, `ZeroWord};
					cnt_o <= 2'b00;
					madd_msub_out <= {`ZeroWord, `ZeroWord};
					stallreq_for_madd_msub <= `NoStop;
				end
			endcase
		end


	reg stallreq_for_div;

	// div, divu
	always @ (*) begin
		if(rst_n == `RstEnable)
		begin
			stallreq_for_div <= `NoStop;
			div_opdata1_o <= `ZeroWord;
			div_opdata2_o <= `ZeroWord;
			div_start_o <= `DivStop;
			signed_div_o <= 1'b0;
			div_started_o <= 1'b0;
		end
		else
		begin
			stallreq_for_div <= `NoStop;
			div_opdata1_o <= `ZeroWord;
			div_opdata2_o <= `ZeroWord;
			div_start_o <= `DivStop;
			signed_div_o <= 1'b0;
			div_started_o <= 1'b0;

			case (aluop_i) 
				`EXE_DIV_OP, `EXE_DIVU_OP:
				begin
					if(div_started_i == 1'b0)
					begin
						div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStart;
						signed_div_o <= (aluop_i == `EXE_DIV_OP) ? 1'b1 : 1'b0;
						div_started_o <= 1'b1;
						stallreq_for_div <= `Stop;
					end
					else if(div_started_i == 1'b1)
					begin
						div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStop;
						signed_div_o <= (aluop_i == `EXE_DIV_OP) ? 1'b1 : 1'b0;
						div_started_o <= 1'b1;
						stallreq_for_div <= (div_ready_i == `DivResultReady) ? `NoStop : `Stop;
					end
				end
				default:
				begin
				end
			endcase
		end
	end	

	//aluop_o传递到访存阶段，用于加载、存储指令
	//到时候再决定其加载、存储类型
	assign aluop_o = aluop_i;

	//mem_addr传递到访存阶段，是加载、存储指令对应的存储器地址
	assign mem_addr_o = imm_i;

	//将两个操作数也传递到访存阶段，也是为记载、存储指令准备的
	// 存储，lwl, lwr 指令需要
	assign reg2_o = reg2_i;

	assign mem_phy_addr_o = mem_phy_addr_i;
	assign data_tlb_r_miss_exception_o = data_tlb_r_miss_exception_i;
	assign data_tlb_w_miss_exception_o = data_tlb_w_miss_exception_i;
	assign data_tlb_mod_exception_o = data_tlb_mod_exception_i;

	always @(*)
		if(rst_n == `RstEnable)
			{mem_we_o, mem_ce_o} <= {`WriteDisable, `ChipDisable};
		else
			case(aluop_i)
				`EXE_LB_OP, `EXE_LBU_OP, `EXE_LH_OP, `EXE_LHU_OP, `EXE_LW_OP, `EXE_LWL_OP, `EXE_LWR_OP, `EXE_LL_OP:
					{mem_we_o, mem_ce_o} <= {`WriteDisable, `ChipEnable};

				`EXE_SB_OP, `EXE_SH_OP, `EXE_SW_OP, `EXE_SWL_OP, `EXE_SWR_OP, `EXE_SC_OP:
					{mem_we_o, mem_ce_o} <= {`WriteEnable, `ChipEnable};
					
				default:
					{mem_we_o, mem_ce_o} <= {`WriteDisable, `ChipDisable};
			endcase



	/************************** 暂停流水线 ******************************/
	always @(*)
	 	stallreq <= stallreq_for_madd_msub || stallreq_for_div; 


	/***************** 这条指令要写到 regfile 的内容 ********************/

	always @ (*)
		if(rst_n == `RstEnable)
		begin
			wreg_o <= `WriteDisable;
			wd_o <= `NOPRegAddr;
			wdata_o <= `ZeroWord;
			ovassert <= `OverflowNotAssert;
		end
		else
		begin
			wd_o <= wd_i;
			wreg_o <= wreg_i;
			ovassert <= `OverflowNotAssert;

			case ( alusel_i ) 
				`EXE_RES_LOGIC:
					wdata_o <= logicout;
					
				`EXE_RES_SHIFT:
					wdata_o <= shiftout;
					
				`EXE_RES_MOVE:
					wdata_o <= moveout;

				`EXE_RES_ARITHMETIC:
					wdata_o <= arithout;

				`EXE_RES_MUL:
					wdata_o <= multiout[31:0];

				`EXE_RES_JUMP_BRANCH:
					wdata_o <= link_address_i;
				
				default:
					wdata_o <= `ZeroWord;
			endcase
		end
	
	
	/***************** 这条指令要写到 hi, lo 的内容 ********************/
	always @ (*)
		if(rst_n == `RstEnable)
		begin
			whilo_o <= `WriteDisable;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;		
		end
		else if(aluop_i == `EXE_MULT_OP || aluop_i == `EXE_MULTU_OP)
		begin
			whilo_o <= `WriteEnable;
			{hi_o, lo_o} <= multiout;
		end 
		else if(aluop_i == `EXE_MADD_OP || aluop_i == `EXE_MADDU_OP ||
				aluop_i == `EXE_MSUB_OP || aluop_i == `EXE_MSUBU_OP)
		begin
			whilo_o <= `WriteEnable;
			{hi_o, lo_o} <= madd_msub_out;
		end 
		else if(aluop_i == `EXE_DIV_OP || aluop_i == `EXE_DIVU_OP)
		begin
			whilo_o <= `WriteEnable;
			{hi_o, lo_o} <= div_result_i;
		end
		else if(aluop_i == `EXE_MTHI_OP)
		begin
			whilo_o <= `WriteEnable;
			hi_o <= reg1_i;
			lo_o <= LO;
		end 
		else if(aluop_i == `EXE_MTLO_OP)
		begin
			whilo_o <= `WriteEnable;
			hi_o <= HI;
			lo_o <= reg1_i;
		end 
		else 
		begin
			whilo_o <= `WriteDisable;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
		end

	/******************* 这条指令要写到 csr 的内容 **********************/
	assign csr_reg_write_addr_o = inst_i[31:20];
	assign csr_reg_data_o = reg1_i;
	assign csr_reg_we_o = csr_reg_we_i;

	always @ (*)
		if(rst_n == `RstEnable)
		begin
			csr_write_tlb_index_o <= `False_v;
			csr_write_tlb_random_o <= `False_v;
		end
		else
		begin
			csr_write_tlb_index_o <= `False_v;
			csr_write_tlb_random_o <= `False_v;

			case(aluop_i)
				`EXE_CSRRW_OP:
				begin
				end

				default:
				begin
				end
			endcase
		end
endmodule
