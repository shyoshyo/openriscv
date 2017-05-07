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
// Description: MMU convert module
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module mmu_conv
(
	input wire rst_n,

	input wire [`RegBus]tlb0_vpn_i, input wire [`RegBus]tlb0_mask_i, input wire [`RegBus]tlb0_pte_i,
	input wire [`RegBus]tlb1_vpn_i, input wire [`RegBus]tlb1_mask_i, input wire [`RegBus]tlb1_pte_i,
	input wire [`RegBus]tlb2_vpn_i, input wire [`RegBus]tlb2_mask_i, input wire [`RegBus]tlb2_pte_i,
	input wire [`RegBus]tlb3_vpn_i, input wire [`RegBus]tlb3_mask_i, input wire [`RegBus]tlb3_pte_i,
	input wire [`RegBus]tlb4_vpn_i, input wire [`RegBus]tlb4_mask_i, input wire [`RegBus]tlb4_pte_i,
	input wire [`RegBus]tlb5_vpn_i, input wire [`RegBus]tlb5_mask_i, input wire [`RegBus]tlb5_pte_i,
	input wire [`RegBus]tlb6_vpn_i, input wire [`RegBus]tlb6_mask_i, input wire [`RegBus]tlb6_pte_i,
	input wire [`RegBus]tlb7_vpn_i, input wire [`RegBus]tlb7_mask_i, input wire [`RegBus]tlb7_pte_i,
	input wire [`RegBus]tlb8_vpn_i, input wire [`RegBus]tlb8_mask_i, input wire [`RegBus]tlb8_pte_i,
	input wire [`RegBus]tlb9_vpn_i, input wire [`RegBus]tlb9_mask_i, input wire [`RegBus]tlb9_pte_i,
	input wire [`RegBus]tlb10_vpn_i, input wire [`RegBus]tlb10_mask_i, input wire [`RegBus]tlb10_pte_i,
	input wire [`RegBus]tlb11_vpn_i, input wire [`RegBus]tlb11_mask_i, input wire [`RegBus]tlb11_pte_i,
	input wire [`RegBus]tlb12_vpn_i, input wire [`RegBus]tlb12_mask_i, input wire [`RegBus]tlb12_pte_i,
	input wire [`RegBus]tlb13_vpn_i, input wire [`RegBus]tlb13_mask_i, input wire [`RegBus]tlb13_pte_i,
	input wire [`RegBus]tlb14_vpn_i, input wire [`RegBus]tlb14_mask_i, input wire [`RegBus]tlb14_pte_i,
	input wire [`RegBus]tlb15_vpn_i, input wire [`RegBus]tlb15_mask_i, input wire [`RegBus]tlb15_pte_i,

	input wire [`CSR_mstatus_vm_bus] vm_i,
	input wire [1:0]prv_i,
	input wire mxr_i,

	input wire ce_i,
	input wire ex_i,
	input wire we_i,
	input wire [`RegBus] vir_addr_i,
	output reg [`PhyAddrBus] phy_addr_o,

	output reg tlb_exception_o,
	output reg tlb_update_o,

	output reg [3:0]hit_index_o
);
	/************************* TLB 表 *************************/

	wire [`RegBus]tlb_vpn[15:0];
	wire [`RegBus]tlb_pte[15:0];
	wire [`RegBus]tlb_mask[15:0];

	assign tlb_vpn[0] = tlb0_vpn_i;
	assign tlb_vpn[1] = tlb1_vpn_i;
	assign tlb_vpn[2] = tlb2_vpn_i;
	assign tlb_vpn[3] = tlb3_vpn_i;
	assign tlb_vpn[4] = tlb4_vpn_i;
	assign tlb_vpn[5] = tlb5_vpn_i;
	assign tlb_vpn[6] = tlb6_vpn_i;
	assign tlb_vpn[7] = tlb7_vpn_i;
	assign tlb_vpn[8] = tlb8_vpn_i;
	assign tlb_vpn[9] = tlb9_vpn_i;
	assign tlb_vpn[10] = tlb10_vpn_i;
	assign tlb_vpn[11] = tlb11_vpn_i;
	assign tlb_vpn[12] = tlb12_vpn_i;
	assign tlb_vpn[13] = tlb13_vpn_i;
	assign tlb_vpn[14] = tlb14_vpn_i;
	assign tlb_vpn[15] = tlb15_vpn_i;

	assign tlb_mask[0] = tlb0_mask_i;
	assign tlb_mask[1] = tlb1_mask_i;
	assign tlb_mask[2] = tlb2_mask_i;
	assign tlb_mask[3] = tlb3_mask_i;
	assign tlb_mask[4] = tlb4_mask_i;
	assign tlb_mask[5] = tlb5_mask_i;
	assign tlb_mask[6] = tlb6_mask_i;
	assign tlb_mask[7] = tlb7_mask_i;
	assign tlb_mask[8] = tlb8_mask_i;
	assign tlb_mask[9] = tlb9_mask_i;
	assign tlb_mask[10] = tlb10_mask_i;
	assign tlb_mask[11] = tlb11_mask_i;
	assign tlb_mask[12] = tlb12_mask_i;
	assign tlb_mask[13] = tlb13_mask_i;
	assign tlb_mask[14] = tlb14_mask_i;
	assign tlb_mask[15] = tlb15_mask_i;

	assign tlb_pte[0] = tlb0_pte_i;
	assign tlb_pte[1] = tlb1_pte_i;
	assign tlb_pte[2] = tlb2_pte_i;
	assign tlb_pte[3] = tlb3_pte_i;
	assign tlb_pte[4] = tlb4_pte_i;
	assign tlb_pte[5] = tlb5_pte_i;
	assign tlb_pte[6] = tlb6_pte_i;
	assign tlb_pte[7] = tlb7_pte_i;
	assign tlb_pte[8] = tlb8_pte_i;
	assign tlb_pte[9] = tlb9_pte_i;
	assign tlb_pte[10] = tlb10_pte_i;
	assign tlb_pte[11] = tlb11_pte_i;
	assign tlb_pte[12] = tlb12_pte_i;
	assign tlb_pte[13] = tlb13_pte_i;
	assign tlb_pte[14] = tlb14_pte_i;
	assign tlb_pte[15] = tlb15_pte_i;

	/*********************** 計算是否命中 ***********************/

	reg [15:0]hit;
	reg [15:0]protect_exception;
	reg [15:0]update_exception;
	wire [`PhyAddrBus]phy_addr[15:0];

	generate
		genvar i;
		for (i = 0; i < 16; i = i + 1)
		begin :hit_check
			always @(*)
			begin
				case(vm_i)
					`CSR_mstatus_vm_Mbare:
						hit[i] <= 1'b0;

`ifdef RV32
					`CSR_mstatus_vm_Sv32:
`else
					`CSR_mstatus_vm_Sv32, `CSR_mstatus_vm_Sv39, `CSR_mstatus_vm_Sv48:
`endif
						hit[i] <= ((vir_addr_i & tlb_mask[i]) == (tlb_vpn[i] & tlb_mask[i]));
					default:
						hit[i] <= 1'b0;
				endcase

				if(tlb_pte[i][`PTE_V] == 1'b0)
					hit[i] <= 1'b0;
			end
				
			always @(*)
			begin
				protect_exception[i] <= !hit[i];

				if(ex_i)
				begin
					if(tlb_pte[i][`PTE_X] == 1'b0) protect_exception[i] <= 1'b1;
				end
				else if(we_i == `WriteEnable)
				begin
					if(tlb_pte[i][`PTE_W] == 1'b0) protect_exception[i] <= 1'b1;
					if(tlb_pte[i][`PTE_R] == 1'b0) protect_exception[i] <= 1'b1;
				end
				else
				begin
					if(mxr_i)
					begin
						if(tlb_pte[i][`PTE_R] == 1'b0 && tlb_pte[i][`PTE_X] == 1'b0)
							protect_exception[i] <= 1'b1;
					end
					else
					begin
						if(tlb_pte[i][`PTE_R] == 1'b0)
							protect_exception[i] <= 1'b1;
					end
				end
			end

			always @(*)
			begin
				update_exception[i] <= !hit[i];

				if(tlb_pte[i][`PTE_A] == 1'b0)
					update_exception[i] <= 1'b1;
				if(we_i == `WriteEnable && tlb_pte[i][`PTE_D] == 1'b0)
					update_exception[i] <= 1'b1;
			end

			assign phy_addr[i] = ({tlb_pte[i], 2'b00} & tlb_mask[i]) | (vir_addr_i & ~tlb_mask[i]);
		end
	endgenerate

	wire tlb_miss_exception;
	wire tlb_exception;

	assign tlb_miss_exception = ((|hit) == 1'b1) ? `False_v : `True_v;

	always @(*)
	begin
		hit_index_o <= 4'd0;
		if(hit[15]) hit_index_o <= 4'd15;
		if(hit[14]) hit_index_o <= 4'd14;
		if(hit[13]) hit_index_o <= 4'd13;
		if(hit[12]) hit_index_o <= 4'd12;
		if(hit[11]) hit_index_o <= 4'd11;
		if(hit[10]) hit_index_o <= 4'd10;
		if(hit[9]) hit_index_o <= 4'd9;
		if(hit[8]) hit_index_o <= 4'd8;
		if(hit[7]) hit_index_o <= 4'd7;
		if(hit[6]) hit_index_o <= 4'd6;
		if(hit[5]) hit_index_o <= 4'd5;
		if(hit[4]) hit_index_o <= 4'd4;
		if(hit[3]) hit_index_o <= 4'd3;
		if(hit[2]) hit_index_o <= 4'd2;
		if(hit[1]) hit_index_o <= 4'd1;
		if(hit[0]) hit_index_o <= 4'd0;
	end

	assign tlb_exception = tlb_miss_exception | protect_exception[hit_index_o] | update_exception[hit_index_o];

	/*********************** 計算物理地址 ***********************/

	always @(*)
		if (rst_n == `RstEnable)
		begin
			phy_addr_o <= `ZeroWord;

			tlb_exception_o <= `False_v;
			tlb_update_o <= `False_v;
		end
		else if (ce_i == `ChipDisable)
		begin
			phy_addr_o <= `ZeroWord;

			tlb_exception_o <= `False_v;
			tlb_update_o <= `False_v;
		end
		else if(prv_i == `PRV_M || vm_i == `CSR_mstatus_vm_Mbare)
		begin
			phy_addr_o <= `ZeroWord;
			phy_addr_o[`RegBus] <= vir_addr_i;
			
			tlb_exception_o <= `False_v;
			tlb_update_o <= `False_v;
		end
`ifdef RV32
		else if(vm_i == `CSR_mstatus_vm_Sv32)
`else
		else if(vm_i == `CSR_mstatus_vm_Sv32 || vm_i == `CSR_mstatus_vm_Sv39 || vm_i == `CSR_mstatus_vm_Sv48)
`endif
		begin
			phy_addr_o <= `ZeroWord;
			if(tlb_exception == 1'b0)
				phy_addr_o <= phy_addr[hit_index_o];

			tlb_exception_o <= tlb_exception;
			if(tlb_miss_exception)
				tlb_update_o <= `False_v;
			else
				tlb_update_o <= update_exception[hit_index_o];
		end
		else
		begin
			$display("should never arrive here");
			$stop;

			phy_addr_o <= `ZeroWord;

			tlb_exception_o <= `False_v;
			tlb_update_o <= `False_v;
		end

endmodule
