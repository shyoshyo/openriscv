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
// Module:  openriscv_min_sopc_tb
// File:    openriscv_min_sopc_tb.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: openriscv_min_sopcµÄtestbench
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"
`timescale 1ns/1ps

module openriscv_min_sopc_tb();

	reg CLOCK_100;
	reg CLOCK_50;
	reg CLOCK_25;
	reg CLOCK_12_5;
	reg CLOCK_1;
	reg CLOCK_0_1;
	reg rst_n;

	initial begin
		CLOCK_0_1 = 1'b1;
		forever #5000 CLOCK_0_1 = ~CLOCK_0_1;
		
		// 2 * 40ns = 80ns ~ 12.5Mhz
	end


	initial begin
		CLOCK_1 = 1'b1;
		forever #500 CLOCK_1 = ~CLOCK_1;
		
		// 2 * 40ns = 80ns ~ 12.5Mhz
	end

	initial begin
		CLOCK_12_5 = 1'b1;
		forever #40 CLOCK_12_5 = ~CLOCK_12_5;
		
		// 2 * 40ns = 80ns ~ 12.5Mhz
	end

	initial begin
		CLOCK_25 = 1'b1;
		forever #20 CLOCK_25 = ~CLOCK_25;
		
		// 2 * 20ns = 40ns ~ 25Mhz
	end

	initial begin
		CLOCK_50 = 1'b1;
		forever #10 CLOCK_50 = ~CLOCK_50;
		
		// 2 * 10ns = 20ns ~ 50Mhz
	end
	
	initial begin
		CLOCK_100 = 1'b1;
		forever #5 CLOCK_100 = ~CLOCK_100;
		
		// 2 * 5ns = 10ns ~ 100Mhz
	end


	parameter IDLE				 = 3'b000;
	parameter RX_START_BIT = 3'b001;
	parameter RX_DATA_BITS = 3'b010;
	parameter RX_STOP_BIT	= 3'b011;
	parameter CLEANUP			= 3'b100;
	
	reg [15:0]		 r_Clock_Count;
	reg [2:0]		 r_Bit_Index; //8 bits total
	reg [7:0]		 r_RX_Byte;
	reg					 r_RX_DV;
	reg [2:0]		 r_SM_Main;
	
	wire i_RX_Serial;
	
	// Testbench uses a 25 MHz clock (same as Go Board)
	// Want to interface to 115200 baud UART
	// 25000000 / 115200 = 217 Clocks Per Bit.
	parameter CLOCK_PERIOD_NS = 10;
	parameter CLKS_PER_BIT    = 868/2;
	//parameter BIT_PERIOD      = 8600;
	parameter c_BIT_PERIOD      = 8680;

	// Purpose: Control RX state machine
	always @(posedge CLOCK_50 or negedge rst_n)
	if(~rst_n)
	begin
		r_Clock_Count <= 0;
		r_Bit_Index <= 0;
		r_RX_Byte <= 0;
		r_RX_DV <= 0;
		r_SM_Main <= 0;
	end
	else
	begin
			
		case (r_SM_Main)
			IDLE :
				begin
					r_RX_DV			 <= 1'b0;
					r_Clock_Count <= 0;
					r_Bit_Index	 <= 0;
					
					if (i_RX_Serial == 1'b0)					// Start bit detected
					begin
						r_SM_Main <= RX_START_BIT;
			 		end
					else
						r_SM_Main <= IDLE;
				end
			
			// Check middle of start bit to make sure it's still low
			RX_START_BIT :
				begin
					if (r_Clock_Count == (CLKS_PER_BIT-1)/2)
					begin
						if (i_RX_Serial == 1'b0)
						begin
							r_Clock_Count <= 0;	// reset counter, found the middle
							r_SM_Main		 <= RX_DATA_BITS;
						end
						else
							r_SM_Main <= IDLE;
					end
					else
					begin
						r_Clock_Count <= r_Clock_Count + 1;
						r_SM_Main		 <= RX_START_BIT;
					end
				end // case: RX_START_BIT
			
			
			// Wait CLKS_PER_BIT-1 clock cycles to sample serial data
			RX_DATA_BITS :
				begin
					if (r_Clock_Count < CLKS_PER_BIT-1)
					begin
						r_Clock_Count <= r_Clock_Count + 1;
						r_SM_Main		 <= RX_DATA_BITS;
					end
					else
					begin
						r_Clock_Count					<= 0;
						r_RX_Byte[r_Bit_Index] <= i_RX_Serial;
						
						// Check if we have received all bits
						if (r_Bit_Index < 7)
						begin
							r_Bit_Index <= r_Bit_Index + 1;
							r_SM_Main	 <= RX_DATA_BITS;
						end
						else
						begin
							r_Bit_Index <= 0;
							r_SM_Main	 <= RX_STOP_BIT;
						end
					end
				end // case: RX_DATA_BITS
			
			
			// Receive Stop bit.	Stop bit = 1
			RX_STOP_BIT :
				begin
					// Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
					if (r_Clock_Count < CLKS_PER_BIT-1)
					begin
						r_Clock_Count <= r_Clock_Count + 1;
		 			r_SM_Main		 <= RX_STOP_BIT;
					end
					else
					begin
			 			r_RX_DV			 <= 1'b1;

			 			$write("%c", r_RX_Byte);

						r_Clock_Count <= 0;
						r_SM_Main		 <= CLEANUP;
					end
				end // case: RX_STOP_BIT
			
			
			// Stay here 1 clock
			CLEANUP :
				begin
					r_SM_Main <= IDLE;
					r_RX_DV	 <= 1'b0;
				end
			
			
			default :
				r_SM_Main <= IDLE;
			
		endcase
	end		


	reg r_RX_Serial = 1;
	wire [7:0] w_RX_Byte;
	
	
	// Takes in input byte and serializes it 
	task UART_WRITE_BYTE;
		input [7:0] i_Data;
		integer     ii;
		begin
			
			// Send Start Bit
			r_RX_Serial <= 1'b0;
			#(c_BIT_PERIOD);

			// Send Data Byte
			for (ii=0; ii<8; ii=ii+1)
			begin
				r_RX_Serial <= i_Data[ii];
				#(c_BIT_PERIOD);
			end

			// Send Stop Bit
			r_RX_Serial <= 1'b1;
			#(c_BIT_PERIOD);
		end
	endtask // UART_WRITE_BYTE

	initial begin
		rst_n = `RstEnable;
		#195 rst_n= `RstDisable;

		@(posedge CLOCK_100);
		#400 UART_WRITE_BYTE(8'h37);
		@(posedge CLOCK_100);
		#400 UART_WRITE_BYTE(8'h38);
		@(posedge CLOCK_100);
		#400 UART_WRITE_BYTE(8'h39);
		// #400 $stop;
	end


	openriscv_min_sopc openriscv_min_sopc0(
		.clk(CLOCK_1),
		.wishbone_clk(CLOCK_100),
		.rst_n(rst_n),

		.uart_rxd_i(r_RX_Serial),
		.uart_cts_i(1'b0),
		.uart_txd_o(i_RX_Serial),
		.uart_rts_o()
	);

endmodule
