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
// Module:  id
// File:    id.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: ����׶�
//   ������ mtc0/mfc0 �� sel �ֶ�
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module id(
	input wire rst_n,
	input wire[`RegBus] pc_i,
	input wire[`InstBus] inst_i,
	
	// �Ѿ���⵽���쳣
	input wire[31:0] excepttype_i,

	input wire not_stall_i,

	//����ִ�н׶ε�ָ���һЩ��Ϣ�����ڽ��load���
	input wire[`AluOpBus] ex_aluop_i,
	
	// ������·
	// ����ִ�н׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
	input wire ex_wreg_i,
	input wire[`RegBus] ex_wdata_i,
	input wire[`RegAddrBus] ex_wd_i,
	
	//���ڷô�׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
	input wire mem_wreg_i,
	input wire[`RegBus] mem_wdata_i,
	input wire[`RegAddrBus] mem_wd_i,
	
	input wire[`RegBus] reg1_data_i,
	input wire[`RegBus] reg2_data_i,

	// �����һ��ָ����ת��ָ���ô��һ��ָ���������ʱ�� is_in_delayslot Ϊ true
	input wire is_in_delayslot_i,

	// ������D �t��ͣһ����ˮ������Ҫ�����������ܡ�
	// step_i ��ʾ֮ǰ�����Ǹ�����
	input wire step_i,

	//�͵� regfile ����Ϣ�����ڷ��ʼĴ���
	output reg reg1_read_o,
	output reg reg2_read_o,
	output wire[`RegAddrBus] reg1_addr_o,
	output wire[`RegAddrBus] reg2_addr_o,
	
	
	// �͵�����һ�׶Σ�ִ�н׶ε���Ϣ
	
	// op �����ͣ�������
	output reg[`AluOpBus] aluop_o,
	output reg[`AluSelBus] alusel_o,
	
	// �������ļĴ���
	output reg[`RegBus] reg1_o,
	output reg[`RegBus] reg2_o,
	output wire[`RegBus] imm_o,
	
	// ��Ҫд�صļĴ������Լ��Ƿ���Ҫд��
	output wire[`RegAddrBus] wd_o,
	output reg wreg_o,

	// ��һ��ָ�����������
	output wire[`InstBus] inst_o,


	// ��һ��ָ���Ƿ����ӳٲ���
	output reg next_inst_in_delayslot_o,

	// �Ƿ���Ҫ��ת���Լ���ת��ַ�����ӵ�ַ
	output reg branch_flag_o,
	output reg[`RegBus] branch_target_address_o,       
	output wire[`RegBus] link_addr_o,

	// ����ָ���Ƿ����ӳٲ���
	output reg is_in_delayslot_o,

	output wire[31:0] excepttype_o,
	output wire[`RegBus] current_inst_address_o,
	output wire not_stall_o,

	// ������D �t��ͣһ����ˮ������Ҫ�����������ܡ�
	// step_o ��ʾ��ǰ�����Ǹ�����
	output reg step_o,

	// ��ͣ����
	output wire stallreq
);
	// �����a
	wire [6:0] opcode = inst_i[6:0];
	wire [2:0] funct3 = inst_i[14:12];

	// Դ�Ĵ���
	assign reg1_addr_o = inst_i[19:15];
	assign reg2_addr_o = inst_i[24:20];

	// Ŀ�˼Ĵ���
	assign wd_o = inst_i[11:7];
	
	// ������
	reg [`RegBus] imm;
	wire [`RegBus] imm_i_type  = {{52{inst_i[31]}}, inst_i[31:20]};
	wire [`RegBus] imm_s_type  = {{52{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
	wire [`RegBus] imm_u_type  = {{32{inst_i[31]}}, inst_i[31:12], 12'b0};
	wire [`RegBus] imm_sb_type =
		{{51{inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
	wire [`RegBus] imm_uj_type =
		{{43{inst_i[31]}}, inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
	
	reg instvalid;

	reg stallreq_for_reg1_loadrelate;
	reg stallreq_for_reg2_loadrelate;
	reg stallreq_for_jump_and_branch;
	wire pre_inst_is_load;
	reg excepttype_is_syscall;
	reg excepttype_is_eret;

	assign link_addr_o = pc_i + 4'd4;

	assign stallreq = 
		stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate | stallreq_for_jump_and_branch;

	assign pre_inst_is_load = 
		(
			(ex_aluop_i == `EXE_LB_OP) || (ex_aluop_i == `EXE_LBU_OP) || (ex_aluop_i == `EXE_LH_OP) ||
	  		(ex_aluop_i == `EXE_LHU_OP) || (ex_aluop_i == `EXE_LW_OP) || (ex_aluop_i == `EXE_LWR_OP)||
	  		(ex_aluop_i == `EXE_LWL_OP) || (ex_aluop_i == `EXE_LL_OP) || (ex_aluop_i == `EXE_SC_OP)
  		) ? 1'b1 : 1'b0;

	assign inst_o = inst_i;

	// exceptiontype
	//   0   machine check   TLB write that conflicts with an existing entry
	//   1-8 �ⲿ�Д�         Assertion of unmasked HW or SW interrupt signal.
	// . 9   adEl            Fetch address alignment error.
	// . 10  TLBL            Fetch TLB miss, Fetch TLB hit to page with V=0 (inst)
	// * 11  syscall
	// * 12  RI              �oЧָ�� Reserved Instruction
	//   13  ov              ���
	//   14  trap
	//   15  AdEL            Load address alignment error,  
	//   16  adES            Store address alignment error.
	//                       User mode store to kernel address.
	//   17  TLBL            Load TLB miss,  (4Kc core). (data)
	//   18  TLBS            Store TLB miss
	//   19  TLB Mod         Store to TLB page with D=0
	// * 20  ERET
	assign excepttype_o = {excepttype_i[31:21], excepttype_is_eret, excepttype_i[19:13], instvalid, excepttype_is_syscall, excepttype_i[10:0]};
	 
	assign current_inst_address_o = pc_i;
	assign not_stall_o = not_stall_i;

	/******************* ��ָ��������� ********************/

	always @ (*) begin
		if (rst_n == `RstEnable)
		begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			instvalid <= `InstValid;
			
			wreg_o <= `WriteDisable;
			
			reg1_read_o <= `ReadDisable;
			reg2_read_o <= `ReadDisable;
			
			imm <= `ZeroDoubleWord;

			branch_target_address_o <= `ZeroDoubleWord;
			branch_flag_o <= `NotBranch;
			next_inst_in_delayslot_o <= `NotInDelaySlot;
			stallreq_for_jump_and_branch <= `NoStop;
			step_o <= 1'b0;

			excepttype_is_syscall <= `False_v;
			excepttype_is_eret <= `False_v;
		end
		else
		begin
			// Ĭ�ϵ�ָ�����ͺ�������
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			instvalid <= `InstInvalid;
			
			// �Ƿ�д��Ĵ���
			wreg_o <= `WriteDisable;
			
			// �Ƿ��ȡ�Ĵ���
			reg1_read_o <= `ReadDisable;
			reg2_read_o <= `ReadDisable;
			
			imm <= `ZeroDoubleWord;

			// �Ƿ���ת����ת��ַ����һ��ָ���Ƿ����ӳٲ���
			branch_target_address_o <= `ZeroDoubleWord;
			branch_flag_o <= `NotBranch;
			next_inst_in_delayslot_o <= `NotInDelaySlot;
			stallreq_for_jump_and_branch <= `NoStop;
			step_o <= 1'b0;

			// �Ƿ񴥷� syscall, eret �쳣
			excepttype_is_syscall <= `False_v;
			excepttype_is_eret <= `False_v;

			case (opcode)
				`EXE_OP_IMM:
					case (funct3)
						`EXE_ADDI:
						begin
							aluop_o <= `EXE_ADD_OP;
							alusel_o <= `EXE_RES_ARITHMETIC;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteEnable;
							
							reg1_read_o <= `ReadEnable;
							
							imm <= imm_i_type;
						end

						`EXE_SLTI:
						begin
							aluop_o <= `EXE_SLT_OP;
							alusel_o <= `EXE_RES_ARITHMETIC;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteEnable;
							
							reg1_read_o <= `ReadEnable;
							
							imm <= imm_i_type;
						end

						`EXE_SLTIU:
						begin
							aluop_o <= `EXE_SLTU_OP;
							alusel_o <= `EXE_RES_ARITHMETIC;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteEnable;
							
							reg1_read_o <= `ReadEnable;
							
							imm <= imm_i_type;
						end


						`EXE_ANDI:
						begin
							aluop_o <= `EXE_AND_OP;
							alusel_o <= `EXE_RES_LOGIC;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteEnable;
							
							reg1_read_o <= `ReadEnable;
							
							imm <= imm_i_type;
						end

						`EXE_ORI:
						begin
							aluop_o <= `EXE_OR_OP;
							alusel_o <= `EXE_RES_LOGIC;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteEnable;
							
							reg1_read_o <= `ReadEnable;
							
							imm <= imm_i_type;
						end

						`EXE_XORI:
						begin
							aluop_o <= `EXE_XOR_OP;
							alusel_o <= `EXE_RES_LOGIC;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteEnable;
							
							reg1_read_o <= `ReadEnable;
							
							imm <= imm_i_type;
						end

						`EXE_SLLI:
						begin
							if(inst_i[31:25] == 7'b0000000)
							begin
								aluop_o <= `EXE_SLL_OP;
								alusel_o <= `EXE_RES_SHIFT;
								instvalid <= `InstValid;
								
								wreg_o <= `WriteEnable;
								
								reg1_read_o <= `ReadEnable;
								
								imm <= imm_i_type;
							end
							else
							begin
							end
						end

						`EXE_SRLI_SRAI:
						begin
							if(inst_i[31:25] == 7'b0000000)
							begin
								aluop_o <= `EXE_SRL_OP;
								alusel_o <= `EXE_RES_SHIFT;
								instvalid <= `InstValid;
								
								wreg_o <= `WriteEnable;
								
								reg1_read_o <= `ReadEnable;
								
								imm <= imm_i_type;
							end
							else if(inst_i[31:25] == 7'b0100000)
							begin
								aluop_o <= `EXE_SRA_OP;
								alusel_o <= `EXE_RES_SHIFT;
								instvalid <= `InstValid;
								
								wreg_o <= `WriteEnable;
								
								reg1_read_o <= `ReadEnable;
								
								imm <= imm_i_type;
							end
							else
							begin
							end
						end

						default:
						begin
						end
					endcase

				`EXE_LUI:
				begin
					aluop_o <= `EXE_OR_OP;
					alusel_o <= `EXE_RES_LOGIC;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteEnable;
					
					imm <= imm_u_type;
				end
				
				`EXE_AUIPC:
				begin
					aluop_o <= `EXE_OR_OP;
					alusel_o <= `EXE_RES_LOGIC;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteEnable;

					imm <= imm_u_type + pc_i;
				end
				
				`EXE_OP:
					case (funct3)
						`EXE_ADD_SUB:
						begin
							if(inst_i[31:25] == 7'b0000000)
							begin
								aluop_o <= `EXE_ADD_OP;
								alusel_o <= `EXE_RES_ARITHMETIC;
								instvalid <= `InstValid;
								
								wreg_o <= `WriteEnable;
								
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
							end
							else if(inst_i[31:25] == 7'b0100000)
							begin
								aluop_o <= `EXE_SUB_OP;
								alusel_o <= `EXE_RES_ARITHMETIC;
								instvalid <= `InstValid;
								
								wreg_o <= `WriteEnable;
								
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
							end
							else
							begin
							end
						end

						`EXE_SLT:
						begin
							if(inst_i[31:25] == 7'b0000000)
							begin
								aluop_o <= `EXE_SLT_OP;
								alusel_o <= `EXE_RES_ARITHMETIC;
								instvalid <= `InstValid;
								
								wreg_o <= `WriteEnable;
								
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
							end
							else
							begin
							end
						end

						`EXE_SLTU:
						begin
							if(inst_i[31:25] == 7'b0000000)
							begin
								aluop_o <= `EXE_SLTU_OP;
								alusel_o <= `EXE_RES_ARITHMETIC;
								instvalid <= `InstValid;
								
								wreg_o <= `WriteEnable;
								
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
							end
							else
							begin
							end
						end

						`EXE_AND:
						begin
							if(inst_i[31:25] == 7'b0000000)
							begin
								aluop_o <= `EXE_AND_OP;
								alusel_o <= `EXE_RES_LOGIC;
								instvalid <= `InstValid;
								
								wreg_o <= `WriteEnable;
								
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
							end
							else
							begin
							end
						end

						`EXE_OR:
						begin
							if(inst_i[31:25] == 7'b0000000)
							begin
								aluop_o <= `EXE_OR_OP;
								alusel_o <= `EXE_RES_LOGIC;
								instvalid <= `InstValid;
								
								wreg_o <= `WriteEnable;
								
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
							end
							else
							begin
							end
						end

						`EXE_XOR:
						begin
							if(inst_i[31:25] == 7'b0000000)
							begin
								aluop_o <= `EXE_XOR_OP;
								alusel_o <= `EXE_RES_LOGIC;
								instvalid <= `InstValid;
								
								wreg_o <= `WriteEnable;
								
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
							end
							else
							begin
							end
						end

						`EXE_SLL:
						begin
							if(inst_i[31:25] == 7'b0000000)
							begin
								aluop_o <= `EXE_SLL_OP;
								alusel_o <= `EXE_RES_SHIFT;
								instvalid <= `InstValid;
								
								wreg_o <= `WriteEnable;
								
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
							end
							else
							begin
							end
						end

						`EXE_SRL_SRA:
						begin
							if(inst_i[31:25] == 7'b0000000)
							begin
								aluop_o <= `EXE_SRL_OP;
								alusel_o <= `EXE_RES_SHIFT;
								instvalid <= `InstValid;
								
								wreg_o <= `WriteEnable;
								
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
							end
							else if(inst_i[31:25] == 7'b0100000)
							begin
								aluop_o <= `EXE_SRA_OP;
								alusel_o <= `EXE_RES_SHIFT;
								instvalid <= `InstValid;
								
								wreg_o <= `WriteEnable;
								
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;
							end
							else
							begin
							end
						end



						default:
						begin
						end
					endcase

				`EXE_JAL:
				begin
					aluop_o <= `EXE_JAL_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH;
					instvalid <= `InstValid;

					wreg_o <= `WriteEnable;

					if(step_i == 1'b0)
					begin
						branch_target_address_o <= pc_i + imm_uj_type;
						branch_flag_o <= `Branch;
						stallreq_for_jump_and_branch <= `Stop;

						step_o <= 1'b1;
					end
					else
					begin
						step_o <= 1'b1;
					end
				end

				`EXE_JALR:
					if(funct3 == 3'b000)
					begin
						aluop_o <= `EXE_JAL_OP;
						alusel_o <= `EXE_RES_JUMP_BRANCH;
						instvalid <= `InstValid;

						wreg_o <= `WriteEnable;

						if(step_i == 1'b0)
						begin
							branch_target_address_o <= reg1_o + imm_i_type;
							branch_target_address_o[0] <= 1'b0;

							branch_flag_o <= `Branch;
							stallreq_for_jump_and_branch <= `Stop;

							step_o <= 1'b1;
						end
						else
						begin
							step_o <= 1'b1;
						end
					end

				`EXE_BRANCH:
					case(funct3)
						`EXE_BEQ:
						begin
							instvalid <= `InstValid;

							if(step_i == 1'b0)
							begin
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;

								if(reg1_o == reg2_o)
								begin
									branch_target_address_o <= pc_i + imm_sb_type;
									branch_flag_o <= `Branch;
									stallreq_for_jump_and_branch <= `Stop;

									step_o <= 1'b1;
								end
							end
							else
							begin
								step_o <= 1'b1;
							end
						end

						`EXE_BNE:
						begin
							instvalid <= `InstValid;

							if(step_i == 1'b0)
							begin
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;

								if(reg1_o != reg2_o)
								begin
									branch_target_address_o <= pc_i + imm_sb_type;
									branch_flag_o <= `Branch;
									stallreq_for_jump_and_branch <= `Stop;

									step_o <= 1'b1;
								end
							end
							else
							begin
								step_o <= 1'b1;
							end
						end

						`EXE_BLT:
						begin
							instvalid <= `InstValid;

							if(step_i == 1'b0)
							begin
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;

								if($signed(reg1_o) < $signed(reg2_o))
								begin
									branch_target_address_o <= pc_i + imm_sb_type;
									branch_flag_o <= `Branch;
									stallreq_for_jump_and_branch <= `Stop;

									step_o <= 1'b1;
								end
							end
							else
							begin
								step_o <= 1'b1;
							end
						end

						`EXE_BLTU:
						begin
							instvalid <= `InstValid;

							if(step_i == 1'b0)
							begin
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;

								if(reg1_o < reg2_o)
								begin
									branch_target_address_o <= pc_i + imm_sb_type;
									branch_flag_o <= `Branch;
									stallreq_for_jump_and_branch <= `Stop;

									step_o <= 1'b1;
								end
							end
							else
							begin
								step_o <= 1'b1;
							end
						end

						`EXE_BGE:
						begin
							instvalid <= `InstValid;

							if(step_i == 1'b0)
							begin
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;

								if($signed(reg1_o) >= $signed(reg2_o))
								begin
									branch_target_address_o <= pc_i + imm_sb_type;
									branch_flag_o <= `Branch;
									stallreq_for_jump_and_branch <= `Stop;

									step_o <= 1'b1;
								end
							end
							else
							begin
								step_o <= 1'b1;
							end
						end

						`EXE_BGEU:
						begin
							instvalid <= `InstValid;

							if(step_i == 1'b0)
							begin
								reg1_read_o <= `ReadEnable;
								reg2_read_o <= `ReadEnable;

								if(reg1_o >= reg2_o)
								begin
									branch_target_address_o <= pc_i + imm_sb_type;
									branch_flag_o <= `Branch;
									stallreq_for_jump_and_branch <= `Stop;

									step_o <= 1'b1;
								end
							end
							else
							begin
								step_o <= 1'b1;
							end
						end

						default:
						begin
						end
					endcase

				`EXE_LOAD:
					case(funct3)
						`EXE_LB:
						begin
							aluop_o <= `EXE_LB_OP;
							alusel_o <= `EXE_RES_LOAD_STORE;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteEnable;
							
							reg1_read_o <= `ReadEnable;
							
							imm <= imm_i_type + reg1_o;
						end

						`EXE_LH:
						begin
							aluop_o <= `EXE_LH_OP;
							alusel_o <= `EXE_RES_LOAD_STORE;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteEnable;
							
							reg1_read_o <= `ReadEnable;
							
							imm <= imm_i_type + reg1_o;
						end

						`EXE_LW:
						begin
							aluop_o <= `EXE_LW_OP;
							alusel_o <= `EXE_RES_LOAD_STORE;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteEnable;
							
							reg1_read_o <= `ReadEnable;
							
							imm <= imm_i_type + reg1_o;
						end
						
						`EXE_LBU:
						begin
							aluop_o <= `EXE_LBU_OP;
							alusel_o <= `EXE_RES_LOAD_STORE;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteEnable;
							
							reg1_read_o <= `ReadEnable;
							
							imm <= imm_i_type + reg1_o;
						end

						`EXE_LHU:
						begin
							aluop_o <= `EXE_LBU_OP;
							alusel_o <= `EXE_RES_LOAD_STORE;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteEnable;
							
							reg1_read_o <= `ReadEnable;
							
							imm <= imm_i_type + reg1_o;
						end

						default:
						begin
						end
					endcase

				`EXE_STORE:
					case(funct3)
						`EXE_SB:
						begin
							aluop_o <= `EXE_SB_OP;
							alusel_o <= `EXE_RES_LOAD_STORE;
							instvalid <= `InstValid;
							
							reg1_read_o <= `ReadEnable;
							reg2_read_o <= `ReadEnable;
							
							imm <= imm_s_type + reg1_o;
						end

						`EXE_SH:
						begin
							aluop_o <= `EXE_SH_OP;
							alusel_o <= `EXE_RES_LOAD_STORE;
							instvalid <= `InstValid;
							
							reg1_read_o <= `ReadEnable;
							reg2_read_o <= `ReadEnable;
							
							imm <= imm_s_type + reg1_o;
						end

						`EXE_SW:
						begin
							aluop_o <= `EXE_SW_OP;
							alusel_o <= `EXE_RES_LOAD_STORE;
							instvalid <= `InstValid;
							
							reg1_read_o <= `ReadEnable;
							reg2_read_o <= `ReadEnable;
							
							imm <= imm_s_type + reg1_o;
						end

						default:
						begin
						end
					endcase

				default:
				begin

				end
			endcase
		end
	end
	
	
	/**************** ȷ��Դ������ 1 *****************/
	
	always @ (*)
	begin
		stallreq_for_reg1_loadrelate <= `NoStop;	

		if(rst_n == `RstEnable)
			reg1_o <= `ZeroDoubleWord;
		else if((reg1_read_o == 1'b1) && (reg1_addr_o == `ZeroRegAddr))
			reg1_o <= `ZeroDoubleWord;
		else if((reg1_read_o == 1'b1) && (pre_inst_is_load == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o))
		begin
			stallreq_for_reg1_loadrelate <= `Stop;
			reg1_o <= `ZeroDoubleWord;
		end
		else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o))
			reg1_o <= ex_wdata_i; 
		else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o))
			reg1_o <= mem_wdata_i;
		else if(reg1_read_o == 1'b1)
			reg1_o <= reg1_data_i;
		else if(reg1_read_o == 1'b0)
			reg1_o <= imm;
		else
			reg1_o <= `ZeroDoubleWord;
	end
	
	/**************** ȷ��Դ������ 2 *****************/
	
	always @ (*)
	begin
		stallreq_for_reg2_loadrelate <= `NoStop;	

		if(rst_n == `RstEnable)
			reg2_o <= `ZeroDoubleWord;
		else if((reg2_read_o == 1'b1) && (reg2_addr_o == `ZeroRegAddr))
			reg2_o <= `ZeroDoubleWord;
		else if((reg2_read_o == 1'b1) && (pre_inst_is_load == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o))
		begin
			stallreq_for_reg2_loadrelate <= `Stop;
			reg2_o <= `ZeroDoubleWord;
		end
		else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o))
			reg2_o <= ex_wdata_i; 
		else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o))
			reg2_o <= mem_wdata_i;
		else if(reg2_read_o == 1'b1)
			reg2_o <= reg2_data_i;
		else if(reg2_read_o == 1'b0)
			reg2_o <= imm;
		else
			reg2_o <= `ZeroDoubleWord;
	end

	/***************** ȷ��Դ imm ******************/

	assign imm_o = imm;
	
	/*********** ȷ����һ��ָ���Ƿ����ӳٲ��� **********/

	always @ (*)
	begin
		if(rst_n == `RstEnable)
		begin
			is_in_delayslot_o <= `NotInDelaySlot;
		end
		else
		begin
			is_in_delayslot_o <= is_in_delayslot_i;		
		end
	end
endmodule
