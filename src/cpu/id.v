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
	input wire[`RegBus] inst_i,
	
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

	//�͵� regfile ����Ϣ�����ڷ��ʼĴ���
	output reg reg1_read_o,
	output reg reg2_read_o,
	output reg[`RegAddrBus] reg1_addr_o,
	output reg[`RegAddrBus] reg2_addr_o,
	
	
	// �͵�����һ�׶Σ�ִ�н׶ε���Ϣ
	
	// op �����ͣ�������
	output reg[`AluOpBus] aluop_o,
	output reg[`AluSelBus] alusel_o,
	
	// �������ļĴ���
	output reg[`RegBus] reg1_o,
	output reg[`RegBus] reg2_o,
	
	// ��Ҫд�صļĴ������Լ��Ƿ���Ҫд��
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,

	// ��һ��ָ�����������
	output wire[`RegBus] inst_o,


	// ��һ��ָ���Ƿ����ӳٲ���
	output reg next_inst_in_delayslot_o,

	// �Ƿ���Ҫ��ת���Լ���ת��ַ�����ӵ�ַ
	output reg branch_flag_o,
	output reg[`RegBus] branch_target_address_o,       
	output reg[`RegBus] link_addr_o,

	// ����ָ���Ƿ����ӳٲ���
	output reg is_in_delayslot_o,

	output wire[31:0] excepttype_o,
	output wire[`RegBus] current_inst_address_o,
	output wire not_stall_o,

	// ��ͣ����
	output wire stallreq
);

	wire [5:0] op = inst_i[31:26];
	wire [4:0] op2 = inst_i[10:6];
	wire [5:0] op3 = inst_i[5:0];
	wire [4:0] op4 = inst_i[20:16];
	
	reg [`RegBus] imm;
	
	reg instvalid;

	reg stallreq_for_reg1_loadrelate;
	reg stallreq_for_reg2_loadrelate;
	wire pre_inst_is_load;
	reg excepttype_is_syscall;
	reg excepttype_is_eret;


	wire[`RegBus] pc_plus_8;
	wire[`RegBus] pc_plus_4;
	wire[`RegBus] imm_sll2_signedext;

	assign pc_plus_8 = pc_i + 4'd8;
	assign pc_plus_4 = pc_i + 4'd4;

	// Branch ָ�� offset ������λ��������չ�� 32 λ�Ľ����
	assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};

	assign stallreq = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;
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
			
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			
			
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= `NOPRegAddr;
			reg2_addr_o <= `NOPRegAddr;
			
			imm <= 32'h0;

			link_addr_o <= `ZeroWord;
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;
			next_inst_in_delayslot_o <= `NotInDelaySlot;

			excepttype_is_syscall <= `False_v;
			excepttype_is_eret <= `False_v;
		end
		else
		begin
			// Ĭ�ϵ�ָ�����ͺ�������
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			instvalid <= `InstInvalid;	
			
			// �Ƿ�д��Ĵ�����д���ĸ��Ĵ���
			wd_o <= inst_i[15:11];
			wreg_o <= `WriteDisable;
			
			// �Ƿ��ȡ�Ĵ��������ĸ��Ĵ�����
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= inst_i[25:21];
			reg2_addr_o <= inst_i[20:16];		
			

			// �Ƿ���ת����ת��ַ����һ��ָ���Ƿ����ӳٲ���
			link_addr_o <= `ZeroWord;
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;
			next_inst_in_delayslot_o <= `NotInDelaySlot;

			// �Ƿ񴥷� syscall, eret �쳣
			excepttype_is_syscall <= `False_v;
			excepttype_is_eret <= `False_v;

			imm <= `ZeroWord;			
			case (op)
				`EXE_SPECIAL_INST:
				begin
					case(op2)
						5'b00000:
							case(op3)
								`EXE_OR:
								begin
									aluop_o <= `EXE_OR_OP;
									alusel_o <= `EXE_RES_LOGIC;
									instvalid <= `InstValid;
								
									wreg_o <= `WriteEnable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end
								
								`EXE_AND:
								begin
									aluop_o <= `EXE_AND_OP;
									alusel_o <= `EXE_RES_LOGIC;
									instvalid <= `InstValid;
								
									wreg_o <= `WriteEnable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end
								
								
								`EXE_XOR:
								begin
									aluop_o <= `EXE_XOR_OP;
									alusel_o <= `EXE_RES_LOGIC;
									instvalid <= `InstValid;
								
									wreg_o <= `WriteEnable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end
								
								
								`EXE_NOR:
								begin
									aluop_o <= `EXE_NOR_OP;
									alusel_o <= `EXE_RES_LOGIC;
									instvalid <= `InstValid;
								
									wreg_o <= `WriteEnable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end
								
								
								`EXE_SLLV:
								begin
									aluop_o <= `EXE_SLL_OP;
									alusel_o <= `EXE_RES_SHIFT;
									instvalid <= `InstValid;
								
									wreg_o <= `WriteEnable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end
								
								`EXE_SRLV:
								begin
									aluop_o <= `EXE_SRL_OP;
									alusel_o <= `EXE_RES_SHIFT;
									instvalid <= `InstValid;
								
									wreg_o <= `WriteEnable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end
								
								`EXE_SRAV:
								begin
									aluop_o <= `EXE_SRA_OP;
									alusel_o <= `EXE_RES_SHIFT;
									instvalid <= `InstValid;
								
									wreg_o <= `WriteEnable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end
								
								`EXE_SYNC:
								begin
									aluop_o <= `EXE_NOP_OP;
									alusel_o <= `EXE_RES_NOP;
									instvalid <= `InstValid;
								
									wreg_o <= `WriteDisable;
									
									reg1_read_o <= 1'b0;
									reg2_read_o <= 1'b0;
								end
								
								`EXE_MFHI:
								begin
									aluop_o <= `EXE_MFHI_OP;
									alusel_o <= `EXE_RES_MOVE;
									instvalid <= `InstValid;
								
									wreg_o <= `WriteEnable;
									
									reg1_read_o <= 1'b0;
									reg2_read_o <= 1'b0;
								end
								
								
								`EXE_MFLO:
								begin
									aluop_o <= `EXE_MFLO_OP;
									alusel_o <= `EXE_RES_MOVE;
									instvalid <= `InstValid;
								
									wreg_o <= `WriteEnable;
									
									reg1_read_o <= 1'b0;
									reg2_read_o <= 1'b0;
								end
								
								`EXE_MTHI:
								begin
									aluop_o <= `EXE_MTHI_OP;
									instvalid <= `InstValid;
								
									wreg_o <= `WriteDisable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b0;
								end
								
								`EXE_MTLO:
								begin
									aluop_o <= `EXE_MTLO_OP;
									instvalid <= `InstValid;
								
									wreg_o <= `WriteDisable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b0;
								end
								
								`EXE_MOVN:
								begin
									aluop_o <= `EXE_MOVN_OP;
									alusel_o <= `EXE_RES_MOVE;
									instvalid <= `InstValid;
									
									// ����ط� wreg_o �ǴӺ��������ȡ�Ĵ���������߼�������
									wreg_o <= (reg2_o == `ZeroWord) ? `WriteDisable : `WriteEnable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end
								
								`EXE_MOVZ:
								begin
									aluop_o <= `EXE_MOVZ_OP;
									alusel_o <= `EXE_RES_MOVE;
									instvalid <= `InstValid;
									
									// ����ط� wreg_o �ǴӺ��������ȡ�Ĵ���������߼�������
									wreg_o <= (reg2_o == `ZeroWord) ? `WriteEnable : `WriteDisable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end
								
								`EXE_SLT:
								begin
									aluop_o <= `EXE_SLT_OP;
									alusel_o <= `EXE_RES_ARITHMETIC;
									instvalid <= `InstValid;
									
									wreg_o <= `WriteEnable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end

								`EXE_SLTU:
								begin
									aluop_o <= `EXE_SLTU_OP;
									alusel_o <= `EXE_RES_ARITHMETIC;
									instvalid <= `InstValid;
									
									wreg_o <= `WriteEnable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end

								`EXE_ADD:
								begin
									aluop_o <= `EXE_ADD_OP;
									alusel_o <= `EXE_RES_ARITHMETIC;
									instvalid <= `InstValid;
									
									wreg_o <= `WriteEnable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end

								`EXE_ADDU:
								begin
									aluop_o <= `EXE_ADDU_OP;
									alusel_o <= `EXE_RES_ARITHMETIC;
									instvalid <= `InstValid;
									
									wreg_o <= `WriteEnable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end

								`EXE_SUB:
								begin
									aluop_o <= `EXE_SUB_OP;
									alusel_o <= `EXE_RES_ARITHMETIC;
									instvalid <= `InstValid;
									
									wreg_o <= `WriteEnable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end

								`EXE_SUBU:
								begin
									aluop_o <= `EXE_SUBU_OP;
									alusel_o <= `EXE_RES_ARITHMETIC;
									instvalid <= `InstValid;
									
									wreg_o <= `WriteEnable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end

								`EXE_MULT:
								begin
									aluop_o <= `EXE_MULT_OP;
									alusel_o <= `EXE_RES_NOP;
									instvalid <= `InstValid;
									
									wreg_o <= `WriteDisable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end

								`EXE_MULTU:
								begin
									aluop_o <= `EXE_MULTU_OP;
									alusel_o <= `EXE_RES_NOP;
									instvalid <= `InstValid;
									
									wreg_o <= `WriteDisable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end
								
								`EXE_DIV:
								begin
									aluop_o <= `EXE_DIV_OP;
									alusel_o <= `EXE_RES_NOP;
									instvalid <= `InstValid;
									
									wreg_o <= `WriteDisable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end


								`EXE_DIVU:
								begin
									aluop_o <= `EXE_DIVU_OP;
									alusel_o <= `EXE_RES_NOP;
									instvalid <= `InstValid;
									
									wreg_o <= `WriteDisable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
								end


								`EXE_JR:
								begin
									aluop_o <= `EXE_JR_OP;
									alusel_o <= `EXE_RES_JUMP_BRANCH;
									instvalid <= `InstValid;
									
									wreg_o <= `WriteDisable;
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b0;

									link_addr_o <= `ZeroWord;
									branch_target_address_o <= reg1_o;
									branch_flag_o <= `Branch;
									next_inst_in_delayslot_o <= `InDelaySlot;
								end
								
								`EXE_JALR:
								begin
									aluop_o <= `EXE_JALR_OP;
									alusel_o <= `EXE_RES_JUMP_BRANCH;
									instvalid <= `InstValid;
									
									wreg_o <= `WriteEnable;
									wd_o <= inst_i[15:11];
									
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b0;
									
									link_addr_o <= pc_plus_8;
									branch_target_address_o <= reg1_o;
									branch_flag_o <= `Branch;
									next_inst_in_delayslot_o <= `InDelaySlot;
								end
								default:
								begin
								end
							endcase
							
							default:
							begin
							end
					endcase

					case (op3)
							`EXE_TEQ:
							begin
								aluop_o <= `EXE_TEQ_OP;
								alusel_o <= `EXE_RES_NOP;
		  						instvalid <= `InstValid;
								
								wreg_o <= `WriteDisable;
								
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;
		  					end
		  					`EXE_TGE:
		  					begin
								aluop_o <= `EXE_TGE_OP;
								alusel_o <= `EXE_RES_NOP;
		  						instvalid <= `InstValid;
								
								wreg_o <= `WriteDisable;
								
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;
		  					end		
		  					`EXE_TGEU:
		  					begin
								aluop_o <= `EXE_TGEU_OP;
								alusel_o <= `EXE_RES_NOP;
		  						instvalid <= `InstValid;
								
								wreg_o <= `WriteDisable;
								
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;
		  					end	
		  					`EXE_TLT:
		  					begin
								aluop_o <= `EXE_TLT_OP;
								alusel_o <= `EXE_RES_NOP;
		  						instvalid <= `InstValid;
								
								wreg_o <= `WriteDisable;
								
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;
		  					end
		  					`EXE_TLTU:
		  					begin
								aluop_o <= `EXE_TLTU_OP;
								alusel_o <= `EXE_RES_NOP;
		  						instvalid <= `InstValid;
								
								wreg_o <= `WriteDisable;
								
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;
		  					end	
		  					`EXE_TNE:
		  					begin
								aluop_o <= `EXE_TNE_OP;
								alusel_o <= `EXE_RES_NOP;
		  						instvalid <= `InstValid;
								
								wreg_o <= `WriteDisable;
								
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;
		  					end
		  					`EXE_SYSCALL: begin
		  						aluop_o <= `EXE_SYSCALL_OP;
								alusel_o <= `EXE_RES_NOP;
		  						instvalid <= `InstValid;
								
								wreg_o <= `WriteDisable;
								
								reg1_read_o <= 1'b0;
								reg2_read_o <= 1'b0;

								excepttype_is_syscall<= `True_v;
		  					end				 																					
							default:	begin
							end	
					endcase
				end
					
				`EXE_ORI:	//ORIָ��
				begin
					aluop_o <= `EXE_OR_OP;
					alusel_o <= `EXE_RES_LOGIC;
					instvalid <= `InstValid;
					
					wd_o <= inst_i[20:16];
					wreg_o <= `WriteEnable;
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;	  	
					
					imm <= {16'h0, inst_i[15:0]};			
				end
				
				`EXE_ANDI:
				begin
					aluop_o <= `EXE_AND_OP;
					alusel_o <= `EXE_RES_LOGIC;
					instvalid <= `InstValid;
					
					wd_o <= inst_i[20:16];
					wreg_o <= `WriteEnable;
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;	  	
					
					imm <= {16'h0, inst_i[15:0]};			
				end
				
				
				`EXE_XORI:
				begin
					aluop_o <= `EXE_XOR_OP;
					alusel_o <= `EXE_RES_LOGIC;
					instvalid <= `InstValid;
					
					wd_o <= inst_i[20:16];
					wreg_o <= `WriteEnable;
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;	  	
					
					imm <= {16'h0, inst_i[15:0]};			
				end
				
				
				`EXE_LUI:
				begin
					aluop_o <= `EXE_OR_OP;
					alusel_o <= `EXE_RES_LOGIC;
					instvalid <= `InstValid;
					
					wd_o <= inst_i[20:16];
					wreg_o <= `WriteEnable;
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;	  	
					
					imm <= {inst_i[15:0], 16'h0};			
				end
				
				`EXE_PREF:
				begin
					aluop_o <= `EXE_NOP_OP;
					alusel_o <= `EXE_RES_NOP;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteDisable;
					
					reg1_read_o <= 1'b0;
					reg2_read_o <= 1'b0;
				end
				
				`EXE_SLTI:
				begin
					aluop_o <= `EXE_SLT_OP;
					alusel_o <= `EXE_RES_ARITHMETIC;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteEnable;
					wd_o <= inst_i[20:16];
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};
				end


				`EXE_SLTIU:
				begin
					aluop_o <= `EXE_SLTU_OP;
					alusel_o <= `EXE_RES_ARITHMETIC;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteEnable;
					wd_o <= inst_i[20:16];
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};
				end


				`EXE_ADDI:
				begin
					aluop_o <= `EXE_ADDI_OP;
					alusel_o <= `EXE_RES_ARITHMETIC;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteEnable;
					wd_o <= inst_i[20:16];
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};
				end


				`EXE_ADDIU:
				begin
					aluop_o <= `EXE_ADDIU_OP;
					alusel_o <= `EXE_RES_ARITHMETIC;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteEnable;
					wd_o <= inst_i[20:16];
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};
				end

				`EXE_J:
				begin
					aluop_o <= `EXE_J_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteDisable;
					
					reg1_read_o <= 1'b0;
					reg2_read_o <= 1'b0;
					
					link_addr_o <= `ZeroWord;
					branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
					branch_flag_o <= `Branch;
					next_inst_in_delayslot_o <= `InDelaySlot;
				end

				`EXE_JAL:
				begin
					aluop_o <= `EXE_JAL_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteEnable;
					wd_o <= 5'b11111;
					
					reg1_read_o <= 1'b0;
					reg2_read_o <= 1'b0;
					
					link_addr_o <= pc_plus_8;
					branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
					branch_flag_o <= `Branch;
					next_inst_in_delayslot_o <= `InDelaySlot;
				end

				`EXE_BEQ:
				begin
					aluop_o <= `EXE_BEQ_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteDisable;
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
					
					link_addr_o <= `ZeroWord;
					if(reg1_o == reg2_o)
					begin
						branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
						branch_flag_o <= `Branch;
						next_inst_in_delayslot_o <= `InDelaySlot;
					end
				end


				`EXE_BGTZ:
				begin
					aluop_o <= `EXE_BGTZ_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteDisable;
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					
					link_addr_o <= `ZeroWord;
					if((reg1_o[31] == 1'b0) && (reg1_o != `ZeroWord))
					begin
						branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
						branch_flag_o <= `Branch;
						next_inst_in_delayslot_o <= `InDelaySlot;
					end
				end

				`EXE_BLEZ:
				begin
					aluop_o <= `EXE_BLEZ_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteDisable;
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					
					link_addr_o <= `ZeroWord;
					if((reg1_o[31] == 1'b1) || (reg1_o == `ZeroWord))
					begin
						branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
						branch_flag_o <= `Branch;
						next_inst_in_delayslot_o <= `InDelaySlot;
					end
				end

				`EXE_BNE:
				begin
					aluop_o <= `EXE_BNE_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteDisable;
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
					
					link_addr_o <= `ZeroWord;
					if(reg1_o != reg2_o)
					begin
						branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
						branch_flag_o <= `Branch;
						next_inst_in_delayslot_o <= `InDelaySlot;
					end
				end

				`EXE_LB:
				begin
					aluop_o <= `EXE_LB_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteEnable;
					wd_o <= inst_i[20:16];
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
				end

				`EXE_LBU:
				begin
					aluop_o <= `EXE_LBU_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteEnable;
					wd_o <= inst_i[20:16];
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
				end

				`EXE_LH:
				begin
					aluop_o <= `EXE_LH_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteEnable;
					wd_o <= inst_i[20:16];
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
				end

				`EXE_LHU:
				begin
					aluop_o <= `EXE_LHU_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteEnable;
					wd_o <= inst_i[20:16];
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
				end

				`EXE_LW:
				begin
					aluop_o <= `EXE_LW_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteEnable;
					wd_o <= inst_i[20:16];
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
				end

				`EXE_LWL:
				begin
					aluop_o <= `EXE_LWL_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteEnable;
					wd_o <= inst_i[20:16];
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
				end

				`EXE_LWR:
				begin
					aluop_o <= `EXE_LWR_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteEnable;
					wd_o <= inst_i[20:16];
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
				end


				`EXE_SB:
				begin
					aluop_o <= `EXE_SB_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteDisable;
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
				end

				`EXE_SH:
				begin
					aluop_o <= `EXE_SH_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteDisable;
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
				end

				`EXE_SW:
				begin
					aluop_o <= `EXE_SW_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteDisable;
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
				end

				`EXE_SWL:
				begin
					aluop_o <= `EXE_SWL_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteDisable;
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
				end

				`EXE_SWR:
				begin
					aluop_o <= `EXE_SWR_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteDisable;
					
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
				end

				`EXE_LL:
				begin
					aluop_o <= `EXE_LL_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteEnable;
					wd_o <= inst_i[20:16];

					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
				end

				`EXE_SC:
				begin
					aluop_o <= `EXE_SC_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteEnable;
					wd_o <= inst_i[20:16];

					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
				end

				`EXE_CACHE:
				begin
					aluop_o <= `EXE_NOP_OP;
					alusel_o <= `EXE_RES_NOP;
					instvalid <= `InstValid;
					
					wreg_o <= `WriteDisable;

					reg1_read_o <= 1'b0;
					reg2_read_o <= 1'b0;
				end

				
				`EXE_REGIMM_INST:
					case(op4)
						`EXE_BGEZ:
						begin
							aluop_o <= `EXE_BGEZ_OP;
							alusel_o <= `EXE_RES_JUMP_BRANCH;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteDisable;
							
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;
							
							link_addr_o <= `ZeroWord;
							if(reg1_o[31] == 1'b0)
							begin
								branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
								branch_flag_o <= `Branch;
								next_inst_in_delayslot_o <= `InDelaySlot;
							end
						end

						`EXE_BGEZAL:
						begin
							aluop_o <= `EXE_BGEZAL_OP;
							alusel_o <= `EXE_RES_JUMP_BRANCH;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteEnable;
							wd_o <= 5'b11111;
							
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;
							link_addr_o <= pc_plus_8;
							
							if(reg1_o[31] == 1'b0)
							begin
								branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
								branch_flag_o <= `Branch;
								next_inst_in_delayslot_o <= `InDelaySlot;
							end
						end

						`EXE_BLTZ:
						begin
							aluop_o <= `EXE_BLTZ_OP;
							alusel_o <= `EXE_RES_JUMP_BRANCH;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteDisable;
							
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;
							
							link_addr_o <= `ZeroWord;
							if(reg1_o[31] == 1'b1)
							begin
								branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
								branch_flag_o <= `Branch;
								next_inst_in_delayslot_o <= `InDelaySlot;
							end
						end

						`EXE_BLTZAL:
						begin
							aluop_o <= `EXE_BLTZAL_OP;
							alusel_o <= `EXE_RES_JUMP_BRANCH;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteEnable;
							wd_o <= 5'b11111;
							
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;
							link_addr_o <= pc_plus_8;
							
							if(reg1_o[31] == 1'b1)
							begin
								branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
								branch_flag_o <= `Branch;
								next_inst_in_delayslot_o <= `InDelaySlot;
							end
						end

						`EXE_TEQI:
						begin
							aluop_o <= `EXE_TEQ_OP;
							alusel_o <= `EXE_RES_NOP;
							instvalid <= `InstValid;

							wreg_o <= `WriteDisable;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;

							imm <= {{16{inst_i[15]}}, inst_i[15:0]};
						end

						`EXE_TGEI:
						begin
		  					aluop_o <= `EXE_TGE_OP;
							alusel_o <= `EXE_RES_NOP;
							instvalid <= `InstValid;

							wreg_o <= `WriteDisable;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;

							imm <= {{16{inst_i[15]}}, inst_i[15:0]};	
						end

						`EXE_TGEIU:
						begin
			  				aluop_o <= `EXE_TGEU_OP;
							alusel_o <= `EXE_RES_NOP;
							instvalid <= `InstValid;

							wreg_o <= `WriteDisable;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;

							imm <= {{16{inst_i[15]}}, inst_i[15:0]};
						end

						`EXE_TLTI:
						begin
			  				aluop_o <= `EXE_TLT_OP;
							alusel_o <= `EXE_RES_NOP;
							instvalid <= `InstValid;

							wreg_o <= `WriteDisable;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;

							imm <= {{16{inst_i[15]}}, inst_i[15:0]};
						end

						`EXE_TLTIU:
						begin
			  				aluop_o <= `EXE_TLTU_OP;
							alusel_o <= `EXE_RES_NOP;
							instvalid <= `InstValid;

							wreg_o <= `WriteDisable;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;

							imm <= {{16{inst_i[15]}}, inst_i[15:0]};
						end

						`EXE_TNEI:
						begin
			  				aluop_o <= `EXE_TNE_OP;
							alusel_o <= `EXE_RES_NOP;
							instvalid <= `InstValid;

							wreg_o <= `WriteDisable;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;

							imm <= {{16{inst_i[15]}}, inst_i[15:0]};
						end		

						default:
						begin
						end
					endcase

				`EXE_SPECIAL2_INST:
					case(op3)
						`EXE_CLZ:
						begin
							aluop_o <= `EXE_CLZ_OP;
							alusel_o <= `EXE_RES_ARITHMETIC;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteEnable;
							
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;
						end

						`EXE_CLO:
						begin
							aluop_o <= `EXE_CLO_OP;
							alusel_o <= `EXE_RES_ARITHMETIC;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteEnable;
							
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;
						end

						`EXE_MUL:
						begin
							aluop_o <= `EXE_MUL_OP;
							alusel_o <= `EXE_RES_MUL;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteEnable;
							
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
						end

						`EXE_MADD:
						begin
							aluop_o <= `EXE_MADD_OP;
							alusel_o <= `EXE_RES_NOP;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteDisable;
							
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
						end

						`EXE_MADDU:
						begin
							aluop_o <= `EXE_MADDU_OP;
							alusel_o <= `EXE_RES_NOP;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteDisable;
							
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
						end


						`EXE_MSUB:
						begin
							aluop_o <= `EXE_MSUB_OP;
							alusel_o <= `EXE_RES_NOP;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteDisable;
							
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
						end

						`EXE_MSUBU:
						begin
							aluop_o <= `EXE_MSUBU_OP;
							alusel_o <= `EXE_RES_NOP;
							instvalid <= `InstValid;
							
							wreg_o <= `WriteDisable;
							
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
						end
						
						default:
						begin
						end
					endcase

				default:		
				begin
				end
			endcase
			
			if(inst_i[31:21] == 11'b0)
				case(op3)
					`EXE_SLL:
					begin
						aluop_o <= `EXE_SLL_OP;
						alusel_o <= `EXE_RES_SHIFT;
						instvalid <= `InstValid;
						
						wreg_o <= `WriteEnable;
						wd_o <= inst_i[15:11];
						
						reg1_read_o <= 1'b0;
						reg2_read_o <= 1'b1;
						
						imm <= inst_i[10:6];
					end
					
					`EXE_SRL:
					begin
						aluop_o <= `EXE_SRL_OP;
						alusel_o <= `EXE_RES_SHIFT;
						instvalid <= `InstValid;
						
						wreg_o <= `WriteEnable;
						wd_o <= inst_i[15:11];
						
						reg1_read_o <= 1'b0;
						reg2_read_o <= 1'b1;
						
						imm[4:0] <= inst_i[10:6];
					end
					
					`EXE_SRA:
					begin
						aluop_o <= `EXE_SRA_OP;
						alusel_o <= `EXE_RES_SHIFT;
						instvalid <= `InstValid;
						
						wreg_o <= `WriteEnable;
						wd_o <= inst_i[15:11];
						
						reg1_read_o <= 1'b0;
						reg2_read_o <= 1'b1;
						
						imm[4:0] <= inst_i[10:6];
					end

					default:
					begin
					end
				endcase


			if(inst_i[31:21] == `EXE_MFC0 && inst_i[10:3] == 8'b00000000)
			begin
				aluop_o <= `EXE_MFC0_OP;
				alusel_o <= `EXE_RES_MOVE;
				instvalid <= `InstValid;	

				wreg_o <= `WriteEnable;
				wd_o <= inst_i[20:16];

				reg1_read_o <= 1'b0;
				reg2_read_o <= 1'b0;
			end
			else if(inst_i[31:21] == `EXE_MTC0 && inst_i[10:3] == 8'b00000000)
			begin
				aluop_o <= `EXE_MTC0_OP;
				alusel_o <= `EXE_RES_NOP;
				instvalid <= `InstValid;

				wreg_o <= `WriteDisable;
				
				reg1_read_o <= 1'b1;
				reg1_addr_o <= inst_i[20:16];
				reg2_read_o <= 1'b0;
			end

			if(inst_i == `EXE_ERET)
			begin
				aluop_o <= `EXE_ERET_OP;
				alusel_o <= `EXE_RES_NOP;
				instvalid <= `InstValid;

				wreg_o <= `WriteDisable;	

				reg1_read_o <= 1'b0;
				reg2_read_o <= 1'b0;

				excepttype_is_eret<= `True_v;
			end
			
			if(inst_i == `EXE_TLBWI)
			begin
				aluop_o <= `EXE_TLBWI_OP;
				alusel_o <= `EXE_RES_NOP;
				instvalid <= `InstValid;

				wreg_o <= `WriteDisable;

				reg1_read_o <= 1'b0;
				reg2_read_o <= 1'b0;
			end
			else if(inst_i == `EXE_TLBWR)
			begin
				aluop_o <= `EXE_TLBWR_OP;
				alusel_o <= `EXE_RES_NOP;
				instvalid <= `InstValid;

				wreg_o <= `WriteDisable;

				reg1_read_o <= 1'b0;
				reg2_read_o <= 1'b0;
			end
			
		end
	end
	
	
	/**************** ȷ��Դ������ 1 *****************/
	
	always @ (*)
	begin
		stallreq_for_reg1_loadrelate <= `NoStop;	

		if(rst_n == `RstEnable)
			reg1_o <= `ZeroWord;
		else if((reg1_read_o == 1'b1) && (pre_inst_is_load == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o))
		begin
			stallreq_for_reg1_loadrelate <= `Stop;
			reg1_o <= `ZeroWord;
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
			reg1_o <= `ZeroWord;
	end
	
	/**************** ȷ��Դ������ 2 *****************/
	
	always @ (*)
	begin
		stallreq_for_reg2_loadrelate <= `NoStop;	

		if(rst_n == `RstEnable)
			reg2_o <= `ZeroWord;
		else if((reg2_read_o == 1'b1) && (pre_inst_is_load == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o))
		begin
			stallreq_for_reg2_loadrelate <= `Stop;
			reg2_o <= `ZeroWord;
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
			reg2_o <= `ZeroWord;
	end
	
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
