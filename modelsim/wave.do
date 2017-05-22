onerror {resume}
quietly virtual signal -install /openriscv_min_sopc_tb/openriscv_min_sopc0/data_ram0 { (context /openriscv_min_sopc_tb/openriscv_min_sopc0/data_ram0 )&{wishbone_we_i ,wishbone_addr_i }} ram_we_addr_i
quietly WaveActivateNextPane {} 0
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/rst_n
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/clk
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/wishbone_clk
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/timer_int_i
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/prv_o
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/cpu_ack_id
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/cpu_addr_i
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/cpu_ce_i
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/cpu_clk
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/cpu_data_i
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/cpu_data_o
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/cpu_req_id
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/cpu_sel_i
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/cpu_we_i
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/cyc_len_log_2
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/delay
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/flush_i
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/not_use
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/process
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/req_cnt
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/request_bus
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/rst_n
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/stall_delay
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/stall_i
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/stall_this_i
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/stallreq
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/wishbone_ack_i
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/wishbone_ack_id
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/wishbone_ack_valid
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/wishbone_addr_o
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/wishbone_clk
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/wishbone_cyc_o
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/wishbone_data_i
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/wishbone_data_o
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/wishbone_sel_o
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/wishbone_stb_o
add wave -noupdate -group iwishbone /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/iwishbone_bus_if/wishbone_we_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/pc_reg0/exception_new_pc
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/pc_reg0/next_inst_tlb_exception_i
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/pc_reg0/pc
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/pc_reg0/excepttype_o
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/if_inst
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/if_pc
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/if_excepttype
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/marchid
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mbadaddr
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/medeleg
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mepc_addr
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mhartid
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mideleg
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mimpid
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mip_mtip
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/misa
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mscratch
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_fs
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_mie
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_mpie
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_mpp
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_sd
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_sie
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_spie
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_spp
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_uie
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_vm
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtlbindex
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtlbmask
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtlbpte
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtlbptevaddr
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtlbvpn
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtvec_addr
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mvendorid
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/prv_o
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/raddr_i
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/re_i
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/rst_n
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/sptbr_ppn
add wave -noupdate -label {Contributors: csr_protect_i} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_protect_i} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/will_write_in_mem_i
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/id_inst
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/id_pc
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/id_excepttype
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_reg_addr_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_reg_data_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/is_in_delayslot_i
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/is_in_delayslot_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/branch_flag_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/stallreq_for_reg1_loadrelate
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/stallreq_for_reg2_loadrelate
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg1_o
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_o
add wave -noupdate -label {Contributors: reg2_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o
add wave -noupdate -label {Contributors: reg2_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/csr_reg_data_i
add wave -noupdate -label {Contributors: reg2_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/ex_wd_i
add wave -noupdate -label {Contributors: reg2_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/ex_wdata_i
add wave -noupdate -label {Contributors: reg2_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/ex_wreg_i
add wave -noupdate -label {Contributors: reg2_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/imm
add wave -noupdate -label {Contributors: reg2_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/mem_wd_i
add wave -noupdate -label {Contributors: reg2_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/mem_wdata_i
add wave -noupdate -label {Contributors: reg2_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/mem_wreg_i
add wave -noupdate -label {Contributors: reg2_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/pre_inst_is_load
add wave -noupdate -label {Contributors: reg2_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_addr_o
add wave -noupdate -label {Contributors: reg2_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_data_i
add wave -noupdate -label {Contributors: reg2_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_read_o
add wave -noupdate -label {Contributors: reg2_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/rst_n
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/marchid
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mbadaddr
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/medeleg
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mepc_addr
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mhartid
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mideleg
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mimpid
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mip_mtip
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/misa
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mscratch
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_fs
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_mie
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_mpie
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_mpp
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_sd
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_sie
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_spie
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_spp
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_uie
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_vm
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtlbindex
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtlbmask
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtlbpte
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtlbptevaddr
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtlbvpn
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtvec_addr
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mvendorid
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/prv_o
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/raddr_i
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/re_i
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/rst_n
add wave -noupdate -label {Contributors: data_o} -group {Contributors: sim:/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/sptbr_ppn
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_current_inst_address
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex0/data_tlb_exception_i
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex0/data_tlb_r_exception_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex0/data_tlb_w_exception_o
add wave -noupdate -label mem_pc -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/current_inst_address_i
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/mem_addr_i
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/mem_addr_o
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/mem_phy_addr_i
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/mem_phy_addr_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/cnt_i
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/cnt_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/wd_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/wdata_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/wreg_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/LLbit_addr_i
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/LLbit_i
add wave -noupdate -group llbit /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/LLbit_reg0/LLbit
add wave -noupdate -group llbit /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/LLbit_reg0/LLbit_addr
add wave -noupdate -group llbit -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/LLbit_reg0/we_i
add wave -noupdate -group llbit -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/LLbit_reg0/LLbit_i
add wave -noupdate -group llbit -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/LLbit_reg0/LLbit_addr_i
add wave -noupdate -group llbit -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/LLbit_reg0/LLbit_o
add wave -noupdate -group llbit -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/LLbit_reg0/LLbit_addr_o
add wave -noupdate -group csr_write /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/wb_csr_reg_we
add wave -noupdate -group csr_write /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/wb_csr_reg_data
add wave -noupdate -group csr_write -radix symbolic /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/mem_csr_reg_we
add wave -noupdate -group csr_write /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/mem_csr_reg_data
add wave -noupdate -group csr_write -radix symbolic /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_csr_reg_we
add wave -noupdate -group csr_write /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_csr_reg_data
add wave -noupdate -group csr_write -radix symbolic /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id_ex0/id_csr_reg_we
add wave -noupdate -expand -group reg -label {reg x0, zero} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[0]}
add wave -noupdate -expand -group reg -label {reg x1, ra} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[1]}
add wave -noupdate -expand -group reg -label {reg x2, sp} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[2]}
add wave -noupdate -expand -group reg -label {reg x3, gp} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[3]}
add wave -noupdate -expand -group reg -label {reg x4, tp} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[4]}
add wave -noupdate -expand -group reg -label {reg x5, t0} -radix hexadecimal -childformat {{{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][31]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][30]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][29]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][28]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][27]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][26]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][25]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][24]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][23]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][22]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][21]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][20]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][19]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][18]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][17]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][16]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][15]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][14]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][13]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][12]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][11]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][10]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][9]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][8]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][7]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][6]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][5]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][4]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][3]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][2]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][1]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][0]} -radix hexadecimal}} -subitemconfig {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][31]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][30]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][29]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][28]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][27]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][26]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][25]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][24]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][23]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][22]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][21]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][20]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][19]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][18]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][17]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][16]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][15]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][14]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][13]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][12]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][11]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][10]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][9]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][8]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][7]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][6]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][5]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][4]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][3]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][2]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][1]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][0]} {-height 17 -radix hexadecimal}} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5]}
add wave -noupdate -expand -group reg -label {reg x6, t1} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[6]}
add wave -noupdate -expand -group reg -label {reg x10, a0} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[10]}
add wave -noupdate -expand -group reg -label a1 -radix ascii {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[11]}
add wave -noupdate -expand -group reg -label a2 -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[12]}
add wave -noupdate -expand -group reg -label {reg x31, t6} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[31]}
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/current_inst_address_i
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/current_inst_address_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/excepttype_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mepc_addr
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ctrl0/stall
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mscratch
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/marchid
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mbadaddr
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mcause_code
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mcause_intr
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/medeleg
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mepc_addr
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mhartid
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mideleg
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mie_meie
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mie_msie
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mie_mtie
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mie_ssie
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mie_stie
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mimpid
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mip_meip
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mip_msip
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mip_mtip
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mip_ssip
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mip_stip
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/misa
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mscounteren_tm
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mscratch
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_fs
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_mie
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_mpie
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_mpp
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_mprv
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_mxr
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_sd
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_sie
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_spie
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_spp
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_uie
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mstatus_vm
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/scause_code
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/scause_intr
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/sepc_addr
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/software_int_i
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/sptbr_ppn
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/sscratch
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/stvec_addr
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtlbindex
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtlbmask
add wave -noupdate -expand -group {CSR Reg} -expand /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtlbpte
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtlbptevaddr
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtlbvpn
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mtvec_addr
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mucounteren_tm
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mvendorid
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/sbadaddr
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/raddr_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/re_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mscratch
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/waddr_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/we_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/raddr_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/re_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/waddr_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/we_i
add wave -noupdate -group {write CSR} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/wb_csr_reg_we
add wave -noupdate -group {write CSR} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/wb_csr_reg_data
add wave -noupdate -group {write CSR} -radix symbolic /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/mem_csr_reg_we
add wave -noupdate -group {write CSR} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/mem_csr_reg_data
add wave -noupdate -group {write CSR} -radix symbolic /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_csr_reg_we
add wave -noupdate -group {write CSR} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_csr_reg_data
add wave -noupdate -group {write CSR} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_current_inst_address
add wave -noupdate -group {write CSR} -radix symbolic /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id_ex0/id_csr_reg_we
add wave -noupdate -group {write CSR} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/id_pc
add wave -noupdate -group {write CSR} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/id_inst
add wave -noupdate -group {write CSR} -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/if_pc
add wave -noupdate -group {write CSR} -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/if_inst
add wave -noupdate -group {write CSR} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/wishbone_clk
add wave -noupdate -group {write CSR} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/clk
add wave -noupdate -group exception /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ctrl0/stall
add wave -noupdate -group exception /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/excepttype_o
add wave -noupdate -group exception /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/current_inst_address_o
add wave -noupdate -group exception /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/current_inst_address_i
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/stx_pad_o
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_ack_o
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_adr_i
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_adr_int
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_clk_i
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_cyc_i
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_dat32_o
add wave -noupdate -expand -group uart -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_dat8_i
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_dat8_o
add wave -noupdate -expand -group uart -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_dat_i
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_dat_o
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_rst_i
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_sel_i
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_stb_i
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_we_i
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/we_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/config_string_and_timer0/mtime
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/config_string_and_timer0/mtimecmp
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/config_string_and_timer0/timer_int_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mip_mtip
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/data_ram0/ram_we_addr_i
add wave -noupdate -group mmv_conv1 /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mmu_conv1/hit
add wave -noupdate -group mmv_conv1 /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mmu_conv1/protect_exception
add wave -noupdate -group mmv_conv1 /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mmu_conv1/tlb_exception_o
add wave -noupdate -group mmuconv0 /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mmu_conv0/hit
add wave -noupdate -group mmuconv0 /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mmu_conv0/vir_addr_i
add wave -noupdate -group mmuconv0 /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mmu_conv0/phy_addr_o
add wave -noupdate -group mmuconv0 /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mmu_conv0/protect_exception
add wave -noupdate -group mmuconv0 /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mmu_conv0/tlb_exception_o
add wave -noupdate -group mmuconv0 /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mmu_conv0/tlb0_mask_i
add wave -noupdate -group mmuconv0 /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mmu_conv0/tlb0_pte_i
add wave -noupdate -group mmuconv0 /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mmu_conv0/tlb0_vpn_i
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_tlb_exception_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/inst_tlb_exception_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {first {640487 ps} 1} {{Cursor 7} {5122506234213 ps} 1} {print {5122633417312 ps} 1} {{prob inst} {5122016360182 ps} 1} {{really prob} {5121060982893 ps} 1} {{Cursor 26} {840000 ps} 0}
quietly wave cursor active 6
configure wave -namecolwidth 211
configure wave -valuecolwidth 114
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {708519 ps} {971481 ps}
