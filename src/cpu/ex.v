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
// Module:  ex
// File:    ex.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: ִ�н׶�
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module ex(

	input wire rst_n,
	
	// �͵�ִ�н׶ε���Ϣ
	input wire[`AluOpBus] aluop_i,
	input wire[`AluSelBus] alusel_i,
	input wire[`RegBus] reg1_i,
	input wire[`RegBus] reg2_i,
	input wire[`RegBus] imm_i,
	input wire[`RegAddrBus] wd_i,
	input wire wreg_i,
	input wire[`InstBus] inst_i,

	// �Ѿ���⵽���쳣��ָ���ַ�����Ƿ�Ϸ�
	input wire[`ExceptionTypeBus] excepttype_i,
	input wire[`RegBus] current_inst_address_i,
	input wire not_stall_i,
	
	// ��ͣ����һ�� ex �õ��Ľ��
	input wire[1:0] cnt_i,
	input wire div_started_i,

	// ����ģ����Ľ��
	input wire[`RegBus] div_result_rem_i,
	input wire[`RegBus] div_result_div_i,
	input wire div_ready_i,

	// �Ƿ����ӳٲ��С��Լ�link address
	input wire[`RegBus] link_address_i,
	input wire is_in_delayslot_i,

	/*
	//�ô�׶ε�ָ���Ƿ�Ҫдcsr����������������
	input wire mem_csr_reg_we,
	input wire[`CSRAddrBus] mem_csr_reg_write_addr,
	input wire[`RegBus] mem_csr_reg_data,
	
	//��д�׶ε�ָ���Ƿ�Ҫдcsr����������������
	input wire wb_csr_reg_we,
	input wire[`CSRAddrBus] wb_csr_reg_write_addr,
	input wire[`RegBus] wb_csr_reg_data,
	*/

	//csr
	input wire[`CSRWriteTypeBus] csr_reg_we_i,
	input wire[`RegBus] csr_reg_data_i,

	// TLB �ṩ�������ַ
	input wire[`PhyAddrBus] mem_phy_addr_i,
	input wire data_tlb_r_miss_exception_i,
	input wire data_tlb_w_miss_exception_i,
	input wire data_tlb_mod_exception_i, 

	//����һ��ˮ�����ݣ�����дcsr�еļĴ���
	output wire[`CSRWriteTypeBus] csr_reg_we_o,
	output wire[`CSRAddrBus] csr_reg_write_addr_o,
	output wire[`RegBus] csr_reg_data_o,
	output reg csr_write_tlb_index_o,
	output reg csr_write_tlb_random_o,

	// �Ƿ�д�Ĵ������Լ��Ĵ����ĵ�ַ��Ҫд��ֵ
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
	output reg[`RegBus] wdata_o,

	// ��ͣ����һ�� ex ��Ҫ�Ľ��
	output reg[1:0] cnt_o,
	output reg div_started_o,

	// ���͸�������������
	output reg[`RegBus] div_opdata1_o,
	output reg[`RegBus] div_opdata2_o,
	output reg div_start_o,
	output reg signed_div_o,

	// Ϊ���ء��洢ָ��׼���ģ�
	// �ڴ��дʹ�ܺ�ʹ����Ϊ����ʵ��ַת�������Լ���ģ������������Ĵ�
	// ������ʹ��ȷʵ�ǿ��Ļ������������Ҫ�ǿ���дʹ��Ҳ�����
	output wire[`AluOpBus] aluop_o,
	output wire[`RegBus] mem_addr_o,
	output reg mem_we_o,
	output reg mem_ce_o,
	output wire[`RegBus] reg2_o,
	
	// �¼������쳣����
	output reg[`ExceptionTypeBus] excepttype_o,
	// ��ǰָ���Ƿ����ӳٲ���
	output wire is_in_delayslot_o,
	// ��ǰָ���ַ�Լ����Ƿ�Ϸ�
	output wire[`RegBus] current_inst_address_o,
	output wire not_stall_o,


	// ���� MEM �׶ε������ַ
	output wire[`PhyAddrBus] mem_phy_addr_o,
	output wire data_tlb_r_miss_exception_o,
	output wire data_tlb_w_miss_exception_o,
	output wire data_tlb_mod_exception_o, 

	output reg stallreq
);
	reg[`RegBus] logicout;
	reg[`RegBus] shiftout;
	reg[`RegBus] moveout;

	reg[`RegBus] arithout;
	reg[`RegBus] multiout;

	// �����쳣
	reg trapassert;
	// ����쳣
	reg ovassert;

	always @(*)
		if (rst_n == `RstEnable)
		begin
			excepttype_o <= `ZeroWord;
		end
		else
		begin
			excepttype_o <= excepttype_i;

			/*
			
			TODO: FIXME

			excepttype_o[0] <= trapassert;
			excepttype_o[0] <= ovassert;
			*/
		end
	
	assign is_in_delayslot_o = is_in_delayslot_i;
	assign current_inst_address_o = current_inst_address_i;
	assign not_stall_o = not_stall_i;

	/***********************************************************/

	// logic op
	always @ (*)
		if(rst_n == `RstEnable)
			logicout <= `ZeroWord;
		else
			case (aluop_i)
				`EXE_OR_OP: logicout <= reg1_i | reg2_i;
				`EXE_AND_OP: logicout <= reg1_i & reg2_i;
				`EXE_XOR_OP: logicout <= reg1_i ^ reg2_i;
				default: logicout <= `ZeroWord;
			endcase
	
	/***********************************************************/

	// shift op
	always @ (*)
		if(rst_n == `RstEnable)
			shiftout <= `ZeroWord;
		else
			case (aluop_i)
				`EXE_SLL_OP: shiftout <= reg1_i << reg2_i[4:0];
				`EXE_SRL_OP: shiftout <= reg1_i >> reg2_i[4:0];
				`EXE_SRA_OP: shiftout <= $signed(reg1_i) >>> reg2_i[4:0];
				default: shiftout <= `ZeroWord;
			endcase

	/***********************************************************/

	// arithmetic op
	/*
	wire reg1_lt_reg2;
	wire [`RegBus] reg2_i_mux;
	wire [`RegBus] result_sum;

	assign reg2_i_mux = (aluop_i == `EXE_SUB_OP) ? ((~reg2_i) + 1'b1) : reg2_i;

	assign result_sum = reg1_i + reg2_i_mux;

	assign reg1_lt_reg2 =
			(aluop_i == `EXE_SLT_OP) ? ($signed(reg1_i) < $signed(reg2_i)) : (reg1_i < reg2_i);
	*/

	always @ (*)
		if(rst_n == `RstEnable)
			arithout <= `ZeroWord;
		else
			case (aluop_i)
				`EXE_SLT_OP:  arithout <= ($signed(reg1_i) < $signed(reg2_i));
				`EXE_SLTU_OP: arithout <= (reg1_i < reg2_i);
				`EXE_ADD_OP:  arithout <= reg1_i + reg2_i;
				`EXE_SUB_OP:  arithout <= reg1_i - reg2_i;

				default:      arithout <= `ZeroWord;
			endcase
	
	/***********************************************************/

	// trap op
	always @ (*)
		if(rst_n == `RstEnable)
			trapassert <= `TrapNotAssert;
		else
		begin
			trapassert <= `TrapNotAssert;
			case (aluop_i)

				default:
					trapassert <= `TrapNotAssert;
			endcase
		end
	
	

	// move op
	always @ (*)
		if(rst_n == `RstEnable)
			moveout <= `ZeroWord;
		else
			case (aluop_i)
				`EXE_MOVZ_OP, `EXE_MOVN_OP:
					moveout <= reg1_i;
				
				`EXE_CSRRW_OP, `EXE_CSRRS_OP, `EXE_CSRRC_OP:
					moveout <= csr_reg_data_i;

				default: moveout <= `ZeroWord;
			endcase

	// multi op
	wire [`DoubleRegBus] opdata1_mult;
	wire [`DoubleRegBus] opdata2_mult;
	wire [`DoubleRegBus] result_mul;

	assign opdata1_mult = 
		(
			aluop_i == `EXE_MULH_OP || 
			aluop_i == `EXE_MULHSU_OP
		) ? {{32{reg1_i[31]}}, reg1_i} : {`ZeroWord, reg1_i};

	assign opdata2_mult = 
		(
			aluop_i == `EXE_MULH_OP
		) ? {{32{reg2_i[31]}}, reg2_i} : {`ZeroWord, reg2_i};

	assign result_mul = opdata1_mult * opdata2_mult;
	
	always @ (*)
		if(rst_n == `RstEnable)
			multiout <= `ZeroWord;
		else
			case (aluop_i)
				`EXE_MUL_OP:
					multiout <= result_mul[`RegBus];
					
				`EXE_MULH_OP, `EXE_MULHSU_OP, `EXE_MULHU_OP:
					multiout <= result_mul[`HighRegBus];
					
				`EXE_DIV_OP, `EXE_DIVU_OP:
					multiout <= div_result_div_i;
					
				`EXE_REM_OP, `EXE_REMU_OP:
					multiout <= div_result_rem_i;

				default:
					multiout <= `ZeroWord;
			endcase

	/*
	// madd op, msub op
	reg [`DoubleRegBus]madd_msub_out;
	reg stallreq_for_madd_msub;

	always @ (*)
		if(rst_n == `RstEnable)
		begin
			hilo_temp_o <= {`ZeroWord, `ZeroWord};
			cnt_o <= 2'b00;
			stallreq_for_madd_msub <= `NoStop;
			madd_msub_out <= {`ZeroWord, `ZeroWord};
		end
		else
		begin
			case(aluop_i)
				`EXE_MADD_OP, `EXE_MADDU_OP:
				begin
					if(cnt_i == 2'b00)
					begin
						hilo_temp_o <= multiout;
						cnt_o <= 2'b01;
						madd_msub_out <= {`ZeroWord, `ZeroWord};
						stallreq_for_madd_msub <= `Stop;
					end
					else if(cnt_i == 2'b01)
					begin
						hilo_temp_o <= hilo_temp_i + {HI, LO};
						cnt_o <= 2'b10;
						madd_msub_out <= hilo_temp_i + {HI, LO};
						stallreq_for_madd_msub <= `NoStop;
					end
					else
					begin
						hilo_temp_o <= hilo_temp_i;
						cnt_o <= 2'b10;
						madd_msub_out <= hilo_temp_i;
						stallreq_for_madd_msub <= `NoStop;
					end
				end

				`EXE_MSUB_OP, `EXE_MSUBU_OP:
				begin
					if(cnt_i == 2'b00)
					begin
						hilo_temp_o <= multiout;
						cnt_o <= 2'b01;
						madd_msub_out <= {`ZeroWord, `ZeroWord};
						stallreq_for_madd_msub <= `Stop;
					end
					else if(cnt_i == 2'b01)
					begin
						hilo_temp_o <= {HI, LO} - hilo_temp_i;
						cnt_o <= 2'b10;
						madd_msub_out <= {HI, LO} - hilo_temp_i;
						stallreq_for_madd_msub <= `NoStop;
					end
					else
					begin
						hilo_temp_o <= hilo_temp_i;
						cnt_o <= 2'b10;
						madd_msub_out <= hilo_temp_i;
						stallreq_for_madd_msub <= `NoStop;
					end
				end

				default:
				begin
					hilo_temp_o <= {`ZeroWord, `ZeroWord};
					cnt_o <= 2'b00;
					madd_msub_out <= {`ZeroWord, `ZeroWord};
					stallreq_for_madd_msub <= `NoStop;
				end
			endcase
		end
	*/


	reg stallreq_for_div;

	// div, divu
	always @ (*) begin
		if(rst_n == `RstEnable)
		begin
			stallreq_for_div <= `NoStop;
			div_opdata1_o <= `ZeroWord;
			div_opdata2_o <= `ZeroWord;
			div_start_o <= `DivStop;
			signed_div_o <= 1'b0;
			div_started_o <= 1'b0;
		end
		else
		begin
			stallreq_for_div <= `NoStop;
			div_opdata1_o <= `ZeroWord;
			div_opdata2_o <= `ZeroWord;
			div_start_o <= `DivStop;
			signed_div_o <= 1'b0;
			div_started_o <= 1'b0;

			case (aluop_i) 
				`EXE_DIV_OP, `EXE_DIVU_OP, `EXE_REM_OP, `EXE_REMU_OP:
				begin
					if(div_started_i == 1'b0)
					begin
						div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStart;
						signed_div_o <=
							(aluop_i == `EXE_DIV_OP || aluop_i == `EXE_REM_OP) ? 1'b1 : 1'b0;
						div_started_o <= 1'b1;
						stallreq_for_div <= `Stop;
					end
					else if(div_started_i == 1'b1)
					begin
						div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStop;
						signed_div_o <=
							(aluop_i == `EXE_DIV_OP || aluop_i == `EXE_REM_OP) ? 1'b1 : 1'b0;
						div_started_o <= 1'b1;
						stallreq_for_div <= (div_ready_i == `DivResultReady) ? `NoStop : `Stop;
					end
				end
				default:
				begin
				end
			endcase
		end
	end	

	//aluop_o���ݵ��ô�׶Σ����ڼ��ء��洢ָ��
	//��ʱ���پ�������ء��洢����
	assign aluop_o = aluop_i;

	//mem_addr���ݵ��ô�׶Σ��Ǽ��ء��洢ָ���Ӧ�Ĵ洢����ַ
	assign mem_addr_o = imm_i;

	//������������Ҳ���ݵ��ô�׶Σ�Ҳ��Ϊ���ء��洢ָ��׼����
	// �洢��lwl, lwr ָ����Ҫ
	assign reg2_o = reg2_i;

	assign mem_phy_addr_o = mem_phy_addr_i;
	assign data_tlb_r_miss_exception_o = data_tlb_r_miss_exception_i;
	assign data_tlb_w_miss_exception_o = data_tlb_w_miss_exception_i;
	assign data_tlb_mod_exception_o = data_tlb_mod_exception_i;

	// for mmu to check whether writable
	always @(*)
		if(rst_n == `RstEnable)
			{mem_we_o, mem_ce_o} <= {`WriteDisable, `ChipDisable};
		else
			case(aluop_i)
				`EXE_LB_OP, `EXE_LBU_OP, `EXE_LH_OP, `EXE_LHU_OP, `EXE_LW_OP, `EXE_LR_OP:
					{mem_we_o, mem_ce_o} <= {`WriteDisable, `ChipEnable};

				`EXE_SB_OP, `EXE_SH_OP, `EXE_SW_OP, `EXE_SC_OP, `EXE_AMOSWAP_W_OP, `EXE_AMOADD_W_OP,
				`EXE_AMOXOR_W_OP, `EXE_AMOAND_W_OP, `EXE_AMOOR_W_OP, `EXE_AMOMIN_W_OP, `EXE_AMOMAX_W_OP,
				`EXE_AMOMINU_W_OP, `EXE_AMOMAXU_W_OP:
					{mem_we_o, mem_ce_o} <= {`WriteEnable, `ChipEnable};
					
				default:
					{mem_we_o, mem_ce_o} <= {`WriteDisable, `ChipDisable};
			endcase



	/************************** ��ͣ��ˮ�� ******************************/
	always @(*)
	 	stallreq <= stallreq_for_div; 


	/***************** ����ָ��Ҫд�� regfile ������ ********************/

	always @ (*)
		if(rst_n == `RstEnable)
		begin
			wreg_o <= `WriteDisable;
			wd_o <= `NOPRegAddr;
			wdata_o <= `ZeroWord;
			ovassert <= `OverflowNotAssert;
		end
		else
		begin
			wd_o <= wd_i;
			wreg_o <= wreg_i;
			ovassert <= `OverflowNotAssert;

			case ( alusel_i ) 
				`EXE_RES_LOGIC:
					wdata_o <= logicout;
					
				`EXE_RES_SHIFT:
					wdata_o <= shiftout;
					
				`EXE_RES_MOVE:
					wdata_o <= moveout;

				`EXE_RES_ARITHMETIC:
					wdata_o <= arithout;

				`EXE_RES_MUL:
					wdata_o <= multiout;

				`EXE_RES_JUMP_BRANCH:
					wdata_o <= link_address_i;
				
				default:
					wdata_o <= `ZeroWord;
			endcase
		end

	/******************* ����ָ��Ҫд�� csr ������ **********************/
	assign csr_reg_write_addr_o = inst_i[31:20];
	assign csr_reg_data_o = reg1_i;
	assign csr_reg_we_o = csr_reg_we_i;

	always @ (*)
		if(rst_n == `RstEnable)
		begin
			csr_write_tlb_index_o <= `False_v;
			csr_write_tlb_random_o <= `False_v;
		end
		else
		begin
			csr_write_tlb_index_o <= `False_v;
			csr_write_tlb_random_o <= `False_v;

			case(aluop_i)
				`EXE_CSRRW_OP:
				begin
				end

				default:
				begin
				end
			endcase
		end
endmodule
