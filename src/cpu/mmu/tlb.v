//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2016 shyoshyo                                  ////
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
// Module:  tlb
// File:    tlb.v
// Author:  shyoshyo
// E-mail:  shyoshyo@qq.com
// Description: TLB module - MMU
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module tlb
(
	input wire clk,
	input wire rst_n,

	input wire csr_write_tlb_index_i,
	input wire csr_write_tlb_random_i,

	input wire[`RegBus] csr_index_i,
	input wire[`RegBus] csr_random_i,
	input wire[`RegBus] csr_entrylo0_i,
	input wire[`RegBus] csr_entrylo1_i,
	input wire[`RegBus] csr_entryhi_i,
	input wire[`RegBus] csr_pagemask_i,

	output wire[1151:0] tlb_entry_o,

	output reg tlb_machine_check_exception_o
);
	/************************* TLB 表 *************************/

	reg [71:0]tlb_entry[15:0];

	assign tlb_entry_o =
	{
		tlb_entry[0],
		tlb_entry[1],
		tlb_entry[2],
		tlb_entry[3],
		tlb_entry[4],
		tlb_entry[5],
		tlb_entry[6],
		tlb_entry[7],
		tlb_entry[8],
		tlb_entry[9],
		tlb_entry[10],
		tlb_entry[11],
		tlb_entry[12],
		tlb_entry[13],
		tlb_entry[14],
		tlb_entry[15]
	};


	/************** 計算要填入的 tlb 表項的內容和下標 *************/

	wire [71:0]tlb_entry_i =
	{
		csr_entryhi_i[31:13] & ~csr_pagemask_i[31:13], // vpn
		csr_entryhi_i[7:0], // now ASID
		csr_entrylo0_i[0] & csr_entrylo1_i[0], // G
		
		csr_entrylo1_i[25:6] & ~csr_pagemask_i[25:6], // pfn1
		csr_entrylo1_i[2:1], // {D, V}1

		csr_entrylo0_i[25:6] & ~csr_pagemask_i[25:6], // pfn0
		csr_entrylo0_i[2:1] // {D, V}0
	};

	wire [3:0]tlb_index_i = 
		csr_write_tlb_index_i ? (csr_index_i[3:0]) : (csr_random_i[3:0]);


	/********************** 檢查有沒有衝突 *********************/
	
	wire [15:0] machine_check_err;

	generate
		genvar j;

		for(j = 0; j < 16; j = j + 1)
		begin :machine_check
			assign machine_check_err[j] = 
			(
				
				(tlb_index_i != j) && 
				(
					tlb_entry[j][71:45] == tlb_entry_i[71:45] ||
					(
						tlb_entry[j][71:53] == tlb_entry_i[71:53] && 
						(tlb_entry[j][44] | tlb_entry_i[44]) == 1'b1
					)
				)
			);
		end
	endgenerate

	always @(posedge clk or negedge rst_n)
	begin
		if (rst_n == `RstEnable)
		begin
			{
				tlb_entry[0],
				tlb_entry[1],
				tlb_entry[2],
				tlb_entry[3],
				tlb_entry[4],
				tlb_entry[5],
				tlb_entry[6],
				tlb_entry[7],
				tlb_entry[8],
				tlb_entry[9],
				tlb_entry[10],
				tlb_entry[11],
				tlb_entry[12],
				tlb_entry[13],
				tlb_entry[14],
				tlb_entry[15]
			} <= 1152'b0;

			tlb_machine_check_exception_o <= `False_v;
		end
		else if (csr_write_tlb_index_i || csr_write_tlb_random_i)
		begin
			if(|machine_check_err)
			begin
				tlb_machine_check_exception_o <= `True_v;
			end
			else
			begin
				tlb_entry[tlb_index_i] <= tlb_entry_i;
				tlb_machine_check_exception_o <= `False_v;
			end
		end
		else
		begin
			tlb_machine_check_exception_o <= `False_v;
		end
	end

endmodule