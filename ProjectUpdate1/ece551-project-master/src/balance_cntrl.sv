module balance_cntrl(clk,rst_n,vld,ptch,ld_cell_diff,lft_spd,lft_rev,
                     rght_spd,rght_rev,rider_off, en_steer, pwr_up, too_fast);
								
  	input clk,rst_n;
  	input vld;						// tells when a new valid inertial reading ready
  	input signed [15:0] ptch;			// actual pitch measured
  	input signed [11:0] ld_cell_diff;	// lft_ld - rght_ld from steer_en block
  	input rider_off;					// High when weight on load cells indicates no rider
  	input en_steer;
	input pwr_up;					// Comes from Auth_blk to enable device
  	output [10:0] lft_spd;			// 11-bit unsigned speed at which to run left motor
  	output lft_rev;					// direction to run left motor (1==>reverse)
  	output [10:0] rght_spd;			// 11-bit unsigned speed at which to run right motor
 	output rght_rev;				// direction to run right motor (1==>reverse)
	output too_fast;				// Warns rider if the speed is too fast
  
  	////////////////////////////////////
  	// Define needed registers below //
  	//////////////////////////////////
  	reg signed [17:0] integrator;
  	reg signed [9:0] first_reading, prev_ptch_err;
  
  	///////////////////////////////////////////
  	// Define needed internal signals below //
  	/////////////////////////////////////////

	wire signed [9:0] ptch_err_sat, nxt_first_reading, nxt_prev_ptch_err, ptch_D_diff;
	wire signed [14:0] ptch_P_term_old;
    reg signed [14:0] ptch_P_term;
	wire signed [17:0] nxt_integrator, hold_integrator, summed_integrator, extended_integrator;
	wire ov, hold, pos_sat, neg_sat, d_pos_sat, d_neg_sat, lft_greater, rght_greater;
	wire signed [12:0] ptch_D_term_old;
    reg signed [12:0] ptch_D_term;
    wire signed [6:0] diff_sat;
	wire signed [15:0] ld_cell_diff_extended, ptch_P_term_extended, integrator_extended, ptch_D_term_extended, PID_cntrl, cell_diff, cell_sum, lft_torque_abs, rght_torque_abs, lft_torque_old, rght_torque_old, lft_plus_min, rght_plus_min, lft_mult_gain, rght_mult_gain, lft_abs, rght_abs, lft_shaped, rght_shaped, integrator_choice;

    reg signed [15:0] lft_torque, rght_torque;

	/////////////////////////////////////////////
	// local params for increased flexibility //
	///////////////////////////////////////////
	localparam P_COEFF = 5'h0E;
	localparam D_COEFF = 6'h14;				// D coefficient in PID control = +20 
    
	localparam LOW_TORQUE_BAND = 8'h46;	// LOW_TORQUE_BAND = 5*P_COEFF
	localparam GAIN_MULTIPLIER = 6'h0F;	// GAIN_MULTIPLIER = 1 + (MIN_DUTY/LOW_TORQUE_BAND)
	localparam MIN_DUTY = 15'h03D4;		// minimum duty cycle (stiffen motor and get it ready)

	/////////////////
	// Parameters //
	////////////////
	parameter fast_sim = 0;
  
	//// You fill in the rest ////
   
	// P term 
	// Saturate
    assign pos_sat = ptch > $signed(10'h1FF);
    assign neg_sat = ptch < $signed(10'h200);
    assign ptch_err_sat = (pos_sat) ? 10'h1FF : (neg_sat) ? 10'h200 : ptch[9:0];

    // Signed multiply
    assign ptch_P_term_old = ptch_err_sat * $signed(P_COEFF);

    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            ptch_P_term <= 0;
        else
            ptch_P_term <= ptch_P_term_old;
    
    // I term
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            integrator <= 18'h00000;
        else
            integrator <= nxt_integrator;

    assign nxt_integrator = (rider_off | ~pwr_up) ? 18'h00000 : hold_integrator;
    assign hold_integrator = (hold) ? summed_integrator : integrator;
    assign summed_integrator = integrator + extended_integrator;
    assign extended_integrator = {{8{ptch_err_sat[9]}}, ptch_err_sat};
    assign ov = extended_integrator[17] == integrator[17] && extended_integrator[17] != summed_integrator[17];
    assign hold = vld & ~ov;
    
    // D term
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            first_reading <= 10'h000;
        else
            first_reading <= nxt_first_reading;

    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            prev_ptch_err <= 10'h000;
        else
            prev_ptch_err <= nxt_prev_ptch_err;

    assign nxt_first_reading = (vld) ? ptch_err_sat : first_reading;
    assign nxt_prev_ptch_err = (vld) ? first_reading : prev_ptch_err;
    assign ptch_D_diff = ptch_err_sat - prev_ptch_err;

    assign d_pos_sat = ptch_D_diff > $signed(7'h3F);
    assign d_neg_sat = ptch_D_diff < $signed(7'h40);
    assign diff_sat = (d_pos_sat) ? 7'h3F : (d_neg_sat) ? 7'h40 : ptch_D_diff[6:0];
    assign ptch_D_term_old = diff_sat * $signed(D_COEFF);

    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            ptch_D_term <= 0;
        else
            ptch_D_term <= ptch_D_term_old;
	
	// Sum
	assign ptch_P_term_extended = {ptch_P_term[14], ptch_P_term};
    assign integrator_extended = {{4{integrator[17]}}, integrator[17:6]};
    assign ptch_D_term_extended = {{3{ptch_D_term[12]}}, ptch_D_term};
    assign ld_cell_diff_extended = {{7{ld_cell_diff[11]}}, ld_cell_diff[11:3]};
    
	assign integrator_choice = fast_sim ? integrator[17:2] : integrator_extended;

    assign PID_cntrl = ptch_P_term_extended + integrator_choice + ptch_D_term_extended;
    assign cell_diff = PID_cntrl - ld_cell_diff_extended;
    assign cell_sum = PID_cntrl + ld_cell_diff_extended;

    assign lft_torque_old = (en_steer) ? cell_diff : PID_cntrl;
    assign rght_torque_old = (en_steer) ? cell_sum : PID_cntrl;

    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            lft_torque <= 0;
        else
            lft_torque <= lft_torque_old;

    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            rght_torque <= 0;
        else
            rght_torque <= rght_torque_old;
	
	// Shape Torque
	assign lft_torque_abs = lft_torque[15] ? -lft_torque : lft_torque;
	assign rght_torque_abs = rght_torque[15] ? -rght_torque : rght_torque;
	// calculate what will need to be done to the torque
	assign rght_greater = rght_torque_abs >= $signed(LOW_TORQUE_BAND);
	assign lft_greater = lft_torque_abs >= $signed(LOW_TORQUE_BAND);
	assign lft_plus_min = lft_torque[15] ? lft_torque - MIN_DUTY : lft_torque + MIN_DUTY;
	assign rght_plus_min = rght_torque[15] ? rght_torque - MIN_DUTY : rght_torque + MIN_DUTY;
	// perform signed multiplication
	assign lft_mult_gain = lft_torque * $signed(GAIN_MULTIPLIER);
	assign rght_mult_gain = rght_torque * $signed(GAIN_MULTIPLIER);

	// assign the correct calculation based off if the torque was greater or not
	assign lft_shaped = lft_greater ? lft_plus_min : lft_mult_gain;
	assign rght_shaped = rght_greater ? rght_plus_min : rght_mult_gain;
	assign lft_abs = lft_shaped[15] ? -lft_shaped : lft_shaped;
	assign rght_abs = rght_shaped[15] ? -rght_shaped : rght_shaped;
	assign lft_rev = lft_shaped[15];
	assign rght_rev = rght_shaped[15];
	assign lft_spd = pwr_up ? $unsigned(lft_abs) > 11'h7FF ? 11'h7FF : lft_abs[10:0] : 11'd0;
	assign rght_spd = pwr_up ? $unsigned(rght_abs) > 11'h7FF ? 11'h7FF : rght_abs[10:0] : 11'd0;
	assign too_fast = ($signed(lft_spd) > $signed(11'd1536) || $signed(rght_spd) > $signed(11'd1536));
  
endmodule 
