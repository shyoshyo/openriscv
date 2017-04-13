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

`include "defines.v"

//数据存储器data_ram
`define DataAddrBus 31:0
`define DataBus 31:0
`define DataMemNum 16777216
`define DataMemNumLog2 24
`define ByteWidth 7:0

`timescale 1ns/1ps

module data_ram(
	input wire clk,
	input wire rst_n,

	input wire[`RegBus]           wishbone_addr_i,
	input wire[`RegBus]           wishbone_data_i,
	input wire                    wishbone_we_i,
	input wire[3:0]               wishbone_sel_i,
	input wire                    wishbone_stb_i,
	input wire                    wishbone_cyc_i,
	
	output reg[`RegBus]           wishbone_data_o,
	output wire                   wishbone_ack_o
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


	reg[`RegBus]  mem[0:`DataMemNum-1];
	
	initial
	begin
		:block 
		integer i;
		for(i = 0; i < `DataMemNum; i = i + 1)
			mem[i] <= `ZeroWord;

		#100 $readmemh ( "inst_rom.data", mem );
	end
	

	always @ (posedge clk or negedge rst_n)
		if (rst_n == `RstEnable)
			wishbone_data_o <= `ZeroWord;

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
			{ram_ack_delay} <= 3'b000;
		else if(request == 1'b0)
			{ram_ack_delay} <= 3'b000;
		else if (request_rising_edge == 1'b1)
		begin
			{ram_ack_delay} <= {ram_ack_delay[1:0], 1'b1};

			if(is_write)
			begin
				if (wishbone_sel_i[3] == 1'b1)
					mem[wishbone_addr_i[`DataMemNumLog2+1:2]][31:24] <= wishbone_data_i[31:24];
				if (wishbone_sel_i[2] == 1'b1)
					mem[wishbone_addr_i[`DataMemNumLog2+1:2]][23:16] <= wishbone_data_i[23:16];
				if (wishbone_sel_i[1] == 1'b1)
					mem[wishbone_addr_i[`DataMemNumLog2+1:2]][15:8] <= wishbone_data_i[15:8];
				if (wishbone_sel_i[0] == 1'b1)
					mem[wishbone_addr_i[`DataMemNumLog2+1:2]][7:0] <= wishbone_data_i[7:0];
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

	/*
	// 片内内存
	reg[`ByteWidth]	data_mem0[0:`DataMemNum-1];
	reg[`ByteWidth]	data_mem1[0:`DataMemNum-1];
	reg[`ByteWidth]	data_mem2[0:`DataMemNum-1];
	reg[`ByteWidth]	data_mem3[0:`DataMemNum-1];

	always @ (posedge clk)
		if (ce == `ChipDisable)
		begin
		end
		else if(we == `WriteEnable)
		begin
			if (sel[3] == 1'b1)
				data_mem3[addr[`DataMemNumLog2+1:2]] <= data_i[31:24];
			if (sel[2] == 1'b1)
				data_mem2[addr[`DataMemNumLog2+1:2]] <= data_i[23:16];
			if (sel[1] == 1'b1)
				data_mem1[addr[`DataMemNumLog2+1:2]] <= data_i[15:8];
			if (sel[0] == 1'b1)
				data_mem0[addr[`DataMemNumLog2+1:2]] <= data_i[7:0];
		end
	
	always @ (*)
		if (ce == `ChipDisable)
			data_o <= `ZeroWord;
		else if(we == `WriteDisable)
			data_o <= 
			{
				data_mem3[addr[`DataMemNumLog2+1:2]],
				data_mem2[addr[`DataMemNumLog2+1:2]],
				data_mem1[addr[`DataMemNumLog2+1:2]],
				data_mem0[addr[`DataMemNumLog2+1:2]]
			};
		else
				data_o <= `ZeroWord;
	*/


endmodule