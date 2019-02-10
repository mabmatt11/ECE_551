module balance_cntrl(clk,rst_n,vld,ptch,ld_cell_diff,lft_spd,lft_rev,
                     rght_spd,rght_rev,rider_off, en_steer, pwr_up);
								
  input clk,rst_n;
  input vld;						// tells when a new valid inertial reading ready
  input signed [15:0] ptch;			// actual pitch measured
  input signed [11:0] ld_cell_diff;	// lft_ld - rght_ld from steer_en block
  input rider_off;					// High when weight on load cells indicates no rider
  input en_steer;
  input pwr_up;
  output [10:0] lft_spd;			// 11-bit unsigned speed at which to run left motor
  output lft_rev;					// direction to run left motor (1==>reverse)
  output [10:0] rght_spd;			// 11-bit unsigned speed at which to run right motor
  output rght_rev;					// direction to run right motor (1==>reverse)
  
  ////////////////////////////////////
  // Define needed registers below //
  //////////////////////////////////
  logic signed [9:0] ptch_err_sat;
  logic [14:0] ptch_P_term;
  logic [17:0] integrator;
  logic [9:0] prev_ptch_err;
  logic [9:0] next_ptch_err;
  logic [12:0] ptch_D_term;
  logic [15:0] PID_cntrl;
  logic [15:0] lft_torque;
  logic [15:0] rght_torque;
  
  ///////////////////////////////////////////
  // Define needed internal signals below //
  /////////////////////////////////////////
  logic [17:0] ptch_err_ext;
  logic [17:0] next_integrator;
  logic vld_no_ovfl;
  logic [17:0] final_next_integrator;
  logic [9:0] ptch_D_diff;
  logic signed [6:0] ptch_D_diff_sat;
  logic [15:0] ld_cell_diff_ext;
  logic [15:0] ptch_P_term_ext;
  logic [15:0] integrator_ext;
  logic [15:0] ptch_D_term_ext;
  logic [15:0] cntrl_ld_diff;
  logic [15:0] cntrl_ld_sum;
  logic [15:0] lft_mult;
  logic [15:0] rght_mult;
  logic [15:0] lft_abs_val;
  logic [15:0] rght_abs_val;
  logic [15:0] lft_add;
  logic [15:0] rght_add;
  logic lft_compare;
  logic rght_compare;
  logic [15:0] lft_shaped;
  logic [15:0] rght_shaped;
  logic [15:0] lft_shaped_abs;
  logic [15:0] rght_shaped_abs;

  /////////////////////////////////////////////
  // local params for increased flexibility //
  ///////////////////////////////////////////
  localparam P_COEFF = 5'h0E;
  localparam D_COEFF = 6'h14;				// D coefficient in PID control = +20 
    
  localparam LOW_TORQUE_BAND = 8'h46;	// LOW_TORQUE_BAND = 5*P_COEFF
  localparam GAIN_MULTIPLIER = 6'h0F;	// GAIN_MULTIPLIER = 1 + (MIN_DUTY/LOW_TORQUE_BAND)
  localparam MIN_DUTY = 15'h03D4;		// minimum duty cycle (stiffen motor and get it ready)
  
  //// You fill in the rest ////

  ////// P term in PID ///////////
  assign ptch_err_sat = (~ptch[15] && |ptch[14:9]) ? 10'h1FF : 
			(ptch[15] && ~&ptch[14:9]) ? 10'h200 :
						    ptch[9:0];

  assign ptch_P_term = $signed(P_COEFF)*ptch_err_sat;

  //////// I term in PID ////////
  assign ptch_err_ext = {{8{ptch_err_sat[9]}},ptch_err_sat};

  assign next_integrator = integrator + ptch_err_ext;

  assign vld_no_ovfl = (~vld) ? 1'b0 :
                       ((ptch_err_ext[17] == integrator[17]) && (ptch_err_ext[17] != next_integrator[17])) ? 1'b0 :
                       1'b1;

  assign final_next_integrator = (vld_no_ovfl) ? next_integrator : integrator;

  always_ff @(posedge clk, negedge rst_n)
     if (!rst_n)
        integrator <= 18'h00000;
     else if (rider_off)
        integrator <= 18'h00000;
	 else if (~pwr_up)
	    integrator <= 18'h00000;
     else
        integrator <= final_next_integrator;

  ////////// D term in PID ////////////
  always_ff @(posedge clk, negedge rst_n)
     if (!rst_n)
        next_ptch_err <= 10'h000;
     else if (vld)
        next_ptch_err <= ptch_err_sat;

  always_ff @(posedge clk, negedge rst_n)
     if (!rst_n)
        prev_ptch_err <= 10'h000;
     else if (vld)
        prev_ptch_err <= next_ptch_err;

  assign ptch_D_diff = ptch_err_sat - prev_ptch_err;

  assign ptch_D_diff_sat = (~ptch_D_diff[9] && |ptch_D_diff[8:6]) ? 7'h3F : 
			   (ptch_D_diff[9] && ~&ptch_D_diff[8:6]) ? 7'h40 :
						          ptch_D_diff[6:0];

  assign ptch_D_term = ptch_D_diff_sat*$signed(D_COEFF);

  /////////// PID MATH ////////////
  assign ld_cell_diff_ext = {{7{ld_cell_diff[11]}}, ld_cell_diff[11:3]};

  assign ptch_P_term_ext = {ptch_P_term[14], ptch_P_term[14:0]};
  
  assign integrator_ext = {{4{integrator[17]}}, integrator[17:6]};

  assign ptch_D_term_ext = {{3{ptch_D_term[12]}}, ptch_D_term};

  assign PID_cntrl = ptch_P_term_ext + integrator_ext + ptch_D_term_ext;

  assign cntrl_ld_diff = PID_cntrl - ld_cell_diff_ext;

  assign cntrl_ld_sum = PID_cntrl + ld_cell_diff_ext;

  assign lft_torque = (en_steer) ? cntrl_ld_diff : PID_cntrl;

  assign rght_torque = (en_steer) ? cntrl_ld_sum : PID_cntrl;

  //////////// FORM DUTY /////////////
  //////////// LEFT SIDE /////////////
  assign lft_mult = lft_torque*GAIN_MULTIPLIER;

  assign lft_abs_val = (lft_torque[15]) ? ~lft_torque + 1 : lft_torque;
  
  assign lft_add = (lft_torque[15]) ? lft_torque - MIN_DUTY : lft_torque + MIN_DUTY;

  assign lft_compare = (lft_abs_val >= LOW_TORQUE_BAND) ? 1'b1 : 1'b0;

  assign lft_shaped = (lft_compare) ? lft_add : lft_mult;

  assign lft_shaped_abs = (lft_shaped[15]) ? ~lft_shaped + 1 : lft_shaped;

  assign lft_spd = (|lft_shaped_abs[15:11]) ? 11'h7FF : lft_shaped_abs[10:0];

  assign lft_rev = lft_shaped[15];

  ///////////// RIGHT SIDE ///////////////
  assign rght_mult = rght_torque*GAIN_MULTIPLIER;

  assign rght_abs_val = (rght_torque[15]) ? ~rght_torque + 1 : rght_torque;
  
  assign rght_add = (rght_torque[15]) ? rght_torque - MIN_DUTY : rght_torque + MIN_DUTY;

  assign rght_compare = (rght_abs_val >= LOW_TORQUE_BAND) ? 1'b1 : 1'b0;

  assign rght_shaped = (rght_compare) ? rght_add : rght_mult;

  assign rght_shaped_abs = (rght_shaped[15]) ? ~rght_shaped + 1 : rght_shaped;

  assign rght_spd = (|rght_shaped_abs[15:11]) ? 11'h7FF : rght_shaped_abs[10:0];

  assign rght_rev = rght_shaped[15];
	           

endmodule 
