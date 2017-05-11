module sdram_top
(
	input clk_sdram,
	input rst_n,

	output S_CKE, S_NCS, S_NRAS, S_NCAS, S_NWE, S_CLK,
	output [1:0]S_BA,
	output [12:0]S_A, 
	output [3:0]S_DQM,
	inout [31:0]S_DQ,
	output wire sdram_init_done,

	input              wb_clk_i,
    input              wb_stb_i,
    input              wb_cyc_i,
    output reg         wb_ack_o,
    input      [31: 0] wb_addr_i,
    input      [ 3: 0] wb_sel_i,
    input              wb_we_i,
    input      [31: 0] wb_data_i,
    output reg [31: 0] wb_data_o
); 
	
	// request signal
	wire request;
	wire is_read, is_write;

	// get request signal
	assign request = wb_stb_i & wb_cyc_i;

	// Internal Assignments
	assign is_read  = wb_stb_i & wb_cyc_i & ~wb_we_i;
	assign is_write = wb_stb_i & wb_cyc_i & wb_we_i;

	// request signal's rising edge
	reg  request_delay;
	wire request_rising_edge;
	
	// get the rising edge of request signal
	always @ (posedge wb_clk_i or negedge rst_n)
		if(~rst_n)
			request_delay <= 0;
		else
			request_delay <= request;
	
	// ack signal
	reg [2:0]ack_delay;
	reg [2:0]cancel_delay;
	reg [1:0]status_wishbone;

	assign request_rising_edge = ((request_delay ^ request) & request) | (request & request_delay & (ack_delay[2] | cancel_delay[2]));

	parameter WISHBONE_IDLE_0 = 2'b00, WISHBONE_PROCESS_0 = 2'b01;
	parameter WISHBONE_IDLE_1 = 2'b10, WISHBONE_PROCESS_1 = 2'b11;

	reg[1:0] call_i;
	reg request_i;
	wire done_request_o;
	wire done_valid_o;

	reg in_request_reg;


	reg[31:0] wb_data_i_reg;
	reg[31:0] wb_addr_i_reg;
	reg[3:0] wb_sel_i_reg;
	reg is_read_reg;
	wire [31:0] wb_data_o_wire;

	always @ (posedge wb_clk_i or negedge rst_n)
		if (~rst_n)
		begin
			ack_delay <= 3'b000;
			cancel_delay <= 3'b000;

			in_request_reg <= 1'b0;

			status_wishbone <= WISHBONE_IDLE_0;

			call_i <= 2'b00;
			request_i <= 1'b0;

			wb_data_i_reg <= 32'b0;
			wb_addr_i_reg <= 32'b0;
			wb_sel_i_reg <= 4'b0;
			is_read_reg <= 1'b0;
		end
		else
		begin
			ack_delay <= {ack_delay[1:0], 1'b0};
			cancel_delay <= {cancel_delay[1:0], 1'b0};

			case(status_wishbone)
				WISHBONE_IDLE_0, WISHBONE_IDLE_1: // IDLE
				begin
					if(request_rising_edge)
					begin
						wb_data_i_reg <= wb_data_i;
						wb_addr_i_reg <= wb_addr_i;
						wb_sel_i_reg <= wb_sel_i;
						is_read_reg <= is_read;

						call_i <= {is_write, is_read};
						request_i <= 
							(status_wishbone == WISHBONE_IDLE_0 ? 1'b0 : 1'b1);

						status_wishbone <= 
							(status_wishbone == WISHBONE_IDLE_0 ? WISHBONE_PROCESS_0 : WISHBONE_PROCESS_1);

						in_request_reg <= 1'b1;
					end
				end	
				
				WISHBONE_PROCESS_0, WISHBONE_PROCESS_1: // PROCESS
				begin
					if(~request) in_request_reg <= 1'b0;

					if((done_request_o == ((status_wishbone == WISHBONE_PROCESS_0 ? 1'b0 : 1'b1))) && done_valid_o)
					begin
						if(request && in_request_reg)
						begin
							ack_delay <= {ack_delay[1:0], 1'b1};
							if(is_read_reg)
								wb_data_o <= wb_data_o_wire;
						end
						else
						begin
							cancel_delay <= {cancel_delay[1:0], 1'b1};
						end

						status_wishbone <=
							(status_wishbone == WISHBONE_PROCESS_0 ? WISHBONE_IDLE_1 : WISHBONE_IDLE_0);
					end
				end

				default:
					status_wishbone <= WISHBONE_IDLE_0;
			endcase
		end

	always @ (posedge wb_clk_i or negedge rst_n)
		if (~rst_n)
			wb_ack_o <= 0;
		else if(~request)
			wb_ack_o <= 0;
		else
			wb_ack_o <= ack_delay[0];


	/*************************************************************************/
		

	/*
	wire idle_o;
	wire [1:0] done_o;


	reg [1:0]status_sdram;

	parameter SDRAM_IDLE = 2'd0, SDRAM_WAIT_TO_PROCESS = 2'd1, SDRAM_PROCESS = 2'd2, SDRAM_WAIT_TO_IDLE = 2'd3;

	always @ (posedge clk_sdram or negedge rst_n)
		if (~rst_n)
		begin
			status_sdram <= 1'b0;
			call_i <= 2'b0;
		end	
		else
		begin
			case(status_sdram)
				SDRAM_IDLE: // IDLE
				begin
					if(request_rising_edge)
					begin
						call_i <= {is_write, is_read};
						wb_data_o_reg <= 32'b0;
						wb_data_i_reg <= wb_data_i;
						wb_addr_i_reg <= wb_addr_i;
						wb_sel_i_reg <= wb_sel_i;

						status_sdram <= idle_o ? SDRAM_PROCESS : SDRAM_WAIT_TO_PROCESS;


						ack <= 1'b0;
					end
					else
					begin
						call_i <= 2'b0;
						status_sdram <= SDRAM_IDLE;
					end
				end

				SDRAM_WAIT_TO_PROCESS: // WAIT TO PROCESS
				begin
					status_sdram <= idle_o ? SDRAM_PROCESS : SDRAM_WAIT_TO_PROCESS;
				end

				SDRAM_PROCESS: // PROCESS
				begin
					call_i <= 2'b0;

					if(done_o[0]) // READ
						wb_data_o_reg <= wb_data_o_wire;

					if(|done_o)
					begin
						status_sdram <= SDRAM_WAIT_TO_IDLE;
						ack <= 1'b1;
					end
				end

				SDRAM_WAIT_TO_IDLE:  // WAIT TO IDLE
				begin
					if(ack_delay[0])
						status_sdram <= SDRAM_IDLE;
				end


				default:
				begin
					status_sdram <= SDRAM_IDLE;
					ack <= 1'b0;
				end
			endcase

			if(~request)
				status_sdram <= SDRAM_IDLE;
		end
	*/


	wire [3:0]call_func_module; // [3]Refresh, [2]Read, [1]Write, [0]Initial
	wire done_from_func_module;

	sdram_ctrlmod sdram_ctrlmod0
	(
		.clk( clk_sdram ),
		.rst_n( rst_n ),
		.call_i( call_i ),   // < top ,[1]Write [0]Read
		.request_i( request_i ),
		.done_request_o( done_request_o ),
		.call_o( call_func_module ),  // > U2 
		.done_i( done_from_func_module ),
		.done_valid_o( done_valid_o ), 
		.idle_o( ),
		.sdram_init_done( sdram_init_done )
	);

	sdram_funcmod sdram_funcmod0
	(
		.clk( clk_sdram ),
		.rst_n( rst_n ),
		.S_CKE( S_CKE ),   // > top
		.S_NCS( S_NCS ),   // > top
		.S_NRAS( S_NRAS ), // > top
		.S_NCAS( S_NCAS ), // > top
		.S_NWE( S_NWE ), // > top
		.S_CLK( S_CLK ), 
		.S_BA( S_BA ),   // > top
		.S_A( S_A ),     // > top
		.S_DQM( S_DQM ), // > top
		.S_DQ( S_DQ ),   // <> top        
		.call_i( call_func_module ),    // < U1
		.done_o( done_from_func_module ),  // > U1
		.sel_i( wb_sel_i_reg ),
		.addr_i( wb_addr_i_reg[24:0] ),       // < top
		.data_i( wb_data_i_reg ),       // < top
		.data_o( wb_data_o_wire )       // > top
	);

endmodule
