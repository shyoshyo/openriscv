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
	input wire[`PhyAddrBus] mem_phy_addr_i,
	input wire data_tlb_r_exception_i,
	input wire data_tlb_w_exception_i,
	
	//来自执行阶段的信息	
	input wire[`RegAddrBus] wd_i,
	input wire wreg_i,
	input wire[`RegBus] wdata_i,
	input wire[`AluOpBus] aluop_i,
	input wire[`RegBus] mem_addr_i,
	input wire[`RegBus] reg2_i,

	//来自memory的信息
	input wire[`RegBus] mem_data_i,
	
	//LLbit_i是LLbit寄存器的值
	input wire LLbit_i,
	input wire [`PhyAddrBus]LLbit_addr_i,

	input wire stallreq_from_mem_i,
	input wire [1:0] cnt_i,
	input wire [`RegBus] original_data_i,

	//协处理器csr的写信号
	input wire[`CSRWriteTypeBus] csr_reg_we_i,
	input wire[`CSRAddrBus] csr_reg_addr_i,
	input wire[`RegBus] csr_reg_data_i,


	input wire[`ExceptionTypeBus] excepttype_i,
	input wire is_in_delayslot_i,
	input wire[`RegBus] current_inst_address_i,
	input wire not_stall_i,

	//送到回写阶段的信息
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
	output reg[`RegBus] wdata_o,

	// LLbit 的输出
	output reg LLbit_we_o,
	output reg LLbit_value_o,
	output reg [`PhyAddrBus]LLbit_addr_o,

	output wire stallreq,
	output reg [1:0] cnt_o,
	output reg [`RegBus] original_data_o,

	//协处理器csr的写信号
	output reg[`CSRWriteTypeBus] csr_reg_we_o,
	output reg[`CSRAddrBus] csr_reg_addr_o,
	output reg[`RegBus] csr_reg_data_o,

	// 最终确认的异常类型
	output reg[`ExceptionTypeBus] excepttype_o,
	output wire is_in_delayslot_o,
	// 当前指令的地址 以及此指令要訪問的數據地址
	output wire[`RegBus] current_inst_address_o,
	output wire[`RegBus] current_data_address_o,
	output wire not_stall_o,
	
	/*
	// 最新的 EPC 值
	output wire[`RegBus] csr_epc_o,
	*/

	//送到memory的信息
	output reg[`RegBus] mem_addr_o,
	output reg[`PhyAddrBus] mem_phy_addr_o,
	output wire mem_we_o,
	output reg[`RegSel] mem_sel_o,
	output reg[`RegBus] mem_data_o,
	// memory 使能
	output wire mem_ce_o
);
	reg mem_we;
	reg mem_ce;

	assign mem_we_o = mem_we;
	assign mem_ce_o = mem_ce;
	assign is_in_delayslot_o = is_in_delayslot_i;
	assign current_inst_address_o = current_inst_address_i;
	assign current_data_address_o = mem_addr_i;
	/*
	assign csr_epc_o = csr_epc;
	*/

	reg load_alignment_error;
	reg load_access_error;
	reg store_alignment_error;
	reg store_access_error;

	reg stallreq_from_amo;

	assign stallreq = (stallreq_from_mem_i | stallreq_from_amo);

	always @ (*)
		if(rst_n == `RstEnable)
		begin
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			wdata_o <= `ZeroWord;

			csr_reg_we_o <= `CSRWriteDisable;
			csr_reg_addr_o <= `NOPRegAddr;
			csr_reg_data_o <= `ZeroWord;

			mem_addr_o <= `ZeroWord;
			mem_phy_addr_o <= `ZeroWord;
			mem_we <= `WriteDisable;
			mem_sel_o <= 4'b0;
			mem_data_o <= `ZeroWord;
			mem_ce <= `ChipDisable;

			LLbit_we_o <= `WriteDisable;
			LLbit_addr_o <= `ZeroWord;
			LLbit_value_o <= 1'b0;

			cnt_o <= 2'b0;
			original_data_o <= `ZeroWord;

			load_alignment_error <= `False_v;
			load_access_error <= `False_v;
			store_alignment_error <= `False_v;
			store_access_error <= `False_v;

			stallreq_from_amo <= `False_v;
		end
		else
		begin
			wd_o <= wd_i;
			wreg_o <= wreg_i;
			wdata_o <= wdata_i;

			csr_reg_we_o <= `CSRWriteDisable;
			csr_reg_addr_o <= `NOPRegAddr;
			csr_reg_data_o <= `ZeroWord;

			mem_addr_o <= `ZeroWord;
			mem_phy_addr_o <= `ZeroWord;
			mem_we <= `WriteDisable;
			mem_sel_o <= 4'b1111;
			mem_data_o <= `ZeroWord;
			mem_ce <= `ChipDisable;

			LLbit_we_o <= `WriteDisable;
			LLbit_addr_o <= `ZeroWord;
			LLbit_value_o <= 1'b0;

			cnt_o <= 2'b0;
			original_data_o <= `ZeroWord;

			load_alignment_error <= `False_v;
			load_access_error <= `False_v;
			store_alignment_error <= `False_v;
			store_access_error <= `False_v;

			stallreq_from_amo <= `False_v;

			case(aluop_i)
				`EXE_LB_OP:
					if(data_tlb_r_exception_i)
						load_access_error <= `True_v;
					else
					begin
						mem_ce <= `ChipEnable;

						mem_addr_o <= mem_addr_i;
						mem_phy_addr_o <= mem_phy_addr_i;
						mem_we <= `WriteDisable;

						LLbit_we_o <= `WriteEnable;
						LLbit_value_o <= 1'b0;
						
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
					if(data_tlb_r_exception_i)
						load_access_error <= `True_v;
					else
					begin
						mem_ce <= `ChipEnable;

						mem_addr_o <= mem_addr_i;
						mem_phy_addr_o <= mem_phy_addr_i;
						mem_we <= `WriteDisable;

						LLbit_we_o <= `WriteEnable;
						LLbit_value_o <= 1'b0;
						
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
					if(data_tlb_r_exception_i)
						load_access_error <= `True_v;
					else	
					begin
						mem_ce <= `ChipEnable;
						
						mem_addr_o <= mem_addr_i;
						mem_phy_addr_o <= mem_phy_addr_i;
						mem_we <= `WriteDisable;

						LLbit_we_o <= `WriteEnable;
						LLbit_value_o <= 1'b0;
						
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
					if(data_tlb_r_exception_i)
						load_access_error <= `True_v;
					else
					begin
						mem_ce <= `ChipEnable;
						
						mem_addr_o <= mem_addr_i;
						mem_phy_addr_o <= mem_phy_addr_i;
						mem_we <= `WriteDisable;

						LLbit_we_o <= `WriteEnable;
						LLbit_value_o <= 1'b0;
						
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
					if(data_tlb_r_exception_i)
						load_access_error <= `True_v;
					else
					begin
						mem_ce <= `ChipEnable;
						
						mem_addr_o <= mem_addr_i;
						mem_phy_addr_o <= mem_phy_addr_i;
						mem_we <= `WriteDisable;

						LLbit_we_o <= `WriteEnable;
						LLbit_value_o <= 1'b0;
						
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

				`EXE_LR_OP:
					if(data_tlb_r_exception_i)
						load_access_error <= `True_v;
					else
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

						LLbit_we_o <= `WriteEnable;
						LLbit_addr_o <= mem_phy_addr_i;
						LLbit_value_o <= 1'b1;
					end
				
				`EXE_SB_OP:
					if(data_tlb_w_exception_i)
						store_access_error <= `True_v;
					else
					begin
						mem_ce <= `ChipEnable;

						mem_addr_o <= mem_addr_i;
						mem_phy_addr_o <= mem_phy_addr_i;
						mem_we <= `WriteEnable;
						mem_data_o <= {4{reg2_i[7:0]}};
						
						LLbit_we_o <= `WriteEnable;
						LLbit_value_o <= 1'b0;

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
					if(data_tlb_w_exception_i)
						store_access_error <= `True_v;
					else
					begin
						mem_ce <= `ChipEnable;

						mem_addr_o <= mem_addr_i;
						mem_phy_addr_o <= mem_phy_addr_i;
						mem_we <= `WriteEnable;
						mem_data_o <= {2{reg2_i[15:0]}};

						LLbit_we_o <= `WriteEnable;
						LLbit_value_o <= 1'b0;

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
					if(data_tlb_w_exception_i)
						store_access_error <= `True_v;
					else
					begin
						mem_ce <= `ChipEnable;
						
						mem_addr_o <= mem_addr_i;
						mem_phy_addr_o <= mem_phy_addr_i;
						mem_we <= `WriteEnable;
						mem_data_o <= reg2_i;

						LLbit_we_o <= `WriteEnable;
						LLbit_value_o <= 1'b0;
						
						case(mem_addr_i[1:0])
							2'b00: mem_sel_o <= 4'b1111;

							default:
							begin
								mem_sel_o <= 4'b0000;

								mem_ce <= `ChipDisable;
							end
						endcase
					end

				`EXE_SC_OP:
				begin
					if(data_tlb_w_exception_i)
						store_access_error <= `True_v;
					else if(LLbit_i == 1'b1 && LLbit_addr_i == mem_phy_addr_i)
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

						LLbit_we_o <= `WriteEnable;
						LLbit_value_o <= 1'b0;
						
						wdata_o <= `SCSucceed;
					end
					else
					begin
						mem_ce <= `ChipDisable;

						mem_addr_o <= mem_addr_i;
						mem_phy_addr_o <= mem_phy_addr_i;
						mem_we <= `WriteEnable;
						mem_data_o <= `ZeroWord;

						LLbit_we_o <= `WriteEnable;
						LLbit_value_o <= 1'b0;

						wdata_o <= `SCFail;
					end
				end

				`EXE_AMOSWAP_W_OP, `EXE_AMOADD_W_OP, `EXE_AMOXOR_W_OP,
				`EXE_AMOAND_W_OP, `EXE_AMOOR_W_OP, `EXE_AMOMIN_W_OP,
				`EXE_AMOMAX_W_OP, `EXE_AMOMINU_W_OP, `EXE_AMOMAXU_W_OP:
				begin
					if(data_tlb_r_exception_i | data_tlb_w_exception_i)
						store_access_error <= `True_v;
					else if(cnt_i == 2'h0)
					begin
						mem_ce <= `ChipEnable;
						
						mem_addr_o <= mem_addr_i;
						mem_phy_addr_o <= mem_phy_addr_i;
						mem_we <= `WriteDisable;

						LLbit_we_o <= `WriteEnable;
						LLbit_value_o <= 1'b0;
						
						case(mem_addr_i[1:0])
							2'b00:
							begin
								mem_sel_o <= 4'b1111;
								stallreq_from_amo <= `True_v;
							end

							default:
							begin
								mem_sel_o <= 4'b0000;

								mem_ce <= `ChipDisable;
								store_alignment_error <= `True_v;
							end
						endcase

						cnt_o <= ((stallreq_from_mem_i == `True_v) ? 2'h0 : 2'h1);
						original_data_o <= mem_data_i;
					end
					else if(cnt_i == 2'h1)
					begin
						mem_ce <= `ChipEnable;
						
						mem_addr_o <= mem_addr_i;
						mem_phy_addr_o <= mem_phy_addr_i;
						mem_we <= `WriteEnable;

						LLbit_we_o <= `WriteEnable;
						LLbit_value_o <= 1'b0;

						case(aluop_i)
							`EXE_AMOSWAP_W_OP:
								mem_data_o <= reg2_i;

							`EXE_AMOADD_W_OP:
								mem_data_o <= (original_data_i + reg2_i);

							`EXE_AMOXOR_W_OP:
								mem_data_o <= (original_data_i ^ reg2_i);

							`EXE_AMOAND_W_OP:
								mem_data_o <= (original_data_i & reg2_i);

							`EXE_AMOOR_W_OP:
								mem_data_o <= (original_data_i | reg2_i);

							`EXE_AMOMIN_W_OP:
								mem_data_o <= (($signed(original_data_i) < $signed(reg2_i)) ? original_data_i : reg2_i);

							`EXE_AMOMAX_W_OP:
								mem_data_o <= (($signed(original_data_i) > $signed(reg2_i)) ? original_data_i : reg2_i);

							`EXE_AMOMINU_W_OP:
								mem_data_o <= ((original_data_i < reg2_i) ? mem_data_i : reg2_i);

							`EXE_AMOMAXU_W_OP:
								mem_data_o <= ((original_data_i > reg2_i) ? mem_data_i : reg2_i);

							default: mem_data_o <= `ZeroWord;
						endcase

						mem_sel_o <= 4'b1111;

						wdata_o <= original_data_i;

						cnt_o <= 2'h1;
						original_data_o <= original_data_i;
					end
				end

				default:
				begin
				end
			endcase
		end

	always @(*)
		if (rst_n == `RstEnable)
		begin
			excepttype_o <= `ZeroWord;
		end
		else if(!not_stall_i)
		begin
			excepttype_o <= `ZeroWord;
		end
		else
		begin
			excepttype_o <= excepttype_i;

			//excepttype_o[`Exception_LOAD_MISALIGNED] <= load_alignment_error;
			//excepttype_o[`Exception_LOAD_ACCESS_FAULT] <= load_access_error; //(data_tlb_r_exception_i & mem_ce);
			//excepttype_o[`Exception_STORE_MISALIGNED] <= store_alignment_error;
			//excepttype_o[`Exception_STORE_ACCESS_FAULT] <= store_access_error; //(data_tlb_w_exception_i & mem_ce);
			
			// TODO: interrupt
			// excepttype_o[0] <= (csr_cause[15:8] & csr_status[15:8]) & ({8{~csr_status[1]}}) & ({8{csr_status[0]}});
		end

	assign not_stall_o = not_stall_i;
endmodule
