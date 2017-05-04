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
// Module:  pc_reg
// File:    pc_reg.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: 指令指针寄存器PC
// Revision: 1.0



//////////////////////////////////////////////////////////////////////

`include "defines.v"

module pc_reg(

	input wire clk,
	input wire rst_n,

	//来自控制模块的信息
	input wire[5:0] stall,

	input wire flush,
	input wire[`RegBus] exception_new_pc,

	//来自译码阶段的信息
	input wire branch_flag_i,
	input wire[`RegBus] branch_target_address_i,

	// TLB 提供的物理地址
	input wire[`PhyAddrBus] next_inst_phy_addr_i,
	input wire next_inst_tlb_exception_i,

	// pc 寄存器，及其物理地址
	output reg[`RegBus] pc,
	output reg[`PhyAddrBus] inst_phy_addr_o,
	
	// 指令存储器是否使能
	output reg ce,

	// 接到 MMU 提前查物理地址
	output reg[`RegBus] next_inst_vir_addr_o,
	output wire pc_ce_o,

	// pc_reg 做虚实地址转换的时候发生的异常
	output reg[`ExceptionTypeBus] excepttype_o
);
	// 在 rst 的时候我也要提前查第一条指令的物理地址
	assign pc_ce_o = `ChipEnable;
	
	always @ (*)
		if (rst_n == `RstEnable)
			next_inst_vir_addr_o <= `StartInstAddr;
		else if (ce == `ChipDisable)
			next_inst_vir_addr_o <= `StartInstAddr;
		else if(flush == `Flush)
			next_inst_vir_addr_o <= exception_new_pc;
		else
		begin
			if(branch_flag_i == `Branch)
				next_inst_vir_addr_o <= branch_target_address_i;
			else
	 			next_inst_vir_addr_o <= pc + 4'h4;
	 	end

	reg[`ExceptionTypeBus] excepttype;
	always @(*)
		if (rst_n == `RstEnable)
		begin
			excepttype <= `ZeroWord;
		end
		else
		begin
			excepttype <= `ZeroWord;

			excepttype[`Exception_INST_MISALIGNED] <= (next_inst_vir_addr_o[1:0] != 2'b00);
			excepttype[`Exception_INST_ACCESS_FAULT] <= next_inst_tlb_exception_i;
		end

	always @ (posedge clk or negedge rst_n)
	begin
		if (rst_n == `RstEnable)
		begin
			pc <= `StartInstAddr;

			ce <= `ChipDisable;
			inst_phy_addr_o <= `ZeroWord;
			excepttype_o <= `ZeroWord;
		end
		else if(flush == `Flush)
		begin
			pc <= next_inst_vir_addr_o;

			ce <= `ChipEnable;
			inst_phy_addr_o <= next_inst_phy_addr_i;
			excepttype_o <= excepttype;
		end
		else if(stall[0] == `NoStop)
		begin
			pc <= next_inst_vir_addr_o;

			ce <= `ChipEnable;
			inst_phy_addr_o <= next_inst_phy_addr_i;
			excepttype_o <= excepttype;
		end

	end
	
endmodule
