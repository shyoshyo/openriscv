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
// Module:  data_ram
// File:    data_ram.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: bootloader
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "../cpu/defines.v"

//数据存储器data_ram
`define DataAddrBus 31:0
`define DataBus 31:0
`define DataMemNum (256)
`define DataMemNumLog2 8
`define ByteWidth 7:0

`timescale 1ns/1ps

module bootloader(
	input wire clk,
	input wire cpu_clk,
	input wire rst_n,

	input wire[`WishboneAddrBus]           wishbone_addr_i,
	input wire[`WishboneDataBus]           wishbone_data_i,
	input wire                             wishbone_we_i,
	input wire[`WishboneSelBus]            wishbone_sel_i,
	input wire                             wishbone_stb_i,
	input wire                             wishbone_cyc_i,
	
	output reg[`WishboneDataBus]           wishbone_data_o,
	output wire                            wishbone_ack_o
);
	// request signal
	wire request;

	// request signal's rising edge
	reg  request_delay;
	wire request_rising_edge;
	wire is_read, is_write;

	// ack signal
	reg  [2:0]ram_ack_delay;

	// get request signal
	assign request = wishbone_stb_i & wishbone_cyc_i;

	// Internal Assignments
	assign is_read  = wishbone_stb_i & wishbone_cyc_i & ~wishbone_we_i;
	assign is_write = wishbone_stb_i & wishbone_cyc_i & wishbone_we_i;

	wire[`WishboneDataBus]  mem[0:`DataMemNum-1];
	`include"bootloader_rom/bootloader_rom.v"

	always @ (posedge clk or negedge rst_n)
		if(rst_n == `RstEnable)
			request_delay <= 1'b0;
		else
			request_delay <= request;
 
 	assign request_rising_edge = ((request_delay ^ request) & request) | (request & request_delay & ram_ack_delay[2]);

	// generate a 1 cycle acknowledgement for each request rising edge
	always @ (posedge clk or negedge rst_n)
	begin
		if (rst_n == `RstEnable)
		begin
			{ram_ack_delay} <= 3'b000;
			
			wishbone_data_o <= `ZeroWord;
		end
		else if(request == 1'b0)
		begin
			{ram_ack_delay} <= 3'b000;
		end
		else if (request_rising_edge == 1'b1)
		begin
			{ram_ack_delay} <= {ram_ack_delay[1:0], 1'b1};

			if(is_write)
			begin
				
			end
			else
			begin
				wishbone_data_o <= `ZeroWord;

				if (wishbone_sel_i[3] == 1'b1)
					wishbone_data_o[31:24] <= mem[wishbone_addr_i[`DataMemNumLog2+1:2]][31:24];
				if (wishbone_sel_i[2] == 1'b1)
					wishbone_data_o[23:16] <= mem[wishbone_addr_i[`DataMemNumLog2+1:2]][23:16];
				if (wishbone_sel_i[1] == 1'b1)
					wishbone_data_o[15:8] <= mem[wishbone_addr_i[`DataMemNumLog2+1:2]][15:8];
				if (wishbone_sel_i[0] == 1'b1)
					wishbone_data_o[7:0] <= mem[wishbone_addr_i[`DataMemNumLog2+1:2]][7:0];
			end
		end
		else
		begin
			{ram_ack_delay} <= {ram_ack_delay[1:0], 1'b0};
		end
	end

	assign wishbone_ack_o = ram_ack_delay[0] & request;
endmodule