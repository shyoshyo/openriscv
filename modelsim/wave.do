onerror {resume}
quietly virtual signal -install /openriscv_min_sopc_tb/openriscv_min_sopc0/data_ram0 { (context /openriscv_min_sopc_tb/openriscv_min_sopc0/data_ram0 )&{wishbone_we_i ,wishbone_addr_i }} ram_we_addr_i
quietly WaveActivateNextPane {} 0
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/clk
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/wishbone_clk
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/pc_reg0/pc
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/if_inst
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/if_pc
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/id_inst
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/id_pc
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/is_in_delayslot_i
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/is_in_delayslot_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/branch_flag_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/stallreq_for_reg1_loadrelate
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/stallreq_for_reg2_loadrelate
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg1_o
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id0/reg2_o
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_current_inst_address
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
add wave -noupdate -expand -group llbit /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/LLbit_reg0/LLbit
add wave -noupdate -expand -group llbit /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/LLbit_reg0/LLbit_addr
add wave -noupdate -expand -group llbit -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/LLbit_reg0/we_i
add wave -noupdate -expand -group llbit -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/LLbit_reg0/LLbit_i
add wave -noupdate -expand -group llbit -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/LLbit_reg0/LLbit_addr_i
add wave -noupdate -expand -group llbit -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/LLbit_reg0/LLbit_o
add wave -noupdate -expand -group llbit -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/LLbit_reg0/LLbit_addr_o
add wave -noupdate -group csr_write /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/wb_csr_reg_write_addr
add wave -noupdate -group csr_write /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/wb_csr_reg_we
add wave -noupdate -group csr_write /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/wb_csr_reg_data
add wave -noupdate -group csr_write /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/mem_csr_reg_write_addr
add wave -noupdate -group csr_write -radix symbolic /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/mem_csr_reg_we
add wave -noupdate -group csr_write /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/mem_csr_reg_data
add wave -noupdate -group csr_write /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_csr_reg_write_addr
add wave -noupdate -group csr_write -radix symbolic /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_csr_reg_we
add wave -noupdate -group csr_write /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_csr_reg_data
add wave -noupdate -group csr_write -radix symbolic /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id_ex0/id_csr_reg_we
add wave -noupdate -expand -group reg -label {reg x0, zero} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[0]}
add wave -noupdate -expand -group reg -label {reg x1, ra} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[1]}
add wave -noupdate -expand -group reg -label {reg x2, sp} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[2]}
add wave -noupdate -expand -group reg -label {reg x3, gp} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[3]}
add wave -noupdate -expand -group reg -label {reg x4, tp} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[4]}
add wave -noupdate -expand -group reg -label {reg x5, t0} -radix hexadecimal -childformat {{{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][31]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][30]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][29]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][28]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][27]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][26]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][25]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][24]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][23]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][22]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][21]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][20]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][19]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][18]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][17]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][16]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][15]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][14]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][13]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][12]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][11]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][10]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][9]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][8]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][7]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][6]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][5]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][4]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][3]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][2]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][1]} -radix hexadecimal} {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][0]} -radix hexadecimal}} -subitemconfig {{/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][31]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][30]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][29]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][28]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][27]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][26]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][25]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][24]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][23]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][22]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][21]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][20]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][19]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][18]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][17]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][16]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][15]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][14]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][13]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][12]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][11]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][10]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][9]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][8]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][7]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][6]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][5]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][4]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][3]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][2]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][1]} {-height 17 -radix hexadecimal} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5][0]} {-height 17 -radix hexadecimal}} {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[5]}
add wave -noupdate -expand -group reg -label {reg x10, a0} -radix ascii {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[10]}
add wave -noupdate -expand -group reg -label a1 -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[11]}
add wave -noupdate -expand -group reg -label a2 -radix ascii {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[12]}
add wave -noupdate -expand -group reg -label {reg x31, t6} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[31]}
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/current_inst_address_i
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/current_inst_address_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ctrl0/excepttype_i
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/excepttype_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ctrl0/flush
add wave -noupdate -expand /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ctrl0/stall
add wave -noupdate -expand -group {CSR Reg} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mscratch
add wave -noupdate -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o
add wave -noupdate -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/raddr_i
add wave -noupdate -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/re_i
add wave -noupdate -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mscratch
add wave -noupdate -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_i
add wave -noupdate -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/waddr_i
add wave -noupdate -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/we_i
add wave -noupdate -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o
add wave -noupdate -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/raddr_i
add wave -noupdate -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/re_i
add wave -noupdate -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_i
add wave -noupdate -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/waddr_i
add wave -noupdate -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/we_i
add wave -noupdate -group {write CSR} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/wb_csr_reg_write_addr
add wave -noupdate -group {write CSR} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/wb_csr_reg_we
add wave -noupdate -group {write CSR} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/wb_csr_reg_data
add wave -noupdate -group {write CSR} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/mem_csr_reg_write_addr
add wave -noupdate -group {write CSR} -radix symbolic /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/mem_csr_reg_we
add wave -noupdate -group {write CSR} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/mem_csr_reg_data
add wave -noupdate -group {write CSR} /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_csr_reg_write_addr
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
add wave -noupdate -group exception /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ctrl0/flush
add wave -noupdate -group exception /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/excepttype_o
add wave -noupdate -group exception /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ctrl0/excepttype_i
add wave -noupdate -group exception /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/current_inst_address_o
add wave -noupdate -group exception /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/current_inst_address_i
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/stx_pad_o
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_ack_o
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_adr_i
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_adr_int
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_clk_i
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_cyc_i
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_dat32_o
add wave -noupdate -expand -group uart -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_dat8_i
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_dat8_o
add wave -noupdate -expand -group uart /openriscv_min_sopc_tb/openriscv_min_sopc0/uart_top0/wb_dat_i
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
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {first {640487 ps} 1} {output {6689872 ps} 1} {{Cursor 7} {208522000000 ps} 1} {{Cursor 5} {34711041000 ps} 1} {{Cursor 6} {34711498106 ps} 0}
quietly wave cursor active 5
configure wave -namecolwidth 185
configure wave -valuecolwidth 175
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
WaveRestoreZoom {340004112384 ps} {340016625664 ps}
