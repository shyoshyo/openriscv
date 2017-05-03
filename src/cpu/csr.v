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

	// next pc for excpetion
	output reg[`RegBus] exception_new_pc_o,

	output reg [1:0] prv_o 
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
		1'b0;
	

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
			mstatus_fs <= `CSR_mstatus_fs_Off;
			mstatus_mpp <= `PRV_U;
			mstatus_spp <= `PRV_U;
			mstatus_mpie <= 1'b0;
			mstatus_spie <= 1'b0;
			mstatus_upie <= 1'b0;
			mstatus_mie <= 1'b0;
			mstatus_sie <= 1'b0;
			mstatus_uie <= 1'b0;

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
				prv_o <= `PRV_M;
			end
			else if(excepttype_i[`Exception_ERET_FROM_U])
			begin
				/*
				require_privilege(PRV_U); => trap_illegal_instruction
				*/
				
				// x = u -> y = u
				mstatus_uie <= mstatus_upie;
				mstatus_upie <= 1'b1;
				prv_o <= `PRV_U;
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
						prv_o <= `PRV_U;
					end
					`PRV_S:
					begin
						// x = s -> y = s
						mstatus_sie <= mstatus_spie;
						mstatus_spie <= 1'b1;
						mstatus_spp <= `PRV_U_1;
						prv_o <= `PRV_S;
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
						prv_o <= `PRV_U;
					end
					`PRV_S:
					begin
						// x = m -> y = s
						mstatus_sie <= mstatus_mpie;
						mstatus_mpie <= 1'b1;
						mstatus_mpp <= `PRV_U;
						prv_o <= `PRV_S;
					end
					`PRV_M:
					begin
						// x = m -> y = m
						mstatus_mie <= mstatus_mpie;
						mstatus_mpie <= 1'b1;
						mstatus_mpp <= `PRV_U;
						prv_o <= `PRV_M;
					end

					default:
					begin
					end
				endcase
			end
			else if(excepttype_i[`Exception_FENCEI])
			begin
				
			end
		end


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

				`CSR_mip:
					data_o[`CSR_mip_mtip_bus] <= mip_mtip;

				default:
				begin
				end
			endcase
		end

endmodule
