module SPI_mstr16(clk, rst_n, SS_n, SCLK, MOSI, MISO, wrt, cmd, done, rd_data);

	input clk, rst_n, wrt, MISO;
	input [15:0] cmd;
	output SS_n, SCLK, MOSI, done;
	output [15:0] rd_data;

	reg [4:0] sclk_div, sampled;
	reg [15:0] shft_reg;
	reg rst_cnt, shft, smpl, done, MISO_smpl, SS_n, set_done, clr_done;
	
	typedef enum reg [1:0] {IDLE, SAMPLE, FRONT_PORCH, BACK_PORCH} state_t;
	state_t state, nxt_state;

	// State of the SM
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			state <= IDLE;
		else 
			state <= nxt_state;
	end
	
	// Clock divider
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			sclk_div <= 5'b10111;
		else if(rst_cnt)
			sclk_div <= 5'b10111;
		else 
			sclk_div <= sclk_div + 1;
	end
	
	// MISO sample value
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			MISO_smpl <= 1'b0;
		else if(smpl)
			MISO_smpl <= MISO;
	end
	
	// Main 16-bit shift register
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			shft_reg <= 16'h0;
		else if(wrt) 
			shft_reg <= cmd;
		else if(shft)
			shft_reg <= {shft_reg[14:0], MISO_smpl};
	end

	// Keep track of # shifts that have occurred
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			sampled <= 5'b0;
		else if(wrt)
			sampled <= 5'b0; 
		else if(smpl)
			sampled <= sampled + 1;
	end

	// SR-FF for done signal
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			done <= 1'b0;
		else if(clr_done)
			done <= 1'b0;
		else if(set_done)
			done <= 1'b1;
	end

	// SR-FF for SS_n signal
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			SS_n <= 1'b1;
		else if(set_done)
			SS_n <= 1'b1;
		else if(clr_done)
			SS_n <= 1'b0;
	end
	
	always_comb begin
		// Set default values for SM outputs
		nxt_state = IDLE;
		rst_cnt = 0;
		shft = 0;
		smpl = 0;
		set_done = 0;
		clr_done = 0;

		case(state)
			// Contains logic for both sampling and shifting	
			SAMPLE: begin
				if(sclk_div == 5'b01111)
					smpl = 1;
				else if(sclk_div == 5'b11111)
					shft = 1;
				nxt_state = sampled == 5'd16 ? BACK_PORCH : SAMPLE;
			end
			FRONT_PORCH: begin
				// Wait for SCLK to drop before beginning to wait for sample/shift
				nxt_state = sclk_div == 5'b00000 ? SAMPLE : FRONT_PORCH;
			end
			BACK_PORCH: begin
				// Shift last bit into shift register
				shft = sclk_div == 5'b11110;
				nxt_state = shft ? IDLE : BACK_PORCH;
				set_done = shft;
			end
			// Idle state
			default: begin
				rst_cnt = 1;
				nxt_state = wrt ? FRONT_PORCH : IDLE;
				clr_done = wrt;
				shft = nxt_state == FRONT_PORCH;
			end 
		endcase
	end
	
	// Continuously assigned values
	assign SCLK = sclk_div[4];
	assign MOSI = shft_reg[15];
	assign rd_data = shft_reg;

endmodule
