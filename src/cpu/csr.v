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
// Module:  csr
// File:    csr.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description:实现了一些 CSR
// 
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module csr(
	input wire clk,
	input wire rst_n,
	
	// CSR write port
	input wire[`CSRWriteTypeBus] we_i,
	input wire[`CSRAddrBus] waddr_i,
	input wire[`RegBus] data_i,

	// CSR read port
	input wire re_i,
	input wire[`CSRWriteTypeBus]will_write_in_mem_i,
	input wire[`CSRAddrBus] raddr_i,
	

	// Exception
	input wire[`ExceptionTypeBus] excepttype_i,
	
	// Interrupt source
	input wire timer_int_i,
	input wire software_int_i,

	// inst vaddr & data vaddr
	input wire[`RegBus] current_inst_addr_i,
	input wire[`RegBus] current_data_addr_i,

	// delatslot(TODO: FIXME)
	input wire is_in_delayslot_i,

	// CSR read port
	output reg[`RegBus] data_o,
	output reg protect_o,

	// next pc for excpetion
	output reg[`RegBus] exception_new_pc_o,

	output reg [1:0] prv_o,

	// MMU
	input wire inst_ce_i,
	input wire [`RegBus] inst_vir_addr_i,
	output wire [`PhyAddrBus] inst_phy_addr_o,
	output wire inst_tlb_exception_o,

	input wire data_ce_i,
	input wire data_we_i,
	input wire [`RegBus] data_vir_addr_i,
	output wire [`PhyAddrBus] data_phy_addr_o,
	output wire data_tlb_exception_o
);

`ifdef RV32
	wire[`RegBus] misa = {2'b01, 4'b0, 26'h0141101};
`else
	wire[`RegBus] misa = {2'b10, 4'b0, 32'b0, 26'h0141101};
`endif

	wire[`RegBus] mvendorid = `ZeroWord;
	wire[`RegBus] marchid = `ZeroWord;
	wire[`RegBus] mimpid = `ZeroWord;
	wire[`RegBus] mhartid = `ZeroWord;

	reg[`RegBus] mscratch;
	reg[`CSR_mtvec_addr_bus] mtvec_addr;
	reg[`CSR_mepc_addr_bus] mepc_addr;
	reg[`CSR_medeleg_bus] medeleg;
	reg[`CSR_mideleg_bus] mideleg;
	reg[`RegBus] mcause;
	reg[`RegBus] mbadaddr;

	reg[`CSR_mstatus_vm_bus] mstatus_vm;
	reg[`CSR_mstatus_mxr_bus] mstatus_mxr;
	reg[`CSR_mstatus_mprv_bus] mstatus_mprv;
	reg[`CSR_mstatus_fs_bus] mstatus_fs;
	wire[`CSR_mstatus_sd_bus] mstatus_sd = (mstatus_fs == `CSR_mstatus_fs_Dirty);
	reg[`CSR_mstatus_mpp_bus] mstatus_mpp;
	reg[`CSR_mstatus_spp_bus] mstatus_spp;
	reg[`CSR_mstatus_mpie_bus] mstatus_mpie;
	reg[`CSR_mstatus_spie_bus] mstatus_spie;
	reg[`CSR_mstatus_upie_bus] mstatus_upie;
	reg[`CSR_mstatus_mie_bus] mstatus_mie;
	reg[`CSR_mstatus_sie_bus] mstatus_sie;
	reg[`CSR_mstatus_uie_bus] mstatus_uie;


	wire[`CSR_mip_mtip_bus] mip_mtip = timer_int_i;

	reg[`CSR_mucounteren_tm_bus] mucounteren_tm;
	reg[`CSR_mscounteren_tm_bus] mscounteren_tm;


	wire has_cause = 
		excepttype_i[`Exception_INST_MISALIGNED] ? 1'b1 :
		excepttype_i[`Exception_INST_ACCESS_FAULT] ? 1'b1 : 
		excepttype_i[`Exception_INST_ILLEGAL] ? 1'b1 : 
		excepttype_i[`Exception_BREAK] ? 1'b1 : 
		excepttype_i[`Exception_LOAD_MISALIGNED] ? 1'b1 : 
		excepttype_i[`Exception_LOAD_ACCESS_FAULT] ? 1'b1 : 
		excepttype_i[`Exception_STORE_MISALIGNED] ? 1'b1 : 
		excepttype_i[`Exception_STORE_ACCESS_FAULT] ? 1'b1 : 
		excepttype_i[`Exception_ECALL_FROM_U] ? 1'b1 : 
		excepttype_i[`Exception_ECALL_FROM_S] ? 1'b1 : 
		excepttype_i[`Exception_ECALL_FROM_M] ? 1'b1 : 
		1'b0;

	wire [`RegBus] cause = 
		excepttype_i[`Exception_INST_MISALIGNED] ? `CSR_mcause_INST_MISALIGNED :
		excepttype_i[`Exception_INST_ACCESS_FAULT] ? `CSR_mcause_INST_ACCESS_FAULT : 
		excepttype_i[`Exception_INST_ILLEGAL] ? `CSR_mcause_INST_ILLEGAL : 
		excepttype_i[`Exception_BREAK] ? `CSR_mcause_BREAK : 
		excepttype_i[`Exception_LOAD_MISALIGNED] ? `CSR_mcause_LOAD_MISALIGNED : 
		excepttype_i[`Exception_LOAD_ACCESS_FAULT] ? `CSR_mcause_LOAD_ACCESS_FAULT : 
		excepttype_i[`Exception_STORE_MISALIGNED] ? `CSR_mcause_STORE_MISALIGNED : 
		excepttype_i[`Exception_STORE_ACCESS_FAULT] ? `CSR_mcause_STORE_ACCESS_FAULT : 
		excepttype_i[`Exception_ECALL_FROM_U] ? `CSR_mcause_ECALL_FROM_U : 
		excepttype_i[`Exception_ECALL_FROM_S] ? `CSR_mcause_ECALL_FROM_S : 
		excepttype_i[`Exception_ECALL_FROM_M] ? `CSR_mcause_ECALL_FROM_M : 
		`ZeroWord;

	wire has_badaddr = 
		excepttype_i[`Exception_INST_MISALIGNED] ? 1'b1 :
		excepttype_i[`Exception_INST_ACCESS_FAULT] ? 1'b1 :
		excepttype_i[`Exception_LOAD_MISALIGNED] ? 1'b1 : 
		excepttype_i[`Exception_LOAD_ACCESS_FAULT] ? 1'b1 : 
		excepttype_i[`Exception_STORE_MISALIGNED] ? 1'b1 : 
		excepttype_i[`Exception_STORE_ACCESS_FAULT] ? 1'b1 : 
		1'b0;
	
	wire [`RegBus]badaddr = 
		excepttype_i[`Exception_INST_MISALIGNED] ? current_inst_addr_i :
		excepttype_i[`Exception_INST_ACCESS_FAULT] ? current_inst_addr_i :
		excepttype_i[`Exception_LOAD_MISALIGNED] ? current_data_addr_i : 
		excepttype_i[`Exception_LOAD_ACCESS_FAULT] ? current_data_addr_i : 
		excepttype_i[`Exception_STORE_MISALIGNED] ? current_data_addr_i : 
		excepttype_i[`Exception_STORE_ACCESS_FAULT] ? current_data_addr_i : 
		`ZeroWord;
	
	reg[`CSR_sptbr_ppn_bus] sptbr_ppn;

	reg [`CSR_mtlbindex_bus]mtlbindex;
	reg [`RegBus]mtlbvpn[15:0];
	reg [`RegBus]mtlbmask[15:0];
	reg [`RegBus]mtlbpte[15:0];
	reg [`RegBus]mtlbptevaddr[15:0];
	wire[3:0] inst_tlb_index;
	wire inst_tlb_access_we_o;
	wire inst_tlb_dirty_we_o;
	wire[3:0] data_tlb_index;
	wire data_tlb_access_we_o;
	wire data_tlb_dirty_we_o;


	reg[`RegBus] sscratch;
	reg[`CSR_stvec_addr_bus] stvec_addr;

	/* privilege transfer */
	reg [1:0] next_prv;
	always @ (*)
	begin
		next_prv = prv_o;

		if(has_cause)
		begin
			next_prv <= `PRV_M;
		end
		else if(excepttype_i[`Exception_ERET_FROM_U])
		begin
			/*
			require_privilege(PRV_U); => trap_illegal_instruction
			*/
			
			next_prv <= `PRV_U;
		end
		else if(excepttype_i[`Exception_ERET_FROM_S])
		begin
			/*
			require_privilege(PRV_S); => trap_illegal_instruction
			 */
			
			case(mstatus_spp)
				`PRV_U: next_prv <= `PRV_U;
				`PRV_S: next_prv <= `PRV_S;

				default: begin end
			endcase
		end
		else if(excepttype_i[`Exception_ERET_FROM_M])
		begin
			/*
			require_privilege(PRV_M); => trap_illegal_instruction
			 */
			
			case(mstatus_mpp)
				`PRV_U: next_prv <= `PRV_U;
				`PRV_S: next_prv <= `PRV_S;
				`PRV_M: next_prv <= `PRV_M;

				default: begin end
			endcase
		end
		else if(excepttype_i[`Exception_FENCEI])
		begin
			
		end
	end


	// write & modify CSR
	always @ (posedge clk or negedge rst_n)
		if (rst_n == `RstEnable)
		begin
			mscratch <= `ZeroWord;
			mtvec_addr <= `ZeroWord;
			mepc_addr <= `ZeroWord;
			medeleg <= `ZeroWord;
			mideleg <= `ZeroWord;

			mstatus_vm <= `CSR_mstatus_vm_Mbare;
			mstatus_mxr <= 1'b0;
			mstatus_mprv <= 1'b0;
			mstatus_fs <= `CSR_mstatus_fs_Off;
			mstatus_mpp <= `PRV_U;
			mstatus_spp <= `PRV_U;
			mstatus_mpie <= 1'b0;
			mstatus_spie <= 1'b0;
			mstatus_upie <= 1'b0;
			mstatus_mie <= 1'b0;
			mstatus_sie <= 1'b0;
			mstatus_uie <= 1'b0;

			mscounteren_tm <= 1'b0;
			mucounteren_tm <= 1'b0;

			sptbr_ppn <= `ZeroWord;
			mtlbindex <= `ZeroWord;
			mtlbvpn[0] <= `ZeroWord; mtlbmask[0] <= `ZeroWord; mtlbpte[0] <= `ZeroWord; mtlbptevaddr[0] <= `ZeroWord;
			mtlbvpn[1] <= `ZeroWord; mtlbmask[1] <= `ZeroWord; mtlbpte[1] <= `ZeroWord; mtlbptevaddr[1] <= `ZeroWord;
			mtlbvpn[2] <= `ZeroWord; mtlbmask[2] <= `ZeroWord; mtlbpte[2] <= `ZeroWord; mtlbptevaddr[2] <= `ZeroWord;
			mtlbvpn[3] <= `ZeroWord; mtlbmask[3] <= `ZeroWord; mtlbpte[3] <= `ZeroWord; mtlbptevaddr[3] <= `ZeroWord;
			mtlbvpn[4] <= `ZeroWord; mtlbmask[4] <= `ZeroWord; mtlbpte[4] <= `ZeroWord; mtlbptevaddr[4] <= `ZeroWord;
			mtlbvpn[5] <= `ZeroWord; mtlbmask[5] <= `ZeroWord; mtlbpte[5] <= `ZeroWord; mtlbptevaddr[5] <= `ZeroWord;
			mtlbvpn[6] <= `ZeroWord; mtlbmask[6] <= `ZeroWord; mtlbpte[6] <= `ZeroWord; mtlbptevaddr[6] <= `ZeroWord;
			mtlbvpn[7] <= `ZeroWord; mtlbmask[7] <= `ZeroWord; mtlbpte[7] <= `ZeroWord; mtlbptevaddr[7] <= `ZeroWord;
			mtlbvpn[8] <= `ZeroWord; mtlbmask[8] <= `ZeroWord; mtlbpte[8] <= `ZeroWord; mtlbptevaddr[8] <= `ZeroWord;
			mtlbvpn[9] <= `ZeroWord; mtlbmask[9] <= `ZeroWord; mtlbpte[9] <= `ZeroWord; mtlbptevaddr[9] <= `ZeroWord;
			mtlbvpn[10] <= `ZeroWord; mtlbmask[10] <= `ZeroWord; mtlbpte[10] <= `ZeroWord; mtlbptevaddr[10] <= `ZeroWord;
			mtlbvpn[11] <= `ZeroWord; mtlbmask[11] <= `ZeroWord; mtlbpte[11] <= `ZeroWord; mtlbptevaddr[11] <= `ZeroWord;
			mtlbvpn[12] <= `ZeroWord; mtlbmask[12] <= `ZeroWord; mtlbpte[12] <= `ZeroWord; mtlbptevaddr[12] <= `ZeroWord;
			mtlbvpn[13] <= `ZeroWord; mtlbmask[13] <= `ZeroWord; mtlbpte[13] <= `ZeroWord; mtlbptevaddr[13] <= `ZeroWord;
			mtlbvpn[14] <= `ZeroWord; mtlbmask[14] <= `ZeroWord; mtlbpte[14] <= `ZeroWord; mtlbptevaddr[14] <= `ZeroWord;
			mtlbvpn[15] <= `ZeroWord; mtlbmask[15] <= `ZeroWord; mtlbpte[15] <= `ZeroWord; mtlbptevaddr[15] <= `ZeroWord;

			prv_o <= `PRV_M;
		end
		else
		begin
			if(we_i == `CSRWrite)
				case (waddr_i)
					`CSR_mscratch:
						mscratch <= data_i;
					`CSR_mtvec:
						mtvec_addr <= data_i[`CSR_mtvec_addr_bus];
					`CSR_mepc:
						mepc_addr <= data_i[`CSR_mepc_addr_bus];
					`CSR_medeleg:
						medeleg <= data_i[`CSR_medeleg_bus];
					`CSR_mideleg:
						mideleg <= data_i[`CSR_mideleg_bus];
					`CSR_mcause:
						mcause <= data_i;
					`CSR_mbadaddr:
						mbadaddr <= data_i;
					
					`CSR_mstatus:
					begin
						case(data_i[`CSR_mstatus_vm_bus])
`ifdef RV32
							`CSR_mstatus_vm_Mbare, `CSR_mstatus_vm_Sv32:
`else
							`CSR_mstatus_vm_Mbare, `CSR_mstatus_vm_Sv32,
							`CSR_mstatus_vm_Sv39, `CSR_mstatus_vm_Sv48:
`endif
								mstatus_vm <= data_i[`CSR_mstatus_vm_bus];

							default: begin end
						endcase

						mstatus_mxr <= data_i[`CSR_mstatus_mxr_bus];
						mstatus_mprv <= data_i[`CSR_mstatus_mprv_bus];
						mstatus_fs <= data_i[`CSR_mstatus_fs_bus];

						case(data_i[`CSR_mstatus_mpp_bus])
							`PRV_M, `PRV_S, `PRV_U:
								mstatus_mpp <= data_i[`CSR_mstatus_mpp_bus];
							default: begin end
						endcase

						case({1'b0, data_i[`CSR_mstatus_spp_bus]})
							`PRV_S, `PRV_U:
								mstatus_spp <= data_i[`CSR_mstatus_spp_bus];
							default: begin end
						endcase

						mstatus_mpie <= data_i[`CSR_mstatus_mpie_bus];
						mstatus_spie <= data_i[`CSR_mstatus_spie_bus];
						mstatus_upie <= data_i[`CSR_mstatus_upie_bus];
						mstatus_mie <= data_i[`CSR_mstatus_mie_bus];
						mstatus_sie <= data_i[`CSR_mstatus_sie_bus];
						mstatus_uie <= data_i[`CSR_mstatus_uie_bus];
					end

					`CSR_mscounteren: mscounteren_tm <= data_i[`CSR_mscounteren_tm_bus];
					`CSR_mucounteren: mucounteren_tm <= data_i[`CSR_mucounteren_tm_bus];

					`CSR_sptbr:     sptbr_ppn <= data_i[`CSR_sptbr_ppn_bus];

					`CSR_mtlbindex: mtlbindex <= data_i[`CSR_mtlbindex_bus];
					`CSR_mtlbvpn:   mtlbvpn[mtlbindex] <= data_i;
					`CSR_mtlbmask:  mtlbmask[mtlbindex] <= data_i;
					`CSR_mtlbpte:   mtlbpte[mtlbindex] <= data_i;
					`CSR_mtlbptevaddr: mtlbptevaddr[mtlbindex] <= data_i;

					`CSR_sscratch:  sscratch <= data_i;
					`CSR_stvec:     stvec_addr <= data_i[`CSR_stvec_addr_bus];
					
					`CSR_sstatus:
					begin
						mstatus_fs <= data_i[`CSR_mstatus_fs_bus];

						case({1'b0, data_i[`CSR_mstatus_spp_bus]})
							`PRV_S, `PRV_U:
								mstatus_spp <= data_i[`CSR_mstatus_spp_bus];
							default: begin end
						endcase

						mstatus_spie <= data_i[`CSR_mstatus_spie_bus];
						mstatus_upie <= data_i[`CSR_mstatus_upie_bus];
						mstatus_sie <= data_i[`CSR_mstatus_sie_bus];
						mstatus_uie <= data_i[`CSR_mstatus_uie_bus];
					end
					default:
					begin
					end
				endcase
			
			if(has_cause)
			begin
				mepc_addr <= current_inst_addr_i[`CSR_mepc_addr_bus];
				mcause <= cause;
				if(has_badaddr) mbadaddr <= badaddr;

				case(prv_o)
					`PRV_U: mstatus_mpie <= mstatus_uie;
					`PRV_S: mstatus_mpie <= mstatus_sie;
					`PRV_M: mstatus_mpie <= mstatus_mie;
					default: begin end
				endcase
				case(prv_o)
					`PRV_U: mstatus_mpp <= `PRV_U;
					`PRV_S: mstatus_mpp <= `PRV_S;
					`PRV_M: mstatus_mpp <= `PRV_M;
					default: begin end
				endcase
				mstatus_mie <= 1'b0;
			end
			else if(excepttype_i[`Exception_ERET_FROM_U])
			begin
				/*
				require_privilege(PRV_U); => trap_illegal_instruction
				*/
				
				// x = u -> y = u
				mstatus_uie <= mstatus_upie;
				mstatus_upie <= 1'b1;
			end
			else if(excepttype_i[`Exception_ERET_FROM_S])
			begin
				/*
				require_privilege(PRV_S); => trap_illegal_instruction
				 */
				
				case(mstatus_spp)
					`PRV_U:
					begin
						// x = s -> y = u
						mstatus_uie <= mstatus_spie;
						mstatus_spie <= 1'b1;
						mstatus_spp <= `PRV_U_1;
					end
					`PRV_S:
					begin
						// x = s -> y = s
						mstatus_sie <= mstatus_spie;
						mstatus_spie <= 1'b1;
						mstatus_spp <= `PRV_U_1;
					end

					default:
					begin
					end
				endcase
			end
			else if(excepttype_i[`Exception_ERET_FROM_M])
			begin
				/*
				require_privilege(PRV_M); => trap_illegal_instruction
				 */
				
				case(mstatus_mpp)
					`PRV_U:
					begin
						// x = m -> y = u
						mstatus_uie <= mstatus_mpie;
						mstatus_mpie <= 1'b1;
						mstatus_mpp <= `PRV_U;
					end
					`PRV_S:
					begin
						// x = m -> y = s
						mstatus_sie <= mstatus_mpie;
						mstatus_mpie <= 1'b1;
						mstatus_mpp <= `PRV_U;
					end
					`PRV_M:
					begin
						// x = m -> y = m
						mstatus_mie <= mstatus_mpie;
						mstatus_mpie <= 1'b1;
						mstatus_mpp <= `PRV_U;
					end

					default:
					begin
					end
				endcase
			end
			else if(excepttype_i[`Exception_FENCEI])
			begin
				
			end

			if(inst_tlb_access_we_o) mtlbpte[inst_tlb_index][`PTE_A] <= 1'b1;
			if(inst_tlb_dirty_we_o)  mtlbpte[inst_tlb_index][`PTE_D] <= 1'b1;
			if(data_tlb_access_we_o) mtlbpte[data_tlb_index][`PTE_A] <= 1'b1;
			if(data_tlb_dirty_we_o)  mtlbpte[data_tlb_index][`PTE_D] <= 1'b1;

			prv_o <= next_prv;
		end


	mmu_conv mmu_conv0(
		.rst_n(rst_n),

		.tlb0_vpn_i(mtlbvpn[0]), .tlb0_pte_i(mtlbpte[0]), .tlb0_mask_i(mtlbmask[0]),
		.tlb1_vpn_i(mtlbvpn[1]), .tlb1_pte_i(mtlbpte[1]), .tlb1_mask_i(mtlbmask[1]),
		.tlb2_vpn_i(mtlbvpn[2]), .tlb2_pte_i(mtlbpte[2]), .tlb2_mask_i(mtlbmask[2]),
		.tlb3_vpn_i(mtlbvpn[3]), .tlb3_pte_i(mtlbpte[3]), .tlb3_mask_i(mtlbmask[3]),
		.tlb4_vpn_i(mtlbvpn[4]), .tlb4_pte_i(mtlbpte[4]), .tlb4_mask_i(mtlbmask[4]),
		.tlb5_vpn_i(mtlbvpn[5]), .tlb5_pte_i(mtlbpte[5]), .tlb5_mask_i(mtlbmask[5]),
		.tlb6_vpn_i(mtlbvpn[6]), .tlb6_pte_i(mtlbpte[6]), .tlb6_mask_i(mtlbmask[6]),
		.tlb7_vpn_i(mtlbvpn[7]), .tlb7_pte_i(mtlbpte[7]), .tlb7_mask_i(mtlbmask[7]),
		.tlb8_vpn_i(mtlbvpn[8]), .tlb8_pte_i(mtlbpte[8]), .tlb8_mask_i(mtlbmask[8]),
		.tlb9_vpn_i(mtlbvpn[9]), .tlb9_pte_i(mtlbpte[9]), .tlb9_mask_i(mtlbmask[9]),
		.tlb10_vpn_i(mtlbvpn[10]), .tlb10_pte_i(mtlbpte[10]), .tlb10_mask_i(mtlbmask[10]),
		.tlb11_vpn_i(mtlbvpn[11]), .tlb11_pte_i(mtlbpte[11]), .tlb11_mask_i(mtlbmask[11]),
		.tlb12_vpn_i(mtlbvpn[12]), .tlb12_pte_i(mtlbpte[12]), .tlb12_mask_i(mtlbmask[12]),
		.tlb13_vpn_i(mtlbvpn[13]), .tlb13_pte_i(mtlbpte[13]), .tlb13_mask_i(mtlbmask[13]),
		.tlb14_vpn_i(mtlbvpn[14]), .tlb14_pte_i(mtlbpte[14]), .tlb14_mask_i(mtlbmask[14]),
		.tlb15_vpn_i(mtlbvpn[15]), .tlb15_pte_i(mtlbpte[15]), .tlb15_mask_i(mtlbmask[15]),

		.vm_i(mstatus_vm),
		.prv_i(next_prv),
		.mxr_i(mstatus_mxr),

		.ce_i(inst_ce_i),
		.ex_i(1'b1),
		.we_i(`WriteDisable),

		.vir_addr_i(inst_vir_addr_i),
		.phy_addr_o(inst_phy_addr_o),
		
		.tlb_exception_o(inst_tlb_exception_o),
		
		.hit_index_o(inst_tlb_index),
		.access_we_o(inst_tlb_access_we_o),
		.dirty_we_o(inst_tlb_dirty_we_o)
	);


	mmu_conv mmu_conv1(
		.rst_n(rst_n),

		.tlb0_vpn_i(mtlbvpn[0]), .tlb0_pte_i(mtlbpte[0]), .tlb0_mask_i(mtlbmask[0]),
		.tlb1_vpn_i(mtlbvpn[1]), .tlb1_pte_i(mtlbpte[1]), .tlb1_mask_i(mtlbmask[1]),
		.tlb2_vpn_i(mtlbvpn[2]), .tlb2_pte_i(mtlbpte[2]), .tlb2_mask_i(mtlbmask[2]),
		.tlb3_vpn_i(mtlbvpn[3]), .tlb3_pte_i(mtlbpte[3]), .tlb3_mask_i(mtlbmask[3]),
		.tlb4_vpn_i(mtlbvpn[4]), .tlb4_pte_i(mtlbpte[4]), .tlb4_mask_i(mtlbmask[4]),
		.tlb5_vpn_i(mtlbvpn[5]), .tlb5_pte_i(mtlbpte[5]), .tlb5_mask_i(mtlbmask[5]),
		.tlb6_vpn_i(mtlbvpn[6]), .tlb6_pte_i(mtlbpte[6]), .tlb6_mask_i(mtlbmask[6]),
		.tlb7_vpn_i(mtlbvpn[7]), .tlb7_pte_i(mtlbpte[7]), .tlb7_mask_i(mtlbmask[7]),
		.tlb8_vpn_i(mtlbvpn[8]), .tlb8_pte_i(mtlbpte[8]), .tlb8_mask_i(mtlbmask[8]),
		.tlb9_vpn_i(mtlbvpn[9]), .tlb9_pte_i(mtlbpte[9]), .tlb9_mask_i(mtlbmask[9]),
		.tlb10_vpn_i(mtlbvpn[10]), .tlb10_pte_i(mtlbpte[10]), .tlb10_mask_i(mtlbmask[10]),
		.tlb11_vpn_i(mtlbvpn[11]), .tlb11_pte_i(mtlbpte[11]), .tlb11_mask_i(mtlbmask[11]),
		.tlb12_vpn_i(mtlbvpn[12]), .tlb12_pte_i(mtlbpte[12]), .tlb12_mask_i(mtlbmask[12]),
		.tlb13_vpn_i(mtlbvpn[13]), .tlb13_pte_i(mtlbpte[13]), .tlb13_mask_i(mtlbmask[13]),
		.tlb14_vpn_i(mtlbvpn[14]), .tlb14_pte_i(mtlbpte[14]), .tlb14_mask_i(mtlbmask[14]),
		.tlb15_vpn_i(mtlbvpn[15]), .tlb15_pte_i(mtlbpte[15]), .tlb15_mask_i(mtlbmask[15]),

		.vm_i(mstatus_vm),
		.prv_i(mstatus_mprv == 1'b1 ? mstatus_mpp : next_prv),
		.mxr_i(mstatus_mxr),

		.ce_i(data_ce_i),
		.ex_i(1'b0),
		.we_i(data_we_i),
		.vir_addr_i(data_vir_addr_i),
		.phy_addr_o(data_phy_addr_o),

		.tlb_exception_o(data_tlb_exception_o),

		.hit_index_o(data_tlb_index),
		.access_we_o(data_tlb_access_we_o),
		.dirty_we_o(data_tlb_dirty_we_o)
	);

	// 計算異常時跳轉到的位置
	always @(*)
	if(rst_n == `RstEnable)
	begin
		exception_new_pc_o <= `ZeroWord;
	end
	else
	begin
		exception_new_pc_o <= `ZeroWord;

		if(has_cause)
		begin
			// TODO:
			exception_new_pc_o <= `ZeroWord;
			exception_new_pc_o[`CSR_mtvec_addr_bus] <= mtvec_addr;
		end
		else if(excepttype_i[`Exception_ERET_FROM_U])
		begin
			// TODO: 
			// exception_new_pc_o <= 
			$display("TODO: should not arrive here");
			$stop;
		end
		else if(excepttype_i[`Exception_ERET_FROM_S])
		begin
			// TODO:
			// exception_new_pc_o <= 
			$display("TODO: should not arrive here");
			$stop;
		end
		else if(excepttype_i[`Exception_ERET_FROM_M])
		begin
			exception_new_pc_o <= `ZeroWord;
			exception_new_pc_o[`CSR_mepc_addr_bus] <= mepc_addr;
		end
		else if(excepttype_i[`Exception_FENCEI] == 1'b1)
		begin
			exception_new_pc_o <= current_inst_addr_i + 4'd4;
		end
	end
	// CSR protect
	always @(*)
		if (rst_n == `RstEnable)
			protect_o <= 1'b0;
		else if(re_i == `ReadDisable && will_write_in_mem_i == `CSRWriteDisable)
			protect_o <= 1'b0;
		else if(prv_o < raddr_i[`CSRAddrPrvBus])
		begin
			protect_o <= 1'b1;
		end
		else if(will_write_in_mem_i == `CSRWrite && raddr_i[`CSRAddrRWBus] == `CSRAddrReadOnly)
		begin
			protect_o <= 1'b1;
		end
		else
		begin
			protect_o <= 1'b0;

			case (raddr_i)
				`CSR_misa,

				`CSR_mvendorid,
				`CSR_mimpid,
				`CSR_marchid,
				`CSR_mhartid,

				`CSR_mscratch,
				`CSR_mtvec,
				`CSR_mepc,
				`CSR_medeleg,
				`CSR_mideleg,

				`CSR_mcause,
				`CSR_mbadaddr,

				`CSR_mstatus,
				`CSR_mip,
				`CSR_mie,


				`CSR_mscounteren,
				`CSR_mucounteren,

				`CSR_sptbr,

				`CSR_mtlbindex,
				`CSR_mtlbvpn,
				`CSR_mtlbmask,
				`CSR_mtlbpte,
				`CSR_mtlbptevaddr,

				`CSR_sscratch,
				`CSR_stvec,
				`CSR_sstatus:
					protect_o <= 1'b0;
				
				default:
					protect_o <= 1'b1;
			endcase
		end

	// CSR read
	always @(*)
		if (rst_n == `RstEnable)
			data_o <= `ZeroWord;
		else if(re_i == `ReadDisable)
			data_o <= `ZeroWord;
		else
		begin
			data_o <= `ZeroWord;

			case (raddr_i)
				`CSR_misa:      data_o <= misa;

				`CSR_mvendorid: data_o <= mvendorid;
				`CSR_mimpid:    data_o <= mimpid;
				`CSR_marchid:   data_o <= marchid;
				`CSR_mhartid:   data_o <= mhartid;

				`CSR_mscratch:  data_o <= mscratch;
				`CSR_mtvec:     data_o[`CSR_mtvec_addr_bus] <= mtvec_addr;
				`CSR_mepc:      data_o[`CSR_mepc_addr_bus] <= mepc_addr;
				`CSR_medeleg:   data_o[`CSR_medeleg_bus] <= medeleg;
				`CSR_mideleg:   data_o[`CSR_mideleg_bus] <= mideleg;

				`CSR_mcause:    data_o <= mcause;
				`CSR_mbadaddr:  data_o <= mbadaddr;

				`CSR_mstatus:
				begin
					data_o[`CSR_mstatus_vm_bus] <= mstatus_vm;
					data_o[`CSR_mstatus_mxr_bus] <= mstatus_mxr;
					data_o[`CSR_mstatus_mprv_bus] <= mstatus_mprv;
					data_o[`CSR_mstatus_fs_bus] <= mstatus_fs;
					data_o[`CSR_mstatus_sd_bus] <= mstatus_sd;
					data_o[`CSR_mstatus_mpp_bus] <= mstatus_mpp;
					data_o[`CSR_mstatus_spp_bus] <= mstatus_spp;
					data_o[`CSR_mstatus_mpie_bus] <= mstatus_mpie;
					data_o[`CSR_mstatus_spie_bus] <= mstatus_spie;
					data_o[`CSR_mstatus_upie_bus] <= mstatus_upie;
					data_o[`CSR_mstatus_mie_bus] <= mstatus_mie;
					data_o[`CSR_mstatus_sie_bus] <= mstatus_sie;
					data_o[`CSR_mstatus_uie_bus] <= mstatus_uie;
				end

				`CSR_mip:       data_o[`CSR_mip_mtip_bus] <= mip_mtip;


				`CSR_mscounteren: data_o[`CSR_mscounteren_tm_bus] <= mscounteren_tm;
				`CSR_mucounteren: data_o[`CSR_mucounteren_tm_bus] <= mucounteren_tm;

				`CSR_sptbr:     data_o[`CSR_sptbr_ppn_bus] <= sptbr_ppn;

				`CSR_mtlbindex: data_o[`CSR_mtlbindex_bus] <= mtlbindex;
				`CSR_mtlbvpn:   data_o <= mtlbvpn[mtlbindex];
				`CSR_mtlbmask:  data_o <= mtlbmask[mtlbindex];
				`CSR_mtlbpte:   data_o <= mtlbpte[mtlbindex];
				`CSR_mtlbptevaddr: data_o <= mtlbptevaddr[mtlbindex];

				`CSR_sscratch:  data_o <= sscratch;
				`CSR_stvec:     data_o[`CSR_stvec_addr_bus] <= stvec_addr;
				`CSR_sstatus:
				begin
					data_o[`CSR_mstatus_fs_bus] <= mstatus_fs;
					data_o[`CSR_mstatus_sd_bus] <= mstatus_sd;
					data_o[`CSR_mstatus_spp_bus] <= mstatus_spp;
					data_o[`CSR_mstatus_spie_bus] <= mstatus_spie;
					data_o[`CSR_mstatus_upie_bus] <= mstatus_upie;
					data_o[`CSR_mstatus_sie_bus] <= mstatus_sie;
					data_o[`CSR_mstatus_uie_bus] <= mstatus_uie;
				end
				default:        begin end
			endcase
		end

endmodule
