module balance_cntrl_chk_tb();

	// Create registers to hold the values from memory
	reg [31:0] mem_in [0:999];
	reg [23:0] mem_out [0:999];
	reg [31:0] stim;
	reg clk;
	reg pwr_up;
	
	
	wire too_fast;
	wire [10:0] lft_spd, rght_spd;
	wire lft_rev, rght_rev;
	
	reg [9:0] i;
	
	// Instantiate the DUT
	balance_cntrl iDUT(.clk(clk), .rst_n(stim[31]), .vld(stim[30]), 
					.ptch(stim[29:14]), .ld_cell_diff(stim[13:2]), 
					.rider_off(stim[1]), .en_steer(stim[0]), .lft_spd(lft_spd), 
					.rght_spd(rght_spd), .lft_rev(lft_rev), .rght_rev(rght_rev),
					.pwr_up(pwr_up),.too_fast(too_fast));
	
	initial begin
		// load files from memory
		$readmemh("balance_cntrl_stim.hex", mem_in);
		$readmemh("balance_cntrl_resp.hex", mem_out);
		clk = 0;
		repeat(3) @(posedge clk);
		pwr_up = 1;
		
		// iterate through all 1000 enteries of vectors
		for(i = 0; i < 1000; i = i + 1) begin
			// assign the input of the DUT			
			stim = mem_in[i];
			@(posedge clk);
			// Check all values against expected answers
			#1 if(lft_rev != mem_out[i][23]) begin
				$display("Wrong lft_rev %h %h Iter: %d", lft_rev, mem_out[i][23], i);
				$stop;
			end
			if(lft_spd != mem_out[i][22:12]) begin
				$display("Wrong lft_spd %h %h Iter: %d", lft_spd, mem_out[i][22:12], i);
				$stop;
			end
			if(rght_rev != mem_out[i][11]) begin
				$display("Wrong rght_rev %h %h Iter: %d", rght_rev, mem_out[i][11], i);
				$stop;
			end
			if(rght_spd != mem_out[i][10:0]) begin
				$display("Wrong rght_spd %h %h Iter: %d", rght_spd, mem_out[i][10:0], i);
				$stop;
			end
		end
		$display("Passed all tests in Golden Test Vectors!!");
		$stop;
	end
	
	always #5 clk = ~clk;

endmodule
