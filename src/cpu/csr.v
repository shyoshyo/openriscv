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
	output reg[`RegBus] exception_new_pc_o,

	// timer interrupt output
	output reg timer_int_o
);
	reg[`RegBus] mscratch;
	reg[`RegBus] mtvec;

	// write & modify CSR
	always @ (posedge clk or negedge rst_n)
		if (rst_n == `RstEnable)
		begin
			timer_int_o <= `InterruptNotAssert;

			mscratch <= `ZeroWord;
			mtvec <= `ZeroWord;
		end
		else
		begin
			// TODO: fixme
			if(`False_v)
			begin
				timer_int_o <= `InterruptAssert;
				timer_int_o <= `InterruptNotAssert;
			end
			
			case(we_i)
				`CSRWrite:
					case (waddr_i)
						`CSR_mscratch:
							mscratch <= data_i;
						`CSR_mtvec:
							mtvec <= data_i;

						default:
						begin
						end
					endcase

				`CSRSet:
					case (waddr_i)
						`CSR_mscratch:
							mscratch <= mscratch | data_i;
						`CSR_mtvec:
							mtvec <= mtvec | data_i;

						default:
						begin
						end
					endcase

				`CSRClear:
					case (waddr_i)
						`CSR_mscratch:
							mscratch <= mscratch & ~data_i;
						`CSR_mtvec:
							mtvec <= mtvec & ~data_i;
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
			exception_new_pc_o <= 32'h0x00000001;
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
			case (raddr_i)
				`CSR_mscratch: data_o <= mscratch;
				`CSR_mtvec: data_o <= mtvec;

				default: data_o <= `ZeroWord;
			endcase
		end

endmodule
