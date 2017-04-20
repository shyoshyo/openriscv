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
	input wire[31:0] excepttype_i,
	input wire[`RegBus] current_inst_address_i,
	input wire not_stall_i,

	// HILO ģ������� HI��LO �Ĵ�����ֵ
	input wire[`RegBus] hi_i,
	input wire[`RegBus] lo_i,

	//��д�׶ε�ָ���Ƿ�ҪдHI��LO�����ڼ��HI��LO���������
	input wire[`RegBus] wb_hi_i,
	input wire[`RegBus] wb_lo_i,
	input wire wb_whilo_i,
	
	//�ô�׶ε�ָ���Ƿ�ҪдHI��LO�����ڼ��HI��LO���������
	input wire[`RegBus] mem_hi_i,
	input wire[`RegBus] mem_lo_i,
	input wire mem_whilo_i,
	
	// ��ͣ����һ�� ex �õ��Ľ��
	input wire[`DoubleRegBus] hilo_temp_i,
	input wire[1:0] cnt_i,
	input wire div_started_i,

	// ����ģ����Ľ��
	input wire[`DoubleRegBus] div_result_i,
	input wire div_ready_i,

	// �Ƿ����ӳٲ��С��Լ�link address
	input wire[`RegBus] link_address_i,
	input wire is_in_delayslot_i,

	//�ô�׶ε�ָ���Ƿ�ҪдCP0����������������
	input wire mem_cp0_reg_we,
	input wire[7:0] mem_cp0_reg_write_addr,
	input wire[`RegBus] mem_cp0_reg_data,
	
	//��д�׶ε�ָ���Ƿ�ҪдCP0����������������
	input wire wb_cp0_reg_we,
	input wire[7:0] wb_cp0_reg_write_addr,
	input wire[`RegBus] wb_cp0_reg_data,

	// TLB �ṩ��������ַ
	input wire[`RegBus] mem_phy_addr_i,
	input wire data_tlb_r_miss_exception_i,
	input wire data_tlb_w_miss_exception_i,
	input wire data_tlb_mod_exception_i, 

	//��CP0��������ȡ����CP0�Ĵ�����ֵ
	input wire[`RegBus] cp0_reg_data_i,
	output reg[7:0] cp0_reg_read_addr_o,

	//����һ��ˮ�����ݣ�����дCP0�еļĴ���
	output reg cp0_reg_we_o,
	output reg[7:0] cp0_reg_write_addr_o,
	output reg[`RegBus] cp0_reg_data_o,
	output reg cp0_write_tlb_index_o,
	output reg cp0_write_tlb_random_o,

	// �Ƿ�д�Ĵ������Լ��Ĵ����ĵ�ַ��Ҫд��ֵ
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
	output reg[`RegBus] wdata_o,
	
	// �Ƿ�д�� hi, lo, Ҫд���ֵ
	output reg[`RegBus] hi_o,
	output reg[`RegBus] lo_o,
	output reg whilo_o,

	// ��ͣ����һ�� ex ��Ҫ�Ľ��
	output reg[`DoubleRegBus] hilo_temp_o,
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
	output wire[31:0] excepttype_o,
	// ��ǰָ���Ƿ����ӳٲ���
	output wire is_in_delayslot_o,
	// ��ǰָ���ַ�Լ����Ƿ�Ϸ�
	output wire[`RegBus] current_inst_address_o,
	output wire not_stall_o,


	// ���� MEM �׶ε�������ַ
	output wire[`RegBus] mem_phy_addr_o,
	output wire data_tlb_r_miss_exception_o,
	output wire data_tlb_w_miss_exception_o,
	output wire data_tlb_mod_exception_o, 

	output reg stallreq
);
	reg[`RegBus] logicout;
	reg[`RegBus] shiftout;
	reg[`RegBus] moveout;

	reg[`RegBus] arithout;
	reg[`DoubleRegBus] multiout;

	// �����쳣
	reg trapassert;
	// ����쳣
	reg ovassert;

	// exceptiontype
	//   0   machine check   TLB write that conflicts with an existing entry
	//   1-8 �ⲿ�Д�         Assertion of unmasked HW or SW interrupt signal.
	// . 9   adEl            Fetch address alignment error.
	// . 10  TLBL            Fetch TLB miss, Fetch TLB hit to page with V=0 (inst)
	// . 11  syscall
	// . 12  RI              �oЧָ�� Reserved Instruction
	// * 13  ov              ���
	// * 14  trap
	//   15  AdEL            Load address alignment error,  
	//   16  adES            Store address alignment error.
	//                       User mode store to kernel address.
	//   17  TLBL            Load TLB miss,  (4Kc core). (data)
	//   18  TLBS            Store TLB miss
	//   19  TLB Mod         Store to TLB page with D=0
	// . 20  ERET
	assign excepttype_o = {excepttype_i[31:15], trapassert, ovassert, excepttype_i[12:0]};

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
	wire reg1_lt_reg2;
	wire [`RegBus] reg2_i_mux;
	wire [`RegBus] result_sum;

	assign reg2_i_mux = 
			(
				aluop_i == `EXE_SUB_OP || aluop_i == `EXE_TLT_OP || aluop_i == `EXE_TGE_OP 
			) ? ((~reg2_i) + 1'b1) : reg2_i;

	assign result_sum = reg1_i + reg2_i_mux;

	assign reg1_lt_reg2 =
			(aluop_i == `EXE_SLT_OP || aluop_i == `EXE_TLT_OP || aluop_i == `EXE_TGE_OP) ? 
				($signed(reg1_i) < $signed(reg2_i)) : (reg1_i < reg2_i);

	always @ (*)
		if(rst_n == `RstEnable)
			arithout <= `ZeroWord;
		else
			case (aluop_i)
				`EXE_SLT_OP, `EXE_SLTU_OP:
					arithout <= reg1_lt_reg2;

				`EXE_ADD_OP, `EXE_SUB_OP:
					arithout <= result_sum;

				default: arithout <= `ZeroWord;
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
				`EXE_TEQ_OP:
					if(reg1_i == reg2_i) trapassert <= `TrapAssert;
					
				`EXE_TGE_OP, `EXE_TGEU_OP:
					if(~reg1_lt_reg2) trapassert <= `TrapAssert;
					
				`EXE_TLT_OP, `EXE_TLTU_OP:
					if(reg1_lt_reg2) trapassert <= `TrapAssert;
					
				`EXE_TNE_OP:
					if(reg1_i != reg2_i) trapassert <= `TrapAssert;
					
				default:
					trapassert <= `TrapNotAssert;
			endcase
		end


	reg[`RegBus] HI;
	reg[`RegBus] LO;
	
	// HI��LO �Ĵ���������·
	// �õ����µ�HI��LO�Ĵ�����ֵ���˴�Ҫ���ָ�������������
	always @ (*) begin
		if(rst_n == `RstEnable) begin
			{HI, LO} <= {`ZeroWord, `ZeroWord};
		end else if(mem_whilo_i == `WriteEnable) begin
			{HI, LO} <= {mem_hi_i, mem_lo_i};
		end else if(wb_whilo_i == `WriteEnable) begin
			{HI, LO} <= {wb_hi_i, wb_lo_i};
		end else begin
			{HI, LO} <= {hi_i, lo_i};			
		end
	end
	
	reg[`RegBus] cp0regout;
	always @ (*)
		if(rst_n == `RstEnable)
		begin
			cp0regout <= `ZeroWord;
			cp0_reg_read_addr_o <= 8'h0;
		end
		else
		begin
			cp0_reg_read_addr_o <= {inst_i[15:11], inst_i[2:0]};
			cp0regout <= cp0_reg_data_i;

			if({inst_i[15:11], inst_i[2:0]} == `CP0_REG_RANDOM)
				cp0regout <= {28'h0, cp0_reg_data_i[3:0] - 4'h3};
			else if({inst_i[15:11], inst_i[2:0]} == `CP0_REG_COUNT)
				cp0regout <= cp0_reg_data_i + 32'h3;
			
			if(mem_cp0_reg_we == `WriteEnable && mem_cp0_reg_write_addr == {inst_i[15:11], inst_i[2:0]})
			begin
				cp0regout <= cp0_reg_data_i;
				case ({inst_i[15:11], inst_i[2:0]})
					`CP0_REG_INDEX:
					begin
						cp0regout[3:0] <= mem_cp0_reg_data[3:0];
					end

					`CP0_REG_RANDOM:
					begin
						cp0regout <= {28'h0, cp0_reg_data_i[3:0] - 4'h3};
					end

					`CP0_REG_ENTRYLO0, `CP0_REG_ENTRYLO1:
					begin
						cp0regout[25:6] <= mem_cp0_reg_data[25:6];  // pfn
						cp0regout[2:0] <= mem_cp0_reg_data[2:0];    // {dirty, valid, global}
					end

					`CP0_REG_PAGEMASK:
					begin
					end

					`CP0_REG_BadVAddr:
					begin
					end

					`CP0_REG_ENTRYHI:
					begin
						cp0regout[31:13] <= mem_cp0_reg_data[31:13];  // vpn2
						cp0regout[7:0] <= mem_cp0_reg_data[7:0];      // asid
					end

					`CP0_REG_EBASE:
					begin
						cp0regout[29:12] <= mem_cp0_reg_data[29:12];
					end

					`CP0_REG_COUNT:
					begin
						cp0regout <= mem_cp0_reg_data + 32'h1;
					end
					
					`CP0_REG_COMPARE:
					begin
						cp0regout <= mem_cp0_reg_data;
					end
					
					`CP0_REG_STATUS:
					begin
						// cp0regout <= mem_cp0_reg_data;

						// {ERL, EXL, IE}
						cp0regout[2:0] <= mem_cp0_reg_data[2:0];

						// {UM}
						cp0regout[4] <= mem_cp0_reg_data[4];

						// {InterruptMask}
						cp0regout[15:8] <= mem_cp0_reg_data[15:8];

						// {BEV}
						cp0regout[22] <= mem_cp0_reg_data[22];
					end
					
					`CP0_REG_CAUSE:
					begin
						//cause�Ĵ���ֻ��IP[1:0]��IV��WP�ֶ��ǿ�д��
						cp0regout[9:8] <= mem_cp0_reg_data[9:8];
						cp0regout[22] <= mem_cp0_reg_data[22];
						cp0regout[23] <= mem_cp0_reg_data[23];
						cp0regout[27] <= mem_cp0_reg_data[27];
					end
					
					`CP0_REG_EPC:
					begin
						cp0regout <= mem_cp0_reg_data;
					end
					
					`CP0_REG_PrId, `CP0_REG_CONFIG:
					begin
					end

					default:
					begin
						cp0regout <= `ZeroWord;
					end
				endcase
			end
			else if(wb_cp0_reg_we == `WriteEnable && wb_cp0_reg_write_addr == {inst_i[15:11], inst_i[2:0]})
			begin
				cp0regout <= cp0_reg_data_i;
				case ({inst_i[15:11], inst_i[2:0]})
					`CP0_REG_INDEX:
					begin
						cp0regout[3:0] <= wb_cp0_reg_data[3:0];
					end

					`CP0_REG_RANDOM:
					begin
						cp0regout <= {28'h0, cp0_reg_data_i[3:0] - 4'h3};
					end

					`CP0_REG_ENTRYLO0, `CP0_REG_ENTRYLO1:
					begin
						cp0regout[25:6] <= wb_cp0_reg_data[25:6];  // pfn
						cp0regout[2:0] <= wb_cp0_reg_data[2:0];    // {dirty, valid, global}
					end

					`CP0_REG_PAGEMASK:
					begin
					end

					`CP0_REG_BadVAddr:
					begin
					end

					`CP0_REG_ENTRYHI:
					begin
						cp0regout[31:13] <= wb_cp0_reg_data[31:13];  // vpn2
						cp0regout[7:0] <= wb_cp0_reg_data[7:0];      // asid
					end

					`CP0_REG_EBASE:
					begin
						cp0regout[29:12] <= wb_cp0_reg_data[29:12];
					end

					`CP0_REG_COUNT:
					begin
						cp0regout <= wb_cp0_reg_data + 32'h2;
					end
					
					`CP0_REG_COMPARE:
					begin
						cp0regout <= wb_cp0_reg_data;
					end
					
					`CP0_REG_STATUS:
					begin
						// cp0regout <= wb_cp0_reg_data;

						// {ERL, EXL, IE}
						cp0regout[2:0] <= mem_cp0_reg_data[2:0];

						// {UM}
						cp0regout[4] <= mem_cp0_reg_data[4];

						// {InterruptMask}
						cp0regout[15:8] <= mem_cp0_reg_data[15:8];

						// {BEV}
						cp0regout[22] <= mem_cp0_reg_data[22];
					end
					
					`CP0_REG_CAUSE:
					begin
						//cause�Ĵ���ֻ��IP[1:0]��IV��WP�ֶ��ǿ�д��
						cp0regout[9:8] <= wb_cp0_reg_data[9:8];
						cp0regout[22] <= wb_cp0_reg_data[22];
						cp0regout[23] <= wb_cp0_reg_data[23];
						cp0regout[27] <= wb_cp0_reg_data[27];
					end
					
					`CP0_REG_EPC:
					begin
						cp0regout <= wb_cp0_reg_data;
					end
					
					`CP0_REG_PrId, `CP0_REG_CONFIG:
					begin
					end

					default:
					begin
						cp0regout <= `ZeroWord;
					end
				endcase
			end
		end

	// move op
	always @ (*)
		if(rst_n == `RstEnable)
			moveout <= `ZeroWord;
		else
			case (aluop_i)
				`EXE_MFHI_OP: moveout <= HI;
				`EXE_MFLO_OP: moveout <= LO;
				`EXE_MOVZ_OP, `EXE_MOVN_OP: moveout <= reg1_i;
				`EXE_MFC0_OP: moveout <= cp0regout;

				default: moveout <= `ZeroWord;
			endcase

	// multi op
	wire [`DoubleRegBus] opdata1_mult;
	wire [`DoubleRegBus] opdata2_mult;
	wire [`DoubleRegBus] result_mul;

	assign opdata1_mult = 
		(
			aluop_i == `EXE_MULT_OP || 
			aluop_i == `EXE_MADD_OP || 
			aluop_i == `EXE_MSUB_OP
		) ? {{32{reg1_i[31]}}, reg1_i} : {`ZeroWord, reg1_i};

	assign opdata2_mult = 
		(
			aluop_i == `EXE_MULT_OP || 
			aluop_i == `EXE_MADD_OP || 
			aluop_i == `EXE_MSUB_OP
		) ? {{32{reg2_i[31]}}, reg2_i} : {`ZeroWord, reg2_i};

	assign result_mul = opdata1_mult * opdata2_mult;
	
	always @ (*)
		if(rst_n == `RstEnable)
			multiout <= {`ZeroWord, `ZeroWord};
		else 
			multiout <= result_mul;

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
				`EXE_DIV_OP, `EXE_DIVU_OP:
				begin
					if(div_started_i == 1'b0)
					begin
						div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStart;
						signed_div_o <= (aluop_i == `EXE_DIV_OP) ? 1'b1 : 1'b0;
						div_started_o <= 1'b1;
						stallreq_for_div <= `Stop;
					end
					else if(div_started_i == 1'b1)
					begin
						div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStop;
						signed_div_o <= (aluop_i == `EXE_DIV_OP) ? 1'b1 : 1'b0;
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

	always @(*)
		if(rst_n == `RstEnable)
			{mem_we_o, mem_ce_o} <= {`WriteDisable, `ChipDisable};
		else
			case(aluop_i)
				`EXE_LB_OP, `EXE_LBU_OP, `EXE_LH_OP, `EXE_LHU_OP, `EXE_LW_OP, `EXE_LWL_OP, `EXE_LWR_OP, `EXE_LL_OP:
					{mem_we_o, mem_ce_o} <= {`WriteDisable, `ChipEnable};

				`EXE_SB_OP, `EXE_SH_OP, `EXE_SW_OP, `EXE_SWL_OP, `EXE_SWR_OP, `EXE_SC_OP:
					{mem_we_o, mem_ce_o} <= {`WriteEnable, `ChipEnable};
					
				default:
					{mem_we_o, mem_ce_o} <= {`WriteDisable, `ChipDisable};
			endcase



	/************************** ��ͣ��ˮ�� ******************************/
	always @(*)
	 	stallreq <= stallreq_for_madd_msub || stallreq_for_div; 


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
					wdata_o <= multiout[31:0];

				`EXE_RES_JUMP_BRANCH:
					wdata_o <= link_address_i;
				
				default:
					wdata_o <= `ZeroWord;
			endcase
		end
	
	
	/***************** ����ָ��Ҫд�� hi, lo ������ ********************/
	always @ (*)
		if(rst_n == `RstEnable)
		begin
			whilo_o <= `WriteDisable;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;		
		end
		else if(aluop_i == `EXE_MULT_OP || aluop_i == `EXE_MULTU_OP)
		begin
			whilo_o <= `WriteEnable;
			{hi_o, lo_o} <= multiout;
		end 
		else if(aluop_i == `EXE_MADD_OP || aluop_i == `EXE_MADDU_OP ||
				aluop_i == `EXE_MSUB_OP || aluop_i == `EXE_MSUBU_OP)
		begin
			whilo_o <= `WriteEnable;
			{hi_o, lo_o} <= madd_msub_out;
		end 
		else if(aluop_i == `EXE_DIV_OP || aluop_i == `EXE_DIVU_OP)
		begin
			whilo_o <= `WriteEnable;
			{hi_o, lo_o} <= div_result_i;
		end
		else if(aluop_i == `EXE_MTHI_OP)
		begin
			whilo_o <= `WriteEnable;
			hi_o <= reg1_i;
			lo_o <= LO;
		end 
		else if(aluop_i == `EXE_MTLO_OP)
		begin
			whilo_o <= `WriteEnable;
			hi_o <= HI;
			lo_o <= reg1_i;
		end 
		else 
		begin
			whilo_o <= `WriteDisable;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
		end


	/******************* ����ָ��Ҫд�� cp0 ������ **********************/
	always @ (*)
		if(rst_n == `RstEnable)
		begin
			cp0_reg_write_addr_o <= 8'b00000_000;
			cp0_reg_we_o <= `WriteDisable;
			cp0_reg_data_o <= `ZeroWord;

			cp0_write_tlb_index_o <= `False_v;
			cp0_write_tlb_random_o <= `False_v;
		end
		else
		begin
			cp0_reg_write_addr_o <= 8'b00000_000;
			cp0_reg_we_o <= `WriteDisable;
			cp0_reg_data_o <= `ZeroWord;

			cp0_write_tlb_index_o <= `False_v;
			cp0_write_tlb_random_o <= `False_v;

			case(aluop_i)
				`EXE_MTC0_OP:
				begin
					cp0_reg_write_addr_o <= {{inst_i[15:11], inst_i[2:0]}};
					cp0_reg_we_o <= `WriteEnable;
					cp0_reg_data_o <= reg1_i;
				end

				`EXE_TLBWI_OP:
					cp0_write_tlb_index_o <= `True_v;
				
				`EXE_TLBWR_OP:
					cp0_write_tlb_random_o <= `True_v;

				default:
				begin
				end
			endcase
		end
endmodule