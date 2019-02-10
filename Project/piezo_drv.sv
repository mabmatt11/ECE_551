module piezo_drv(clk,rst_n,norm_mode,ovr_spd,batt_low,dig_sqr,dig_sqr_n);

	input logic clk,rst_n;
	input logic norm_mode,ovr_spd,batt_low;
	
	output logic dig_sqr,dig_sqr_n;
	
	logic cnt_27;
	
	always_ff @(posedge clk, negedge rst_n)  // 2 second counter
		if (~rst_n)
			cnt_27 <= 27'h0000000;
		else if (cnt_27 == 27'd200000000)
			cnt_27 <= 27'h0000000;
		else
			cnt_27 <= cnt_27 + 1;
			
	assign dig_sqr = 
																 
	assign dig_sqr_n = ~dig_sqr;
	
	
	
	