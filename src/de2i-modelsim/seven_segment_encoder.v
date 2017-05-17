/**
 *  将二进制转换为七段数字码
 */

module seven_segment_encoder
(
	input wire rst_n,
	
	input wire [3:0]data,
	output wire [6:0]seven_segment_data
);
	parameter _0 = 8'b1100_0000, _1 = 8'b1111_1001, _2 = 8'b1010_0100, 
	          _3 = 8'b1011_0000, _4 = 8'b1001_1001, _5 = 8'b1001_0010,
			  _6 = 8'b1000_0010, _7 = 8'b1111_1000, _8 = 8'b1000_0000,
			  _9 = 8'b1001_0000, _a = 8'b1000_1000, _b = 8'b1000_0011,
			  _c = 8'b1100_0110, _d = 8'b1010_0001, _e = 8'b1000_0110,
			  _f = 8'b1000_1110;
				 
	
	reg [7:0]seven_segment_data_r;
	
	/********************************************/

	always @(*)
		if(!rst_n)
		begin
			seven_segment_data_r <= 8'hff;
		end
		else
			case(data)
				4'h0: seven_segment_data_r <= _0;
				4'h1: seven_segment_data_r <= _1;
				4'h2: seven_segment_data_r <= _2;
				4'h3: seven_segment_data_r <= _3;
				
				4'h4: seven_segment_data_r <= _4;
				4'h5: seven_segment_data_r <= _5;
				4'h6: seven_segment_data_r <= _6;
				4'h7: seven_segment_data_r <= _7;
				
				4'h8: seven_segment_data_r <= _8;
				4'h9: seven_segment_data_r <= _9;
				4'ha: seven_segment_data_r <= _a;
				4'hb: seven_segment_data_r <= _b;
				
				4'hc: seven_segment_data_r <= _c;
				4'hd: seven_segment_data_r <= _d;
				4'he: seven_segment_data_r <= _e;
				4'hf: seven_segment_data_r <= _f;
				
				default: seven_segment_data_r <= 8'hff;
			endcase
	
	/********************************************/
	
	assign seven_segment_data = seven_segment_data_r[6:0];

endmodule