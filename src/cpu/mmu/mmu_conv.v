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
// Module:  mmu_conv
// File:    mmu_conv.v
// Author:  shyoshyo
// E-mail:  shyoshyo@qq.com
// Description: MMU module - sub convert module
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module mmu_conv
(
	input wire rst_n,

	input wire[1151:0] tlb_entry_i,
	input wire[`RegBus] cp0_pagemask_i,
	input wire[`RegBus] cp0_entryhi_i,

	input wire ce_i,
	input wire we_i,
	input wire [`RegBus] vir_addr_i,
	output reg [`RegBus] phy_addr_o,

	// TLB 缺失
	output reg tlb_r_miss_exception_o,
	output reg tlb_w_miss_exception_o,

	// 对不可写的 TLB 进行写操作
	output reg tlb_mod_exception_o
);

	/************************* TLB 表 *************************/

	wire [71:0]tlb_entry[15:0];

	assign
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
	} = tlb_entry_i[1151:0];



	/*********************** 計算是否命中 ***********************/

	wire [15:0]match;
	wire [15:0]write_on_readonly_page;
	wire [`RegBus]phy_addr_item[15:0];
	wire tlb_miss_exception;
	wire tlb_mod_exception;

	generate
		genvar i;
		for (i = 0; i < 16; i = i + 1)
		begin :machine_check
			/*
				tlb entry

				[71:53]    vpn
				[52:45]    ASID
				[44]       G

				[43:24]    pfn1
				[23:22]    {D, V}1
				[21:2]     pfn0
				[1:0]      {D, V}0
			*/

			assign match[i] =
			(
				((tlb_entry[i][71:53] & ~cp0_pagemask_i[31:13]) == (vir_addr_i[31:13] & ~cp0_pagemask_i[31:13])) &&
				((tlb_entry[i][52:45] == cp0_entryhi_i[7:0]) || tlb_entry[i][44] == 1'b1) &&
				(tlb_entry[i][(vir_addr_i[12] == 1'b0) ? (0) : (22)] == 1'b1)
			);

			assign write_on_readonly_page[i] =
				(match[i]) && (tlb_entry[i][(vir_addr_i[12] == 1'b0) ? (1) : (23)] == 1'b0 && we_i == `WriteEnable);

			assign phy_addr_item[i] = (~match[i]) ? `ZeroWord : 
				{(vir_addr_i[12] == 1'b0) ? tlb_entry[i][21:2] : tlb_entry[i][43:24], vir_addr_i[11:0]};
		end
	endgenerate

	assign tlb_miss_exception = 
		((|match) == 1'b1) ? `False_v : `True_v;

	assign tlb_mod_exception =
		(tlb_miss_exception == `False_v && (|write_on_readonly_page) == 1'b1) ? `True_v : `False_v;


	/*********************** 計算物理地址 ***********************/
    
    /*
	always @(*)
		if (ce_i == `ChipDisable)
		begin
			phy_addr_o <= `ZeroWord;

			tlb_r_miss_exception_o <= `False_v;
			tlb_w_miss_exception_o <= `False_v;
			tlb_mod_exception_o <= `False_v;
		end
		else if (vir_addr_i[31:30] == 2'b10)
		begin
			phy_addr_o <= {3'b000, vir_addr_i[28:0]};
			
			tlb_r_miss_exception_o <= `False_v;
			tlb_w_miss_exception_o <= `False_v;
			tlb_mod_exception_o <= `False_v;
		end
		else
		begin
			phy_addr_o <= `ZeroWord;

			if(match[15]) phy_addr_o <= phy_addr_item[15];
			if(match[14]) phy_addr_o <= phy_addr_item[14];
			if(match[13]) phy_addr_o <= phy_addr_item[13];
			if(match[12]) phy_addr_o <= phy_addr_item[12];
			if(match[11]) phy_addr_o <= phy_addr_item[11];
			if(match[10]) phy_addr_o <= phy_addr_item[10];
			if(match[9]) phy_addr_o <= phy_addr_item[9];
			if(match[8]) phy_addr_o <= phy_addr_item[8];
			if(match[7]) phy_addr_o <= phy_addr_item[7];
			if(match[6]) phy_addr_o <= phy_addr_item[6];
			if(match[5]) phy_addr_o <= phy_addr_item[5];
			if(match[4]) phy_addr_o <= phy_addr_item[4];
			if(match[3]) phy_addr_o <= phy_addr_item[3];
			if(match[2]) phy_addr_o <= phy_addr_item[2];
			if(match[1]) phy_addr_o <= phy_addr_item[1];
			if(match[0]) phy_addr_o <= phy_addr_item[0];

			tlb_r_miss_exception_o <= `False_v;
			tlb_w_miss_exception_o <= `False_v;
			
			if(we_i == `WriteEnable)
				tlb_w_miss_exception_o <= tlb_miss_exception;
			else
				tlb_r_miss_exception_o <= tlb_miss_exception;

			tlb_mod_exception_o <= tlb_mod_exception;
		end
	*/

	/* vaddr = paddr for now */
	always @(*)
		if (ce_i == `ChipDisable)
		begin
			phy_addr_o <= `ZeroWord;

			tlb_r_miss_exception_o <= `False_v;
			tlb_w_miss_exception_o <= `False_v;
			tlb_mod_exception_o <= `False_v;
		end
		else
		begin
			phy_addr_o <= vir_addr_i;
			
			tlb_r_miss_exception_o <= `False_v;
			tlb_w_miss_exception_o <= `False_v;
			tlb_mod_exception_o <= `False_v;
		end


endmodule
