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
// Module:  mmu
// File:    mmu.v
// Author:  shyoshyo
// E-mail:  shyoshyo@qq.com
// Description: MMU module
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module mmu
(
	input clk,
	input rst_n,

	input wire inst_ce_i,
	input wire [`RegBus] inst_vir_addr_i,
	output wire [`RegBus] inst_phy_addr_o,
	output wire inst_tlb_r_miss_exception_o,

	input wire data_ce_i,
	input wire data_we_i,
	input wire [`RegBus] data_vir_addr_i,
	output wire [`RegBus] data_phy_addr_o,
	output wire data_tlb_r_miss_exception_o,
	output wire data_tlb_w_miss_exception_o,
	output wire data_tlb_mod_exception_o,

	input wire csr_write_tlb_index_i,
	input wire csr_write_tlb_random_i,

	input wire[`RegBus] csr_index_i,
	input wire[`RegBus] csr_random_i,
	input wire[`RegBus] csr_entrylo0_i,
	input wire[`RegBus] csr_entrylo1_i,
	input wire[`RegBus] csr_entryhi_i,
	input wire[`RegBus] csr_pagemask_i,

	output wire tlb_machine_check_exception_o
);
	
	wire [1151:0]tlb_entry;

	mmu_conv mmu_conv0(
		.rst_n(rst_n),

		.tlb_entry_i(tlb_entry),
		.csr_pagemask_i(csr_pagemask_i),
		.csr_entryhi_i(csr_entryhi_i),

		.ce_i(inst_ce_i),
		.we_i(`WriteDisable),
		.vir_addr_i(inst_vir_addr_i),
		.phy_addr_o(inst_phy_addr_o),
		
		.tlb_r_miss_exception_o(inst_tlb_r_miss_exception_o),
		.tlb_w_miss_exception_o(),
		.tlb_mod_exception_o()
	);

	mmu_conv mmu_conv1(
		.rst_n(rst_n),

		.tlb_entry_i(tlb_entry),
		.csr_pagemask_i(csr_pagemask_i),
		.csr_entryhi_i(csr_entryhi_i),

		.ce_i(data_ce_i),
		.we_i(data_we_i),
		.vir_addr_i(data_vir_addr_i),
		.phy_addr_o(data_phy_addr_o),

		.tlb_r_miss_exception_o(data_tlb_r_miss_exception_o),
		.tlb_w_miss_exception_o(data_tlb_w_miss_exception_o),
		.tlb_mod_exception_o(data_tlb_mod_exception_o)
	);


	tlb tlb0(
		.clk(clk),
		.rst_n(rst_n),

		.csr_write_tlb_index_i(csr_write_tlb_index_i),
		.csr_write_tlb_random_i(csr_write_tlb_random_i),

		.csr_index_i(csr_index_i),
		.csr_random_i(csr_random_i),
		.csr_entrylo0_i(csr_entrylo0_i),
		.csr_entrylo1_i(csr_entrylo1_i),
		.csr_entryhi_i(csr_entryhi_i),
		.csr_pagemask_i(csr_pagemask_i),

		.tlb_entry_o(tlb_entry),

		.tlb_machine_check_exception_o(tlb_machine_check_exception_o)
	);
endmodule
