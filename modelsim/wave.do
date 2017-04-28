onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/clk
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/wishbone_clk
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/if_inst
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/if_pc
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/id_inst
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/id_pc
add wave -noupdate -radix symbolic /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id_ex0/id_csr_reg_we
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_current_inst_address
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_csr_reg_data
add wave -noupdate -radix symbolic /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_csr_reg_we
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_csr_reg_write_addr
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/mem_csr_reg_data
add wave -noupdate -radix symbolic /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/mem_csr_reg_we
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/mem_csr_reg_write_addr
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/wb_csr_reg_data
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/wb_csr_reg_we
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/wb_csr_reg_write_addr
add wave -noupdate -expand -group reg -label {reg x0, zero} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[0]}
add wave -noupdate -expand -group reg -label {reg x1, ra} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[1]}
add wave -noupdate -expand -group reg -label {reg x2, sp} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[2]}
add wave -noupdate -expand -group reg -label {reg x3, gp} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[3]}
add wave -noupdate -expand -group reg -label {reg x4, tp} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[4]}
add wave -noupdate -expand -group reg -label {reg x31, t6} -radix hexadecimal {/openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/regfile1/regs[31]}
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/current_inst_address_i
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/current_inst_address_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ctrl0/excepttype_i
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/excepttype_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ctrl0/flush
add wave -noupdate -expand /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ctrl0/stall
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/we_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/waddr_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mscratch
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/re_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/raddr_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/we_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/waddr_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/mscratch
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/re_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/raddr_i
add wave -noupdate -expand -group csr /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/csr0/data_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/clk
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/wishbone_clk
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/if_inst
add wave -noupdate -radix hexadecimal /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/if_pc
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/id_inst
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/if_id0/id_pc
add wave -noupdate -radix symbolic /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/id_ex0/id_csr_reg_we
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_current_inst_address
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_csr_reg_data
add wave -noupdate -radix symbolic /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_csr_reg_we
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ex_mem0/ex_csr_reg_write_addr
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/mem_csr_reg_data
add wave -noupdate -radix symbolic /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/mem_csr_reg_we
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/mem_csr_reg_write_addr
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/wb_csr_reg_data
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/wb_csr_reg_we
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem_wb0/wb_csr_reg_write_addr
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/current_inst_address_i
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/current_inst_address_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ctrl0/excepttype_i
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/mem0/excepttype_o
add wave -noupdate /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ctrl0/flush
add wave -noupdate -expand /openriscv_min_sopc_tb/openriscv_min_sopc0/openriscv0/ctrl0/stall
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {first {640487 ps} 1} {{Cursor 2} {1454457 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 200
configure wave -valuecolwidth 97
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
WaveRestoreZoom {1295325 ps} {2399459 ps}
