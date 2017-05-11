module sdram_funcmod
(
	input clk,
	input rst_n,

	output S_CKE, S_NCS, S_NRAS, S_NCAS, S_NWE, S_CLK,
	output [1:0]S_BA,  //2
	output [12:0]S_A,  //12, CA0~CA8, RA0~RA12, BA0~BA1, 9+13+2 = 24;
	output [3:0]S_DQM,
	inout [31:0]S_DQ,

	input [3:0]call_i,
	output done_o,
	input [3:0]sel_i,
	input [24:0]addr_i,
	input [31:0]data_i,
	output [31:0]data_o
);
	// [23:22]BA,[21:9]Row,[8:0]Column
	wire [1:0] bank_addr = {addr_i[24], addr_i[10]};
	wire [9:0] column_addr = addr_i[9:0];
	wire [12:0] row_addr = addr_i[23:11];

	parameter T100US = 16'd13300;
	parameter T250US = 16'd33250;

	// tRP 20ns, tRRC 63ns, tRCD 20ns, tMRD 2CLK, tWR/tDPL 2CLK, CAS Latency 3CLK
	parameter TRP = 16'd3, TRRC = 16'd9, TMRD = 16'd2, TRCD = 16'd3, TWR = 16'd2, CL = 16'd3;
	parameter _INIT = 5'b01111, _NOP = 5'b10111, _ACT = 5'b10011, _RD = 5'b10101, _WR = 5'b10100,
	_BSTP = 5'b10110, _PR = 5'b10010, _AR = 5'b10001, _LMR = 5'b10000;

	reg [5:0]i;
	reg [15:0]C1;
	reg [31:0]D1;
	reg [4:0]rCMD;
	reg [1:0]rBA;
	reg [12:0]rA;
	reg [3:0]rDQM;
	reg is_out;
	reg is_done;

	always @ ( posedge clk or negedge rst_n )
	if( !rst_n )
	begin
		i <= 5'd0;
		C1 <= 16'd0;
		D1 <= 16'd0;
		rCMD <= _NOP;
		rBA <= 2'b11;
		rA <= 13'h1fff;
		rDQM <= 4'b1111;
		is_out <= 1'b0;
		is_done <= 1'b0;
	end
	else if( call_i[3] ) // WRITE
		case( i )

			// Set IO to output State
			0: // Send Active Command with Bank and Row address
			begin rDQM <= ~sel_i; is_out <= 1'b1; rCMD <= _ACT; rBA <= bank_addr; rA <= row_addr; i <= i + 1'b1; end

			1: // wait TRCD 20ns
			if( C1 == TRCD - 1'b1 ) begin C1 <= 16'd0; i <= i + 1'b1; end
			else begin rCMD <= _NOP; C1 <= C1 + 1'b1; end		   

			/*********************************************/

			2: // Send Write command with row address, pull up A10 1 clk to Auto Precharge
			begin rCMD <= _WR; rBA <= bank_addr; rA <= { 3'b001, column_addr }; i <= i + 1'b1; end

			3: // wait TWR 2 clock
			if( C1 == TWR - 1'b1 ) begin C1 <= 16'd0; i <= i + 1'b1; end
			else begin rCMD <= _NOP; C1 <= C1 + 1'b1; end  

			4: // wait TRP 20ns
			if( C1 == TRP - 1'b1 ) begin C1 <= 16'd0; i <= i + 1'b1; end
			else begin rCMD <= _NOP; C1 <= C1 + 1'b1; end			 

			/**********************************************/

			5: // Generate done signal
			begin is_done <= 1'b1; i <= i + 1'b1; end

			6:
			begin rDQM <= 4'b0000; is_out <= 1'b0; is_done <= 1'b0; i <= 5'd0; end

		endcase
	else if( call_i[2] )  // READ
		case( i )

			// Set IO to output State
			0: // Send Active command with Bank and Row address
			begin rDQM <= ~sel_i; is_out <= 1'b0; D1 <= 16'd0; rCMD <= _ACT; rBA <= bank_addr; rA <= row_addr; i <= i + 1'b1; end

			1: // wait TRCD 20ns
			if( C1 == TRCD - 1'b1 ) begin C1 <= 16'd0; i <= i + 1'b1; end
			else begin rCMD <= _NOP; C1 <= C1 + 1'b1; end 

			/********************/

			2: // Send Read command and column address, pull up A10 to auto precharge.
			begin rCMD <= _RD; rBA <= bank_addr; rA <= { 3'b001, column_addr}; i <= i + 1'b1; end

			3: // wait CL 4 clock
			if( C1 == CL + 1'b1 - 1'b1 ) begin C1 <= 16'd0; i <= i + 1'b1; end
			else begin rCMD <= _NOP; C1 <= C1 + 1'b1; end 
				
			/********************/ 

			4: // Read Data
			begin D1 <= S_DQ; i <= i + 1'b1; end

			/********************/

			5: // wait TRP 20ns
			if( C1 == TRP - 1'b1 ) begin C1 <= 16'd0; i <= i + 1'b1; end
			else begin rCMD <= _NOP; C1 <= C1 + 1'b1; end  

			/********************/

			6: // Generate done signal
			begin is_done <= 1'b1; i <= i + 1'b1; end

			7:
			begin rDQM <= 4'b0000; is_out <= 1'b0; is_done <= 1'b0; i <= 5'd0; end

		endcase
	else if( call_i[1] )  // REFRESH
		case( i )

			0: // Send Precharge Command
			begin is_out <= 1'b0; rCMD <= _PR; {rBA, rA} <= 15'h0400; i <= i + 1'b1; end

			1: // wait TRP 20ns
			if( C1 == TRP - 1'b1 ) begin C1 <= 16'd0; i <= i + 1'b1; end
			else begin rCMD <= _NOP; C1 <= C1 + 1'b1; end

			2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32: // Send Auto Refresh Command
			begin rCMD <= _AR; i <= i + 1'b1; end

			3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33: // wait TRRC 63ns
			if( C1 == TRRC - 1'b1 ) begin C1 <= 16'd0; i <= i + 1'b1; end
			else begin rCMD <= _NOP; C1 <= C1 + 1'b1; end

			/********************/

			34: // Generate done signal
			begin rCMD <= _NOP; is_done <= 1'b1; i <= i + 1'b1; end

			35:
			begin rCMD <= _NOP; is_out <= 1'b0; is_done <= 1'b0; i <= 5'd0; end

		endcase
	else if( call_i[0] )  // INIT
		case( i )

			0:  // delay 250us
			begin
				is_out <= 1'b0;
				if( C1 == T250US - 1'b1 )
					begin C1 <= 16'd0; i <= i + 1'b1; end
				else
					begin C1 <= C1 + 1'b1; end
				rDQM <= 4'b1111;
			end

			/********************/

			1: // Send Precharge Command
			begin rCMD <= _PR; {rBA, rA} <= 15'h0400; i <= i + 1'b1; end

			2: // wait TRP 
			if( C1 == TRP - 1'b1 ) begin C1 <= 16'd0; i <= i + 1'b1; end
			else begin rCMD <= _NOP; C1 <= C1 + 1'b1; end

			3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33: // Send Auto Refresh Command
			begin rCMD <= _AR; i <= i + 1'b1; end

			4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34: // wait TRRC
			if( C1 == TRRC - 1'b1 ) begin C1 <= 16'd0; i <= i + 1'b1; end
			else begin rCMD <= _NOP; C1 <= C1 + 1'b1; end

			/********************/

			35: // Send LMR Cmd. Burst Read & Write,  3'b010 mean CAS latecy = 3, Sequential, 1 burst length
			begin rCMD <= _LMR; rBA <= 2'b00; rA <= { 3'd0, 1'b0, 2'd0, 3'b011, 1'b0, 3'b000 }; i <= i + 1'b1; end

			36: // Send 2 nop CLK for tMRD
			if( C1 == TMRD - 1'b1 ) begin rCMD <= _NOP; C1 <= 16'd0; i <= i + 1'b1; end
			else begin rCMD <= _NOP; C1 <= C1 + 1'b1; end

			/********************/

			37: // Generate done signal
			begin rCMD <= _NOP; is_done <= 1'b1; i <= i + 1'b1; end

			38:
			begin rCMD <= _NOP; is_done <= 1'b0; is_out <= 1'b0; i <= 5'd0; end

		endcase

	assign { S_CKE, S_NCS, S_NRAS, S_NCAS, S_NWE } = rCMD;
	assign { S_BA, S_A } = { rBA, rA };
	assign S_DQM = rDQM;
	assign S_DQ[31:24] = (sel_i[3] & is_out) ? data_i[31:24] : 8'hzz;
	assign S_DQ[23:16] = (sel_i[2] & is_out) ? data_i[23:16] : 8'hzz;
	assign S_DQ[15: 8] = (sel_i[1] & is_out) ? data_i[15: 8] : 8'hzz;
	assign S_DQ[ 7: 0] = (sel_i[0] & is_out) ? data_i[ 7: 0] : 8'hzz;

	assign S_CLK = ~clk;


	assign done_o = is_done;
	assign data_o = D1;

endmodule
