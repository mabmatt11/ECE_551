module steer_en(clk,rst_n,en_steer,rider_off,lft_ld,rght_ld,ld_cell_diff);

	input logic signed [11:0] lft_ld,rght_ld;
	input logic clk, rst_n;
	
	output logic en_steer,rider_off;
	output logic signed [11:0] ld_cell_diff;
	
	logic tmr_full;			// asserted when timer reaches 1.3 sec
	logic sum_gt_min;			// asserted when left and right load cells together exceed min rider weight
	logic sum_lt_min;	
	logic diff_gt_1_4;		// asserted if load cell difference exceeds 1/4 sum (rider not situated)
	logic diff_gt_15_16;		// asserted if load cell difference is great (rider stepping off)
	logic clr_tmr;	
	logic signed [12:0] sum_ld;
	logic signed [11:0] abs_diff_ld;
	logic [25:0] cnt_26; 
	
	localparam MIN_RIDER_WEIGHT = 12'h200;
	
	parameter fast_sim = 1;
	
	////////// INSTANTIATE steer_en_SM for logic use //////////////////
	steer_en_SM steer_en_SM(.clk(clk),.rst_n(rst_n),.tmr_full(tmr_full),.sum_gt_min(sum_gt_min),.sum_lt_min(sum_lt_min),
	                        .diff_gt_1_4(diff_gt_1_4),.diff_gt_15_16(diff_gt_15_16),.clr_tmr(clr_tmr),.en_steer(en_steer),.rider_off(rider_off));
	
	assign sum_gt_min = (lft_ld+rght_ld >= MIN_RIDER_WEIGHT);  //wait till rider has stepped on
	
	assign sum_lt_min = (lft_ld+rght_ld < MIN_RIDER_WEIGHT); 
	
	assign ld_cell_diff = lft_ld - rght_ld;
	
	assign sum_ld = lft_ld + rght_ld;
	
	assign abs_diff_ld = (ld_cell_diff[11]) ? ~ld_cell_diff + 1 : ld_cell_diff;
	
    assign diff_gt_1_4 = (abs_diff_ld>(sum_ld/4)); // asserted when difference is greater than 1/4 sum (rider not situated)
	
	assign diff_gt_15_16 = (abs_diff_ld>(15*sum_ld/16)); // asserted when difference is less than 15/16 sum (rider stepping off)
	
	always_ff @(posedge clk, negedge rst_n) // Counter to create 1.34 second timer
		if (~rst_n) 
			cnt_26 <= 26'h0000000;
		else if (clr_tmr)
			cnt_26 <= 26'h0000000;
		else
			cnt_26 <= cnt_26+1;
			
	assign tmr_full = (fast_sim) ? &cnt_26[14:0] : &cnt_26;  //when the timer is full assert tmr_full
	
endmodule
	
	