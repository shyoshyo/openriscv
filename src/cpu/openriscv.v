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
// Module:  openriscv
// File:    openriscv.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: OpenRISCV处理器的顶层文件
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module openriscv(

	input wire clk,
	input wire wishbone_clk,
	input wire rst_n,
	
	input wire timer_int_i,
	input wire software_int_i,
	input wire external_int_i,
	
	// inst wishbone
	input wire[`WishboneDataBus]   iwishbone_data_i,
	input wire                     iwishbone_ack_i,
	output wire[`PhyAddrBus]       iwishbone_addr_o,
	output wire[`WishboneDataBus]  iwishbone_data_o,
	output wire                    iwishbone_we_o,
	output wire[`WishboneSelBus]   iwishbone_sel_o,
	output wire                    iwishbone_stb_o,
	output wire                    iwishbone_cyc_o, 
	
	// data wishbone
	input wire[`WishboneDataBus]   dwishbone_data_i,
	input wire                     dwishbone_ack_i,
	output wire[`PhyAddrBus]       dwishbone_addr_o,
	output wire[`WishboneDataBus]  dwishbone_data_o,
	output wire                    dwishbone_we_o,
	output wire[`WishboneSelBus]   dwishbone_sel_o,
	output wire                    dwishbone_stb_o,
	output wire                    dwishbone_cyc_o,
	
	output wire[`RegBus] pc_o
);
	// 下一条需要访问 inst 存储器的地址
	wire [`PhyAddrBus]pc_next_inst_phy_addr;
	wire [`RegBus]pc_next_inst_vir_addr;
	wire pc_next_inst_tlb_exception;
	wire pc_ce_o;


	// pc reg 连接 IF 阶段的输入
	// inst 存储器 使能
	wire[`RegBus] pc;
	wire if_inst_ce_i;
	wire [`PhyAddrBus]if_inst_phy_addr_i;
	wire [`ExceptionTypeBus]if_excepttype_i;

	//连接译码阶段 IF 模块的输出与 IF/ID 模块的输入
	// 从 inst 存储器获得的数据
	wire[`InstBus] if_inst_o;
	wire if_inst_ce_o;
	wire [`ExceptionTypeBus]if_excepttype_o;

	//连接译码阶段ID模块的输入
	wire[`RegBus] id_pc_i;
	wire[`InstBus] id_inst_i;
	wire[`ExceptionTypeBus] id_excepttype_i;
	wire id_not_stall_i;
	
	//连接译码阶段ID模块的输出与ID/EX模块的输入
	wire[`AluOpBus] id_aluop_o;
	wire[`AluSelBus] id_alusel_o;
	wire[`RegBus] id_reg1_o;
	wire[`RegBus] id_reg2_o;
	wire[`RegBus] id_mem_addr_o;
	wire id_wreg_o;
	wire[`RegAddrBus] id_wd_o;
	wire id_is_in_delayslot_o;
	wire[`RegBus] id_link_address_o;
	wire[`InstBus] id_inst_o;
	wire[`ExceptionTypeBus] id_excepttype_o;
	wire[`RegBus] id_current_inst_address_o;
	wire id_not_stall_o;
 	wire id_csr_reg_re_o;
	wire[`CSRWriteTypeBus] id_csr_reg_we_o;
	wire[`CSRAddrBus] id_csr_reg_addr_o;
	wire[`RegBus] id_csr_reg_data_o;
	
	//连接ID/EX模块的输出与执行阶段EX模块的输入
	wire[`AluOpBus] ex_aluop_i;
	wire[`AluSelBus] ex_alusel_i;
	wire[`RegBus] ex_reg1_i;
	wire[`RegBus] ex_reg2_i;
	wire[`RegBus] ex_mem_addr_i;
	wire ex_wreg_i;
	wire[`RegAddrBus] ex_wd_i;
	wire ex_is_in_delayslot_i;	
	wire[`RegBus] ex_link_address_i;
	wire[`InstBus] ex_inst_i;
	wire[`ExceptionTypeBus] ex_excepttype_i;	
	wire[`RegBus] ex_current_inst_address_i;
	wire ex_not_stall_i;
	wire[`CSRWriteTypeBus] ex_csr_reg_we_i;
	wire[`CSRAddrBus] ex_csr_reg_addr_i;
	wire[`RegBus] ex_csr_reg_data_i;

	wire [`PhyAddrBus]ex_mem_phy_addr_i;
	wire ex_data_tlb_exception_i;

	//连接执行阶段EX模块的输出与EX/MEM模块的输入
	wire ex_wreg_o;
	wire[`RegAddrBus] ex_wd_o;
	wire[`RegBus] ex_wdata_o;
	wire[`AluOpBus] ex_aluop_o;
	wire[`RegBus] ex_mem_addr_o;
	wire ex_mem_we_o;
	wire ex_mem_ce_o;
	wire[`RegBus] ex_reg1_o;
	wire[`RegBus] ex_reg2_o;
	wire[`CSRWriteTypeBus] ex_csr_reg_we_o;
	wire[`CSRAddrBus] ex_csr_reg_addr_o;
	wire[`RegBus] ex_csr_reg_data_o;
	wire[`ExceptionTypeBus] ex_excepttype_o;
	wire[`RegBus] ex_current_inst_address_o;
	wire ex_not_stall_o;
	wire ex_is_in_delayslot_o;

	wire[`PhyAddrBus] ex_mem_phy_addr_o;
	wire ex_data_tlb_r_exception_o;
	wire ex_data_tlb_w_exception_o;

	//连接EX/MEM模块的输出与访存阶段MEM模块的输入
	wire mem_wreg_i;
	wire[`RegAddrBus] mem_wd_i;
	wire[`RegBus] mem_wdata_i;
	wire[`AluOpBus] mem_aluop_i;
	wire[`RegBus] mem_mem_addr_i;
	wire[`RegBus] mem_reg1_i;
	wire[`RegBus] mem_reg2_i;
	wire stallreq_from_dwishbone;
	wire [1:0] mem_cnt_i;
	wire [`RegBus] mem_original_data_i;
	wire[`CSRWriteTypeBus] mem_csr_reg_we_i;
	wire[`CSRAddrBus] mem_csr_reg_addr_i;
	wire[`RegBus] mem_csr_reg_data_i;
	wire[`ExceptionTypeBus] mem_excepttype_i;
	wire mem_is_in_delayslot_i;
	wire[`RegBus] mem_current_inst_address_i;
	wire mem_not_stall_i;
	wire [`PhyAddrBus]mem_mem_phy_addr_i;
	wire mem_data_tlb_r_exception_i;
	wire mem_data_tlb_w_exception_i;

	//连接访存阶段MEM模块的输出与MEM/WB模块的输入
	wire mem_wreg_o;
	wire[`RegAddrBus] mem_wd_o;
	wire[`RegBus] mem_wdata_o;
	wire mem_LLbit_value_o;
	wire [`PhyAddrBus]mem_LLbit_addr_o;
	wire mem_LLbit_we_o;
	wire [1:0] mem_cnt_o;
	wire [`RegBus] mem_original_data_o;
	wire[`CSRWriteTypeBus] mem_csr_reg_we_o;
	wire[`CSRAddrBus] mem_csr_reg_addr_o;
	wire[`RegBus] mem_csr_reg_data_o;
	wire[`ExceptionTypeBus] mem_excepttype_o;
	wire mem_is_in_delayslot_o;
	wire[`RegBus] mem_current_inst_address_o;
	wire[`RegBus] mem_current_data_address_o;
	wire mem_not_stall_o;
	
	//连接MEM/WB模块的输出与回写阶段的输入	
	wire wb_wreg_i;
	wire[`RegAddrBus] wb_wd_i;
	wire[`RegBus] wb_wdata_i;
	wire wb_LLbit_value_i;
	wire [`PhyAddrBus] wb_LLbit_addr_i;
	wire wb_LLbit_we_i;
	wire[`CSRWriteTypeBus] wb_csr_reg_we_i;
	wire[`CSRAddrBus] wb_csr_reg_addr_i;
	wire[`RegBus] wb_csr_reg_data_i;
	wire wb_is_in_delayslot_i;
	wire[`RegBus] wb_current_inst_address_i;
	
	//连接译码阶段ID模块与通用寄存器Regfile模块
	wire reg1_read;
	wire reg2_read;
	wire[`RegBus] reg1_data;
	wire[`RegBus] reg2_data;
	wire[`RegAddrBus] reg1_addr;
	wire[`RegAddrBus] reg2_addr;
	
	// 连接执行阶段与ex_reg模块，用于多周期的MADD、MADDU、MSUB、MSUBU指令
	wire[1:0] cnt_o;
	
	wire[1:0] cnt_i;

	// 连接执行阶段与ex_reg模块，用于多周期的DIV, DIVU指令
	wire div_started_i;
	wire div_started_o;

	// ex 连接 除法器
	wire[`RegBus] div_result_rem;
	wire[`RegBus] div_result_div;
	wire div_ready;
	wire[`RegBus] div_opdata1;
	wire[`RegBus] div_opdata2;
	wire div_start;
	wire div_annul;
	wire signed_div;

	// id 到自身、pc 的输出
	wire is_in_delayslot_i;
	wire is_in_delayslot_o;
	wire next_inst_in_delayslot_o;
	wire step_i;
	wire step_o;
	wire id_branch_flag_o;
	wire[`RegBus] branch_target_address;

	wire[5:0] stall;
	wire flush;
	wire stallreq_from_if;
	wire stallreq_from_id;
	wire stallreq_from_ex;
	wire stallreq_from_mem;

	wire LLbit_o;
	wire [`PhyAddrBus]LLbit_addr_o;

	wire[`RegBus] csr_data_o;
	wire csr_protect_o;
	wire flushreq_from_csr;
	wire[1:0] prv;
	wire[`RegBus] exception_new_pc;


	//pc_reg例化
	pc_reg pc_reg0(
		.clk(clk),
		.rst_n(rst_n),
		.stall(stall),

		.flush(flush),
		.exception_new_pc(exception_new_pc),

		.branch_flag_i(id_branch_flag_o),
		.branch_target_address_i(branch_target_address),

		.next_inst_phy_addr_i(pc_next_inst_phy_addr),
		.next_inst_tlb_exception_i(pc_next_inst_tlb_exception), 

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

	//IF/ID模块例化
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
	
	//译码阶段ID模块
	id id0(
		.rst_n(rst_n),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),

		.excepttype_i(id_excepttype_i),
		.not_stall_i(id_not_stall_i),

		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),
		
		//处于执行阶段的指令的一些信息，用于解决load相关
		.ex_aluop_i(ex_aluop_o),

		// 数据旁路
		// 处于执行阶段的指令要写入的目的寄存器信息
		.ex_wreg_i(ex_wreg_o),
		.ex_wdata_i(ex_wdata_o),
		.ex_wd_i(ex_wd_o),

		// 处于访存阶段的指令要写入的目的寄存器信息
		.mem_wreg_i(mem_wreg_o),
		.mem_wdata_i(mem_wdata_o),
		.mem_wd_i(mem_wd_o),

		.ex_csr_reg_we_i(ex_csr_reg_we_o),
		.mem_csr_reg_we_i(mem_csr_reg_we_o),
		.wb_csr_reg_we_i(wb_csr_reg_we_i),

		.ex_not_stall_i(ex_not_stall_i),
		.mem_not_stall_i(mem_not_stall_i),

		// 如果上一条指令是转移指令，那么下一条指令在译码的时候 is_in_delayslot 为 true
		.is_in_delayslot_i(is_in_delayslot_i),
		.step_i(step_i),
		
		.prv_i(prv),
		.csr_reg_data_i(csr_data_o),
		.csr_protect_i(csr_protect_o),

		//送到regfile的信息
		.reg1_read_o(reg1_read),
		.reg2_read_o(reg2_read),
		.reg1_addr_o(reg1_addr),
		.reg2_addr_o(reg2_addr), 

		//送到ID/EX模块的信息
		.aluop_o(id_aluop_o),
		.alusel_o(id_alusel_o),
		.reg1_o(id_reg1_o),
		.reg2_o(id_reg2_o),
		.mem_addr_o(id_mem_addr_o),
		.wd_o(id_wd_o),
		.wreg_o(id_wreg_o),
		.inst_o(id_inst_o),

		// 下一条指令是否在延迟槽中
		.next_inst_in_delayslot_o(next_inst_in_delayslot_o),
		.step_o(step_o),

		// 是否需要跳转，以及跳转地址，链接地址
		.branch_flag_o(id_branch_flag_o),
		.branch_target_address_o(branch_target_address),
		.link_addr_o(id_link_address_o),
		
		// 这条指令是否在延迟槽中
		.is_in_delayslot_o(id_is_in_delayslot_o),

		.excepttype_o(id_excepttype_o),
		.current_inst_address_o(id_current_inst_address_o),
		.not_stall_o(id_not_stall_o),
		.csr_reg_read_o(id_csr_reg_re_o),
		.csr_reg_we_o(id_csr_reg_we_o),
		.csr_reg_addr_o(id_csr_reg_addr_o),
		.csr_reg_data_o(id_csr_reg_data_o),
		
		// 暂停请求
		.stallreq(stallreq_from_id)
	);

	//通用寄存器Regfile例化
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

	//ID/EX模块
	id_ex id_ex0(
		.clk(clk),
		.rst_n(rst_n),

		.stall(stall),
		.flush(flush),
		
		//从译码阶段ID模块传递的信息
		.id_aluop(id_aluop_o),
		.id_alusel(id_alusel_o),
		.id_reg1(id_reg1_o),
		.id_reg2(id_reg2_o),
		.id_mem_addr(id_mem_addr_o),
		.id_wd(id_wd_o),
		.id_wreg(id_wreg_o),
		.id_link_address(id_link_address_o),
		.id_is_in_delayslot(id_is_in_delayslot_o),
		.id_inst(id_inst_o),
		.id_excepttype(id_excepttype_o),
		.id_current_inst_address(id_current_inst_address_o),
		.id_not_stall(id_not_stall_o),
		.id_csr_reg_we(id_csr_reg_we_o),
		.id_csr_reg_addr(id_csr_reg_addr_o),
		.id_csr_reg_data(id_csr_reg_data_o),

		// 译码阶段要传回去的信息
		.next_inst_in_delayslot_i(next_inst_in_delayslot_o),
		.step_i(step_o),
		
		//传递到执行阶段EX模块的信息
		.ex_aluop(ex_aluop_i),
		.ex_alusel(ex_alusel_i),
		.ex_reg1(ex_reg1_i),
		.ex_reg2(ex_reg2_i),
		.ex_mem_addr(ex_mem_addr_i),
		.ex_wd(ex_wd_i),
		.ex_wreg(ex_wreg_i),
		.ex_link_address(ex_link_address_i),
		.ex_is_in_delayslot(ex_is_in_delayslot_i),
		.ex_inst(ex_inst_i),
		.ex_excepttype(ex_excepttype_i),
		.ex_current_inst_address(ex_current_inst_address_i),
		.ex_not_stall(ex_not_stall_i),
		.ex_csr_reg_we(ex_csr_reg_we_i),
		.ex_csr_reg_addr(ex_csr_reg_addr_i),
		.ex_csr_reg_data(ex_csr_reg_data_i),

		// 传回 id 阶段
		.is_in_delayslot_o(is_in_delayslot_i),
		.step_o(step_i)
	);


	//EX模块
	ex ex0(
		.rst_n(rst_n),
	
		//送到执行阶段EX模块的信息
		.aluop_i(ex_aluop_i),
		.alusel_i(ex_alusel_i),
		.reg1_i(ex_reg1_i),
		.reg2_i(ex_reg2_i),
		.mem_addr_i(ex_mem_addr_i),
		.wd_i(ex_wd_i),
		.wreg_i(ex_wreg_i),

		.inst_i(ex_inst_i),

		.cnt_i(cnt_i),
		.div_started_i(div_started_i),

		// 除法模块给的结果
		.div_result_rem_i(div_result_rem),
		.div_result_div_i(div_result_div),
		.div_ready_i(div_ready), 
		
		// 是否在延迟槽中、以及link address
		.link_address_i(ex_link_address_i),
		.is_in_delayslot_i(ex_is_in_delayslot_i),

		// 新检测出的异常类型
		.excepttype_i(ex_excepttype_i),
		.current_inst_address_i(ex_current_inst_address_i),
		.not_stall_i(ex_not_stall_i),
		.csr_reg_we_i(ex_csr_reg_we_i),
		.csr_reg_addr_i(ex_csr_reg_addr_i),
		.csr_reg_data_i(ex_csr_reg_data_i),
		
		.mem_phy_addr_i(ex_mem_phy_addr_i),
		.data_tlb_exception_i(ex_data_tlb_exception_i),
		
		//向下一流水级传递，用于写csr中的寄存器
		.csr_reg_we_o(ex_csr_reg_we_o),
		.csr_reg_addr_o(ex_csr_reg_addr_o),
		.csr_reg_data_o(ex_csr_reg_data_o),

		//EX模块的输出到EX/MEM模块信息
		.wd_o(ex_wd_o),
		.wreg_o(ex_wreg_o),
		.wdata_o(ex_wdata_o),

		.cnt_o(cnt_o),
		.div_started_o(div_started_o),

		// 发送给除法器的请求
		.div_opdata1_o(div_opdata1),
		.div_opdata2_o(div_opdata2),
		.div_start_o(div_start),
		.signed_div_o(signed_div),


		//下面新增的几个输出是为加载、存储指令准备的
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
		.data_tlb_r_exception_o(ex_data_tlb_r_exception_o),
		.data_tlb_w_exception_o(ex_data_tlb_w_exception_o),

		.stallreq(stallreq_from_ex)
	);

	//EX/MEM模块
	ex_mem ex_mem0(
		.clk(clk),
		.rst_n(rst_n),

		.stall(stall),
		.flush(flush),

		//来自执行阶段EX模块的信息	
		.ex_wd(ex_wd_o),
		.ex_wreg(ex_wreg_o),
		.ex_wdata(ex_wdata_o),
		.ex_aluop(ex_aluop_o),
		.ex_mem_addr(ex_mem_addr_o),
		.ex_reg2(ex_reg2_o),
		.ex_csr_reg_we(ex_csr_reg_we_o),
		.ex_csr_reg_addr(ex_csr_reg_addr_o),
		.ex_csr_reg_data(ex_csr_reg_data_o),
		.ex_excepttype(ex_excepttype_o),
		.ex_is_in_delayslot(ex_is_in_delayslot_o),
		.ex_current_inst_address(ex_current_inst_address_o),
		.ex_not_stall(ex_not_stall_o),
		.ex_mem_phy_addr(ex_mem_phy_addr_o),
		.ex_data_tlb_r_exception(ex_data_tlb_r_exception_o),
		.ex_data_tlb_w_exception(ex_data_tlb_w_exception_o),

		.cnt_i(cnt_o),
		.div_started_i(div_started_o),


		//送到访存阶段MEM模块的信息
		.mem_wd(mem_wd_i),
		.mem_wreg(mem_wreg_i),
		.mem_wdata(mem_wdata_i),
		.mem_aluop(mem_aluop_i),
		.mem_mem_addr(mem_mem_addr_i),
		.mem_reg2(mem_reg2_i),
		.mem_csr_reg_we(mem_csr_reg_we_i),
		.mem_csr_reg_addr(mem_csr_reg_addr_i),
		.mem_csr_reg_data(mem_csr_reg_data_i),

		.mem_excepttype(mem_excepttype_i),
		.mem_is_in_delayslot(mem_is_in_delayslot_i),
		.mem_current_inst_address(mem_current_inst_address_i),
		.mem_not_stall(mem_not_stall_i),

		.mem_mem_phy_addr(mem_mem_phy_addr_i),
		.mem_data_tlb_r_exception(mem_data_tlb_r_exception_i),
		.mem_data_tlb_w_exception(mem_data_tlb_w_exception_i),

		.cnt_o(cnt_i),
		.div_started_o(div_started_i)
	);

	// RAM 物理地址
	wire[`PhyAddrBus] ram_phy_addr_o;

	//连接数据存储器 data_ram 虛擬地址
	wire[`RegBus] ram_data_i;
	wire[`RegBus] ram_addr_o;
	wire[`RegBus] ram_data_o;
	wire ram_we_o;
	wire[`RegSel] ram_sel_o;
	wire ram_ce_o;

	//MEM模块例化
	mem mem0(
		.rst_n(rst_n),

		.mem_phy_addr_i(mem_mem_phy_addr_i),
		.data_tlb_r_exception_i(mem_data_tlb_r_exception_i),
		.data_tlb_w_exception_i(mem_data_tlb_w_exception_i),
	
		//来自EX/MEM模块的信息	
		.wd_i(mem_wd_i),
		.wreg_i(mem_wreg_i),
		.wdata_i(mem_wdata_i),
		.aluop_i(mem_aluop_i),
		.mem_addr_i(mem_mem_addr_i),
		.reg2_i(mem_reg2_i),

		.csr_reg_we_i(`CSRWriteDisable),
		.csr_reg_addr_i(`ZeroWord),
		.csr_reg_data_i(`ZeroWord),

		.excepttype_i(mem_excepttype_i),
		.is_in_delayslot_i(mem_is_in_delayslot_i),
		.current_inst_address_i(mem_current_inst_address_i),
		.not_stall_i(mem_not_stall_i),
		
		//来自memory的信息
		.mem_data_i(ram_data_i),

		//LLbit_i是LLbit寄存器的值
		//但不一定是最新值，回写阶段可能要写LLbit，所以还要进一步判断
		// 回写阶段如果要写llbit, 则 llbit_o 会马上变化，提前一周期传过去，起到了类似于数据旁路的作用
		.LLbit_i(LLbit_o),
		.LLbit_addr_i(LLbit_addr_o),

		.stallreq_from_mem_i(stallreq_from_dwishbone),
		.cnt_i(mem_cnt_i),
		.original_data_i(mem_original_data_i),

		//送到MEM/WB模块的信息
		.wd_o(mem_wd_o),
		.wreg_o(mem_wreg_o),
		.wdata_o(mem_wdata_o),
		// LLbit 的输出
		.LLbit_we_o(mem_LLbit_we_o),
		.LLbit_value_o(mem_LLbit_value_o),
		.LLbit_addr_o(mem_LLbit_addr_o),

		.stallreq(stallreq_from_mem),
		.cnt_o(mem_cnt_o),
		.original_data_o(mem_original_data_o),

		.csr_reg_we_o(mem_csr_reg_we_o),
		.csr_reg_addr_o(mem_csr_reg_addr_o),
		.csr_reg_data_o(mem_csr_reg_data_o),
		
		// 最终确认的异常类型
		.excepttype_o(mem_excepttype_o),
		.is_in_delayslot_o(mem_is_in_delayslot_o),
		// 当前指令的地址
		.current_inst_address_o(mem_current_inst_address_o),
		.current_data_address_o(mem_current_data_address_o),
		.not_stall_o(mem_not_stall_o),

		/*
		// 最新的 EPC 值
		.csr_epc_o(),
		*/
	
		//送到memory的信息
		.mem_addr_o(ram_addr_o),
		.mem_phy_addr_o(ram_phy_addr_o),
		.mem_we_o(ram_we_o),
		.mem_sel_o(ram_sel_o),
		.mem_data_o(ram_data_o),
		.mem_ce_o(ram_ce_o)
	);

	//MEM/WB模块
	mem_wb mem_wb0(
		.clk(clk),
		.rst_n(rst_n),
		.stall(stall),
		.flush(flush),

		//来自访存阶段MEM模块的信息	
		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),
		.mem_LLbit_we(mem_LLbit_we_o),
		.mem_LLbit_addr(mem_LLbit_addr_o),
		.mem_LLbit_value(mem_LLbit_value_o),
		.mem_csr_reg_we(mem_csr_reg_we_o),
		.mem_csr_reg_addr(mem_csr_reg_addr_o),
		.mem_csr_reg_data(mem_csr_reg_data_o),

		.mem_cnt_i(mem_cnt_o),
		.mem_original_data_i(mem_original_data_o),
	
		//送到回写阶段的信息
		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),
		.wb_wdata(wb_wdata_i),
		.wb_LLbit_we(wb_LLbit_we_i),
		.wb_LLbit_addr(wb_LLbit_addr_i),
		.wb_LLbit_value(wb_LLbit_value_i),
		.wb_csr_reg_we(wb_csr_reg_we_i),
		.wb_csr_reg_addr(wb_csr_reg_addr_i),
		.wb_csr_reg_data(wb_csr_reg_data_i),

		// send back to mem
		.mem_cnt_o(mem_cnt_i),
		.mem_original_data_o(mem_original_data_i)
	);

	ctrl ctrl0(
		.rst_n(rst_n),

		.flushreq_from_csr(flushreq_from_csr),

		//来自取址阶段的暂停请求
		.stallreq_from_if(stallreq_from_if),
		
		//来自执行译码的暂停请求
		.stallreq_from_id(stallreq_from_id),
		
		//来自执行阶段的暂停请求
		.stallreq_from_ex(stallreq_from_ex),
		
		//来自访存阶段的暂停请求
		.stallreq_from_mem(stallreq_from_mem),

		//来自回写阶段的暂停请求
		.stallreq_from_wb(`NoStop),

		.flush(flush),
		.stall(stall)
	);

	
	div div0(
		.clk(clk),
		.rst_n(rst_n),
	
		.signed_div_i(signed_div),
		.opdata1_i(div_opdata1),
		.opdata2_i(div_opdata2),
		.start_i(div_start),
		.annul_i(flush),
	
		.rem_o(div_result_rem),
		.div_o(div_result_div),
		.ready_o(div_ready)
	);

	LLbit_reg LLbit_reg0(
		.clk(clk),
		.rst_n(rst_n),
		.flush(flush),
		
		//写端口
		.we_i(wb_LLbit_we_i),
		.LLbit_i(wb_LLbit_value_i),
		.LLbit_addr_i(wb_LLbit_addr_i),
		
		//读端口1
		.LLbit_o(LLbit_o),
		.LLbit_addr_o(LLbit_addr_o)
	);
	
	csr csr0(
		.clk(clk),
		.rst_n(rst_n),
		
		.we_i(mem_csr_reg_we_i),
		.waddr_i(mem_csr_reg_addr_i),
		.data_i(mem_csr_reg_data_i),

		.re_i(id_csr_reg_re_o),
		.will_write_in_mem_i(id_csr_reg_we_o),
		.raddr_i(id_csr_reg_addr_o),
		
		.excepttype_i(mem_excepttype_o),
		.timer_int_i(timer_int_i),
		.software_int_i(software_int_i),
		.external_int_i(external_int_i),
		.current_inst_addr_i(mem_current_inst_address_o),
		.current_data_addr_i(mem_current_data_address_o),
		.is_in_delayslot_i(mem_is_in_delayslot_o),
		.not_stall_i(mem_not_stall_o),
		
		.data_o(csr_data_o),
		.protect_o(csr_protect_o),
		
		.flushreq(flushreq_from_csr),
		.exception_new_pc_o(exception_new_pc),

		.prv_o(prv),


		// MMU
		.inst_ce_i(pc_ce_o),
		.inst_vir_addr_i(pc_next_inst_vir_addr),
		.inst_phy_addr_o(pc_next_inst_phy_addr),
		.inst_tlb_exception_o(pc_next_inst_tlb_exception),


		.data_ce_i(ex_mem_ce_o),
		.data_we_i(ex_mem_we_o),
		.data_vir_addr_i(ex_mem_addr_o),
		.data_phy_addr_o(ex_mem_phy_addr_i),
		.data_tlb_exception_o(ex_data_tlb_exception_i)
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

		.stallreq(stallreq_from_dwishbone)
	
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
