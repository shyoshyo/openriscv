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

`define RAM_PHYSICAL_ADDR_BEGIN            34'h08000_0000
`define RAM_PHYSICAL_ADDR_LEN              34'h00800_0000

`define UART_PHYSICAL_ADDR_BEGIN           34'h0bfd003f8
`define UART_PHYSICAL_ADDR_LEN             34'h20

`define CONFIG_STRING_PHYSICAL_ADDR_BEGIN  34'h00000_1000
`define CONFIG_STRING_PHYSICAL_ADDR_LEN    34'h00000_0400

`define MTIME_PHYSICAL_ADDR_BEGIN          34'h04000_0000
`define MTIME_PHYSICAL_ADDR_LEN            34'h00000_0008

`define MTIMECMP_PHYSICAL_ADDR_BEGIN       34'h04000_0008
`define MTIMECMP_PHYSICAL_ADDR_LEN         34'h00000_0008

`define IPI_PHYSICAL_ADDR_BEGIN            34'h04000_1000
`define IPI_PHYSICAL_ADDR_LEN              34'h00000_0004

module phy_bus_addr_conv(
	input wire rst_n,

	input wire[`PhyAddrBus] phy_addr_i,
	output reg[`WishboneAddrBus] bus_addr_o
);
	wire [`PhyAddrBus] ram_index = ((phy_addr_i - `RAM_PHYSICAL_ADDR_BEGIN));
	wire [`PhyAddrBus] uart_index = ((phy_addr_i - `UART_PHYSICAL_ADDR_BEGIN));
	wire [`PhyAddrBus] config_string_index = ((phy_addr_i - `CONFIG_STRING_PHYSICAL_ADDR_BEGIN));
	
	wire [`PhyAddrBus] mtime_index = ((phy_addr_i - `MTIME_PHYSICAL_ADDR_BEGIN));
	wire [`PhyAddrBus] mtimecmp_index = ((phy_addr_i - `MTIMECMP_PHYSICAL_ADDR_BEGIN));
	wire [`PhyAddrBus] ipi_index = ((phy_addr_i - `IPI_PHYSICAL_ADDR_BEGIN));

	always @(*)
		if (rst_n == `RstEnable)
			bus_addr_o <= `ZeroWord;
		else if (`RAM_PHYSICAL_ADDR_BEGIN <= phy_addr_i && phy_addr_i < `RAM_PHYSICAL_ADDR_BEGIN + `RAM_PHYSICAL_ADDR_LEN)
			bus_addr_o <= {4'h0, ram_index[27:0]};
		else if (`UART_PHYSICAL_ADDR_BEGIN <= phy_addr_i && phy_addr_i < `UART_PHYSICAL_ADDR_BEGIN + `UART_PHYSICAL_ADDR_LEN)
			bus_addr_o <= {4'h1, uart_index[27:2], 2'h0};
		else if (`CONFIG_STRING_PHYSICAL_ADDR_BEGIN <= phy_addr_i && phy_addr_i < `CONFIG_STRING_PHYSICAL_ADDR_BEGIN + `CONFIG_STRING_PHYSICAL_ADDR_LEN)
			bus_addr_o <= {4'h3, config_string_index[27:0]};
		else if (`MTIME_PHYSICAL_ADDR_BEGIN <= phy_addr_i && phy_addr_i < `MTIME_PHYSICAL_ADDR_BEGIN + `MTIME_PHYSICAL_ADDR_LEN)
			bus_addr_o <= {4'h3, mtime_index[27:0] + 12'h3f0};
		else if (`MTIMECMP_PHYSICAL_ADDR_BEGIN <= phy_addr_i && phy_addr_i < `MTIMECMP_PHYSICAL_ADDR_BEGIN + `MTIMECMP_PHYSICAL_ADDR_LEN)
			bus_addr_o <= {4'h3, mtimecmp_index[27:0] + 12'h3f8};
		else if (`IPI_PHYSICAL_ADDR_BEGIN <= phy_addr_i && phy_addr_i < `IPI_PHYSICAL_ADDR_BEGIN + `IPI_PHYSICAL_ADDR_LEN)
			bus_addr_o <= {4'h3, ipi_index[27:0] + 12'h3ec};
		else
			bus_addr_o <= ~`ZeroWord;
endmodule
