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
	input wire[`IntSourceBus] int_i,

	// inst vaddr & data vaddr
	input wire[`RegBus] current_inst_addr_i,
	input wire[`RegBus] current_data_addr_i,

	// delatslot(TODO: FIXME)
	input wire is_in_delayslot_i,

	// CSR read port
	output reg[`RegBus] data_o,

	// next pc for excpetion
	output reg[`RegBus] exception_new_pc_o
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
	reg[`CSR_medeleg_bus] medeleg;
	reg[`CSR_mideleg_bus] mideleg;

	reg[`CSR_mstatus_vm_bus] mstatus_vm;
	reg[`CSR_mstatus_fs_bus] mstatus_fs;
	wire[`CSR_mstatus_sd_bus] mstatus_sd = (mstatus_fs == `CSR_mstatus_fs_Dirty);

	wire[`CSR_mip_MTIP_bus] mip_mtip = int_i[0];



	// write & modify CSR
	always @ (posedge clk or negedge rst_n)
		if (rst_n == `RstEnable)
		begin
			mscratch <= `ZeroWord;
			mtvec_addr <= `ZeroWord;
			medeleg <= `ZeroWord;
			mideleg <= `ZeroWord;
			mstatus_vm <= `ZeroWord;

		end
		else
		begin
			case(we_i)
				`CSRWrite:
					case (waddr_i)
						`CSR_mscratch:
							mscratch <= data_i;
						`CSR_mtvec:
							mtvec_addr <= data_i[`CSR_mtvec_addr_bus];
						`CSR_medeleg:
							medeleg <= data_i[`CSR_medeleg_bus];
						`CSR_mideleg:
							mideleg <= data_i[`CSR_mideleg_bus];
						
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
						end

						`CSR_misa:
						begin
						end

						default:
						begin
						end
					endcase

				`CSRSet:
					case (waddr_i)
						`CSR_mscratch:
							mscratch <= mscratch | data_i;
						`CSR_mtvec:
							mtvec_addr <= mtvec_addr | data_i[`CSR_mtvec_addr_bus];
						`CSR_medeleg:
							medeleg <= medeleg | data_i[`CSR_medeleg_bus];
						`CSR_mideleg:
							mideleg <= mideleg | data_i[`CSR_mideleg_bus];
						
						`CSR_mstatus:
						begin
							case(mstatus_vm | data_i[`CSR_mstatus_vm_bus])
`ifdef RV32
								`CSR_mstatus_vm_Mbare, `CSR_mstatus_vm_Sv32:
`else
								`CSR_mstatus_vm_Mbare, `CSR_mstatus_vm_Sv32,
								`CSR_mstatus_vm_Sv39, `CSR_mstatus_vm_Sv48:
`endif
									mstatus_vm <= mstatus_vm | data_i[`CSR_mstatus_vm_bus];

								default: begin end
							endcase

							mstatus_fs <= mstatus_fs | data_i[`CSR_mstatus_fs_bus];
						end


						`CSR_misa:
						begin
						end
						
						default:
						begin
						end
					endcase

				`CSRClear:
					case (waddr_i)
						`CSR_mscratch:
							mscratch <= mscratch & ~data_i;
						`CSR_mtvec:
							mtvec_addr <= mtvec_addr & ~data_i[`CSR_mtvec_addr_bus];
						`CSR_medeleg:
							medeleg <= medeleg & ~data_i[`CSR_medeleg_bus];
						`CSR_mideleg:
							mideleg <= mideleg & ~data_i[`CSR_mideleg_bus];
						
						`CSR_mstatus:
						begin
							case(mstatus_vm & ~data_i[`CSR_mstatus_vm_bus])
`ifdef RV32
								`CSR_mstatus_vm_Mbare, `CSR_mstatus_vm_Sv32:
`else
								`CSR_mstatus_vm_Mbare, `CSR_mstatus_vm_Sv32,
								`CSR_mstatus_vm_Sv39, `CSR_mstatus_vm_Sv48:
`endif
									mstatus_vm <= mstatus_vm & ~data_i[`CSR_mstatus_vm_bus];

								default: begin end
							endcase

							mstatus_fs <= mstatus_fs & ~data_i[`CSR_mstatus_fs_bus];
						end

						`CSR_misa:
						begin
						end
						
						default:
						begin
						end
					endcase

				default:
				begin
				end
			endcase

			/*
			if(excepttype_i[20] == 1'b1 && excepttype_i[19:0] == 20'h0)
			begin

			end
			else if(excepttype_i != 32'h0)
			begin
				
			end
			*/
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

		if(excepttype_i[`Exception_FENCEI] == 1'b1)
		begin
			exception_new_pc_o <= current_inst_addr_i + 4'd4;
		end
		else
		begin
			// TODO: fix me
			exception_new_pc_o <= 32'h00000001;
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
				`CSR_medeleg:   data_o[`CSR_medeleg_bus] <= medeleg;
				`CSR_mideleg:   data_o[`CSR_mideleg_bus] <= mideleg;

				`CSR_mstatus:
				begin
					data_o[`CSR_mstatus_vm_bus] <= mstatus_vm;
					data_o[`CSR_mstatus_fs_bus] <= mstatus_fs;
					data_o[`CSR_mstatus_sd_bus] <= mstatus_sd;
				end

				`CSR_mip:
					data_o[`CSR_mip_MTIP_bus] <= mip_mtip;

				default:
				begin
				end
			endcase
		end

endmodule
