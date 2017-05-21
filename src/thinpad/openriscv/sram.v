/*
 * sram_spartan: a Wishbone wrapper 
 */

`include "../../cpu/defines.v"

/* 
 * States:
 *   R0: sram_data has been read, going to generate ack
 *   R1: wishbone_ack_o maintained for 1 cycle, going to cancel ack and return to IDLE
 *   PW (PartialWrite): sram_data has been read, going to setup sram_data for write, and transit to W0
 *   W0: sram_data maintained for 1c, going to enable sram_we
 *   W1: write should finish. going to generate ack and goto W2.
 */
`define IDLE 3'b000
`define R0   3'b001
`define R1   3'b010
`define W0   3'b011
`define W1   3'b100
`define W2   3'b101
`define PW   3'b110
`define RamEnable  1'b0
`define RamDisable 1'b1
`define RamChipBus 22:0
`define RamChipSel 22

module sram(
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

	output wire[5:0] sram_dbg,

	// Ports of 2 SRAM chips
	output wire[19:0] sram_addr0, sram_addr1,	// addr bus
	output wire sram_oe0, sram_oe1,
	output wire sram_ce0, sram_ce1,
	output wire sram_we0, sram_we1,
	inout wire[31:0] sram_data0, sram_data1		// data bus
);

	// request signal
	wire request;

	// request signal's rising edge
	reg  request_delay;
	wire request_rising_edge;
	wire wb_is_read, wb_is_write;

	// output buffer
	reg sram_oe_r, sram_ce_r, sram_we_r;
	reg [19:0] sram_addr_r;
	reg [31:0] sram_data_outbuf;
	wire [31:0] sram_data_in[1:0];

	reg [2:0] state;
	wire chip_sel;

	// Internal Assignments
	assign wb_is_read  = wishbone_stb_i & wishbone_cyc_i & ~wishbone_we_i;
	assign wb_is_write = wishbone_stb_i & wishbone_cyc_i & wishbone_we_i;
	
	// ram wires
	assign chip_sel = wishbone_addr_i[`RamChipSel];
	assign sram_oe0 = chip_sel == 0 ? sram_oe_r : `RamDisable;
	assign sram_oe1 = chip_sel == 1 ? sram_oe_r : `RamDisable;
	assign sram_ce0 = chip_sel == 0 ? sram_ce_r : `RamDisable;
	assign sram_ce1 = chip_sel == 1 ? sram_ce_r : `RamDisable;
	assign sram_we0 = chip_sel == 0 ? sram_we_r : `RamDisable;
	assign sram_we1 = chip_sel == 1 ? sram_we_r : `RamDisable;
	assign sram_addr0 = chip_sel == 0 ? sram_addr_r : 20'h0;
	assign sram_addr1 = chip_sel == 1 ? sram_addr_r : 20'h0;
	assign sram_data_in[0] = sram_data0;
	assign sram_data_in[1] = sram_data1;
	assign sram_data0 = sram_oe0 == `RamDisable ? sram_data_outbuf : 32'hzz;
	assign sram_data1 = sram_oe1 == `RamDisable ? sram_data_outbuf : 32'hzz;
	assign sram_dbg = {wb_is_read, wb_is_write, wishbone_ack_o, state};

	// State transition
	always @ (posedge clk or negedge rst_n)
	begin
		if (rst_n == `RstEnable)
			state <= `IDLE;
		else
			case (state)
				`IDLE: begin
					if (wb_is_read)
						state <= `R0;
					else if (wb_is_write)
						if (wishbone_sel_i == 4'b1111)
							state <= `W0;
						else
							state <= `PW;
					else
						state <= `IDLE;
				end
				`R0: state <= `R1;
				`R1: state <= `IDLE;
				`W0: state <= `W1;
				`W1: state <= `W2;
				`W2: state <= `IDLE;
				`PW: state <= `W0;
			endcase
	end

	// sram controller
	integer i;
	always @ (posedge clk or negedge rst_n)
	begin
		if (rst_n == `RstEnable) begin
			sram_oe_r <= `RamDisable;
			sram_ce_r <= `RamDisable;
			sram_we_r <= `RamDisable;
		end
		else if (state == `IDLE) begin
			if (wb_is_read) begin
				// READ with wishbone_addr_i
				sram_ce_r <= `RamEnable;
				sram_we_r <= `RamDisable;
				sram_oe_r <= `RamEnable;
				sram_addr_r <= wishbone_addr_i[21:2];
			end
			else if (wb_is_write) begin
				if (wishbone_sel_i != 4'b1111) begin
					// Partial WRITE. Read from the given addr first
					sram_ce_r <= `RamEnable;
					sram_we_r <= `RamDisable;
					sram_oe_r <= `RamEnable;
					sram_addr_r <= wishbone_addr_i[21:2];
				end
				else begin
					// Full WRITE. Set up data and wait for one cycle
					sram_ce_r <= `RamEnable;
					sram_we_r <= `RamDisable;
					sram_oe_r <= `RamDisable;
					sram_addr_r <= wishbone_addr_i[21:2];
					sram_data_outbuf <= wishbone_data_i;
				end
			end
			else begin // IDLE, no request
				sram_ce_r <= `RamDisable;
				sram_we_r <= `RamDisable;
				sram_oe_r <= `RamDisable;
			end
		end
		else if (state == `PW)
		begin
			// write with previously read data and input
			// set up data and wait for 1c
			sram_ce_r <= `RamEnable;
			sram_we_r <= `RamDisable;
			sram_oe_r <= `RamDisable;
			sram_addr_r <= wishbone_addr_i[21:2];
			// mask 
			if (wishbone_sel_i[0] == 1'b1)
				sram_data_outbuf[7:0] <= wishbone_data_i[7:0];
			else
				sram_data_outbuf[7:0] <= sram_data_in[chip_sel][7:0];
			if (wishbone_sel_i[1] == 1'b1)
				sram_data_outbuf[15:8] <= wishbone_data_i[15:8];
			else
				sram_data_outbuf[15:8] <= sram_data_in[chip_sel][15:8];
			if (wishbone_sel_i[2] == 1'b1)
				sram_data_outbuf[23:16] <= wishbone_data_i[23:16];
			else
				sram_data_outbuf[23:16] <= sram_data_in[chip_sel][23:16];
			if (wishbone_sel_i[3] == 1'b1)
				sram_data_outbuf[31:24] <= wishbone_data_i[31:24];
			else
				sram_data_outbuf[31:24] <= sram_data_in[chip_sel][31:24];
		end
		else 
		if (state == `W0) begin
			sram_we_r <= `RamEnable;
		end
		else begin // R0, W1: unset controller
			sram_oe_r <= `RamDisable;
			sram_ce_r <= `RamDisable;
			sram_we_r <= `RamDisable;
		end
	end

	// output signals
	always @ (posedge clk or negedge rst_n)
	begin
		if (rst_n == `RstEnable)
		begin
			wishbone_data_o <= `ZeroWord;
			wishbone_ack_o <= 0;
		end
		else case (state)
			// 1-cycle ack when entering R1/W1
			`R0: begin
				wishbone_ack_o <= 1'b1;
				// output masked out
				wishbone_data_o <= sram_data_in[chip_sel];
			end
			`W1: begin
				wishbone_ack_o <= 1'b1;
			end
			default: begin // R1, W2: unset ack; other states & no request: maintain
				wishbone_ack_o <= 1'b0;
			end
		endcase
	end
	 
endmodule
