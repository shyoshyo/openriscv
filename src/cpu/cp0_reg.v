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
// Module:  cp0_reg
// File:    cp0_reg.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description:实现了CP0中的一些寄存器，具体有：count、compare、status、
//             cause、EPC、config、PrId
//             shyoshyo: 补充了一些其他的寄存器
// 
//                 {addr, sel}
// 
//               CP0_REG_INDEX    {5'b00000, 3'b000}
//               CP0_REG_RANDOM   {5'b00001, 3'b000}
//               CP0_REG_ENTRYLO0 {5'b00010, 3'b000}
//               CP0_REG_ENTRYLO1 {5'b00011, 3'b000}
//               CP0_REG_PAGEMASK {5'b00101, 3'b000}
//               CP0_REG_BadVAddr {5'b01000, 3'b000}
//               CP0_REG_COUNT    {5'b01001, 3'b000}        //可读写
//               CP0_REG_ENTRYHI  {5'b01010, 3'b000}
//               CP0_REG_COMPARE  {5'b01011, 3'b000}        //可读写
//               CP0_REG_STATUS   {5'b01100, 3'b000}        //可读写
//               CP0_REG_CAUSE    {5'b01101, 3'b000}        //只读
//               CP0_REG_EPC      {5'b01110, 3'b000}        //可读写
//               CP0_REG_PrId     {5'b01111, 3'b000}        //只读
//               CP0_REG_EBASE    {5'b01111, 3'b001}
//               CP0_REG_CONFIG   {5'b10000, 3'b000}        //只读
// 
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module cp0_reg(
	input wire clk,
	input wire rst_n,
	
	
	input wire we_i,
	// 地址的格式为 {5'addr, 3'sel}
	input wire[7:0] waddr_i,
	input wire[7:0] raddr_i,
	input wire[`RegBus] data_i,
	

	input wire[31:0] excepttype_i,
	input wire[5:0] int_i,
	input wire[`RegBus] current_inst_addr_i,
	input wire[`RegBus] current_data_addr_i,
	input wire is_in_delayslot_i,


	output reg[`RegBus] data_o,

	output wire[`RegBus] index_o,
	output wire[`RegBus] random_o,
	output wire[`RegBus] entrylo0_o,
	output wire[`RegBus] entrylo1_o,
	output wire[`RegBus] pagemask_o,
	output wire[`RegBus] badvaddr_o,
	output wire[`RegBus] entryhi_o,
	output wire[`RegBus] ebase_o,

	output wire[`RegBus] count_o,
	output wire[`RegBus] compare_o,
	output wire[`RegBus] status_o,
	output wire[`RegBus] cause_o,
	output wire[`RegBus] epc_o,
	output wire[`RegBus] config_o,
	output wire[`RegBus] prid_o,

	output reg[`RegBus] exception_new_pc_o,

	output reg timer_int_o
);

	reg [3:0]index;
	assign index_o = {28'h0, index};


	reg [3:0]random;
	assign random_o = {28'h0, random};


	reg [19:0]entrylo0_pfn;
	reg entrylo0_d;
	reg entrylo0_v;
	reg entrylo0_g;
	// C = 010, Uncacheable
	assign entrylo0_o = {6'b0, entrylo0_pfn, 3'b010, entrylo0_d, entrylo0_v, entrylo0_g};

	reg [19:0]entrylo1_pfn;
	reg entrylo1_d;
	reg entrylo1_v;
	reg entrylo1_g;
	assign entrylo1_o = {6'b0, entrylo1_pfn, 3'b010, entrylo1_d, entrylo1_v, entrylo1_g};
	

	assign pagemask_o = `ZeroWord;


	reg [`RegBus]badvaddr;
	assign badvaddr_o = badvaddr;


	reg [18:0]entryhi_vpn2;
	reg [7:0]entryhi_asid;
	assign entryhi_o = {entryhi_vpn2, 5'b0, entryhi_asid};


	reg [17:0]ebase_addr;
	assign ebase_o = {2'b10, ebase_addr, 12'b0};


	reg [`RegBus]count;
	assign count_o = count;


	reg [`RegBus]compare;
	assign compare_o = compare;


	reg status_bev;
	reg [7:0]status_im;
	reg status_um;
	reg status_erl;
	reg status_exl;
	reg status_ie;
	//status寄存器的CU为0001，表示协处理器CP0存在, CP1存在
	assign status_o = {4'b0011, 5'b0, status_bev, 6'b0,
		status_im, 3'b0, status_um, 1'b0, status_erl, status_exl, status_ie};


	reg cause_bd;
	reg cause_dc;
	reg cause_iv;
	reg cause_wp;
	reg [5:0]cause_ip1;
	reg [1:0]cause_ip0;
	reg [4:0]cause_exe;
	assign cause_o = {cause_bd, 3'b0, cause_dc, 3'b0, cause_iv, cause_wp, 6'b0,
		cause_ip1, cause_ip0, 1'b0, cause_exe, 2'b0};


	reg [`RegBus]epc;

	assign epc_o = epc;

	//config寄存器的BE为0，表示Little-Endian；MT为001，表示有MMU, K0 = 0 = NoCache
	assign config_o = 32'b00000000_00000000_00000000_10000000;

	//制作者是L，对应的是0x48，类型是0x1，基本类型，版本号是1.0
	assign prid_o = 32'b00000000_01001100_00000001_00000010;



	wire[`RegBus] ebase_latest = (we_i == `WriteEnable && waddr_i == `CP0_REG_EBASE) ?
		{2'b10, data_i[29:12], 12'h0} :
			{2'b10, ebase_addr, 12'h0};

	wire cause_iv_latest =  (we_i == `WriteEnable && waddr_i == `CP0_REG_CAUSE) ?
		data_i[23] : cause_iv;

	wire status_exl_latest =  (we_i == `WriteEnable && waddr_i == `CP0_REG_STATUS) ?
		data_i[1] : status_exl;

	wire[`RegBus] epc_latest =  (we_i == `WriteEnable && waddr_i == `CP0_REG_EPC) ?
		data_i : epc;

	always @ (posedge clk or negedge rst_n)
		if (rst_n == `RstEnable)
		begin

			index <= 4'b0;
			random <= 4'b1111;


			entrylo0_pfn <= 20'h0;
			{entrylo0_d, entrylo0_v, entrylo0_g} <= 3'b0;

			entrylo1_pfn <= 20'h0;
			{entrylo1_d, entrylo1_v, entrylo1_g} <= 3'b0;

			badvaddr <= `ZeroWord;

			entryhi_vpn2 <= 19'b0;
			entryhi_asid <= 8'b0;

			ebase_addr <= 18'b0;

			count <= `ZeroWord;
			compare <= `ZeroWord;


			// BEV = 1, ERL = 1
			status_bev <= 1'b1;
			status_im <= 1'b0;
			status_um <= 1'b0;
			status_erl <= 1'b1;
			status_exl <= 1'b0;
			status_ie <= 1'b0;

			cause_iv <= 1'b0;
			cause_wp <= 1'b0;
			cause_bd <= 1'b0;
			cause_dc <= 1'b0;
			cause_ip1 <= 6'b0;
			cause_ip0 <= 2'b0;
			cause_exe <= 5'b0;

			epc <= `ZeroWord;



			timer_int_o <= `InterruptNotAssert;
		end
		else
		begin
			count <= count + 1'b1;
			random <= random - 1'b1;

			cause_ip1 <= int_i;
		
			if(compare != `ZeroWord && count == compare)
			begin
				timer_int_o <= `InterruptAssert;
			end
			
			if(we_i == `WriteEnable)
			begin
				case (waddr_i)
					`CP0_REG_INDEX:
					begin
						index <= data_i[3:0];
					end

					`CP0_REG_RANDOM:
					begin
					end

					`CP0_REG_ENTRYLO0:
					begin
						// pfn
						entrylo0_pfn <= data_i[25:6];

						// {dirty, valid, global}
						{entrylo0_d, entrylo0_v, entrylo0_g} <= data_i[2:0];
					end

					`CP0_REG_ENTRYLO1:
					begin
						// pfn
						entrylo1_pfn <= data_i[25:6];

						// {dirty, valid, global}
						{entrylo1_d, entrylo1_v, entrylo1_g} <= data_i[2:0];
					end

					`CP0_REG_PAGEMASK:
					begin
					end

					`CP0_REG_BadVAddr:
					begin
					end

					`CP0_REG_ENTRYHI:
					begin
						entryhi_vpn2 <= data_i[31:13];  // vpn2
						entryhi_asid <= data_i[7:0];    // asid
					end

					`CP0_REG_EBASE:
					begin
						ebase_addr <= data_i[29:12];
					end

					`CP0_REG_COUNT:
					begin
						count <= data_i;
					end
					
					`CP0_REG_COMPARE:
					begin
						compare <= data_i;
						// count <= `ZeroWord;
						timer_int_o <= `InterruptNotAssert;
					end
					
					`CP0_REG_STATUS:
					begin
						// {ERL, EXL, IE}
						{status_erl, status_exl, status_ie} <= data_i[2:0];

						// {UM}
						status_um <= data_i[4];

						// {InterruptMask}
						status_im <= data_i[15:8];

						// {BEV}
						status_bev <= data_i[22];
					end
					
					`CP0_REG_CAUSE:
					begin
						//cause寄存器只有IP[1:0]、DC, IV、WP字段是可写的

						cause_ip0 <= data_i[9:8];
						cause_wp <= data_i[22];
						cause_iv <= data_i[23];
						cause_dc <= data_i[27];
					end
					
					`CP0_REG_EPC:
					begin
						epc <= data_i;
					end
					
					`CP0_REG_PrId, `CP0_REG_CONFIG:
					begin
					end

					default:
					begin
					end
				endcase
			end

			// 处理异常
			// exceptiontype
			// * 0   machine check   TLB write that conflicts with an existing entry
			// * 1-8 外部中斷         Assertion of unmasked HW or SW interrupt signal.
			// * 9   adEl            Fetch address alignment error.
			// * 10  TLBL            Fetch TLB miss, Fetch TLB hit to page with V=0 (inst)
			// * 11  syscall
			// * 12  RI              無效指令 Reserved Instruction
			// * 13  ov              溢出
			// * 14  trap
			// * 15  AdEL            Load address alignment error,  
			// * 16  adES            Store address alignment error.
			//                       User mode store to kernel address.
			// * 17  TLBL            Load TLB miss,  (4Kc core). (data)
			// * 18  TLBS            Store TLB miss
			// * 19  TLB Mod         Store to TLB page with D=0
			// * 20  ERET

			if(excepttype_i[20] == 1'b1 && excepttype_i[19:0] == 20'h0)
			begin
				status_exl <= 1'b0;
			end
			else if(excepttype_i != 32'h0)
			begin
				if(status_exl == 1'b0)
				begin
					if(is_in_delayslot_i == `InDelaySlot)
					begin
						epc <= current_inst_addr_i - 4;
						cause_bd <= 1'b1;
					end
					else
					begin
						epc <= current_inst_addr_i;
						cause_bd <= 1'b0;
					end
				end
				
				status_exl <= 1'b1;
				



				if(excepttype_i[0])
				begin
					cause_exe <= `CAUSE_MCHECK;
				end
				else if(excepttype_i[8:1] != 8'h00)
				begin
					cause_exe <= `CAUSE_INT;
				end
				else if(excepttype_i[9])
				begin
					cause_exe <= `CAUSE_ADEL;
					badvaddr <= current_inst_addr_i;
				end
				else if(excepttype_i[10])
				begin
					cause_exe <= `CAUSE_TLBL;
					badvaddr <= current_inst_addr_i;
					entryhi_vpn2 <= current_inst_addr_i[31:13];
				end
				else if(excepttype_i[11])
				begin
					cause_exe <= `CAUSE_SYS;
				end
				else if(excepttype_i[12])
				begin
					cause_exe <= `CAUSE_RI;
				end
				else if(excepttype_i[13])
				begin
					cause_exe <= `CAUSE_OV;
				end
				else if(excepttype_i[14])
				begin
					cause_exe <= `CAUSE_TR;
				end
				else if(excepttype_i[15])
				begin
					cause_exe <= `CAUSE_ADEL;
					badvaddr <= current_data_addr_i;
				end
				else if(excepttype_i[16])
				begin
					cause_exe <= `CAUSE_ADES;
					badvaddr <= current_data_addr_i;
				end
				else if(excepttype_i[17])
				begin
					cause_exe <= `CAUSE_TLBL;
					badvaddr <= current_data_addr_i;
					entryhi_vpn2 <= current_data_addr_i[31:13];
				end
				else if(excepttype_i[18])
				begin
					cause_exe <= `CAUSE_TLBS;
					badvaddr <= current_data_addr_i;
					entryhi_vpn2 <= current_data_addr_i[31:13];
				end
				else if(excepttype_i[19])
				begin
					cause_exe <= `CAUSE_MOD;
					badvaddr <= current_data_addr_i;
					entryhi_vpn2 <= current_data_addr_i[31:13];
				end
			end
		end


	// 計算異常時跳轉到的位置
	always @(*)
	if(rst_n == `RstEnable)
	begin
		exception_new_pc_o <= `ZeroWord;
	end
	else
	begin
		exception_new_pc_o <= `ZeroWord;
		if(excepttype_i[20] == 1'b1 && excepttype_i[19:0] == 20'h0)
		begin
			exception_new_pc_o <= epc_latest;
		end
		else if(excepttype_i != 32'h0)
		begin

			if(excepttype_i[0])
			begin
				// General exception vector (offset 0x180)
				exception_new_pc_o <= ebase_latest + 32'h180;
			end
			else if(excepttype_i[8:1] != 8'h00)
			begin
				// General exception vector (offset 0x180) if the IV bit in the Cause register is 0;
				// interrupt vector (offset 0x200) if the IV bit in the Cause register is 1
				exception_new_pc_o <= ebase_latest + ((cause_iv_latest == 1'b0) ? 32'h180 : 32'h200);
			end
			else if(excepttype_i[9])
			begin
				// General exception vector (offset 0x180)
				exception_new_pc_o <= ebase_latest + 32'h180;
			end
			else if(excepttype_i[10])
			begin
				// TLB refill vector (offset 0x000) if Status EXL = 0 at the time of exception;
				// general exception vector (offset 0x180) if Status EXL = 1 at the time of exception
				exception_new_pc_o <= ebase_latest + (status_exl_latest ? 32'h180 : 32'h0);
			end
			else if(excepttype_i[11])
			begin
				// General exception vector (offset 0x180)
				exception_new_pc_o <= ebase_latest + 32'h180;
			end
			else if(excepttype_i[12])
			begin
				// General exception vector (offset 0x180)
				exception_new_pc_o <= ebase_latest + 32'h180;
			end
			else if(excepttype_i[13])
			begin
				// General exception vector (offset 0x180)
				exception_new_pc_o <= ebase_latest + 32'h180;
			end
			else if(excepttype_i[14])
			begin
				// General exception vector (offset 0x180)
				exception_new_pc_o <= ebase_latest + 32'h180;
			end
			else if(excepttype_i[15])
			begin
				// General exception vector (offset 0x180)
				exception_new_pc_o <= ebase_latest + 32'h180;
			end
			else if(excepttype_i[16])
			begin
				// General exception vector (offset 0x180)
				exception_new_pc_o <= ebase_latest + 32'h180;
			end
			else if(excepttype_i[17])
			begin
				// TLB refill vector (offset 0x000) if Status EXL = 0 at the time of exception;
				// general exception vector (offset 0x180) if Status EXL = 1 at the time of exception
				exception_new_pc_o <= ebase_latest + (status_exl_latest ? 32'h180 : 32'h0);
			end
			else if(excepttype_i[18])
			begin
				// TLB refill vector (offset 0x000) if Status EXL = 0 at the time of exception;
				// general exception vector (offset 0x180) if Status EXL = 1 at the time of exception
				exception_new_pc_o <= ebase_latest + (status_exl_latest ? 32'h180 : 32'h0);
			end
			else if(excepttype_i[19])
			begin
				// General exception vector (offset 0x180)
				exception_new_pc_o <= ebase_latest + 32'h180;
			end
		end
	end

	always @(*)
		if (rst_n == `RstEnable)
			data_o <= `ZeroWord;
		else
			case (raddr_i)
				`CP0_REG_INDEX: data_o <= index_o;
				`CP0_REG_RANDOM: data_o <= random_o;
				`CP0_REG_ENTRYLO0: data_o <= entrylo0_o;
				`CP0_REG_ENTRYLO1: data_o <= entrylo1_o;
				`CP0_REG_PAGEMASK: data_o <= pagemask_o;
				`CP0_REG_BadVAddr: data_o <= badvaddr_o;
				`CP0_REG_ENTRYHI: data_o <= entryhi_o;
				`CP0_REG_EBASE: data_o <= ebase_o;
				`CP0_REG_COUNT: data_o <= count_o;
				`CP0_REG_COMPARE: data_o <= compare_o;
				`CP0_REG_STATUS: data_o <= status_o;
				`CP0_REG_CAUSE: data_o <= cause_o;
				`CP0_REG_EPC: data_o <= epc_o;
				`CP0_REG_PrId: data_o <= prid_o;
				`CP0_REG_CONFIG: data_o <= config_o;

				default: data_o <= `ZeroWord;
			endcase
endmodule
