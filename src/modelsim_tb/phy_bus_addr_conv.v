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
// Module:  phy_bus_addr_conv
// File:    phy_bus_addr_conv.v
// Author:  shyoshyo
// E-mail:  shyoshyo@qq.com
// Description: phy addr => bus addr    
// Revision: 1.0
//////////////////////////////////////////////////////////////////////
`include "defines.v"

`define UART_PHYSICAL_ADDR_BEGIN 32'hbfd003f8
`define UART_PHYSICAL_ADDR_LEN 32'h20

`define RAM_PHYSICAL_ADDR_BEGIN 32'h8000_0000
`define RAM_PHYSICAL_ADDR_LEN   32'h0800_0000


module phy_bus_addr_conv(
	input wire rst_n,

	input wire[`RegBus] phy_addr_i,
	output reg[`WishboneAddrBus] bus_addr_o
);
	wire [`RegBus] uart_index = ((phy_addr_i - `UART_PHYSICAL_ADDR_BEGIN));
	wire [`RegBus] ram_index = ((phy_addr_i - `RAM_PHYSICAL_ADDR_BEGIN));
	always @(*)
		if (rst_n == `RstEnable)
			bus_addr_o <= `ZeroWord;
		else if (`UART_PHYSICAL_ADDR_BEGIN <= phy_addr_i && phy_addr_i < `UART_PHYSICAL_ADDR_BEGIN + `UART_PHYSICAL_ADDR_LEN)
			bus_addr_o <= {4'h1, uart_index[27:2], 2'h0};
		else if (`RAM_PHYSICAL_ADDR_BEGIN <= phy_addr_i && phy_addr_i < `RAM_PHYSICAL_ADDR_BEGIN + `RAM_PHYSICAL_ADDR_LEN)
			bus_addr_o <= {4'h0, ram_index[27:0]};
		else
			bus_addr_o <= `ZeroWord;
endmodule
