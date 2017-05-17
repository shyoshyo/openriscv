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

`timescale 1ns/1ps

module ssram_flash(
    input              clk_i,
    input              rst_i,
   
    input              wb_stb_i,
    input              wb_cyc_i,
    output wire        wb_ack_o,
    input      [31: 0] wb_addr_i,
    input      [ 3: 0] wb_sel_i,
    input              wb_we_i,
    input      [31: 0] wb_data_i,
    output reg [31: 0] wb_data_o,

    // SSRAM side
    output             SRAM_CLK,    //  SRAM Clock
    output             SRAM_ADSC_N, //  SRAM Controller Address Status  
    output             SRAM_ADSP_N, //  SRAM Processor Address Status
    output             SRAM_ADV_N,  //  SRAM Burst Address Advance
    output     [ 3: 0] SRAM_BE_N,   //  SRAM Byte Write Enable
    output     [ 1: 0] SRAM_CE1_N,  //  SRAM Chip Enable
    output             SRAM_CE2,    //  SRAM Chip Enable
    output             SRAM_CE3_N,  //  SRAM Chip Enable
    output             SRAM_GW_N,   //  SRAM Global Write Enable
    output             SRAM_OE_N,   //  SRAM Output Enable
    output             SRAM_WE_N,   //  SRAM Write Enable

    // Flash side
    output wire FL_CE_N,
    output wire FL_OE_N,
    output wire FL_RST_N,
    input wire FL_RY,
    output wire FL_WE_N,
    output wire FL_WP_N,


    // SSRAM & FLASH
    inout wire [31: 0] DQ,           //  Data Bus 32 Bits
    output reg [26: 1] A             //  Addr Bus
  );

  // request signal
  wire request;

  wire request_ssram;
  wire request_flash;

 
  // request signal's rising edge
  reg  request_delay;
  wire request_rising_edge;
  wire is_read, is_write;

  // ack signal
  reg  [4:0]ram_ack_delay;
 
  // get request signal
  assign request = wb_stb_i & wb_cyc_i;
 
  // Internal Assignments
  assign is_read  = wb_stb_i & wb_cyc_i & ~wb_we_i;
  assign is_write = wb_stb_i & wb_cyc_i & wb_we_i;

  assign request_ssram = request & (wb_addr_i[27] == 1'b0);
  assign request_flash = request & (wb_addr_i[27] == 1'b1);

 
  // Output Assignments
  /*
  assign wb_data_o[31:24] = (is_read & request_ssram) ? DQ[31:24] : 8'h00;
  assign wb_data_o[23:16] = (is_read & request_ssram) ? DQ[23:16] : 8'h00;
  assign wb_data_o[15: 8] = (is_read)                 ? DQ[15: 8] : 8'h00;
  assign wb_data_o[ 7: 0] = (is_read)                 ? DQ[ 7: 0] : 8'h00;

  assign DQ[31:24] = ((wb_sel_i[3] & is_write & request_ssram) == 1'b1) ? wb_data_i[31:24] : 8'hZZ;
  assign DQ[23:16] = ((wb_sel_i[2] & is_write & request_ssram) == 1'b1) ? wb_data_i[23:16] : 8'hZZ;
  assign DQ[15: 8] = ((wb_sel_i[1] & is_write & request_ssram) == 1'b1) ? wb_data_i[15: 8] : 8'hZZ;
  assign DQ[ 7: 0] = ((wb_sel_i[0] & is_write & request_ssram) == 1'b1) ? wb_data_i[ 7: 0] : 8'hZZ;
  */

  /*
  wire [24: 0]SRAM_A;
  assign SRAM_CLK     = clk_i;
  assign SRAM_A       = wb_addr_i[26:2];
  assign SRAM_ADSC_N  = ~((is_read | is_write) & request_ssram);
  assign SRAM_ADSP_N  = 1'b1;
  assign SRAM_ADV_N   = 1'b1;
  assign SRAM_BE_N[3] = ~(wb_sel_i[3]);
  assign SRAM_BE_N[2] = ~(wb_sel_i[2]);
  assign SRAM_BE_N[1] = ~(wb_sel_i[1]);
  assign SRAM_BE_N[0] = ~(wb_sel_i[0]);
  assign SRAM_CE1_N   = {2{~{request & request_ssram}}};
  assign SRAM_CE2     = 1'b1;
  assign SRAM_CE3_N   = 1'b0;
  assign SRAM_GW_N    = 1'b1;
  assign SRAM_OE_N    = ~(is_read & request_ssram);
  assign SRAM_WE_N    = ~(is_write & request_ssram);

  wire [26:1]FLASH_A;
  assign FLASH_A = {1'b0, wb_addr_i[26:2]};
  assign FL_CE_N = ~(request & request_flash);
  assign FL_OE_N = ~(is_read & request_flash);
  assign FL_RST_N = ~rst_i;
  assign FL_WE_N = 1'b1;
  assign FL_WP_N = 1'b0;

  always@(*)
    if(rst_i)
      A <= 26'h0;
    else if(request_ssram)
      A <= {SRAM_A, 1'b0};
    else if(request_flash)
      A <= FLASH_A;
    else
      A <= 26'h0;
  */


//数据存储器data_ram
`define DataAddrBus 31:0
`define DataBus 31:0
`define DataMemNum (1024*1024)
`define DataMemNumLog2 20
`define ByteWidth 7:0

  reg[31:0]  mem[0:`DataMemNum-1];
  
  initial
  begin
    :block 
    integer i;
    for(i = 0; i < `DataMemNum; i = i + 1)
      mem[i] <= 32'b0;

    #100 $readmemh ( "bbl.data", mem );
  end





  // get the rising edge of request signal
  always @ (posedge clk_i or posedge rst_i)
  begin
    if(rst_i == 1)
      request_delay <= 0;
    else
      request_delay <= request;
  end

  assign request_rising_edge = ((request_delay ^ request) & request) | (request & request_delay & ram_ack_delay[3]);
  reg [31:0]flash_request_rising_edge_delay;
  always @ (posedge clk_i or posedge rst_i)
    if (rst_i == 1)
      flash_request_rising_edge_delay <= 10'b0;
    else 
      flash_request_rising_edge_delay <= {flash_request_rising_edge_delay[30:0], request_rising_edge & request_flash};
  
  // generate a 1 cycle acknowledgement for each request rising edge(ssram)
  always @ (posedge clk_i or posedge rst_i)
  begin
    if (rst_i == 1)
      {ram_ack_delay} <= 5'b00000;
    else if(request == 1'b0)
      {ram_ack_delay} <= 5'b00000;
    else if (request_rising_edge == 1'b1 && request_ssram == 1'b1)
    begin
      {ram_ack_delay} <= {ram_ack_delay[3:0], 1'b1};

      if(is_write)
      begin
        if (wb_sel_i[3] == 1'b1)
          mem[wb_addr_i[`DataMemNumLog2+1:2]][31:24] <= wb_data_i[31:24];
        if (wb_sel_i[2] == 1'b1)
          mem[wb_addr_i[`DataMemNumLog2+1:2]][23:16] <= wb_data_i[23:16];
        if (wb_sel_i[1] == 1'b1)
          mem[wb_addr_i[`DataMemNumLog2+1:2]][15:8] <= wb_data_i[15:8];
        if (wb_sel_i[0] == 1'b1)
          mem[wb_addr_i[`DataMemNumLog2+1:2]][7:0] <= wb_data_i[7:0];
      end
      else
      begin
        wb_data_o <= 1'b0;

        if (wb_sel_i[3] == 1'b1)
          wb_data_o[31:24] <= mem[wb_addr_i[`DataMemNumLog2+1:2]][31:24];
        if (wb_sel_i[2] == 1'b1)
          wb_data_o[23:16] <= mem[wb_addr_i[`DataMemNumLog2+1:2]][23:16];
        if (wb_sel_i[1] == 1'b1)
          wb_data_o[15:8] <= mem[wb_addr_i[`DataMemNumLog2+1:2]][15:8];
        if (wb_sel_i[0] == 1'b1)
          wb_data_o[7:0] <= mem[wb_addr_i[`DataMemNumLog2+1:2]][7:0];
      end
    end
    else if (flash_request_rising_edge_delay[30] == 1'b1 && request_flash == 1'b1)
      {ram_ack_delay} <= {ram_ack_delay[3:0], 1'b1};
    else
      {ram_ack_delay} <= {ram_ack_delay[3:0], 1'b0};
  end

  reg ack;
  // register wb_ack output, because onchip ram0 uses registered output
  always @ (posedge clk_i or posedge rst_i)
  begin
    if (rst_i == 1)
      ack <= 1'b0;
    else if(~request)
      ack <= 1'b0;
    else
      ack <= ram_ack_delay[2];
  end

  assign wb_ack_o = ack & request;

endmodule