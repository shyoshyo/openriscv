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
// Module:  mem_wb
// File:    mem_wb.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: MEM/WB阶段的寄存器
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module mem_wb(
	input wire clk,
	input wire rst_n,
	input wire[5:0] stall,
	input wire flush,
	
	//来自访存阶段的信息	
	input wire[`RegAddrBus] mem_wd,
	input wire mem_wreg,
	input wire[`RegBus] mem_wdata,
	input wire mem_LLbit_we,
	input wire mem_LLbit_value,
	input wire [`PhyAddrBus]mem_LLbit_addr,
	
	input wire[`CSRWriteTypeBus] mem_csr_reg_we,
	input wire[`CSRAddrBus] mem_csr_reg_addr,
	input wire[`RegBus] mem_csr_reg_data,


	input wire [1:0] mem_cnt_i,
	input wire[`RegBus] mem_original_data_i,

	//送到回写阶段的信息
	output reg[`RegAddrBus] wb_wd,
	output reg wb_wreg,
	output reg[`RegBus] wb_wdata,
	
	output reg wb_LLbit_we,
	output reg wb_LLbit_value,
	output reg [`PhyAddrBus]wb_LLbit_addr,

	output reg[`CSRWriteTypeBus] wb_csr_reg_we,
	output reg[`CSRAddrBus] wb_csr_reg_addr,
	output reg[`RegBus] wb_csr_reg_data,

	// send back to mem
	output reg [1:0] mem_cnt_o,
	output reg [`RegBus] mem_original_data_o
);


	always @ (posedge clk or negedge rst_n)
	begin
		if(rst_n == `RstEnable)
		begin
			wb_wd <= `NOPRegAddr;
			wb_wreg <= `WriteDisable;
			wb_wdata <= `ZeroWord;
			
			wb_LLbit_we <= 1'b0;
			wb_LLbit_value <= 1'b0;
			wb_LLbit_addr <= `ZeroWord;
			
			wb_csr_reg_we <= `CSRWriteDisable;
			wb_csr_reg_addr <= `NOPRegAddr;
			wb_csr_reg_data <= `ZeroWord;

			mem_cnt_o <= 2'h0;
			mem_original_data_o <= `ZeroWord;
		end
		else if(flush == `Flush)
		begin
			wb_wd <= `NOPRegAddr;
			wb_wreg <= `WriteDisable;
			wb_wdata <= `ZeroWord;
			
			wb_LLbit_we <= 1'b0;
			wb_LLbit_value <= 1'b0;
			wb_LLbit_addr <= `ZeroWord;

			wb_csr_reg_we <= `CSRWriteDisable;
			wb_csr_reg_addr <= `NOPRegAddr;
			wb_csr_reg_data <= `ZeroWord;

			mem_cnt_o <= 2'h0;
			mem_original_data_o <= `ZeroWord;
		end
		else if(stall[4] == `Stop && stall[5] == `NoStop)
		begin
			wb_wd <= `NOPRegAddr;
			wb_wreg <= `WriteDisable;
			wb_wdata <= `ZeroWord;

			wb_LLbit_we <= 1'b0;
			wb_LLbit_value <= 1'b0;
			wb_LLbit_addr <= `ZeroWord;

			wb_csr_reg_we <= `CSRWriteDisable;
			wb_csr_reg_addr <= `NOPRegAddr;
			wb_csr_reg_data <= `ZeroWord;

			mem_cnt_o <= mem_cnt_i;
			mem_original_data_o <= mem_original_data_i;
		end
		else if(stall[4] == `NoStop)
		begin
			wb_wd <= mem_wd;
			wb_wreg <= mem_wreg;
			wb_wdata <= mem_wdata;

			wb_LLbit_we <= mem_LLbit_we;
			wb_LLbit_value <= mem_LLbit_value;
			wb_LLbit_addr <= mem_LLbit_addr;

			wb_csr_reg_we <= mem_csr_reg_we;
			wb_csr_reg_addr <= mem_csr_reg_addr;
			wb_csr_reg_data <= mem_csr_reg_data;

			mem_cnt_o <= 2'h0;
			mem_original_data_o <= `ZeroWord;
		end
		else // stall[4] 停，stall[5] 也停，wb_* 保持不变
		begin
			mem_cnt_o <= mem_cnt_i;
			mem_original_data_o <= mem_original_data_i;
		end
	end
endmodule