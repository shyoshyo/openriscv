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
// Module:  ctrl
// File:    ctrl.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: 控制模块，控制流水线的刷新、暂停等
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module ctrl(

	input wire rst_n,
	

	input wire[31:0] excepttype_i,
	
	//来自取址阶段的暂停请求
	input wire stallreq_from_if,

	//来自译码阶段的暂停请求
	input wire stallreq_from_id,

	//来自执行阶段的暂停请求
	input wire stallreq_from_ex,

	//来自访存阶段的暂停请求
	input wire stallreq_from_mem,
	
	//来自回写阶段的暂停请求
	input wire stallreq_from_wb,

	output reg flush,
	output reg[5:0] stall
	
);

	// stall <= {WB, MEM, EXE, ID, IF, PC}

	always @ (*)
		if(rst_n == `RstEnable)
		begin
			stall <= {`NoStop, `NoStop, `NoStop, `NoStop, `NoStop, `NoStop};
			flush <= `NoFlush;
		end
		else if(excepttype_i != `ZeroWord)
		begin
			stall <= {`NoStop, `NoStop, `NoStop, `NoStop, `NoStop, `NoStop};
			flush <= `Flush;
		end
		else
		begin
			stall <=
			{
				(stallreq_from_wb == `Stop) ? `Stop : `NoStop,

				(stallreq_from_mem == `Stop || stallreq_from_wb == `Stop) ? `Stop : `NoStop,

				(stallreq_from_ex == `Stop || stallreq_from_mem == `Stop || stallreq_from_wb == `Stop) ? `Stop : `NoStop,

				(stallreq_from_id == `Stop || stallreq_from_ex == `Stop ||
					stallreq_from_mem == `Stop || stallreq_from_wb == `Stop) ? `Stop : `NoStop,

				(stallreq_from_if == `Stop || stallreq_from_id == `Stop || stallreq_from_ex == `Stop ||
					stallreq_from_mem == `Stop || stallreq_from_wb == `Stop) ? `Stop : `NoStop,
				
				(stallreq_from_if == `Stop || stallreq_from_id == `Stop || stallreq_from_ex == `Stop ||
					stallreq_from_mem == `Stop || stallreq_from_wb == `Stop) ? `Stop : `NoStop
			};

			flush <= `NoFlush;
		end
endmodule