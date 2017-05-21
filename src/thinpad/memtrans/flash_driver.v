/*
 * $File: flash_driver.v
 * $Date: Fri Nov 01 22:45:16 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

`timescale 1ns/1ps

module flash_driver
	#(parameter FLASH_ADDR_SIZE = 22)
	(
	input clk,
	input [FLASH_ADDR_SIZE - 1:0] addr,
	input [15:0] data_in,
	output [15:0] data_out,
	/*
	* when asserted, data could be continousely read from flash, just change
	* addr and read in next cycle when busy is 0
	*/
	input enable_read,
	// assert for one cycle to erase; addr would be latched
	input enable_erase,
	// assert for one cycle to write; addr and data would be latched
	input enable_write,
	/*
	* indicate whether can start reading in read mode
	* indicate whether device is busy in writing and erasing mode
	*/
	output reg busy,
	output [FLASH_ADDR_SIZE:0] flash_addr,
	inout [15:0] flash_data,
	output [7:0] flash_ctl);



	assign data_out = flash_data;

	reg flash_oe, flash_we;

	wire flash_byte = 1, flash_vpen = 1, flash_ce = 0, flash_rp = 1;

	reg [FLASH_ADDR_SIZE - 1:0] addr_latch;	
	assign flash_addr = {enable_read ? addr : addr_latch, 1'b0};
	reg [15:0] data_to_write, data_in_latch;	

	// by default, flash_data should be data_to_write, to avoid ruining data
	// write setup time
	assign flash_data = flash_oe ? data_to_write : {16{1'bz}};

	assign flash_ctl = {
		flash_byte,
		flash_ce,
		2'b0,	// ce1 ce2
		flash_oe,
		flash_rp,
		flash_vpen,
		flash_we};

	reg [3:0] state;
	localparam
		IDLE = 4'b0000,
		WRITE1 = 4'b0001,
		WRITE2 = 4'b0011,
		WRITE3 = 4'b0010,
		ERASE1 = 4'b0110,
		ERASE2 = 4'b0111,
		ERASE3 = 4'b0101,
		READ1 = 4'b0100,
		READ2 = 4'b1100,
		READ3 = 4'b1101,
		READ4 = 4'b1111,
		SR1 = 4'b1110,
		SR2 = 4'b1010,
		SR3 = 4'b1011,
		SR4 = 4'b1001;

	// XXX: I do not know why correct data can only appear after some time
	// when read after writing
	reg [2:0] read_wait_cnt;
	always @(posedge clk) begin
		case (state)
			IDLE: begin
				addr_latch <= addr;
				if (enable_write) begin
					data_in_latch <= data_in;
					data_to_write <= 16'h0040;
					flash_we <= 0;
					state <= WRITE1;
					busy <= 1;
				end else if (enable_erase) begin
					data_to_write <= 16'h0020;
					flash_we <= 0;
					state <= ERASE1;
					busy <= 1;
				end else if (enable_read) begin
					data_to_write <= 16'h00FF;
					flash_we <= 0;
					state <= READ1;
					busy <= 1;
				end else begin
					flash_oe <= 1;
					flash_we <= 1;
					busy <= 0;
				end
			end

			WRITE1: begin
				flash_we <= 1;
				state <= WRITE2;
			end
			WRITE2: begin
				flash_we <= 0;
				data_to_write <= data_in_latch;
				state <= WRITE3;
			end
			WRITE3: begin
				flash_we <= 1;
				state <= SR1;
			end

			ERASE1: begin
				flash_we <= 1;
				state <= ERASE2;
			end
			ERASE2: begin
				flash_we <= 0;
				data_to_write <= 16'h00d0;
				state <= ERASE3;
			end
			ERASE3: begin
				flash_we <= 1;
				state <= SR1;
			end

			READ1: begin
				flash_we <= 1;
				state <= READ2;
			end
			READ2: begin
				flash_oe <= 0;
				state <= READ3;
				read_wait_cnt <= 0;
			end
			READ3: begin
				if (read_wait_cnt[2]) begin
					busy <= 0;
					state <= READ4;
				end else
					read_wait_cnt <= read_wait_cnt + 1'b1;
			end
			READ4: begin
				if (!enable_read)
					state <= IDLE;
			end

			// wait for SR[7] to become 1
			SR1: begin
				data_to_write <= 16'h0070;
				flash_we <= 0;
				state <= SR2;
			end
			SR2: begin
				flash_we <= 1;
				state <= SR3;
			end
			SR3: begin
				flash_oe <= 0;
				state <= SR4;
			end
			SR4: begin
				flash_oe <= 1;
				if (flash_data[7]) begin
					state <= IDLE;
					busy <= 0;
				end
				else
					state <= SR1;
			end

			default:
				state <= IDLE;
		endcase
	end


endmodule



