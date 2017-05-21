/*
 * $File: digseg_driver.v
 * $Date: Fri Oct 25 15:53:01 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

/*
 * 4-bit (one hex digit) digit 7-segment display driver
 */
module digseg_driver(
	input [3:0] data,
	output reg [0:6] seg);

	always @(*) begin
		case (data)
			4'b0000: seg = 7'b1111110;
			4'b0001: seg = 7'b0110000;
			4'b0010: seg = 7'b1101101;
			4'b0011: seg = 7'b1111001;
			4'b0100: seg = 7'b0110011;
			4'b0101: seg = 7'b1011011;
			4'b0110: seg = 7'b1011111;
			4'b0111: seg = 7'b1110000;
			4'b1000: seg = 7'b1111111;
			4'b1001: seg = 7'b1110011;
			4'b1010: seg = 7'b1110111;
			4'b1011: seg = 7'b0011111;
			4'b1100: seg = 7'b1001110;
			4'b1101: seg = 7'b0111101;
			4'b1110: seg = 7'b1001111;
			4'b1111: seg = 7'b1000111;
		endcase
	end
endmodule

