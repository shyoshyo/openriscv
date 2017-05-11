create_clock  -add -name clk1  -period 20.000 -waveform { 0.000 10.000 } [get_ports clk_i]
derive_pll_clocks
derive_clock_uncertainty


# set_false_path  -from  [get_ports wishbone_clk] -to [get_ports sdram_clk]
# set_false_path  -from  [get_ports sdram_clk] -to [get_ports wishbone_clk]

# set_false_path  -from  [get_ports wishbone_clk] -to [get_ports sdr_clk_o]
# set_false_path  -from  [get_ports sdr_clk_o] -to [get_ports wishbone_clk]

