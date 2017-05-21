/*
 * $File: vga_driver.v
 * $Date: Mon Dec 30 20:56:56 2013 +0800
 * $Author: Xinyu Zhou <zxytim@gmail.com>
 *          jiakai <jia.kai66@gmail.com>
 */


// specification reference:
// http://tinyvga.com/vga-timing/800x600@72Hz
module vga_driver(
	input clk50M,
//    input [20:0] ram_start_addr, // display data is from ram_start_addr

	output reg [8:0] color_out, // 3 red, 3 green, 3 blue
	output hsync,
	output vsync
	);

	assign clk = clk50M;

	localparam H_VISIBLE_AREA = 800,
		H_FRONT_PORCH = 56,
		H_SYNC_PULSE = 120,
		H_BACK_PORCH = 64,
		H_WHOLE = 1040;

	localparam V_VISIBLE_AREA = 600,
		V_FRONT_PORCH = 37,
		V_SYNC_PULSE = 6,
		V_BACK_PORCH = 23,
		V_WHOLE = 666;

	reg [10:0] hsync_cnt = 0;
	reg [10:0] vsync_cnt = 0;

	assign hsync = (hsync_cnt >= H_SYNC_PULSE);
	assign vsync = (vsync_cnt >= V_SYNC_PULSE);

	wire [10:0] pixel_x = (hsync_cnt >= H_SYNC_PULSE + H_FRONT_PORCH ?
		hsync_cnt - H_SYNC_PULSE - H_FRONT_PORCH : {11{1'b1}});
	wire [10:0] pixel_y = (vsync_cnt >= V_SYNC_PULSE + V_FRONT_PORCH ?
		vsync_cnt - V_SYNC_PULSE - V_FRONT_PORCH : {11{1'b1}});

	wire should_draw = pixel_x >= 0 && pixel_x < H_VISIBLE_AREA && pixel_y >= 0 && pixel_y < V_VISIBLE_AREA;

	always @(posedge clk) begin
		if (hsync_cnt == H_WHOLE - 1) begin
			hsync_cnt <= 0;
			if (vsync_cnt == V_WHOLE - 1) begin
				vsync_cnt <= 0;
			end else begin
				vsync_cnt <= vsync_cnt + 1'b1;
			end
		end else begin
			hsync_cnt <= hsync_cnt + 1'b1;
		end
		if (should_draw) begin
			//`include "logo.v"
			color_out <= {9{1'b1}};
		end else
			color_out <= 0;
	end

endmodule
