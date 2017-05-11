//----------------------------------------------------------------------------//
// Filename       : ssram_wrapper.v                                           //
// Author         : Huailu Ren ...()                                          //
// Email          : hlren.pub@gmail.com                                       //
// Created        : 23:54 2011/5/17                                           //
//----------------------------------------------------------------------------//
// Description    :                                                           //
//                                                                            //
// $Id$                                                                       //
//----------------------------------------------------------------------------//

module ssram(
    input              clk_i,
    input              rst_i,
   
    input              wb_stb_i,
    input              wb_cyc_i,
    output reg         wb_ack_o,
    input      [31: 0] wb_addr_i,
    input      [ 3: 0] wb_sel_i,
    input              wb_we_i,
    input      [31: 0] wb_data_i,
    output     [31: 0] wb_data_o,
    // SSRAM side
    inout      [31: 0] SRAM_DQ,     //  SRAM Data Bus 32 Bits
    inout      [ 3: 0] SRAM_DPA,    //  SRAM Parity Data Bus
    // Outputs                     
    output             SRAM_CLK,    //  SRAM Clock
    output     [31: 0] SRAM_A,      //  SRAM Address bus 21 Bits
    output             SRAM_ADSC_N, //  SRAM Controller Address Status  
    output             SRAM_ADSP_N, //  SRAM Processor Address Status
    output             SRAM_ADV_N,  //  SRAM Burst Address Advance
    output     [ 3: 0] SRAM_BE_N,   //  SRAM Byte Write Enable
    output             SRAM_CE1_N,  //  SRAM Chip Enable
    output             SRAM_CE2,    //  SRAM Chip Enable
    output             SRAM_CE3_N,  //  SRAM Chip Enable
    output             SRAM_GW_N,   //  SRAM Global Write Enable
    output             SRAM_OE_N,   //  SRAM Output Enable
    output             SRAM_WE_N    //  SRAM Write Enable
  );

  // request signal
  wire request;
 
  // request signal's rising edge
  reg  request_delay;
  wire request_rising_edge;
  wire is_read, is_write;

  // ack signal
  reg  ram_ack;
  reg  [1:0]ram_ack_delay;
 
  // get request signal
  assign request = wb_stb_i & wb_cyc_i;
 
  // Internal Assignments
  assign is_read  = wb_stb_i & wb_cyc_i & ~wb_we_i;
  assign is_write = wb_stb_i & wb_cyc_i & wb_we_i;
 
  // Output Assignments
  assign wb_data_o      = SRAM_DQ;
  reg[31:0] wb_data_i_reg;

  assign SRAM_DQ[31:24] = (wb_sel_i[3] & is_write) ? wb_data_i_reg[31:24] : 8'hzz;
  assign SRAM_DQ[23:16] = (wb_sel_i[2] & is_write) ? wb_data_i_reg[23:16] : 8'hzz;
  assign SRAM_DQ[15: 8] = (wb_sel_i[1] & is_write) ? wb_data_i_reg[15: 8] : 8'hzz;
  assign SRAM_DQ[ 7: 0] = (wb_sel_i[0] & is_write) ? wb_data_i_reg[ 7: 0] : 8'hzz;

  assign SRAM_DPA     = 4'hz;

  assign SRAM_CLK     = ~clk_i;
  assign SRAM_A       = {2'b0, wb_addr_i[31:2]};
  assign SRAM_ADSC_N  = ~(is_read | is_write);
  assign SRAM_ADSP_N  = 1'b1;
  assign SRAM_ADV_N   = 1'b1;
  assign SRAM_BE_N[3] = ~(wb_sel_i[3]);
  assign SRAM_BE_N[2] = ~(wb_sel_i[2]);
  assign SRAM_BE_N[1] = ~(wb_sel_i[1]);
  assign SRAM_BE_N[0] = ~(wb_sel_i[0]);
  assign SRAM_CE1_N   = 1'b0;
  assign SRAM_CE2     = 1'b1;
  assign SRAM_CE3_N   = 1'b0;
  assign SRAM_GW_N    = 1'b1;
  assign SRAM_OE_N    = ~is_read;
  assign SRAM_WE_N    = ~is_write;
 
  // get the rising edge of request signal
  always @ (posedge clk_i)
  begin
    if(rst_i == 1)
      request_delay <= 0;
    else
      request_delay <= request;
  end

  assign request_rising_edge = ((request_delay ^ request) & request) | (request & request_delay & ram_ack_delay[0]);
  always @ (posedge clk_i)
    if (rst_i == 1)
    wb_data_i_reg <= 32'b0;
  else if(request_rising_edge)
    wb_data_i_reg <= wb_data_i;
  
  // generate a 1 cycle acknowledgement for each request rising edge
  always @ (posedge clk_i)
  begin
  if (rst_i == 1)
      {ram_ack, ram_ack_delay} <= 3'b000;
  else if(request == 1'b0)
      {ram_ack, ram_ack_delay} <= 3'b000; 
    else if (request_rising_edge == 1)
      {ram_ack, ram_ack_delay} <= {1'b1, ram_ack, ram_ack_delay[1]}; 
    else
      {ram_ack, ram_ack_delay} <= {1'b0, ram_ack, ram_ack_delay[1]}; 
  end

  // register wb_ack output, because onchip ram0 uses registered output
  always @ (posedge clk_i)
  begin
    if (rst_i == 1)
      wb_ack_o <= 0;
    else
      wb_ack_o <= ram_ack;
  end

endmodule