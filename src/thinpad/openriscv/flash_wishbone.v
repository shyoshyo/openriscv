`timescale 1ns / 1ps
`include "../../cpu/defines.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    03:48:58 11/22/2016 
// Design Name: 
// Module Name:    flash_wishbone 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

/* States */
`define IDLE 2'h0
`define READ_H0 2'h1
`define READ_H1 2'h2

module flash_wishbone(

	input wire clk,		// max. 50 MHz
	input wire rst_n,	

	// Wishbone interface
	input wire[`RegBus]           wishbone_addr_i,
	input wire[`RegBus]           wishbone_data_i,
	input wire                    wishbone_we_i,
	input wire[3:0]               wishbone_sel_i,
	input wire                    wishbone_stb_i,
	input wire                    wishbone_cyc_i,
	
	output reg[`RegBus]           wishbone_data_o,
	output reg                    wishbone_ack_o,

	// To flash_io
	inout wire[15:0] flash_data,
	output wire[22:0] flash_addr,
	output wire[0:7] signal	//flash_byte,flash_ce,flash_ce1,flash_ce2,flash_oe,flash_rp,flash_vpen,flash_we

    );

	wire[15:0] data_rd;
	reg flash_is_read;
	wire flash_ack;
	wire wb_is_read, wb_is_write;
	reg[22:1] addr;
	
	assign wb_is_read  = wishbone_stb_i & wishbone_cyc_i & ~wishbone_we_i;
	assign wb_is_write = wishbone_stb_i & wishbone_cyc_i & wishbone_we_i;
	
	flash_io flash_io0(.clk(clk), .rst_n(rst_n),
		.addr(addr),
		.data_wt(16'h0), .data_rd(data_rd), 
		.is_read(flash_is_read), .is_write(1'b0), .is_erase(1'b0),
		.flash_ack(flash_ack),
		// To flash chip
		.signal(signal),
		.flash_addr(flash_addr), 
		.flash_data(flash_data));
		
	reg[1:0] state;
	reg[`RegBus] data_out;
	reg ack_out;
	
	always @(*)
	begin
		wishbone_ack_o <= rst_n && ack_out;
		wishbone_data_o <= data_out;
	end
	
	// Update state, flash_is_read, addr*,
	//        data_out, ack_out
	always @(posedge clk or negedge rst_n)
		if (rst_n == `RstEnable) begin
			state <= `IDLE;
			flash_is_read <= 1'b0;
			data_out <= `ZeroWord;
			ack_out <= 1'b0;
		end else
			case (state)
			`IDLE: 
				if (wb_is_read) begin
					state <= `READ_H0;
					addr <= {wishbone_addr_i[23:2]};
					flash_is_read <= 1'b1;
					ack_out <= 1'b0;
				end
				else begin
					flash_is_read <= 1'b0;
					ack_out <= 1'b0;
				end
			`READ_H0:
				if (flash_ack) begin
					data_out[15:0] <= data_rd;
					data_out[31:16] <= 16'h0;
					//
					state <= `READ_H1;
					flash_is_read <= 1'b0;
					ack_out <= 1'b1;
				end
			`READ_H1: begin
				ack_out <= 1'b0;
				state <= `IDLE;
			end
			endcase
	
endmodule
