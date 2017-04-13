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
// Module:  mem
// File:    mem.v
// Author:  Lei Silei, shyoshyo
// E-mail:  leishangwen@163.com, shyoshyo@qq.com
// Description: 访存阶段
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module mem(

	input wire rst_n,

	// 执行阶段送来的物理地址
	input wire[`RegBus] mem_phy_addr_i,
	input wire data_tlb_r_miss_exception_i,
	input wire data_tlb_w_miss_exception_i,
	input wire data_tlb_mod_exception_i,
	input wire tlb_machine_check_exception_i,
	
	//来自执行阶段的信息	
	input wire[`RegAddrBus] wd_i,
	input wire wreg_i,
	input wire[`RegBus] wdata_i,
	input wire[`RegBus] hi_i,
	input wire[`RegBus] lo_i,
	input wire whilo_i,	
	input wire[`AluOpBus] aluop_i,
	input wire[`RegBus] mem_addr_i,
	input wire[`RegBus] reg2_i,

	//来自memory的信息
	input wire[`RegBus] mem_data_i,
	
	//LLbit_i是LLbit寄存器的值
	input wire LLbit_i,

	//协处理器CP0的写信号
	input wire cp0_reg_we_i,
	input wire[7:0] cp0_reg_write_addr_i,
	input wire[`RegBus] cp0_reg_data_i,
	input wire cp0_write_tlb_index_i,
	input wire cp0_write_tlb_random_i,


	input wire[31:0] excepttype_i,
	input wire is_in_delayslot_i,
	input wire[`RegBus] current_inst_address_i,
	input wire not_stall_i,
	
	//CP0的各个寄存器的值，但不一定是最新的值，要防止回写阶段指令写CP0
	input wire[`RegBus] cp0_status_i,
	input wire[`RegBus] cp0_cause_i,
	input wire[`RegBus] cp0_epc_i,

	//回写阶段的指令是否要写CP0，用来检测数据相关
	input wire wb_cp0_reg_we,
	input wire[7:0] wb_cp0_reg_write_addr,
	input wire[`RegBus] wb_cp0_reg_data,

	//送到回写阶段的信息
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
	output reg[`RegBus] wdata_o,
	output reg[`RegBus] hi_o,
	output reg[`RegBus] lo_o,
	output reg whilo_o,

	// LLbit 的输出
	output reg LLbit_we_o,
	output reg LLbit_value_o,

	//协处理器CP0的写信号
	output reg cp0_reg_we_o,
	output reg[7:0] cp0_reg_write_addr_o,
	output reg[`RegBus] cp0_reg_data_o,
	output reg cp0_write_tlb_index_o,
	output reg cp0_write_tlb_random_o,

	// 最终确认的异常类型
	output wire[31:0] excepttype_o,
	output wire is_in_delayslot_o,
	// 当前指令的地址 以及此指令要訪問的數據地址
	output wire[`RegBus] current_inst_address_o,
	output wire[`RegBus] current_data_address_o,
	
	// 最新的 EPC 值
	output wire[`RegBus] cp0_epc_o,

	//送到memory的信息
	output reg[`RegBus] mem_addr_o,
	output reg[`RegBus] mem_phy_addr_o,
	output wire mem_we_o,
	output reg[3:0] mem_sel_o,
	output reg[`RegBus] mem_data_o,
	// memory 使能
	output wire mem_ce_o
);
	reg mem_we;
	reg mem_ce;

	// CP0 中相关信号的最新值
	reg[`RegBus] cp0_status;
	reg[`RegBus] cp0_cause;
	reg[`RegBus] cp0_epc;
	
	assign mem_we_o = mem_we;
	assign mem_ce_o = mem_ce;
	assign is_in_delayslot_o = is_in_delayslot_i;
	assign current_inst_address_o = current_inst_address_i;
	assign current_data_address_o = mem_addr_i;
	assign cp0_epc_o = cp0_epc;

	reg load_alignment_error;
	reg store_alignment_error;

	always @ (*)
		if(rst_n == `RstEnable)
		begin
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			wdata_o <= `ZeroWord;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
			whilo_o <= `WriteDisable;

			cp0_reg_we_o <= `WriteDisable;
			cp0_reg_write_addr_o <= `NOPRegAddr;
			cp0_reg_data_o <= `ZeroWord;
			cp0_write_tlb_index_o <= `False_v;
			cp0_write_tlb_random_o <= `False_v;

			mem_addr_o <= `ZeroWord;
			mem_phy_addr_o <= `ZeroWord;
			mem_we <= `WriteDisable;
			mem_sel_o <= 4'b0;
			mem_data_o <= `ZeroWord;
			mem_ce <= `ChipDisable;

			LLbit_we_o <= 1'b0;
			LLbit_value_o <= 1'b0;

			load_alignment_error <= `False_v;
			store_alignment_error <= `False_v;
		end
		else
		begin
			wd_o <= wd_i;
			wreg_o <= wreg_i;
			wdata_o <= wdata_i;
			hi_o <= hi_i;
			lo_o <= lo_i;
			whilo_o <= whilo_i;

			cp0_reg_we_o <= cp0_reg_we_i;
			cp0_reg_write_addr_o <= cp0_reg_write_addr_i;
			cp0_reg_data_o <= cp0_reg_data_i;
			cp0_write_tlb_index_o <= cp0_write_tlb_index_i;
			cp0_write_tlb_random_o <= cp0_write_tlb_random_i;

			mem_addr_o <= `ZeroWord;
			mem_phy_addr_o <= `ZeroWord;
			mem_we <= `WriteDisable;
			mem_sel_o <= 4'b1111;
			mem_data_o <= `ZeroWord;
			mem_ce <= `ChipDisable;

			LLbit_we_o <= 1'b0;
			LLbit_value_o <= 1'b0;

			load_alignment_error <= `False_v;
			store_alignment_error <= `False_v;

			case(aluop_i)
				`EXE_LB_OP:
				begin
					mem_ce <= `ChipEnable;

					mem_addr_o <= mem_addr_i;
					mem_phy_addr_o <= mem_phy_addr_i;
					mem_we <= `WriteDisable;
					
					case(mem_addr_i[1:0])
						2'b00:
						begin
							wdata_o <= {{24{mem_data_i[7]}}, mem_data_i[7:0]};
							mem_sel_o <= 4'b0001;
						end
						2'b01:
						begin
							wdata_o <= {{24{mem_data_i[15]}}, mem_data_i[15:8]};
							mem_sel_o <= 4'b0010;
						end
						2'b10:
						begin
							wdata_o <= {{24{mem_data_i[23]}}, mem_data_i[23:16]};
							mem_sel_o <= 4'b0100;
						end
						2'b11:
						begin
							wdata_o <= {{24{mem_data_i[31]}}, mem_data_i[31:24]};
							mem_sel_o <= 4'b1000;
						end
						default:
						begin
							wdata_o <= `ZeroWord;
							mem_sel_o <= 4'b0000;

							mem_ce <= `ChipDisable;
							load_alignment_error <= `True_v;
						end
					endcase
				end
				
				`EXE_LBU_OP:
				begin
					mem_ce <= `ChipEnable;

					mem_addr_o <= mem_addr_i;
					mem_phy_addr_o <= mem_phy_addr_i;
					mem_we <= `WriteDisable;
					
					case(mem_addr_i[1:0])
						2'b00:
						begin
							wdata_o <= {24'b0, mem_data_i[7:0]};
							mem_sel_o <= 4'b0001;
						end
						2'b01:
						begin
							wdata_o <= {24'b0, mem_data_i[15:8]};
							mem_sel_o <= 4'b0010;
						end
						2'b10:
						begin
							wdata_o <= {24'b0, mem_data_i[23:16]};
							mem_sel_o <= 4'b0100;
						end
						2'b11:
						begin
							wdata_o <= {24'b0, mem_data_i[31:24]};
							mem_sel_o <= 4'b1000;
						end
						default:
						begin
							wdata_o <= `ZeroWord;
							mem_sel_o <= 4'b0000;

							mem_ce <= `ChipDisable;
							load_alignment_error <= `True_v;
						end
					endcase
				end

				`EXE_LH_OP:
				begin
					mem_ce <= `ChipEnable;
					
					mem_addr_o <= mem_addr_i;
					mem_phy_addr_o <= mem_phy_addr_i;
					mem_we <= `WriteDisable;
					
					case(mem_addr_i[1:0])
						2'b00:
						begin
							wdata_o <= {{16{mem_data_i[15]}}, mem_data_i[15:0]};
							mem_sel_o <= 4'b0011;
						end
						2'b10:
						begin
							wdata_o <= {{16{mem_data_i[31]}}, mem_data_i[31:16]};
							mem_sel_o <= 4'b1100;
						end
						default:
						begin
							wdata_o <= `ZeroWord;
							mem_sel_o <= 4'b0000;

							mem_ce <= `ChipDisable;
							load_alignment_error <= `True_v;
						end
					endcase
				end

				`EXE_LHU_OP:
				begin
					mem_ce <= `ChipEnable;
					
					mem_addr_o <= mem_addr_i;
					mem_phy_addr_o <= mem_phy_addr_i;
					mem_we <= `WriteDisable;
					
					case(mem_addr_i[1:0])
						2'b00:
						begin
							wdata_o <= {16'b0, mem_data_i[15:0]};
							mem_sel_o <= 4'b0011;
						end
						2'b10:
						begin
							wdata_o <= {16'b0, mem_data_i[31:16]};
							mem_sel_o <= 4'b1100;
						end
						default:
						begin
							wdata_o <= `ZeroWord;
							mem_sel_o <= 4'b0000;

							mem_ce <= `ChipDisable;
							load_alignment_error <= `True_v;
						end
					endcase
				end

				`EXE_LW_OP:
				begin
					mem_ce <= `ChipEnable;
					
					mem_addr_o <= mem_addr_i;
					mem_phy_addr_o <= mem_phy_addr_i;
					mem_we <= `WriteDisable;
					
					case(mem_addr_i[1:0])
						2'b00:
						begin
							wdata_o <= mem_data_i;
							mem_sel_o <= 4'b1111;
						end
						default:
						begin
							wdata_o <= `ZeroWord;
							mem_sel_o <= 4'b0000;

							mem_ce <= `ChipDisable;
							load_alignment_error <= `True_v;
						end
					endcase
				end

				`EXE_LWL_OP:
				begin
					mem_ce <= `ChipEnable;
					
					mem_addr_o <= {mem_addr_i[31:2], 2'b00};
					mem_phy_addr_o <= {mem_phy_addr_i[31:2], 2'b00};
					mem_we <= `WriteDisable;
					mem_sel_o <= 4'b1111;
					
					case(mem_addr_i[1:0])
						2'b00: wdata_o <= {mem_data_i[7:0], reg2_i[23:0]};
						2'b01: wdata_o <= {mem_data_i[15:0], reg2_i[15:0]};
						2'b10: wdata_o <= {mem_data_i[23:0], reg2_i[7:0]};
						2'b11: wdata_o <= mem_data_i[31:0];
						
						default:
						begin
							wdata_o <= `ZeroWord;

							mem_ce <= `ChipDisable;
							load_alignment_error <= `True_v;
						end
					endcase
				end

				`EXE_LWR_OP:
				begin
					mem_ce <= `ChipEnable;
					
					mem_addr_o <= {mem_addr_i[31:2], 2'b00};
					mem_phy_addr_o <= {mem_phy_addr_i[31:2], 2'b00};
					mem_we <= `WriteDisable;
					mem_sel_o <= 4'b1111;
					
					case(mem_addr_i[1:0])
						2'b00: wdata_o <= mem_data_i[31:0];
						2'b01: wdata_o <= {reg2_i[31:24], mem_data_i[31:8]};
						2'b10: wdata_o <= {reg2_i[31:16], mem_data_i[31:16]};
						2'b11: wdata_o <= {reg2_i[31:8], mem_data_i[31:24]};
						
						default:
						begin
							wdata_o <= `ZeroWord;

							mem_ce <= `ChipDisable;
							load_alignment_error <= `True_v;
						end
					endcase
				end

				`EXE_LL_OP:
				begin
					mem_ce <= `ChipEnable;
					
					mem_addr_o <= mem_addr_i;
					mem_phy_addr_o <= mem_phy_addr_i;
					mem_we <= `WriteDisable;
					
					case(mem_addr_i[1:0])
						2'b00:
						begin
							wdata_o <= mem_data_i;
							mem_sel_o <= 4'b1111;
						end

						default:
						begin
							wdata_o <= `ZeroWord;
							mem_sel_o <= 4'b0000;

							mem_ce <= `ChipDisable;
							load_alignment_error <= `True_v;
						end
					endcase

					LLbit_we_o <= 1'b1;
					LLbit_value_o <= 1'b1;
				end
				
				`EXE_SB_OP:
				begin
					mem_ce <= `ChipEnable;

					mem_addr_o <= mem_addr_i;
					mem_phy_addr_o <= mem_phy_addr_i;
					mem_we <= `WriteEnable;
					mem_data_o <= {4{reg2_i[7:0]}};
					
					case(mem_addr_i[1:0])
						2'b00: mem_sel_o <= 4'b0001;
						2'b01: mem_sel_o <= 4'b0010;
						2'b10: mem_sel_o <= 4'b0100;
						2'b11: mem_sel_o <= 4'b1000;

						default:
						begin
							mem_sel_o <= 4'b0000;

							mem_ce <= `ChipDisable;
							store_alignment_error <= `True_v;
						end
					endcase
				end

				`EXE_SH_OP:
				begin
					mem_ce <= `ChipEnable;

					mem_addr_o <= mem_addr_i;
					mem_phy_addr_o <= mem_phy_addr_i;
					mem_we <= `WriteEnable;
					mem_data_o <= {2{reg2_i[15:0]}};
					
					case(mem_addr_i[1:0])
						2'b00: mem_sel_o <= 4'b0011;
						2'b10: mem_sel_o <= 4'b1100;

						default:
						begin
							mem_sel_o <= 4'b0000;

							mem_ce <= `ChipDisable;
							store_alignment_error <= `True_v;
						end
					endcase
				end

				`EXE_SW_OP:
				begin
					mem_ce <= `ChipEnable;
					
					mem_addr_o <= mem_addr_i;
					mem_phy_addr_o <= mem_phy_addr_i;
					mem_we <= `WriteEnable;
					mem_data_o <= reg2_i;
					
					case(mem_addr_i[1:0])
						2'b00: mem_sel_o <= 4'b1111;

						default:
						begin
							mem_sel_o <= 4'b0000;

							mem_ce <= `ChipDisable;
							store_alignment_error <= `True_v;
						end
					endcase
				end

				`EXE_SWL_OP:
				begin
					mem_ce <= `ChipEnable;

					mem_addr_o <= {mem_addr_i[31:2], 2'b00};
					mem_phy_addr_o <= {mem_phy_addr_i[31:2], 2'b00};
					mem_we <= `WriteEnable;
					
					case(mem_addr_i[1:0])
						2'b00:
						begin
							mem_sel_o <= 4'b0001;
							mem_data_o <= {24'b0, reg2_i[31:24]};
						end
						2'b01:
						begin
							mem_sel_o <= 4'b0011;
							mem_data_o <= {16'b0, reg2_i[31:16]};
						end
						2'b10:
						begin
							mem_sel_o <= 4'b0111;
							mem_data_o <= {8'b0, reg2_i[31:8]};
						end
						2'b11:
						begin
							mem_sel_o <= 4'b1111;
							mem_data_o <= reg2_i[31:0];
						end

						default:
						begin
							mem_sel_o <= 4'b0000;
							mem_data_o <= `ZeroWord;

							mem_ce <= `ChipDisable;
							store_alignment_error <= `True_v;
						end
					endcase
				end

				`EXE_SWR_OP:
				begin
					mem_ce <= `ChipEnable;

					mem_addr_o <= {mem_addr_i[31:2], 2'b00};
					mem_phy_addr_o <= {mem_phy_addr_i[31:2], 2'b00};
					mem_we <= `WriteEnable;
					
					case(mem_addr_i[1:0])
						2'b00:
						begin
							mem_sel_o <= 4'b1111;
							mem_data_o <= reg2_i[31:0];
						end
						2'b01:
						begin
							mem_sel_o <= 4'b1110;
							mem_data_o <= {reg2_i[23:0], 8'b0};
						end
						2'b10:
						begin
							mem_sel_o <= 4'b1100;
							mem_data_o <= {reg2_i[15:0], 16'b0};
						end
						2'b11:
						begin
							mem_sel_o <= 4'b1000;
							mem_data_o <= {reg2_i[7:0], 24'b0};
						end

						default:
						begin
							mem_sel_o <= 4'b0000;
							mem_data_o <= `ZeroWord;

							mem_ce <= `ChipDisable;
							store_alignment_error <= `True_v;
						end
					endcase
				end


				`EXE_SC_OP:
				begin
					if(LLbit_i == 1'b1)
					begin
						mem_ce <= `ChipEnable;
					
						mem_addr_o <= mem_addr_i;
						mem_phy_addr_o <= mem_phy_addr_i;
						mem_we <= `WriteEnable;
						mem_data_o <= reg2_i;
						
						case(mem_addr_i[1:0])
							2'b00: mem_sel_o <= 4'b1111;

							default:
							begin
								mem_sel_o <= 4'b0000;

								mem_ce <= `ChipDisable;
								store_alignment_error <= `True_v;
							end
						endcase

						wdata_o <= 32'b1;
						LLbit_we_o <= 1'b1;
						LLbit_value_o <= 1'b0;
					end
					else
					begin
						mem_ce <= `ChipDisable;

						mem_addr_o <= mem_addr_i;
						mem_phy_addr_o <= mem_phy_addr_i;
						mem_we <= `WriteEnable;
						mem_data_o <= `ZeroWord;

						wdata_o <= 32'b0;
					end
				end

				default:
				begin
				end
			endcase
		end


	// 通过数据旁路求得最新的 CP0 相关寄存器的值
	always @ (*)
		if(rst_n == `RstEnable)
			cp0_status <= `ZeroWord;
		else if((wb_cp0_reg_we == `WriteEnable) && (wb_cp0_reg_write_addr == `CP0_REG_STATUS))
			cp0_status <= wb_cp0_reg_data;
		else
			cp0_status <= cp0_status_i;

	always @ (*)
		if(rst_n == `RstEnable)
			cp0_epc <= `ZeroWord;
		else if((wb_cp0_reg_we == `WriteEnable) && (wb_cp0_reg_write_addr == `CP0_REG_EPC))
			cp0_epc <= wb_cp0_reg_data;
		else
			cp0_epc <= cp0_epc_i;

	always @ (*)
		if(rst_n == `RstEnable)
			cp0_cause <= `ZeroWord;
		else if((wb_cp0_reg_we == `WriteEnable) && (wb_cp0_reg_write_addr == `CP0_REG_CAUSE))
		begin
			cp0_cause <= cp0_cause_i;
			{cp0_cause[23], cp0_cause[22], cp0_cause[9:8]} <= {wb_cp0_reg_data[23], wb_cp0_reg_data[22], wb_cp0_reg_data[9:8]};
		end
		else
			cp0_cause <= cp0_cause_i;
	
	// exceptiontype
	// * 0   machine check   TLB write that conflicts with an existing entry
	// * 1-8 外部中斷         Assertion of unmasked HW or SW interrupt signal.
	// . 9   adEl            Fetch address alignment error.
	// . 10  TLBL            Fetch TLB miss, Fetch TLB hit to page with V=0 (inst)
	// . 11  syscall
	// . 12  RI              無效指令 Reserved Instruction
	// . 13  ov              溢出
	// . 14  trap
	// * 15  AdEL            Load address alignment error,  
	// * 16  adES            Store address alignment error.
	//                       User mode store to kernel address.
	// * 17  TLBL            Load TLB miss,  (4Kc core). (data)
	// * 18  TLBS            Store TLB miss
	// * 19  TLB Mod         Store to TLB page with D=0
	// . 20  ERET
	assign excepttype_o = (~not_stall_i) ? 32'h0 : 
		{
			excepttype_i[31:20], (data_tlb_mod_exception_i & mem_ce), 
			(data_tlb_w_miss_exception_i & mem_ce), (data_tlb_r_miss_exception_i & mem_ce),
			store_alignment_error, load_alignment_error,
			excepttype_i[14:9], 
			(cp0_cause[15:8] & cp0_status[15:8]) & ({8{~cp0_status[1]}}) & ({8{cp0_status[0]}}),
			tlb_machine_check_exception_i
		};
endmodule
