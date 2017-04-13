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
// Description: 数据存储器
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`define BootloaderRomNum 32'h0000_0100
`define BootloaderRomNumLog2 8

`include "defines.v"
`timescale 1ns/1ps

module bootloader_rom(
	input wire clk,
	input wire rst_n,

	input wire[`RegBus]           wishbone_addr_i,
	input wire[`RegBus]           wishbone_data_i,
	input wire                    wishbone_we_i,
	input wire[3:0]               wishbone_sel_i,
	input wire                    wishbone_stb_i,
	input wire                    wishbone_cyc_i,
	
	output reg[`RegBus]           wishbone_data_o,
	output reg                    wishbone_ack_o
);
	// request signal
	wire request;

	// request signal's rising edge
	reg  request_delay;
	wire request_rising_edge;
	wire is_read, is_write;

	// ack signal
	reg  ram_ack;

	// get request signal
	assign request = wishbone_stb_i & wishbone_cyc_i;

	// Internal Assignments
	assign is_read  = wishbone_stb_i & wishbone_cyc_i & ~wishbone_we_i;
	assign is_write = wishbone_stb_i & wishbone_cyc_i & wishbone_we_i;


	reg[`RegBus]  mem[0:`BootloaderRomNum-1];
	
	initial
	begin
		:block 
		integer i;
		for(i = 0; i < `BootloaderRomNum; i = i + 1)
			mem[i] <= `ZeroWord;

		mem[0] <= 32'h3c038000;
		mem[1] <= 32'h00600008;
		mem[2] <= 32'h00000000;
	end
	

	always @ (posedge clk or negedge rst_n)
		if(rst_n == `RstEnable)
			request_delay <= 1'b0;
		else
			request_delay <= request;
 
	assign request_rising_edge = (request_delay ^ request) & request;

	// generate a 1 cycle acknowledgement for each request rising edge
	always @ (posedge clk or negedge rst_n)
	begin
		if (rst_n == `RstEnable)
		begin
			ram_ack <= 0;
			wishbone_data_o <= `ZeroWord;
		end
		else if (request_rising_edge == 1'b1)
		begin
			ram_ack <= 1'b1;

			if(is_write)
			begin
				/*
				if (wishbone_sel_i[3] == 1'b1)
					mem[wishbone_addr_i[`BootloaderRomNumLog2+1:2]][31:24] <= wishbone_data_i[31:24];
				if (wishbone_sel_i[2] == 1'b1)
					mem[wishbone_addr_i[`BootloaderRomNumLog2+1:2]][23:16] <= wishbone_data_i[23:16];
				if (wishbone_sel_i[1] == 1'b1)
					mem[wishbone_addr_i[`BootloaderRomNumLog2+1:2]][15:8] <= wishbone_data_i[15:8];
				if (wishbone_sel_i[0] == 1'b1)
					mem[wishbone_addr_i[`BootloaderRomNumLog2+1:2]][7:0] <= wishbone_data_i[7:0];
				*/
			end
			else
			begin
				wishbone_data_o <= `ZeroWord;

				if (wishbone_sel_i[3] == 1'b1)
					wishbone_data_o[31:24] <= mem[wishbone_addr_i[`BootloaderRomNumLog2+1:2]][31:24];
				if (wishbone_sel_i[2] == 1'b1)
					wishbone_data_o[23:16] <= mem[wishbone_addr_i[`BootloaderRomNumLog2+1:2]][23:16];
				if (wishbone_sel_i[1] == 1'b1)
					wishbone_data_o[15:8] <= mem[wishbone_addr_i[`BootloaderRomNumLog2+1:2]][15:8];
				if (wishbone_sel_i[0] == 1'b1)
					wishbone_data_o[7:0] <= mem[wishbone_addr_i[`BootloaderRomNumLog2+1:2]][7:0];
			end
		end
		else
		begin
			ram_ack <= 1'b0;
		end
	end

	// register wishbone_ack output, because onchip ram0 uses registered output
	always @ (posedge clk or negedge rst_n)
	begin
		if (rst_n == `RstEnable)
			wishbone_ack_o <= 1'b0;
		else
			wishbone_ack_o <= ram_ack;
	end
	
endmodule