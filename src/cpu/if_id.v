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
// Module:  if_id
// File:    if_id.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: IF/ID阶段的寄存器
// 
// IF 的指令和地址将在下一时钟周期提供给 ID
// 
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module if_id(

	input wire clk,
	input wire rst_n,
	input wire[5:0] stall,	
	input wire flush,
	input wire[`ExceptionTypeBus] if_excepttype,

	// 取指阶段取得的指令对应的地址
	input wire[`RegBus] if_pc,
	// 取值阶段取到的地址
	input wire[`InstBus] if_inst,
	// 取值阶段使能是否就绪
	input wire if_inst_ce,
	
	
	// 译码阶段要用到的指令的地址
	output reg[`RegBus] id_pc,
	
	// 译码阶段要用的指令
	output reg[`InstBus] id_inst,

	// 新检测出的异常类型
	output reg[`ExceptionTypeBus] id_excepttype,

	output reg id_not_stall
);
	always @ (posedge clk or negedge rst_n) begin
		if (rst_n == `RstEnable)
		begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
			id_not_stall <= `False_v;

			id_excepttype <= 32'b0;
		end
		else if(if_inst_ce == `ChipDisable)
		begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
			id_not_stall <= `False_v;

			id_excepttype <= 32'b0;
		end
		else if(flush == `Flush)
		begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
			id_not_stall <= `False_v;

			id_excepttype <= 32'b0;
		end
		else if(stall[1] == `Stop && stall[2] == `NoStop)
		begin
			$display("should never arrive here");
			$stop;

			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
			id_not_stall <= `False_v;

			id_excepttype <= 32'b0;
		end
		else if(stall[1] == `NoStop)
		begin
			id_pc <= if_pc;
			id_inst <= if_inst;
			id_not_stall <= `True_v;

			id_excepttype <= if_excepttype;
		end
	end

endmodule