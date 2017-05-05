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
// Module:  ex_mem
// File:    ex_mem.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: EX/MEM阶段的寄存器
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module ex_mem(

	input wire clk,
	input wire rst_n,

	//来自控制模块的信息
	input wire[5:0] stall,
	input wire flush,
	
	//来自执行阶段的信息	
	input wire[`RegAddrBus] ex_wd,
	input wire ex_wreg,
	input wire[`RegBus] ex_wdata,
	//为实现加载、访存指令而添加
	input wire[`AluOpBus] ex_aluop,
	input wire[`RegBus] ex_mem_addr,
	input wire[`RegBus] ex_reg2,

	// 即将暂停的 ex 上一阶段保存的信息
	input wire[1:0] cnt_i,
	input wire div_started_i,

	// 要写入 csr 的信息
	input wire[`CSRWriteTypeBus] ex_csr_reg_we,
	input wire[`CSRAddrBus] ex_csr_reg_addr,
	input wire[`RegBus] ex_csr_reg_data,

	// 要写入的物理地址
	input wire [`PhyAddrBus]ex_mem_phy_addr,
	input wire ex_data_tlb_r_exception,
	input wire ex_data_tlb_w_exception,


	// 收集到的异常的信息
	input wire[`ExceptionTypeBus] ex_excepttype,
	input wire ex_is_in_delayslot,
	input wire[`RegBus] ex_current_inst_address,
	input wire ex_not_stall,
	
	//送到访存阶段的信息
	output reg[`RegAddrBus] mem_wd,
	output reg mem_wreg,
	output reg[`RegBus] mem_wdata,
	//为实现加载、访存指令而添加
	output reg[`AluOpBus] mem_aluop,
	output reg[`RegBus] mem_mem_addr,
	output reg[`RegBus] mem_reg2,

	// 要写入 csr 的信息
	output reg[`CSRWriteTypeBus] mem_csr_reg_we,
	output reg[`CSRAddrBus] mem_csr_reg_addr,
	output reg[`RegBus] mem_csr_reg_data,

	// 送到下一阶段的异常的信息
	output reg[`ExceptionTypeBus] mem_excepttype,
	output reg mem_is_in_delayslot,
	output reg[`RegBus] mem_current_inst_address,
	output reg mem_not_stall,


	// 送到下一阶段的物理地址
	output reg [`PhyAddrBus]mem_mem_phy_addr,
	output reg mem_data_tlb_r_exception,
	output reg mem_data_tlb_w_exception,

	// 即将暂停的 ex 下一阶段需要的信息
	output reg[1:0] cnt_o,
	output reg div_started_o
);


	always @ (posedge clk or negedge rst_n) 
	begin
		if(rst_n == `RstEnable)
		begin
			mem_wd <= `NOPRegAddr;
			mem_wreg <= `WriteDisable;
			mem_wdata <= `ZeroWord;	
			
			mem_aluop <= `EXE_NOP_OP;
			mem_mem_addr <= `ZeroWord;
			mem_reg2 <= `ZeroWord;

			mem_csr_reg_we <= `CSRWriteDisable;
			mem_csr_reg_addr <= `NOPRegAddr;
			mem_csr_reg_data <= `ZeroWord;

			mem_excepttype <= `ZeroWord;
			mem_is_in_delayslot <= `NotInDelaySlot;
			mem_current_inst_address <= `ZeroWord;
			mem_not_stall <= `False_v;

			mem_mem_phy_addr <= `ZeroWord;
			mem_data_tlb_r_exception <= `False_v;
			mem_data_tlb_w_exception <= `False_v;

			cnt_o <= 2'b00;
			div_started_o <= 1'b0;

		end 
		else if(flush == `Flush)
		begin
			mem_wd <= `NOPRegAddr;
			mem_wreg <= `WriteDisable;
			mem_wdata <= `ZeroWord;
			
			mem_aluop <= `EXE_NOP_OP;
			mem_mem_addr <= `ZeroWord;
			mem_reg2 <= `ZeroWord;

			mem_csr_reg_we <= `CSRWriteDisable;
			mem_csr_reg_addr <= `NOPRegAddr;
			mem_csr_reg_data <= `ZeroWord;

			mem_excepttype <= `ZeroWord;
			mem_is_in_delayslot <= `NotInDelaySlot;
			mem_current_inst_address <= `ZeroWord;
			mem_not_stall <= `False_v;

			mem_mem_phy_addr <= `ZeroWord;
			mem_data_tlb_r_exception <= `False_v;
			mem_data_tlb_w_exception <= `False_v;

			cnt_o <= 2'b00;
			div_started_o <= 1'b0;
		end 
		else if(stall[3] == `Stop && stall[4] == `NoStop)
		begin
			mem_wd <= `NOPRegAddr;
			mem_wreg <= `WriteDisable;
			mem_wdata <= `ZeroWord;

			mem_aluop <= `EXE_NOP_OP;
			mem_mem_addr <= `ZeroWord;
			mem_reg2 <= `ZeroWord;

			mem_csr_reg_we <= `CSRWriteDisable;
			mem_csr_reg_addr <= `NOPRegAddr;
			mem_csr_reg_data <= `ZeroWord;

			mem_excepttype <= `ZeroWord;
			mem_is_in_delayslot <= `NotInDelaySlot;
			mem_current_inst_address <= `ZeroWord;
			mem_not_stall <= `False_v;

			mem_mem_phy_addr <= `ZeroWord;
			mem_data_tlb_r_exception <= `False_v;
			mem_data_tlb_w_exception <= `False_v;

			cnt_o <= cnt_i;
			div_started_o <= div_started_i;
		end
		else if(stall[3] == `NoStop)
		begin
			mem_wd <= ex_wd;
			mem_wreg <= ex_wreg;
			mem_wdata <= ex_wdata;

			mem_aluop <= ex_aluop;
			mem_mem_addr <= ex_mem_addr;
			mem_reg2 <= ex_reg2;
			
			mem_csr_reg_we <= ex_csr_reg_we;
			mem_csr_reg_addr <= ex_csr_reg_addr;
			mem_csr_reg_data <= ex_csr_reg_data;

			mem_excepttype <= ex_excepttype;
			mem_is_in_delayslot <= ex_is_in_delayslot;
			mem_current_inst_address <= ex_current_inst_address;
			mem_not_stall <= ex_not_stall;

			mem_mem_phy_addr <= ex_mem_phy_addr;
			mem_data_tlb_r_exception <= ex_data_tlb_r_exception;
			mem_data_tlb_w_exception <= ex_data_tlb_w_exception;

			cnt_o <= 2'b00;
			div_started_o <= 1'b0;
		end
		else // stall[3] 停，stall[4] 也停，mem_* 保持不变 
		begin
			cnt_o <= cnt_i;
			div_started_o <= div_started_i;
		end
	end
			

endmodule
