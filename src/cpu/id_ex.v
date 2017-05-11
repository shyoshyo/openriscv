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
// Module:  id_ex
// File:    id_ex.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: ID/EX阶段的寄存器
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module id_ex(

	input wire clk,
	input wire rst_n,
	input wire[5:0] stall,
	input wire flush,

	
	//从译码阶段传递的信息
	input wire[`AluOpBus] id_aluop,
	input wire[`AluSelBus] id_alusel,
	input wire[`RegBus] id_reg1,
	input wire[`RegBus] id_reg2,
	input wire[`RegBus] id_mem_addr,
	input wire[`RegAddrBus] id_wd,
	input wire id_wreg,
	input wire[`RegBus] id_link_address,
	input wire id_is_in_delayslot,
	input wire[`InstBus] id_inst,
	input wire[`RegBus] id_current_inst_address,
	input wire id_not_stall,
	input wire[`ExceptionTypeBus] id_excepttype,

	input wire[`CSRWriteTypeBus] id_csr_reg_we,
	input wire[`CSRAddrBus] id_csr_reg_addr,
	input wire[`RegBus] id_csr_reg_data,

	// 译码阶段要传回去的信息
	input wire next_inst_in_delayslot_i,
	input wire step_i,
	
	//传递到执行阶段的信息
	output reg[`AluOpBus] ex_aluop,
	output reg[`AluSelBus] ex_alusel,
	output reg[`RegBus] ex_reg1,
	output reg[`RegBus] ex_reg2,
	output reg[`RegBus] ex_mem_addr,
	output reg[`RegAddrBus] ex_wd,
	output reg ex_wreg,
	output reg[`RegBus] ex_link_address,
	output reg ex_is_in_delayslot,
	output reg[`InstBus] ex_inst,
	output reg[`ExceptionTypeBus] ex_excepttype,
	output reg[`RegBus] ex_current_inst_address,
	output reg ex_not_stall,

	output reg[`CSRWriteTypeBus] ex_csr_reg_we,
	output reg[`CSRAddrBus] ex_csr_reg_addr,
	output reg[`RegBus] ex_csr_reg_data,

	// 传回 id 阶段
	output reg is_in_delayslot_o,
	output reg step_o
);

	always @ (posedge clk or negedge rst_n) begin
		if (rst_n == `RstEnable)
		begin
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_mem_addr <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;

			ex_link_address <= `ZeroWord;
			ex_is_in_delayslot <= `NotInDelaySlot;
			ex_inst <= `ZeroWord;
			ex_excepttype <= `ZeroWord;
			ex_current_inst_address <= `ZeroWord;
			ex_not_stall <= `False_v;

			ex_csr_reg_we <= `CSRWriteDisable;
			ex_csr_reg_addr <= `ZeroWord;
			ex_csr_reg_data <= `ZeroWord;

			is_in_delayslot_o <= `NotInDelaySlot;
			step_o <= 1'b0;
		end
		else if(flush == `Flush)
		begin
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_mem_addr <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;

			ex_link_address <= `ZeroWord;
			ex_is_in_delayslot <= `NotInDelaySlot;
			ex_inst <= `ZeroWord;
			ex_excepttype <= `ZeroWord;
			ex_current_inst_address <= `ZeroWord;
			ex_not_stall <= `False_v;

			ex_csr_reg_we <= `CSRWriteDisable;
			ex_csr_reg_addr <= `ZeroWord;
			ex_csr_reg_data <= `ZeroWord;

			is_in_delayslot_o <= `NotInDelaySlot;
			step_o <= 1'b0;
		end
		else if(stall[2] == `Stop && stall[3] == `NoStop)
		begin
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_mem_addr <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;

			ex_link_address <= `ZeroWord;
			ex_is_in_delayslot <= `NotInDelaySlot;
			ex_inst <= `ZeroWord;
			ex_excepttype <= `ZeroWord;
			ex_current_inst_address <= `ZeroWord;
			ex_not_stall <= `False_v;

			ex_csr_reg_we <= `CSRWriteDisable;
			ex_csr_reg_addr <= `ZeroWord;
			ex_csr_reg_data <= `ZeroWord;

			// no is_in_delayslot_o, for inputs of id must be kept
			// step_o has to be set, for continuing to next stage of id  
			step_o <= step_i;
		end
		else if(stall[2] == `NoStop)
		begin
			ex_aluop <= id_aluop;
			ex_alusel <= id_alusel;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_mem_addr <= id_mem_addr;
			ex_wd <= id_wd;
			ex_wreg <= id_wreg;

			ex_link_address <= id_link_address;
			ex_is_in_delayslot <= id_is_in_delayslot;
			ex_inst <= id_inst;
			ex_excepttype <= id_excepttype;
			ex_current_inst_address <= id_current_inst_address;
			ex_not_stall <= id_not_stall;

			ex_csr_reg_we <= id_csr_reg_we;
			ex_csr_reg_addr <= id_csr_reg_addr;
			ex_csr_reg_data <= id_csr_reg_data;

			is_in_delayslot_o <= next_inst_in_delayslot_i;
			step_o <= 1'b0;
		end
		else // stall[2] 停，stall[3] 也停，exe_* 保持不变
		begin
			step_o <= step_i;
		end
	end
	
endmodule