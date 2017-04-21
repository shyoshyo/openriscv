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
// Module:  pc_reg
// File:    pc_reg.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: ָ��ָ��Ĵ���PC
// Revision: 1.0



//////////////////////////////////////////////////////////////////////

`include "defines.v"

module pc_reg(

	input wire clk,
	input wire rst_n,

	//���Կ���ģ�����Ϣ
	input wire[5:0] stall,

	input wire flush,
	input wire[`RegBus] exception_new_pc,

	//��������׶ε���Ϣ
	input wire branch_flag_i,
	input wire[`RegBus] branch_target_address_i,

	// TLB �ṩ�������ַ
	input wire[`RegBus] next_inst_phy_addr_i,
	input wire next_inst_tlb_r_miss_exception_i,

	// pc �Ĵ��������������ַ
	output reg[`RegBus] pc,
	output reg[`RegBus] inst_phy_addr_o,
	
	// ָ��洢���Ƿ�ʹ��
	output reg ce,

	// �ӵ� MMU ��ǰ�������ַ
	output reg[`RegBus] next_inst_vir_addr_o,
	output wire pc_ce_o,

	// pc_reg ����ʵ��ַת����ʱ�������쳣
	output reg[`ExceptionTypeBus] excepttype_o
);
	// �� rst ��ʱ����ҲҪ��ǰ���һ��ָ��������ַ
	assign pc_ce_o = `ChipEnable;
	
	always @ (*)
		if (rst_n == `RstEnable)
			next_inst_vir_addr_o <= `StartInstAddr;
		else if (ce == `ChipDisable)
			next_inst_vir_addr_o <= `StartInstAddr;
		else if(flush == `Flush)
			next_inst_vir_addr_o <= exception_new_pc;
		else if(branch_flag_i == `Branch)
			next_inst_vir_addr_o <= branch_target_address_i;
		else
	 		next_inst_vir_addr_o <= pc + 4'h4;

	// exceptiontype
	//   0   machine check   TLB write that conflicts with an existing entry
	//   1-8 �ⲿ�Д�         Assertion of unmasked HW or SW interrupt signal.
	// * 9   adEl            Fetch address alignment error.
	// * 10  TLBL            Fetch TLB miss, Fetch TLB hit to page with V=0 (inst)
	//   11  syscall
	//   12  RI              �oЧָ�� Reserved Instruction
	//   13  ov              ���
	//   14  trap
	//   15  AdEL            Load address alignment error,  
	//   16  adES            Store address alignment error.
	//                       User mode store to kernel address.
	//   17  TLBL            Load TLB miss,  (4Kc core). (data)
	//   18  TLBS            Store TLB miss
	//   19  TLB Mod         Store to TLB page with D=0
	//   20  ERET
	//   21  FENCE.I

	wire [`ExceptionTypeBus]excepttype;
	assign excepttype = {21'b0, next_inst_tlb_r_miss_exception_i, next_inst_vir_addr_o[1:0] != 2'b00, 9'b0};

	always @ (posedge clk or negedge rst_n)
	begin
		if (rst_n == `RstEnable)
		begin
			pc <= `StartInstAddr;

			inst_phy_addr_o <= `ZeroWord;
			excepttype_o <= 32'b0;
			ce <= `ChipDisable;
		end
		else if(flush == `Flush)
		begin
			pc <= next_inst_vir_addr_o;

			inst_phy_addr_o <= next_inst_phy_addr_i;
			excepttype_o <= excepttype;
			ce <= `ChipEnable;
		end
		else if(branch_flag_i == `Branch)
		begin
			pc <= next_inst_vir_addr_o;

			inst_phy_addr_o <= next_inst_phy_addr_i;
			excepttype_o <= excepttype;
			ce <= `ChipEnable;
		end
		else if(stall[0] == `NoStop)
		begin
			pc <= next_inst_vir_addr_o;

			inst_phy_addr_o <= next_inst_phy_addr_i;
			excepttype_o <= excepttype;
			ce <= `ChipEnable;
		end

	end
	
endmodule
