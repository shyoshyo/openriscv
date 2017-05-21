/*
 * $File: memtrans.v
 * $Date: Fri Nov 01 22:32:35 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

/*
* protocol:
* s: server (PC)
* c: client (our board)
* byte order in each word: LSB -> MSB
* s -> c:
*	CMD_WRITE
*		s -> c:
*			3 bytes start_addr
*			3 bytes end_addr
*		c -> s:
*			1 byte, checksum
*		s -> s:
*			2 * (start_addr - end_addr) bytes, the data
*		c -> s:
*			1 byte, checksum
*		goto idle state
* s -> c:
*	CMD_READ
*		s -> c:
*			3 bytes start_addr
*			3 bytes end_addr
*		c -> s:
*			1 byte, checksum
*		c -> s
*			2 * (start_addr - end_addr) bytes, the data
*			for each word
*		c -> s:
*			1 byte, checksum
* s -> c:
*	CMD_ERASE
*		s -> c:
*			3 bytes start_addr
*			3 bytes end_addr
*			(only start_addr would be used)
*		c -> s:
*			1 byte, checksum
*		c -> s:
*			CMD_ERASE_IN_PROGRESS ...
*		c -> s:
*			CMD_ERASE_FINISHED
*
* output:
*	segdisp: number of 4k blocks
*/

module memtrans
	(
	input clk,
	input rst,
	output [15:0] led,
	output [0:6] segdisp0,
	output [0:6] segdisp1,

	output [22:0] flash_addr,
	inout [15:0] flash_data,
	output [7:0] flash_ctl,

	output com_TxD,
	input com_RxD,

	output [19:0] baseram_addr,
	inout [31:0] baseram_data,
	output baseram_ce,
	output baseram_oe,
	output baseram_we,
	output [19:0] extram_addr,
	inout [31:0] extram_data,
	output extram_ce,
	output extram_oe,
	output extram_we);


	localparam
		CMD_FLASH_WRITE	= 8'b01110000,
		CMD_FLASH_READ	= 8'b00001111,
		CMD_FLASH_ERASE	= 8'b00111000,
		CMD_RAM_WRITE	= 8'b11110011,
		CMD_RAM_READ	= 8'b10010011,
		CMD_ERASE_IN_PROGRESS	= 8'b11001100,
		CMD_ERASE_FINISHED		= 8'b00110011;
				

	reg [19:0] frame_cnt;

	// display number of 4k blocks
	digseg_driver disp_fc_high(.data(frame_cnt[19:16]), .seg(segdisp1));
	digseg_driver disp_fc_low(.data(frame_cnt[15:12]), .seg(segdisp0));

	// ------------------- general -----------------------
	reg [7:0] checksum;
	reg [21:0] start_addr, end_addr;
	wire [21:0] start_addr_next = start_addr + 1'b1;
	wire [7:0] checksum_init = 8'h23;
	// ----------------- end general ---------------------

	// ------------------ com part -----------------------
	reg uart_TxD_start;
	wire uart_TxD_busy, uart_RxD_data_ready;

	reg [31:0] data_to_com_shift;
	reg [7:0] data_to_com;
	reg [2:0] nr_data_to_com;
	wire [2:0] nr_data_to_com_prev = nr_data_to_com - 1'b1;

	wire [7:0] data_from_com;

	uart uart_inst(
		.clk(~clk), .rst(~rst), // invert clock to ensure stable signal on posedge
		.data_in(data_to_com), .data_out(data_from_com),
		.TxD_start(uart_TxD_start), .TxD_busy(uart_TxD_busy),
		.RxD_data_ready(uart_RxD_data_ready),
		.com_TxD(com_TxD), .com_RxD(com_RxD));

	reg [47:0] data_from_com_shift;
	always @(posedge clk) begin
		if (~rst) begin
			frame_cnt <= 0;
		end
		else if (uart_RxD_data_ready) begin
			data_from_com_shift <= {data_from_com, data_from_com_shift[47:8]};
			frame_cnt <= frame_cnt + 1'b1;
		end else if (uart_TxD_start)
			frame_cnt <= frame_cnt + 1'b1;
	end
	// ----------------- end com part ---------------------


	// ------------------ flash part ----------------------
	wire flash_busy;
	wire [15:0] data_from_flash;
	wire [15:0] data_to_flash = data_from_com_shift[47:32];
	reg enable_flash_write = 0,
		enable_flash_read = 0,
		enable_flash_erase = 0;

	flash_driver flash_driver_inst(
		.clk(~clk),	
		.addr(start_addr),
		.data_in(data_to_flash),
		.data_out(data_from_flash),
		.enable_read(enable_flash_read),
		.enable_write(enable_flash_write),
		.enable_erase(enable_flash_erase),
		.busy(flash_busy),
		.flash_addr(flash_addr), .flash_data(flash_data), .flash_ctl(flash_ctl));
	// ----------------- end flash part --------------------


	// ------------------ ram part --------------------------
	wire ram_read_ready;
	wire [31:0] data_from_ram;
	reg enable_ram = 0, enable_ram_write = 0, enable_ram_read = 0;
	ram_driver ram_driver_inst(
		.clk(~clk),
		.enable(enable_ram),
		.enable_read(enable_ram_read),
		.enable_write(enable_ram_write),
		.addr(start_addr[20:0]),
		.data_in(data_from_com_shift[47:16]),
		.data_out(data_from_ram),
		.write_finished(),
		.read_ready(ram_read_ready),
		.baseram_addr(baseram_addr), .baseram_data(baseram_data),
		.baseram_ce(baseram_ce), .baseram_oe(baseram_oe), .baseram_we(baseram_we),
		.extram_addr(extram_addr), .extram_data(extram_data),
		.extram_ce(extram_ce), .extram_oe(extram_oe), .extram_we(extram_we));
	// ----------------- end ram part -----------------------

	
	`include "state.v"

	reg [STATE_WIDTH-1:0]
		state,
		state_after_meta_ack, state_after_uart_sent,
		state_after_recv_com, state_after_send_com;

	assign led = {state, frame_cnt[7-STATE_WIDTH:0],
		com_RxD,
		enable_ram, enable_ram_read, enable_ram_write, 
		enable_flash_erase, enable_flash_read, enable_flash_write,
		flash_busy};
		

	reg [2:0] nr_data_from_com;
	wire [2:0] nr_data_from_com_prev = nr_data_from_com - 1'b1;

	always @(posedge clk) begin
		if (!rst)
			state <= IDLE;
		else case (state)
			IDLE: begin
				uart_TxD_start <= 0;
				checksum <= checksum_init;
				enable_flash_write <= 0;
				enable_flash_read <= 0;
				enable_flash_erase <= 0;
				enable_ram <= 0;
				enable_ram_read <= 0;
				enable_ram_write <= 0;
				if (uart_RxD_data_ready) begin
					state <= RECV_META;

					case (data_from_com)
						CMD_FLASH_WRITE:
							state_after_meta_ack <= FLASH_WRITE_INIT_TRANSFER;
						CMD_FLASH_READ:
							state_after_meta_ack <= FLASH_READ_INIT_TRANSFER;
						CMD_FLASH_ERASE:
							state_after_meta_ack <= FLASH_ERASE_START;
						CMD_RAM_WRITE:
							state_after_meta_ack <= RAM_WRITE_INIT_TRANSFER;
						CMD_RAM_READ:
							state_after_meta_ack <= RAM_READ_INIT_TRANSFER;
						default:	// invalid command
							state_after_meta_ack <= IDLE;
					endcase
				end
			end

			RECV_META: begin
				nr_data_from_com <= 6;
				state_after_recv_com <= META_ACK;
				state <= RECV_FROM_COM;
			end
			META_ACK: begin
				start_addr <= data_from_com_shift[21:0];
				end_addr <= data_from_com_shift[45:24];
				data_to_com <= checksum;
				uart_TxD_start <= 1;
				state <= WAITING_UART_SEND;
				state_after_uart_sent <= state_after_meta_ack;
				checksum <= checksum_init;
			end

			FLASH_WRITE_INIT_TRANSFER: begin
				nr_data_from_com <= 2;
				state_after_recv_com <= FLASH_WRITE_DO_WRITE;
				state <= RECV_FROM_COM;
			end
			FLASH_WRITE_DO_WRITE: begin
				if (flash_busy)
					state <= ERROR;	// flash too slow
				else begin
					enable_flash_write <= 1;
					state <= FLASH_WRITE_RESTORE_CTL;
				end
			end
			FLASH_WRITE_RESTORE_CTL: begin
				if (flash_busy) begin
					enable_flash_write <= 0;
					start_addr <= start_addr_next;
					if (start_addr_next == end_addr)
						state <= SEND_CHECKSUM_AND_IDLE;
					else begin
						nr_data_from_com <= 2;
						state_after_recv_com <= FLASH_WRITE_DO_WRITE;
						state <= RECV_FROM_COM;
					end
				end
			end


			FLASH_READ_INIT_TRANSFER: begin
				enable_flash_read <= 1;
				state <= FLASH_READ_DO_READ;
			end
			FLASH_READ_DO_READ:
				if (!flash_busy) begin
					data_to_com_shift <= data_from_flash;
					start_addr <= start_addr_next;
					nr_data_to_com <= 2;
					state <= SEND_TO_COM;
					if (start_addr_next == end_addr)
						state_after_send_com <= SEND_CHECKSUM_AND_IDLE;
					else
						state_after_send_com <= FLASH_READ_DO_READ;
				end

			FLASH_ERASE_START: begin
				enable_flash_erase <= 1;
				state <= FLASH_ERASE_WAIT;
			end
			FLASH_ERASE_WAIT: begin
				uart_TxD_start <= 1;
				enable_flash_erase <= 0;
				if (flash_busy) begin
					data_to_com <= CMD_ERASE_IN_PROGRESS;
					state <= WAITING_UART_SEND;
					state_after_uart_sent <= FLASH_ERASE_WAIT;
				end else begin
					data_to_com <= CMD_ERASE_FINISHED;
					state <= WAITING_UART_SEND;
					state_after_uart_sent <= IDLE;
				end
			end


			RAM_WRITE_INIT_TRANSFER: begin
				enable_ram <= 1;
				nr_data_from_com <= 4;
				state_after_recv_com <= RAM_WRITE_DO_WRITE;
				state <= RECV_FROM_COM;
			end
			RAM_WRITE_DO_WRITE: begin
				enable_ram_write <= 1;
				state <= RAM_WRITE_RESTORE_CTL;
			end
			RAM_WRITE_RESTORE_CTL: begin
				enable_ram_write <= 0;
				start_addr <= start_addr_next;
				if (start_addr_next == end_addr)
					state <= SEND_CHECKSUM_AND_IDLE;
				else begin
					nr_data_from_com <= 4;
					state_after_recv_com <= RAM_WRITE_DO_WRITE;
					state <= RECV_FROM_COM;
				end
			end

			RAM_READ_INIT_TRANSFER: begin
				enable_ram <= 1;
				enable_ram_read <= 1;
				state <= RAM_READ_DO_READ;
			end
			RAM_READ_DO_READ: begin
				if (ram_read_ready) begin
					start_addr <= start_addr_next;
					data_to_com_shift <= data_from_ram;
					nr_data_to_com <= 4;
					state <= SEND_TO_COM;
					if (start_addr_next == end_addr)
						state_after_send_com <= SEND_CHECKSUM_AND_IDLE;
					else
						state_after_send_com <= RAM_READ_DO_READ;
				end
			end

			// waiting for finishing uart send,
			// then return to state_after_uart_sent
			WAITING_UART_SEND:
				if (uart_TxD_busy) begin
					state <= WAITING_UART_SEND_1;
					uart_TxD_start <= 0;
				end
			WAITING_UART_SEND_1: begin
				if (~uart_TxD_busy)
					state <= state_after_uart_sent;
			end

			// receive nr_data_from_com bytes from com; also update checksum
			// then return to state_after_recv_com
			RECV_FROM_COM:
				if (uart_RxD_data_ready) begin
					nr_data_from_com <= nr_data_from_com_prev;
					checksum <= checksum ^ data_from_com;
					if (!nr_data_from_com_prev)
						state <= state_after_recv_com;
				end

			// write nr_data_to_com bytes to com by shifting-right
			// data_to_com_shift; also update checksum
			// return to state_after_send_com
			SEND_TO_COM:
				if (uart_TxD_busy)
					state <= ERROR;
				else begin
					uart_TxD_start <= 1;
					state <= WAITING_UART_SEND;
					nr_data_to_com <= nr_data_to_com_prev;
					checksum <= checksum ^ data_to_com_shift[7:0];
					data_to_com <= data_to_com_shift[7:0];
					data_to_com_shift <= data_to_com_shift >> 8;
					if (!nr_data_to_com_prev)
						state_after_uart_sent <= state_after_send_com;
					else 
						state_after_uart_sent <= SEND_TO_COM;
				end

			// send checksum to server and return to idle state
			SEND_CHECKSUM_AND_IDLE: begin
				enable_ram <= 0;
				enable_ram_read <= 0;
				enable_ram_write <= 0;
				enable_flash_read <= 0;
				enable_flash_write <= 0;
				enable_flash_erase <= 0;
				data_to_com <= checksum;
				uart_TxD_start <= 1;
				state_after_uart_sent <= IDLE;
				state <= WAITING_UART_SEND;
			end

			ERROR:
				state <= ERROR;	// loop forever

			default:
				state <= IDLE;
		endcase
	end

endmodule



