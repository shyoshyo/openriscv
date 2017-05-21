`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:41:18 11/15/2016 
// Design Name: 
// Module Name:    flash_io 
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
module flash_io(
	input clk,rst_n,
	output wire[22:0] flash_addr,
	inout wire[15:0] flash_data,
	input wire[22:1] addr,
	input wire[15:0] data_wt,
	output wire[15:0] data_rd,
	input wire is_read,is_write,is_erase,
	output flash_ack,
	output wire[0:7] signal	//flash_byte,flash_ce,flash_ce1,flash_ce2,flash_oe,flash_rp,flash_vpen,flash_we
    );

reg flash_ce,flash_oe,flash_we;
wire flash_byte,flash_vpen,flash_rp;
reg[15:0] flash_data_tmp;
reg[15:0] flash_out;
reg[22:1] addr_tmp;
assign flash_data = flash_oe ? flash_data_tmp : 16'hzz;
assign data_rd = flash_out;
assign flash_addr = {addr_tmp,1'b0};
assign signal = {flash_byte,flash_ce,1'b0,1'b0,flash_oe,flash_rp,flash_vpen,flash_we};
assign flash_byte = 1'b1;
assign flash_vpen = 1'b1;
assign flash_rp = 1'b1;
reg[3:0] read_wait;
reg[3:0] state;
localparam IDLE = 4'd0,
	READ1 = 4'd1,
	READ2 = 4'd2,
	READ3 = 4'd3,
	ERASE1 = 4'd4,
	ERASE2 = 4'd5,
	ERASE3 = 4'd6,
	WRITE1 = 4'd7,
	WRITE2 = 4'd8,
	WRITE3 = 4'd9,
	CHECK1 = 4'd10,
	CHECK2 = 4'd11,
	CHECK3 = 4'd12,
	CHECK4 = 4'd13,
	DONE = 4'd14;
	
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		state <= IDLE;
		flash_data_tmp <= 16'd0;
		flash_out <= 16'd0;
		addr_tmp <= 22'd0;
		flash_ce <= 1'd0;
		flash_oe <= 1'd0;
		flash_we <= 1'd0;
		read_wait <= 3'd0;
	end else
	case (state)
	IDLE:
	begin
		addr_tmp <= addr;
		if (is_read)
		begin
			flash_ce <= 0;
			flash_oe <= 1;
			flash_we <= 0;
			flash_data_tmp <= 16'h00FF;
			state <= READ1;
		end
		else if (is_erase)
		begin
			flash_ce <= 0;
			flash_oe <= 1;
			flash_we <= 0;
			flash_data_tmp <= 16'h0020;
			state <= ERASE1;
		end
		else if (is_write)
		begin
			flash_ce <= 0;
			flash_oe <= 1;
			flash_we <= 0;
			flash_data_tmp <= 16'h0040;
			state <= WRITE1;
		end
		else
		begin
			flash_ce <= 1;
			flash_oe <= 1;
			flash_we <= 1;
		end
	end
	READ1:
	begin
		flash_we <= 1;
		state <= READ2;
	end
	READ2:
	begin
		flash_oe <= 0;
		state <= READ3;
		read_wait <= 3'd0;
	end
	READ3:
	begin
		if (read_wait[3])
		begin
			flash_out <= flash_data;
			state <= DONE;
		end else
			read_wait <= read_wait+1'b1;
	end
	ERASE1:
	begin
		flash_we <= 1;
		state <= ERASE2;
	end
	ERASE2:
	begin
		flash_we <= 0;
		flash_data_tmp <= 16'h00D0;
		state <= ERASE3;
	end
	ERASE3:
	begin
		flash_we <= 1;
		state <= CHECK1;
	end
	WRITE1:
	begin
		flash_we <= 1;
		state <= WRITE2;
	end
	WRITE2:
	begin
		flash_we <= 0;
		flash_data_tmp <= data_wt;
		state <= WRITE3;
	end
	WRITE3:
	begin
		flash_we <= 1;
		state <= CHECK1;
	end
	CHECK1:
	begin
		flash_data_tmp <= 16'h0070;
		flash_we <= 0;
		state <= CHECK2;
	end
	CHECK2:
	begin
		flash_we <= 1;
		state <= CHECK3;
	end
	CHECK3:
	begin
		flash_oe <= 0;
		state <= CHECK4;
	end
	CHECK4:
	begin
		flash_oe <= 1;
		if (flash_data[7])
			state <= DONE;
		else
			state <= CHECK1;
	end
	DONE:
	begin
		if ({is_read,is_write,is_erase}==3'b000)
			state <= IDLE;
	end
	endcase
end

assign flash_ack = (state==DONE);

endmodule
