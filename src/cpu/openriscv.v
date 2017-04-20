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
// Module:  openmips
// File:    openmips.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: OpenMIPS�������Ķ����ļ�
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module openriscv(

	input wire clk,
	input wire wishbone_clk,
	input wire rst_n,
	
	input wire[5:0] int_i,
	
	// inst wishbone
	input wire[`WishboneDataBus]   iwishbone_data_i,
	input wire                     iwishbone_ack_i,
	output wire[`RegBus]           iwishbone_addr_o,
	output wire[`WishboneDataBus]  iwishbone_data_o,
	output wire                    iwishbone_we_o,
	output wire[`WishboneSelBus]   iwishbone_sel_o,
	output wire                    iwishbone_stb_o,
	output wire                    iwishbone_cyc_o, 
	
	// data wishbone
	input wire[`WishboneDataBus]   dwishbone_data_i,
	input wire                     dwishbone_ack_i,
	output wire[`RegBus]           dwishbone_addr_o,
	output wire[`WishboneDataBus]  dwishbone_data_o,
	output wire                    dwishbone_we_o,
	output wire[`WishboneSelBus]   dwishbone_sel_o,
	output wire                    dwishbone_stb_o,
	output wire                    dwishbone_cyc_o,
	
	output wire[`RegBus] pc_o,
	
	output wire timer_int_o
);
	// ��һ����Ҫ���� inst �洢���ĵ�ַ
	wire [`RegBus]pc_next_inst_phy_addr;
	wire [`RegBus]pc_next_inst_vir_addr;
	wire pc_next_inst_tlb_r_miss_exception;
	wire pc_ce_o;


	// pc reg ���� IF �׶ε�����
	// inst �洢�� ʹ��
	wire[`RegBus] pc;
	wire if_inst_ce_i;
	wire [`RegBus]if_inst_phy_addr_i;
	wire [31:0]if_excepttype_i;

	//��������׶� IF ģ�������� IF/ID ģ�������
	// �� inst �洢����õ�����
	wire[`InstBus] if_inst_o;
	wire if_inst_ce_o;
	wire [31:0]if_excepttype_o;

	//��������׶�IDģ�������
	wire[`RegBus] id_pc_i;
	wire[`InstBus] id_inst_i;
	wire[31:0] id_excepttype_i;
	wire id_not_stall_i;
	
	//��������׶�IDģ��������ID/EXģ�������
	wire[`AluOpBus] id_aluop_o;
	wire[`AluSelBus] id_alusel_o;
	wire[`RegBus] id_reg1_o;
	wire[`RegBus] id_reg2_o;
	wire[`RegBus] id_imm_o;
	wire id_wreg_o;
	wire[`RegAddrBus] id_wd_o;
	wire id_is_in_delayslot_o;
	wire[`RegBus] id_link_address_o;
	wire[`InstBus] id_inst_o;
	wire[31:0] id_excepttype_o;
	wire[`RegBus] id_current_inst_address_o;
	wire id_not_stall_o;
	
	//����ID/EXģ��������ִ�н׶�EXģ�������
	wire[`AluOpBus] ex_aluop_i;
	wire[`AluSelBus] ex_alusel_i;
	wire[`RegBus] ex_reg1_i;
	wire[`RegBus] ex_reg2_i;
	wire[`RegBus] ex_imm_i;
	wire ex_wreg_i;
	wire[`RegAddrBus] ex_wd_i;
	wire ex_is_in_delayslot_i;	
	wire[`RegBus] ex_link_address_i;
	wire[`InstBus] ex_inst_i;
	wire[31:0] ex_excepttype_i;	
	wire[`RegBus] ex_current_inst_address_i;
	wire ex_not_stall_i;

	wire [`RegBus]ex_mem_phy_addr_i;
	wire ex_data_tlb_r_miss_exception_i;
	wire ex_data_tlb_w_miss_exception_i;
	wire ex_data_tlb_mod_exception_i;

	//����ִ�н׶�EXģ��������EX/MEMģ�������
	wire ex_wreg_o;
	wire[`RegAddrBus] ex_wd_o;
	wire[`RegBus] ex_wdata_o;
	wire[`RegBus] ex_hi_o;
	wire[`RegBus] ex_lo_o;
	wire ex_whilo_o;
	wire[`AluOpBus] ex_aluop_o;
	wire[`RegBus] ex_mem_addr_o;
	wire ex_mem_we_o;
	wire ex_mem_ce_o;
	wire[`RegBus] ex_reg1_o;
	wire[`RegBus] ex_reg2_o;
	wire ex_cp0_reg_we_o;
	wire[7:0] ex_cp0_reg_write_addr_o;
	wire[`RegBus] ex_cp0_reg_data_o;
	wire ex_cp0_write_tlb_index_o;
	wire ex_cp0_write_tlb_random_o;
	wire[31:0] ex_excepttype_o;
	wire[`RegBus] ex_current_inst_address_o;
	wire ex_not_stall_o;
	wire ex_is_in_delayslot_o;

	wire[`RegBus] ex_mem_phy_addr_o;
	wire ex_data_tlb_r_miss_exception_o;
	wire ex_data_tlb_w_miss_exception_o;
	wire ex_data_tlb_mod_exception_o;

	//����EX/MEMģ��������ô�׶�MEMģ�������
	wire mem_wreg_i;
	wire[`RegAddrBus] mem_wd_i;
	wire[`RegBus] mem_wdata_i;
	wire[`RegBus] mem_hi_i;
	wire[`RegBus] mem_lo_i;
	wire mem_whilo_i;
	wire[`AluOpBus] mem_aluop_i;
	wire[`RegBus] mem_mem_addr_i;
	wire[`RegBus] mem_reg1_i;
	wire[`RegBus] mem_reg2_i;
	wire mem_cp0_reg_we_i;
	wire[7:0] mem_cp0_reg_write_addr_i;
	wire[`RegBus] mem_cp0_reg_data_i;
	wire mem_cp0_write_tlb_index_i;
	wire mem_cp0_write_tlb_random_i;
	wire[31:0] mem_excepttype_i;
	wire mem_is_in_delayslot_i;
	wire[`RegBus] mem_current_inst_address_i;
	wire mem_not_stall_i;
	wire [`RegBus]mem_mem_phy_addr_i;
	wire mem_data_tlb_r_miss_exception_i;
	wire mem_data_tlb_w_miss_exception_i;
	wire mem_data_tlb_mod_exception_i;
	wire mem_tlb_machine_check_exception_i;

	//���ӷô�׶�MEMģ��������MEM/WBģ�������
	wire mem_wreg_o;
	wire[`RegAddrBus] mem_wd_o;
	wire[`RegBus] mem_wdata_o;
	wire[`RegBus] mem_hi_o;
	wire[`RegBus] mem_lo_o;
	wire mem_whilo_o;
	wire mem_LLbit_value_o;
	wire mem_LLbit_we_o;
	wire mem_cp0_reg_we_o;
	wire[7:0] mem_cp0_reg_write_addr_o;
	wire[`RegBus] mem_cp0_reg_data_o;
	wire mem_cp0_write_tlb_index_o;
	wire mem_cp0_write_tlb_random_o;
	wire[31:0] mem_excepttype_o;
	wire mem_is_in_delayslot_o;
	wire[`RegBus] mem_current_inst_address_o;
	wire[`RegBus] mem_current_data_address_o;
	
	//����MEM/WBģ���������д�׶ε�����	
	wire wb_wreg_i;
	wire[`RegAddrBus] wb_wd_i;
	wire[`RegBus] wb_wdata_i;
	wire[`RegBus] wb_hi_i;
	wire[`RegBus] wb_lo_i;
	wire wb_whilo_i;
	wire wb_LLbit_value_i;
	wire wb_LLbit_we_i;
	wire wb_cp0_reg_we_i;
	wire[7:0] wb_cp0_reg_write_addr_i;
	wire[`RegBus] wb_cp0_reg_data_i;
	wire wb_cp0_write_tlb_index_i;
	wire wb_cp0_write_tlb_random_i;
	wire[31:0] wb_excepttype_i;
	wire wb_is_in_delayslot_i;
	wire[`RegBus] wb_current_inst_address_i;
	
	//��������׶�IDģ����ͨ�üĴ���Regfileģ��
	wire reg1_read;
	wire reg2_read;
	wire[`RegBus] reg1_data;
	wire[`RegBus] reg2_data;
	wire[`RegAddrBus] reg1_addr;
	wire[`RegAddrBus] reg2_addr;
	
	//����ִ�н׶���hiloģ����������ȡHI��LO�Ĵ���
	wire[`RegBus] hi;
	wire[`RegBus] lo;
	wire whilo;
	
	// ����ִ�н׶���ex_regģ�飬���ڶ����ڵ�MADD��MADDU��MSUB��MSUBUָ��
	wire[`DoubleRegBus] hilo_temp_o;
	wire[1:0] cnt_o;
	
	wire[`DoubleRegBus] hilo_temp_i;
	wire[1:0] cnt_i;

	// ����ִ�н׶���ex_regģ�飬���ڶ����ڵ�DIV, DIVUָ��
	wire div_started_i;
	wire div_started_o;

	// ex ���� ������
	wire[`DoubleRegBus] div_result;
	wire div_ready;
	wire[`RegBus] div_opdata1;
	wire[`RegBus] div_opdata2;
	wire div_start;
	wire div_annul;
	wire signed_div;

	// id ��������pc �����
	wire is_in_delayslot_i;
	wire is_in_delayslot_o;
	wire next_inst_in_delayslot_o;
	wire step_i;
	wire step_o;
	wire id_branch_flag_o;
	wire[`RegBus] branch_target_address;

	wire[5:0] stall;
	wire stallreq_from_if;
	wire stallreq_from_id;
	wire stallreq_from_ex;
	wire stallreq_from_mem;

	wire LLbit_o;

	wire[`RegBus] cp0_data_o;
 	wire[7:0] cp0_raddr_i;

	wire flush;
	wire[`RegBus] new_pc;

	wire[`RegBus] cp0_count;
	wire[`RegBus] cp0_compare;
	wire[`RegBus] cp0_status;
	wire[`RegBus] cp0_cause;
	wire[`RegBus] cp0_epc;
	wire[`RegBus] cp0_config;
	wire[`RegBus] cp0_prid;
	wire[`RegBus] cp0_index;
	wire[`RegBus] cp0_random;
	wire[`RegBus] cp0_entrylo0;
	wire[`RegBus] cp0_entrylo1;
	wire[`RegBus] cp0_pagemask;
	wire[`RegBus] cp0_badvaddr;
	wire[`RegBus] cp0_entryhi;
	wire[`RegBus] cp0_ebase;




	//pc_reg����
	pc_reg pc_reg0(
		.clk(clk),
		.rst_n(rst_n),
		.stall(stall),

		.flush(flush),
		.new_pc(new_pc),

		.branch_flag_i(id_branch_flag_o),
		.branch_target_address_i(branch_target_address),

		.next_inst_phy_addr_i(pc_next_inst_phy_addr),
		.next_inst_tlb_r_miss_exception_i(pc_next_inst_tlb_r_miss_exception), 

		.pc(pc),
		.inst_phy_addr_o(if_inst_phy_addr_i),
		.ce(if_inst_ce_i),

		.next_inst_vir_addr_o(pc_next_inst_vir_addr),
		.pc_ce_o(pc_ce_o),
		.excepttype_o(if_excepttype_i)
	);


	assign pc_o = pc;

	assign if_excepttype_o = if_excepttype_i;
	assign if_inst_ce_o = if_inst_ce_i;

	//IF/IDģ������
	if_id if_id0(
		.clk(clk),
		.rst_n(rst_n),
		.stall(stall),
		.flush(flush),
		.if_pc(pc),
		.if_inst(if_inst_o),
		.if_inst_ce(if_inst_ce_o),
		.if_excepttype(if_excepttype_o),
		.id_pc(id_pc_i),
		.id_inst(id_inst_i),
		.id_excepttype(id_excepttype_i),
		.id_not_stall(id_not_stall_i)
	);
	
	//����׶�IDģ��
	id id0(
		.rst_n(rst_n),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),

		.excepttype_i(id_excepttype_i),
		.not_stall_i(id_not_stall_i),

		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),
		
		//����ִ�н׶ε�ָ���һЩ��Ϣ�����ڽ��load���
		.ex_aluop_i(ex_aluop_o),

		// ������·
		// ����ִ�н׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
		.ex_wreg_i(ex_wreg_o),
		.ex_wdata_i(ex_wdata_o),
		.ex_wd_i(ex_wd_o),

		// ���ڷô�׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
		.mem_wreg_i(mem_wreg_o),
		.mem_wdata_i(mem_wdata_o),
		.mem_wd_i(mem_wd_o),

		// �����һ��ָ����ת��ָ���ô��һ��ָ���������ʱ�� is_in_delayslot Ϊ true
		.is_in_delayslot_i(is_in_delayslot_i),
		.step_i(step_i),
		
		//�͵�regfile����Ϣ
		.reg1_read_o(reg1_read),
		.reg2_read_o(reg2_read),
		.reg1_addr_o(reg1_addr),
		.reg2_addr_o(reg2_addr), 

		//�͵�ID/EXģ�����Ϣ
		.aluop_o(id_aluop_o),
		.alusel_o(id_alusel_o),
		.reg1_o(id_reg1_o),
		.reg2_o(id_reg2_o),
		.imm_o(id_imm_o),
		.wd_o(id_wd_o),
		.wreg_o(id_wreg_o),
		.inst_o(id_inst_o),

		// ��һ��ָ���Ƿ����ӳٲ���
		.next_inst_in_delayslot_o(next_inst_in_delayslot_o),
		.step_o(step_o),

		// �Ƿ���Ҫ��ת���Լ���ת��ַ�����ӵ�ַ
		.branch_flag_o(id_branch_flag_o),
		.branch_target_address_o(branch_target_address),
		.link_addr_o(id_link_address_o),
		
		// ����ָ���Ƿ����ӳٲ���
		.is_in_delayslot_o(id_is_in_delayslot_o),

		.excepttype_o(id_excepttype_o),
		.current_inst_address_o(id_current_inst_address_o),
		.not_stall_o(id_not_stall_o),
		
		// ��ͣ����
		.stallreq(stallreq_from_id)
	);

	//ͨ�üĴ���Regfile����
	regfile regfile1(
		.clk (clk),
		.rst_n (rst_n),
		.we	(wb_wreg_i),
		.waddr (wb_wd_i),
		.wdata (wb_wdata_i),
		.re1 (reg1_read),
		.raddr1 (reg1_addr),
		.rdata1 (reg1_data),
		.re2 (reg2_read),
		.raddr2 (reg2_addr),
		.rdata2 (reg2_data)
	);

	//ID/EXģ��
	id_ex id_ex0(
		.clk(clk),
		.rst_n(rst_n),

		.stall(stall),
		.flush(flush),
		
		//������׶�IDģ�鴫�ݵ���Ϣ
		.id_aluop(id_aluop_o),
		.id_alusel(id_alusel_o),
		.id_reg1(id_reg1_o),
		.id_reg2(id_reg2_o),
		.id_imm(id_imm_o),
		.id_wd(id_wd_o),
		.id_wreg(id_wreg_o),
		.id_link_address(id_link_address_o),
		.id_is_in_delayslot(id_is_in_delayslot_o),
		.id_inst(id_inst_o),
		.id_excepttype(id_excepttype_o),
		.id_current_inst_address(id_current_inst_address_o),
		.id_not_stall(id_not_stall_o),

		// ����׶�Ҫ����ȥ����Ϣ
		.next_inst_in_delayslot_i(next_inst_in_delayslot_o),
		.step_i(step_o),
		
		//���ݵ�ִ�н׶�EXģ�����Ϣ
		.ex_aluop(ex_aluop_i),
		.ex_alusel(ex_alusel_i),
		.ex_reg1(ex_reg1_i),
		.ex_reg2(ex_reg2_i),
		.ex_imm(ex_imm_i),
		.ex_wd(ex_wd_i),
		.ex_wreg(ex_wreg_i),
		.ex_link_address(ex_link_address_i),
		.ex_is_in_delayslot(ex_is_in_delayslot_i),
		.ex_inst(ex_inst_i),
		.ex_excepttype(ex_excepttype_i),
		.ex_current_inst_address(ex_current_inst_address_i),
		.ex_not_stall(ex_not_stall_i),

		// ���� id �׶�
		.is_in_delayslot_o(is_in_delayslot_i),
		.step_o(step_i)
	);


	//EXģ��
	ex ex0(
		.rst_n(rst_n),
	
		//�͵�ִ�н׶�EXģ�����Ϣ
		.aluop_i(ex_aluop_i),
		.alusel_i(ex_alusel_i),
		.reg1_i(ex_reg1_i),
		.reg2_i(ex_reg2_i),
		.imm_i(ex_imm_i),
		.wd_i(ex_wd_i),
		.wreg_i(ex_wreg_i),
		
		.hi_i(hi),
		.lo_i(lo),

		.inst_i(ex_inst_i),

		//��д�׶ε�ָ���Ƿ�ҪдHI��LO�����ڼ��HI��LO���������
		.wb_hi_i(wb_hi_i),
		.wb_lo_i(wb_lo_i),
		.wb_whilo_i(wb_whilo_i),

		//�ô�׶ε�ָ���Ƿ�ҪдHI��LO�����ڼ��HI��LO���������
		.mem_hi_i(mem_hi_o),
		.mem_lo_i(mem_lo_o),
		.mem_whilo_i(mem_whilo_o),

		.hilo_temp_i(hilo_temp_i),
		.cnt_i(cnt_i),
		.div_started_i(div_started_i),

		// ����ģ����Ľ��
		.div_result_i(div_result),
		.div_ready_i(div_ready), 
		
		// �Ƿ����ӳٲ��С��Լ�link address
		.link_address_i(ex_link_address_i),
		.is_in_delayslot_i(ex_is_in_delayslot_i),

		// �¼������쳣����
		.excepttype_i(ex_excepttype_i),
		.current_inst_address_i(ex_current_inst_address_i),
		.not_stall_i(ex_not_stall_i),

		//�ô�׶ε�ָ���Ƿ�ҪдCP0����������������
		.mem_cp0_reg_we(mem_cp0_reg_we_o),
		.mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
		.mem_cp0_reg_data(mem_cp0_reg_data_o),
	
		//��д�׶ε�ָ���Ƿ�ҪдCP0����������������
		.wb_cp0_reg_we(wb_cp0_reg_we_i),
		.wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
		.wb_cp0_reg_data(wb_cp0_reg_data_i),

		.mem_phy_addr_i(ex_mem_phy_addr_i),
		.data_tlb_r_miss_exception_i(ex_data_tlb_r_miss_exception_i),
		.data_tlb_w_miss_exception_i(ex_data_tlb_w_miss_exception_i),
		.data_tlb_mod_exception_i(ex_data_tlb_mod_exception_i),

		.cp0_reg_data_i(cp0_data_o),
		.cp0_reg_read_addr_o(cp0_raddr_i),
		
		//����һ��ˮ�����ݣ�����дCP0�еļĴ���
		.cp0_reg_we_o(ex_cp0_reg_we_o),
		.cp0_reg_write_addr_o(ex_cp0_reg_write_addr_o),
		.cp0_reg_data_o(ex_cp0_reg_data_o),
		.cp0_write_tlb_index_o(ex_cp0_write_tlb_index_o),
		.cp0_write_tlb_random_o(ex_cp0_write_tlb_random_o),

		//EXģ��������EX/MEMģ����Ϣ
		.wd_o(ex_wd_o),
		.wreg_o(ex_wreg_o),
		.wdata_o(ex_wdata_o),
		.hi_o(ex_hi_o),
		.lo_o(ex_lo_o),
		.whilo_o(ex_whilo_o),

		.hilo_temp_o(hilo_temp_o),
		.cnt_o(cnt_o),
		.div_started_o(div_started_o),

		// ���͸�������������
		.div_opdata1_o(div_opdata1),
		.div_opdata2_o(div_opdata2),
		.div_start_o(div_start),
		.signed_div_o(signed_div),


		//���������ļ��������Ϊ���ء��洢ָ��׼����
		.aluop_o(ex_aluop_o),
		.mem_addr_o(ex_mem_addr_o),
		.mem_we_o(ex_mem_we_o),
		.mem_ce_o(ex_mem_ce_o),
		.reg2_o(ex_reg2_o),

		.excepttype_o(ex_excepttype_o),
		.is_in_delayslot_o(ex_is_in_delayslot_o),
		.current_inst_address_o(ex_current_inst_address_o),
		.not_stall_o(ex_not_stall_o),

		.mem_phy_addr_o(ex_mem_phy_addr_o),
		.data_tlb_r_miss_exception_o(ex_data_tlb_r_miss_exception_o),
		.data_tlb_w_miss_exception_o(ex_data_tlb_w_miss_exception_o),
		.data_tlb_mod_exception_o(ex_data_tlb_mod_exception_o),

		.stallreq(stallreq_from_ex)
	);

	//EX/MEMģ��
	ex_mem ex_mem0(
		.clk(clk),
		.rst_n(rst_n),

		.stall(stall),
		.flush(flush),

		//����ִ�н׶�EXģ�����Ϣ	
		.ex_wd(ex_wd_o),
		.ex_wreg(ex_wreg_o),
		.ex_wdata(ex_wdata_o),
		.ex_hi(ex_hi_o),
		.ex_lo(ex_lo_o),
		.ex_whilo(ex_whilo_o),
		.ex_aluop(ex_aluop_o),
		.ex_mem_addr(ex_mem_addr_o),
		.ex_reg2(ex_reg2_o),
		.ex_cp0_reg_we(ex_cp0_reg_we_o),
		.ex_cp0_reg_write_addr(ex_cp0_reg_write_addr_o),
		.ex_cp0_reg_data(ex_cp0_reg_data_o),
		.ex_cp0_write_tlb_index(ex_cp0_write_tlb_index_o),
		.ex_cp0_write_tlb_random(ex_cp0_write_tlb_random_o),
		.ex_excepttype(ex_excepttype_o),
		.ex_is_in_delayslot(ex_is_in_delayslot_o),
		.ex_current_inst_address(ex_current_inst_address_o),
		.ex_not_stall(ex_not_stall_o),
		.ex_mem_phy_addr(ex_mem_phy_addr_o),
		.ex_data_tlb_r_miss_exception(ex_data_tlb_r_miss_exception_o),
		.ex_data_tlb_w_miss_exception(ex_data_tlb_w_miss_exception_o),
		.ex_data_tlb_mod_exception(ex_data_tlb_mod_exception_o),



		.hilo_i(hilo_temp_o),	
		.cnt_i(cnt_o),
		.div_started_i(div_started_o),


		//�͵��ô�׶�MEMģ�����Ϣ
		.mem_wd(mem_wd_i),
		.mem_wreg(mem_wreg_i),
		.mem_wdata(mem_wdata_i),
		.mem_hi(mem_hi_i),
		.mem_lo(mem_lo_i),
		.mem_whilo(mem_whilo_i),
		.mem_aluop(mem_aluop_i),
		.mem_mem_addr(mem_mem_addr_i),
		.mem_reg2(mem_reg2_i),
		.mem_cp0_reg_we(mem_cp0_reg_we_i),
		.mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_i),
		.mem_cp0_reg_data(mem_cp0_reg_data_i),
		.mem_cp0_write_tlb_index(mem_cp0_write_tlb_index_i),
		.mem_cp0_write_tlb_random(mem_cp0_write_tlb_random_i),

		.mem_excepttype(mem_excepttype_i),
		.mem_is_in_delayslot(mem_is_in_delayslot_i),
		.mem_current_inst_address(mem_current_inst_address_i),
		.mem_not_stall(mem_not_stall_i),

		.mem_mem_phy_addr(mem_mem_phy_addr_i),
		.mem_data_tlb_r_miss_exception(mem_data_tlb_r_miss_exception_i),
		.mem_data_tlb_w_miss_exception(mem_data_tlb_w_miss_exception_i),
		.mem_data_tlb_mod_exception(mem_data_tlb_mod_exception_i),

		.hilo_o(hilo_temp_i),
		.cnt_o(cnt_i),
		.div_started_o(div_started_i)
	);

	// RAM ������ַ
	wire[`RegBus] ram_phy_addr_o;

	//�������ݴ洢�� data_ram ̓�M��ַ
	wire[`RegBus] ram_data_i;
	wire[`RegBus] ram_addr_o;
	wire[`RegBus] ram_data_o;
	wire ram_we_o;
	wire[`RegSel] ram_sel_o;
	wire ram_ce_o;

	//MEMģ������
	mem mem0(
		.rst_n(rst_n),

		.mem_phy_addr_i(mem_mem_phy_addr_i),
		.data_tlb_r_miss_exception_i(mem_data_tlb_r_miss_exception_i),
		.data_tlb_w_miss_exception_i(mem_data_tlb_w_miss_exception_i),
		.data_tlb_mod_exception_i(mem_data_tlb_mod_exception_i),
		.tlb_machine_check_exception_i(mem_tlb_machine_check_exception_i),
	
		//����EX/MEMģ�����Ϣ	
		.wd_i(mem_wd_i),
		.wreg_i(mem_wreg_i),
		.wdata_i(mem_wdata_i),
		.hi_i(mem_hi_i),
		.lo_i(mem_lo_i),
		.whilo_i(mem_whilo_i),
		.aluop_i(mem_aluop_i),
		.mem_addr_i(mem_mem_addr_i),
		.reg2_i(mem_reg2_i),
		.cp0_reg_we_i(mem_cp0_reg_we_i),
		.cp0_reg_write_addr_i(mem_cp0_reg_write_addr_i),
		.cp0_reg_data_i(mem_cp0_reg_data_i),
		.cp0_write_tlb_index_i(mem_cp0_write_tlb_index_i),
		.cp0_write_tlb_random_i(mem_cp0_write_tlb_random_i),
		.excepttype_i(mem_excepttype_i),
		.is_in_delayslot_i(mem_is_in_delayslot_i),
		.current_inst_address_i(mem_current_inst_address_i),
		.not_stall_i(mem_not_stall_i),
		
		// cp0 ��ؼĴ���
		.cp0_status_i(cp0_status),
		.cp0_cause_i(cp0_cause),
		.cp0_epc_i(cp0_epc),
		
		//��д�׶ε�ָ���Ƿ�ҪдCP0����������������
		.wb_cp0_reg_we(wb_cp0_reg_we_i),
		.wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
		.wb_cp0_reg_data(wb_cp0_reg_data_i),

		//����memory����Ϣ
		.mem_data_i(ram_data_i),

		//LLbit_i��LLbit�Ĵ�����ֵ
		//����һ��������ֵ����д�׶ο���ҪдLLbit�����Ի�Ҫ��һ���ж�
		// ��д�׶����Ҫдllbit, �� llbit_o �����ϱ仯����ǰһ���ڴ���ȥ������������������·������
		.LLbit_i(LLbit_o),

		//�͵�MEM/WBģ�����Ϣ
		.wd_o(mem_wd_o),
		.wreg_o(mem_wreg_o),
		.wdata_o(mem_wdata_o),
		.hi_o(mem_hi_o),
		.lo_o(mem_lo_o),
		.whilo_o(mem_whilo_o),
		// LLbit �����
		.LLbit_we_o(mem_LLbit_we_o),
		.LLbit_value_o(mem_LLbit_value_o),

		.cp0_reg_we_o(mem_cp0_reg_we_o),
		.cp0_reg_write_addr_o(mem_cp0_reg_write_addr_o),
		.cp0_reg_data_o(mem_cp0_reg_data_o),
		.cp0_write_tlb_index_o(mem_cp0_write_tlb_index_o),
		.cp0_write_tlb_random_o(mem_cp0_write_tlb_random_o),
		
		// ����ȷ�ϵ��쳣����
		.excepttype_o(mem_excepttype_o),
		.is_in_delayslot_o(mem_is_in_delayslot_o),
		// ��ǰָ��ĵ�ַ
		.current_inst_address_o(mem_current_inst_address_o),
		.current_data_address_o(mem_current_data_address_o),

		// ���µ� EPC ֵ
		.cp0_epc_o(),

		//�͵�memory����Ϣ
		.mem_addr_o(ram_addr_o),
		.mem_phy_addr_o(ram_phy_addr_o),
		.mem_we_o(ram_we_o),
		.mem_sel_o(ram_sel_o),
		.mem_data_o(ram_data_o),
		.mem_ce_o(ram_ce_o)
	);

	//MEM/WBģ��
	mem_wb mem_wb0(
		.clk(clk),
		.rst_n(rst_n),
		.stall(stall),
		.flush(flush),

		//���Էô�׶�MEMģ�����Ϣ	
		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),
		.mem_hi(mem_hi_o),
		.mem_lo(mem_lo_o),
		.mem_whilo(mem_whilo_o),
		.mem_LLbit_we(mem_LLbit_we_o),
		.mem_LLbit_value(mem_LLbit_value_o),
		.mem_cp0_reg_we(mem_cp0_reg_we_o),
		.mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
		.mem_cp0_reg_data(mem_cp0_reg_data_o),
		.mem_cp0_write_tlb_index(mem_cp0_write_tlb_index_o),
		.mem_cp0_write_tlb_random(mem_cp0_write_tlb_random_o),
	
		//�͵���д�׶ε���Ϣ
		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),
		.wb_wdata(wb_wdata_i),
		.wb_hi(wb_hi_i),
		.wb_lo(wb_lo_i),
		.wb_whilo(wb_whilo_i),
		.wb_LLbit_we(wb_LLbit_we_i),
		.wb_LLbit_value(wb_LLbit_value_i),
		.wb_cp0_reg_we(wb_cp0_reg_we_i),
		.wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
		.wb_cp0_reg_data(wb_cp0_reg_data_i),
		.wb_cp0_write_tlb_index(wb_cp0_write_tlb_index_i),
		.wb_cp0_write_tlb_random(wb_cp0_write_tlb_random_i)
	);

	//HILO�Ĵ�������
	hilo_reg hilo_reg0(
		.clk (clk),
		.rst_n (rst_n),
		
		.we(wb_whilo_i),
		.hi_i(wb_hi_i),
		.lo_i(wb_lo_i),
	
		.hi_o(hi),
		.lo_o(lo)
	);

	ctrl ctrl0(
		.rst_n(rst_n),

		.excepttype_i(mem_excepttype_o),

		//����ȡַ�׶ε���ͣ����
		.stallreq_from_if(stallreq_from_if),
		
		//����ִ���������ͣ����
		.stallreq_from_id(stallreq_from_id),
		
		//����ִ�н׶ε���ͣ����
		.stallreq_from_ex(stallreq_from_ex),
		
		//���Էô�׶ε���ͣ����
		.stallreq_from_mem(stallreq_from_mem),

		//���Ի�д�׶ε���ͣ����
		.stallreq_from_wb(`NoStop),

		.flush(flush),
		.stall(stall)
	);

	/*
	div div0(
		.clk(clk),
		.rst_n(rst_n),
	
		.signed_div_i(signed_div),
		.opdata1_i(div_opdata1),
		.opdata2_i(div_opdata2),
		.start_i(div_start),
		.annul_i(flush),
	
		.result_o(div_result),
		.ready_o(div_ready)
	);
	*/

	LLbit_reg LLbit_reg0(
		.clk(clk),
		.rst_n(rst_n),
		.flush(flush),
		
		//д�˿�
		.LLbit_i(wb_LLbit_value_i),
		.we(wb_LLbit_we_i),
		
		//���˿�1
		.LLbit_o(LLbit_o)
	);
	
	cp0_reg cp0_reg0(
		.clk(clk),
		.rst_n(rst_n),
		
		.we_i(wb_cp0_reg_we_i),
		.waddr_i(wb_cp0_reg_write_addr_i),
		.raddr_i(cp0_raddr_i),
		.data_i(wb_cp0_reg_data_i),
		
		.excepttype_i(mem_excepttype_o),
		.int_i(int_i),
		.current_inst_addr_i(mem_current_inst_address_o),
		.current_data_addr_i(mem_current_data_address_o),
		.is_in_delayslot_i(mem_is_in_delayslot_o),
		
		.data_o(cp0_data_o),
		.count_o(cp0_count),
		.compare_o(cp0_compare),
		.status_o(cp0_status),
		.cause_o(cp0_cause),
		.epc_o(cp0_epc),
		.config_o(cp0_config),
		.prid_o(cp0_prid),

		.index_o(cp0_index),
		.random_o(cp0_random),
		.entrylo0_o(cp0_entrylo0),
		.entrylo1_o(cp0_entrylo1),
		.pagemask_o(cp0_pagemask),
		.badvaddr_o(cp0_badvaddr),
		.entryhi_o(cp0_entryhi),
		.ebase_o(cp0_ebase),
		
		.exception_new_pc_o(new_pc),

		.timer_int_o(timer_int_o)
	);

	mmu mmu0(
		.clk(clk),
		.rst_n(rst_n),

		.inst_ce_i(pc_ce_o),
		.inst_vir_addr_i(pc_next_inst_vir_addr),
		.inst_phy_addr_o(pc_next_inst_phy_addr),
		.inst_tlb_r_miss_exception_o(pc_next_inst_tlb_r_miss_exception),

		.data_ce_i(ex_mem_ce_o),
		.data_we_i(ex_mem_we_o),
		.data_vir_addr_i(ex_mem_addr_o),
		.data_phy_addr_o(ex_mem_phy_addr_i),
		.data_tlb_r_miss_exception_o(ex_data_tlb_r_miss_exception_i),
		.data_tlb_w_miss_exception_o(ex_data_tlb_w_miss_exception_i),
		.data_tlb_mod_exception_o(ex_data_tlb_mod_exception_i),

		.cp0_write_tlb_index_i(wb_cp0_write_tlb_index_i),
		.cp0_write_tlb_random_i(wb_cp0_write_tlb_random_i),

		.cp0_index_i(cp0_index),
		.cp0_random_i(cp0_random),
		.cp0_entrylo0_i(cp0_entrylo0),
		.cp0_entrylo1_i(cp0_entrylo1),
		.cp0_entryhi_i(cp0_entryhi),
		.cp0_pagemask_i(cp0_pagemask),
		
		.tlb_machine_check_exception_o(mem_tlb_machine_check_exception_i)
	);


	wishbone_bus_if #(.delay(1), .cyc_len_log_2(1)) dwishbone_bus_if(
		.cpu_clk(clk),
		.wishbone_clk(wishbone_clk),

		.rst_n(rst_n),
	
		// ctrl
		.stall_i(stall),
		.stall_this_i(stall[4]),
		.flush_i(flush),
	
		// CPU
		.cpu_ce_i(ram_ce_o & (~(|mem_excepttype_o))),
		.cpu_data_i(ram_data_o),
		.cpu_addr_i(ram_phy_addr_o),
		.cpu_we_i(ram_we_o),
		.cpu_sel_i(ram_sel_o),
		.cpu_data_o(ram_data_i),


		// Wishbone 
		.wishbone_data_i(dwishbone_data_i),
		.wishbone_ack_i(dwishbone_ack_i),
		.wishbone_addr_o(dwishbone_addr_o),
		.wishbone_data_o(dwishbone_data_o),
		.wishbone_we_o(dwishbone_we_o),
		.wishbone_sel_o(dwishbone_sel_o),
		.wishbone_stb_o(dwishbone_stb_o),
		.wishbone_cyc_o(dwishbone_cyc_o),

		.stallreq(stallreq_from_mem)	       
	
	);
	
	wire[31:0] useless;

	wishbone_bus_if #(.delay(0)) iwishbone_bus_if(
		.cpu_clk(clk),
		.wishbone_clk(wishbone_clk),

		.rst_n(rst_n),
	
		// ctrl
		.stall_i(stall),
		.stall_this_i(stall[1]),
		.flush_i(flush),
	
		// CPU
		.cpu_ce_i(if_inst_ce_o & (~(|if_excepttype_i))),
`ifdef RV32
		.cpu_data_i(`ZeroWord),
`else
		.cpu_data_i({`ZeroWord, `ZeroWord}),
`endif
		.cpu_addr_i(if_inst_phy_addr_i),
		.cpu_we_i(`WriteDisable),
`ifdef RV32
		.cpu_sel_i(4'b1111),
		.cpu_data_o(if_inst_o),
`else
		.cpu_sel_i(8'b0000_1111),
		.cpu_data_o({useless, if_inst_o}),
`endif

		// Wishbone 
		.wishbone_data_i(iwishbone_data_i),
		.wishbone_ack_i(iwishbone_ack_i),
		.wishbone_addr_o(iwishbone_addr_o),
		.wishbone_data_o(iwishbone_data_o),
		.wishbone_we_o(iwishbone_we_o),
		.wishbone_sel_o(iwishbone_sel_o),
		.wishbone_stb_o(iwishbone_stb_o),
		.wishbone_cyc_o(iwishbone_cyc_o),

		.stallreq(stallreq_from_if)
	);
endmodule