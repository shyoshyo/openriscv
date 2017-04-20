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
// Module:  regfile
// File:    regfile.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: 通用寄存器，共32个
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module regfile(

	input wire clk,
	input wire rst_n,
	
	//写端口
	input wire we,
	input wire[`RegAddrBus] waddr,
	input wire[`RegBus] wdata,
	
	//读端口1
	input wire re1,
	input wire[`RegAddrBus] raddr1,
	output reg[`RegBus] rdata1,
	
	//读端口2
	input wire re2,
	input wire[`RegAddrBus] raddr2,
	output reg[`RegBus] rdata2
	
);
	reg[`RegBus]  regs[0 : `RegNum-1];

	always @ (posedge clk or negedge rst_n) 
		if (rst_n == `RstEnable)
		begin
			{
				regs[0], regs[1], regs[2], regs[3],
				regs[4], regs[5], regs[6], regs[7],
				regs[8], regs[9], regs[10], regs[11],
				regs[12], regs[13], regs[14], regs[15],
				regs[16], regs[17], regs[18], regs[19],
				regs[20], regs[21], regs[22], regs[23],
				regs[24], regs[25], regs[26], regs[27],
				regs[28], regs[29], regs[30], regs[31]
			} <= {`RegNum{`ZeroWord}};
		end
		else
		begin
			if((we == `WriteEnable) && (waddr != `RegNumLog2'h0))
				regs[waddr] <= wdata;
		end
	
	always @ (*)
		if(rst_n == `RstEnable) 
			  rdata1 <= `ZeroWord;
		else if(raddr1 == `RegNumLog2'h0)
	  		rdata1 <= `ZeroWord;
		else if((raddr1 == waddr) && (we == `WriteEnable) 
	  	            && (re1 == `ReadEnable)) 
			rdata1 <= wdata;
		else if(re1 == `ReadEnable)
			rdata1 <= regs[raddr1];
		else
			rdata1 <= `ZeroWord;
		  
	always @ (*)
		if(rst_n == `RstEnable) 
			  rdata2 <= `ZeroWord;
		else if(raddr2 == `RegNumLog2'h0)
	  		rdata2 <= `ZeroWord;
		else if((raddr2 == waddr) && (we == `WriteEnable) 
	  	            && (re2 == `ReadEnable)) 
			rdata2 <= wdata;
		else if(re2 == `ReadEnable)
			rdata2 <= regs[raddr2];
		else
			rdata2 <= `ZeroWord;

endmodule