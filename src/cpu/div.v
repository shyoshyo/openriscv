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
// Module:  div
// File:    div.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: 除法模块
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module div(
	input wire clk,
	input wire rst_n,
	
	// 是否带符号
	input wire signed_div_i,
	
	// 两个 32 位的输入
	input wire[63:0] opdata1_i,
	input wire[63:0] opdata2_i,

	// 开始信号
	// 与书上不同，这里开始信号给一周期就可以了。
	// 如果没有给开始信号，则以前的结果可以一直保留
	input wire start_i,

	// 中断信号
	input wire annul_i,
	

	// 结果寄存器
	output reg[127:0] result_o,
	// 除法运算是否结束
	output reg ready_o
);
	// 32 bit divisor
	
	/*

	wire[32:0] div_temp;

	// 除法进行了多少轮。cnt = 32 时，试商法结束。
	reg[5:0] cnt;

	// 第 k = 0(开始), 1, 2, ... 次迭代结束时
	// dividend[63:k+1] 被除数，dividend[k:0] 结果
	reg[64:0] dividend;
	reg[31:0] divisor;

	// 试一次商
	assign div_temp = {1'b0, dividend[63:32]} - {1'b0, divisor};


	reg[1:0] state;

	reg[31:0] opdata1;
	reg[31:0] opdata2;
	reg signed_div;


	always @ (posedge clk or negedge rst_n) begin
		if (rst_n == `RstEnable)begin
			state <= `DivFree;
			ready_o <= `DivResultNotReady;
			result_o <= {`ZeroWord,`ZeroWord};
		end else begin
			case (state)
				`DivFree:  //DivFree状态
				begin
					if(start_i == `DivStart && annul_i == 1'b0)
					begin
						if(opdata2_i == `ZeroWord)
						begin
							state <= `DivByZero;
						end
						else
						begin
							state <= `DivOn;
							cnt <= 6'b000000;
							dividend <= {`ZeroWord,`ZeroWord};
							dividend[32:1] <= (signed_div_i == 1'b1 && opdata1_i[31] == 1'b1) ? (~opdata1_i + 1) : (opdata1_i);
							divisor <= (signed_div_i == 1'b1 && opdata2_i[31] == 1'b1) ? (~opdata2_i + 1) : (opdata2_i);
						end
						
						opdata1 <= opdata1_i;
						opdata2 <= opdata2_i;
						signed_div <= signed_div_i;
						ready_o <= `DivResultNotReady;
						result_o <= {`ZeroWord,`ZeroWord};
					end
				end

				`DivByZero:  //DivByZero状态
				begin
				 	dividend <= {`ZeroWord,`ZeroWord};
					state <= `DivEnd;
				end

				`DivOn:  //DivOn状态
				begin
					if(annul_i == 1'b0)
					begin
						if(cnt != 6'b100000)
						begin
							 if(div_temp[32] == 1'b1)
							 begin
									dividend <= {dividend[63:0], 1'b0};
							 end
							 else
							 begin
									dividend <= {div_temp[31:0], dividend[31:0], 1'b1};
							 end
							 cnt <= cnt + 1'b1;
						 end
						 else
						 begin
							 if((signed_div == 1'b1) && ((opdata1[31] ^ opdata2[31]) == 1'b1))
							 begin
									dividend[31:0] <= (~dividend[31:0] + 1);
							 end
							 if((signed_div == 1'b1) && ((opdata1[31] ^ dividend[64]) == 1'b1))
							 begin							
									dividend[64:33] <= (~dividend[64:33] + 1);
							 end
							 state <= `DivEnd;
							 cnt <= 6'b000000;							
						 end
					end
					else
					begin
						state <= `DivFree;
						ready_o <= `DivResultNotReady;
						result_o <= {`ZeroWord,`ZeroWord};
					end
				end
				`DivEnd:  //DivEnd状态
				begin
					result_o <= {dividend[64:33], dividend[31:0]};	
					ready_o <= `DivResultReady;
					state <= `DivFree;
				end
			endcase
		end
	end
	*/
endmodule