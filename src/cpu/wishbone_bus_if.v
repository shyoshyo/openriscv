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
// Module:  wishbone_bus_if
// File:    wishbone_bus_if.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: 
//   wishbone bus to cpu control signal
// 
//   if request not change, then do not need come back
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module wishbone_bus_if(
	input wire wishbone_clk,

	input wire cpu_clk,

	input wire rst_n,
	
	//from ctrl module
	input wire[5:0]               stall_i,
	input                         stall_this_i,
	input                         flush_i,
	
	//CPU interface
	input wire                    cpu_ce_i,
	input wire[`RegBus]           cpu_data_i,
	input wire[`PhyAddrBus]       cpu_addr_i,
	input wire                    cpu_we_i,
	input wire[`RegSel]           cpu_sel_i,
	output reg[`RegBus]           cpu_data_o,
	
	//Wishbone interface
	input wire[`WishboneDataBus]  wishbone_data_i,
	input wire                    wishbone_ack_i,
	output wire[`PhyAddrBus]      wishbone_addr_o,
	output wire[`WishboneDataBus] wishbone_data_o,
	output wire                   wishbone_we_o,
	output wire[`WishboneSelBus]  wishbone_sel_o,
	output wire                   wishbone_stb_o,
	output wire                   wishbone_cyc_o,

	output wire                    stallreq	       
	
);
	// 留几个总线周期的缓冲
	parameter delay = 10;

	// to process or not
	wire process;
	assign process = (cpu_ce_i == 1'b1) && (flush_i == `NoFlush);

	// shake hand protocol:
	//     cpu req,
	//     cpu ack(what wants wishbone to ack)
	//     wishbone ack(ack response from wishbone)
	// 
	// def what_wants_wishbone_to_ack:
	//     if process:
	//         ack = req + 1
	//     else:
	//         ack = req
	//     return ack
	reg cpu_ack_id;
	wire cpu_req_id;
	reg wishbone_ack_id;
	assign cpu_req_id = (process == 1'b1) ? (cpu_ack_id ^ 1'b1) : cpu_ack_id;

	// wishbone acked or not
	reg wishbone_ack_valid;

    // is requesting or not
    // 
    // if process == 0:
    //     not req
    // 
	// if ack == req && wishbone_ack_valid == 1:
	//     not req
	// else
	//     req
	wire request_bus;
	assign request_bus = (process == 1'b1) && (wishbone_ack_id != cpu_req_id || wishbone_ack_valid == 1'b0); 

	// request for maximum 2^cyc_len_log_2 consequential bus access
	parameter cyc_len_log_2 = 8;
	reg [(cyc_len_log_2 - 1) : 0] req_cnt;
	always @ (posedge cpu_clk or negedge rst_n)
		if(rst_n == `RstEnable)
		begin
			cpu_ack_id <= 1'b0;
			req_cnt <= {cyc_len_log_2{1'b0}};
		end
		else if(stallreq != `Stop && (stall_this_i != `Stop || flush_i == `NoFlush))
		begin
			cpu_ack_id <= wishbone_ack_id;
			req_cnt <= req_cnt + 1'b1;
		end

	always @ (posedge wishbone_clk or negedge rst_n)
		if(rst_n == `RstEnable)
		begin
			wishbone_ack_valid <= 1'b0;
			wishbone_ack_id <= 1'b0;
		end
		else if((wishbone_ack_i & request_bus) == 1'b1)
		begin
			wishbone_ack_valid <= 1'b1;
			wishbone_ack_id <= cpu_req_id;

			cpu_data_o <= wishbone_data_i;
		end

	// TODO
	assign wishbone_addr_o = cpu_addr_i;
	assign wishbone_data_o = cpu_data_i[`WishboneDataBus];

	// 竞争与冒险？
	assign wishbone_cyc_o = ((request_bus) | ((flush_i == `NoFlush) & ~(&req_cnt) & (stallreq == `Stop || stall_this_i == `NoStop)));
	assign wishbone_stb_o = request_bus; 
	assign wishbone_we_o = cpu_we_i;
	assign wishbone_sel_o = cpu_sel_i[`WishboneSelBus];

	reg[delay:0] stall_delay;
	reg not_use;

	always @ (posedge wishbone_clk or negedge rst_n)
		if(rst_n == `RstEnable)
			stall_delay <= {1'b0};
		else if(flush_i == `Flush)
			stall_delay <= {1'b0};
		else if((wishbone_ack_i & request_bus) == 1'b1)
			{not_use, stall_delay} <= {stall_delay, 1'b0};
		else
			{not_use, stall_delay} <= {stall_delay, request_bus};

	// 留两个总线周期的缓冲
	assign stallreq = (|stall_delay) && (flush_i == `NoFlush);

endmodule