module sdram_ctrlmod
(
	input wire clk,
	input wire rst_n,
	input wire [1:0]call_i, // [1]Write, [0]Read
	input wire request_i,
	output reg done_request_o,
	output reg done_valid_o,
	output reg [3:0]call_o, //[3]Write [2]Read [1]A.Refresh [0]Initial

	input wire done_i,

	output wire idle_o,
	output reg sdram_init_done
);
	parameter IDLE = 4'd0, WRITE = 4'd1, READ = 4'd3, REFRESH = 4'd5, INITIAL = 4'd6;
	parameter TREF = 16'd519;

	reg [3:0]i;
	reg [15:0]C1;

	assign idle_o = (i == IDLE);

	wire process = ((done_valid_o == 1'b0) || (done_request_o != request_i));

	reg request_i_reg;

	always @ ( posedge clk or negedge rst_n )
		if( !rst_n )
		begin
			i <= INITIAL;          // Initial SDRam at first 
			C1 <= 16'd0;
			call_o <= 4'b0000;

			done_request_o <= 1'b1;
			done_valid_o <= 1'b0;

			sdram_init_done <= 1'b0;
		end
	else 
		case( i )

			0: // IDLE
			begin
				C1 <= C1 + 1'b1;

				if( C1 >= TREF )
				begin
					C1 <= 11'd0;
					i <= REFRESH;
				end
				else if( ~process )
				begin
				end
				else if( call_i[1] )
				begin
					i <= WRITE;
					request_i_reg <= request_i;
				end 
				else if( call_i[0] )
				begin
					i <= READ;
					request_i_reg <= request_i;
				end
			end

			/***********************/

			1: //Write
			begin
				C1 <= C1 + 1'b1;
				if( done_i )
				begin
					call_o <= 4'b0000;
					i <= i + 1'b1;
				end
				else
				begin
					call_o <= 4'b1000;
				end
			end

			2:
			begin
				C1 <= C1 + 1'b1;

				done_request_o <= request_i_reg;
				done_valid_o <= 1'b1;
				i <= IDLE;
			end

			/***********************/

			3: // Read
			begin
				C1 <= C1 + 1'b1; 
				if( done_i )
				begin
					call_o <= 4'b0000;
					i <= i + 1'b1;
				end
				else
				begin
					call_o <= 4'b0100;
				end
			end

			4:
			begin
				C1 <= C1 + 1'b1;

				done_request_o <= request_i_reg;
				done_valid_o <= 1'b1;
				i <= IDLE;
			end

			/***********************/

			5: // Auto Refresh 
				if( done_i )
				begin
					call_o <= 4'b0000;
					i <= IDLE;
				end
				else
					call_o <= 4'b0010;

			/***********************/

			6: // Initial 
			begin
				if( done_i )
				begin
					call_o <= 4'b0000;
					i <= IDLE;
					sdram_init_done <= 1'b1;
				end
				else
					call_o <= 4'b0001;
			end

			default:
			begin
				i <= IDLE;
			end
		endcase
	
endmodule
