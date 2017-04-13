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
// Module:  ex_mem
// File:    ex_mem.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: EX/MEM�׶εļĴ���
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module ex_mem(

	input wire clk,
	input wire rst_n,

	//���Կ���ģ�����Ϣ
	input wire[5:0] stall,
	input wire flush,
	
	//����ִ�н׶ε���Ϣ	
	input wire[`RegAddrBus] ex_wd,
	input wire ex_wreg,
	input wire[`RegBus] ex_wdata,
	input wire[`RegBus] ex_hi,
	input wire[`RegBus] ex_lo,
	input wire ex_whilo,
	//Ϊʵ�ּ��ء��ô�ָ������
	input wire[`AluOpBus] ex_aluop,
	input wire[`RegBus] ex_mem_addr,
	input wire[`RegBus] ex_reg2,

	// ������ͣ�� ex ��һ�׶α������Ϣ
	input wire[`DoubleRegBus] hilo_i,	
	input wire[1:0] cnt_i,
	input wire div_started_i,

	// Ҫд�� cp0 ����Ϣ
	input wire ex_cp0_reg_we,
	input wire[7:0] ex_cp0_reg_write_addr,
	input wire[`RegBus] ex_cp0_reg_data,
	input wire ex_cp0_write_tlb_index,
	input wire ex_cp0_write_tlb_random,

	// Ҫд��������ַ
	input wire [`RegBus]ex_mem_phy_addr,
	input wire ex_data_tlb_r_miss_exception,
	input wire ex_data_tlb_w_miss_exception,
	input wire ex_data_tlb_mod_exception,


	// �ռ������쳣����Ϣ
	input wire[31:0] ex_excepttype,
	input wire ex_is_in_delayslot,
	input wire[`RegBus] ex_current_inst_address,
	input wire ex_not_stall,
	
	//�͵��ô�׶ε���Ϣ
	output reg[`RegAddrBus] mem_wd,
	output reg mem_wreg,
	output reg[`RegBus] mem_wdata,
	output reg[`RegBus] mem_hi,
	output reg[`RegBus] mem_lo,
	output reg mem_whilo,
	//Ϊʵ�ּ��ء��ô�ָ������
	output reg[`AluOpBus] mem_aluop,
	output reg[`RegBus] mem_mem_addr,
	output reg[`RegBus] mem_reg2,

	// Ҫд�� cp0 ����Ϣ
	output reg mem_cp0_reg_we,
	output reg[7:0] mem_cp0_reg_write_addr,
	output reg[`RegBus] mem_cp0_reg_data,
	output reg mem_cp0_write_tlb_index,
	output reg mem_cp0_write_tlb_random,

	// �͵���һ�׶ε��쳣����Ϣ
	output reg[31:0] mem_excepttype,
	output reg mem_is_in_delayslot,
	output reg[`RegBus] mem_current_inst_address,
	output reg mem_not_stall,


	// �͵���һ�׶ε������ַ
	output reg [`RegBus]mem_mem_phy_addr,
	output reg mem_data_tlb_r_miss_exception,
	output reg mem_data_tlb_w_miss_exception,
	output reg mem_data_tlb_mod_exception,

	// ������ͣ�� ex ��һ�׶���Ҫ����Ϣ
	output reg[`DoubleRegBus] hilo_o,
	output reg[1:0] cnt_o,
	output reg div_started_o
);


	always @ (posedge clk or negedge rst_n) 
	begin
		if(rst_n == `RstEnable)
		begin
			mem_wd <= `NOPRegAddr;
			mem_wreg <= `WriteDisable;
			mem_wdata <= `ZeroWord;	
			mem_hi <= `ZeroWord;
			mem_lo <= `ZeroWord;
			mem_whilo <= `WriteDisable;
			
			mem_aluop <= `EXE_NOP_OP;
			mem_mem_addr <= `ZeroWord;
			mem_reg2 <= `ZeroWord;

			mem_cp0_reg_we <= `WriteDisable;
			mem_cp0_reg_write_addr <= `NOPRegAddr;
			mem_cp0_reg_data <= `ZeroWord;
			mem_cp0_write_tlb_index <= `False_v;
			mem_cp0_write_tlb_random <= `False_v;

			mem_excepttype <= `ZeroWord;
			mem_is_in_delayslot <= `NotInDelaySlot;
			mem_current_inst_address <= `ZeroWord;
			mem_not_stall <= `False_v;

			mem_mem_phy_addr <= `ZeroWord;
			mem_data_tlb_r_miss_exception <= `False_v;
			mem_data_tlb_w_miss_exception <= `False_v;
			mem_data_tlb_mod_exception <= `False_v;

			hilo_o <= {`ZeroWord, `ZeroWord};
			cnt_o <= 2'b00;
			div_started_o <= 1'b0;

		end 
		else if(flush == `Flush)
		begin
			mem_wd <= `NOPRegAddr;
			mem_wreg <= `WriteDisable;
			mem_wdata <= `ZeroWord;	
			mem_hi <= `ZeroWord;
			mem_lo <= `ZeroWord;
			mem_whilo <= `WriteDisable;
			
			mem_aluop <= `EXE_NOP_OP;
			mem_mem_addr <= `ZeroWord;
			mem_reg2 <= `ZeroWord;

			mem_cp0_reg_we <= `WriteDisable;
			mem_cp0_reg_write_addr <= `NOPRegAddr;
			mem_cp0_reg_data <= `ZeroWord;
			mem_cp0_write_tlb_index <= `False_v;
			mem_cp0_write_tlb_random <= `False_v;

			mem_excepttype <= `ZeroWord;
			mem_is_in_delayslot <= `NotInDelaySlot;
			mem_current_inst_address <= `ZeroWord;
			mem_not_stall <= `False_v;

			mem_mem_phy_addr <= `ZeroWord;
			mem_data_tlb_r_miss_exception <= `False_v;
			mem_data_tlb_w_miss_exception <= `False_v;
			mem_data_tlb_mod_exception <= `False_v;

			hilo_o <= {`ZeroWord, `ZeroWord};
			cnt_o <= 2'b00;
			div_started_o <= 1'b0;
		end 
		else if(stall[3] == `Stop && stall[4] == `NoStop)
		begin
			mem_wd <= `NOPRegAddr;
			mem_wreg <= `WriteDisable;
			mem_wdata <= `ZeroWord;	
			mem_hi <= `ZeroWord;
			mem_lo <= `ZeroWord;
			mem_whilo <= `WriteDisable;

			mem_aluop <= `EXE_NOP_OP;
			mem_mem_addr <= `ZeroWord;
			mem_reg2 <= `ZeroWord;

			mem_cp0_reg_we <= `WriteDisable;
			mem_cp0_reg_write_addr <= `NOPRegAddr;
			mem_cp0_reg_data <= `ZeroWord;
			mem_cp0_write_tlb_index <= `False_v;
			mem_cp0_write_tlb_random <= `False_v;

			mem_excepttype <= `ZeroWord;
			mem_is_in_delayslot <= `NotInDelaySlot;
			mem_current_inst_address <= `ZeroWord;
			mem_not_stall <= `False_v;

			mem_mem_phy_addr <= `ZeroWord;
			mem_data_tlb_r_miss_exception <= `False_v;
			mem_data_tlb_w_miss_exception <= `False_v;
			mem_data_tlb_mod_exception <= `False_v;

			hilo_o <= hilo_i;
			cnt_o <= cnt_i;
			div_started_o <= div_started_i;
		end
		else if(stall[3] == `NoStop)
		begin
			mem_wd <= ex_wd;
			mem_wreg <= ex_wreg;
			mem_wdata <= ex_wdata;	
			mem_hi <= ex_hi;
			mem_lo <= ex_lo;
			mem_whilo <= ex_whilo;

			mem_aluop <= ex_aluop;
			mem_mem_addr <= ex_mem_addr;
			mem_reg2 <= ex_reg2;
			
			mem_cp0_reg_we <= ex_cp0_reg_we;
			mem_cp0_reg_write_addr <= ex_cp0_reg_write_addr;
			mem_cp0_reg_data <= ex_cp0_reg_data;
			mem_cp0_write_tlb_index <= ex_cp0_write_tlb_index;
			mem_cp0_write_tlb_random <= ex_cp0_write_tlb_random;

			mem_excepttype <= ex_excepttype;
			mem_is_in_delayslot <= ex_is_in_delayslot;
			mem_current_inst_address <= ex_current_inst_address;
			mem_not_stall <= ex_not_stall;

			mem_mem_phy_addr <= ex_mem_phy_addr;
			mem_data_tlb_r_miss_exception <= ex_data_tlb_r_miss_exception;
			mem_data_tlb_w_miss_exception <= ex_data_tlb_w_miss_exception;
			mem_data_tlb_mod_exception <= ex_data_tlb_mod_exception;

			hilo_o <= {`ZeroWord, `ZeroWord};
			cnt_o <= 2'b00;
			div_started_o <= 1'b0;
		end
		else // stall[3] ͣ��stall[4] Ҳͣ��mem_* ���ֲ��� 
		begin
			hilo_o <= hilo_i;
			cnt_o <= cnt_i;
			div_started_o <= div_started_i;
		end
	end
			

endmodule
