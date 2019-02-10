module steer_en_SM(clk,rst_n,tmr_full,sum_gt_min,sum_lt_min,diff_gt_1_4,
                   diff_gt_15_16,clr_tmr,en_steer,rider_off);

  input clk;				// 50MHz clock
  input rst_n;				// Active low asynch reset
  input tmr_full;			// asserted when timer reaches 1.3 sec
  input sum_gt_min;			// asserted when left and right load cells together exceed min rider weight
  input sum_lt_min;			// asserted when left_and right load cells are less than min_rider_weight

  /////////////////////////////////////////////////////////////////////////////
  // HEY BUDDY...you are a moron.  sum_gt_min would simply be ~sum_lt_min. Why
  // have both signals coming to this unit??  ANSWER: What if we had a rider
  // (a child) who's weigth was right at the threshold of MIN_RIDER_WEIGHT?
  // We would enable steering and then disable steering then enable it again,
  // ...  We would make that child crash(children are light and flexible and 
  // resilient so we don't care about them, but it might damage our Segway).
  // We can solve this issue by adding hysteresis.  So sum_gt_min is asserted
  // when the sum of the load cells exceeds MIN_RIDER_WEIGHT + HYSTERESIS and
  // sum_lt_min is asserted when the sum of the load cells is less than
  // MIN_RIDER_WEIGHT - HYSTERESIS.  Now we have noise rejection for a rider
  // who's wieght is right at the threshold.  This hysteresis trick is as old
  // as the hills, but very handy...remember it.
  //////////////////////////////////////////////////////////////////////////// 

  input diff_gt_1_4;		// asserted if load cell difference exceeds 1/4 sum (rider not situated)
  input diff_gt_15_16;		// asserted if load cell difference is great (rider stepping off)
  output logic clr_tmr;		// clears the 1.3sec timer
  output logic en_steer;	// enables steering (goes to balance_cntrl)
  output logic rider_off;	// pulses high for one clock on transition back to initial state
  
  // You fill out the rest...use good SM coding practices ///

    reg [1:0] state;

    wire [1:0] nxt_state;

    // State machine values
    parameter MOUNT = 2'b00, WAIT_ENABLE = 2'b01, ENABLE = 2'b10;

    // Begin a state machine
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            state <= MOUNT;
        else
            state <= nxt_state;

    // Begin state transitions at correct spots
    assign nxt_state = (state == MOUNT && sum_gt_min && ~diff_gt_1_4) ? WAIT_ENABLE :       // Begin the timer when the rider steps onto the device
                       (state == WAIT_ENABLE && (sum_lt_min)) ? MOUNT :                     // Go to the init state if the timer is still going and the rider steps off
                       (state == WAIT_ENABLE && (tmr_full && ~diff_gt_1_4)) ? ENABLE :      // Go to the enable steer state if the timer is full and the absolute difference is not high
                       (state == ENABLE && diff_gt_15_16) ? WAIT_ENABLE :                   // Enable the timer again whent he absolute difference is high
                       (state == ENABLE && sum_lt_min) ? MOUNT :                            // Go to the init state if the rider falls off
                       state;

    // Only clear the timer when we are either still in the init state or
    // waiting to enable and the absolue difference is greater than 1/4
    assign clr_tmr = (state == MOUNT || (state == ENABLE && diff_gt_1_4));

    // Enable steering only when we are in the enable state
    assign en_steer = (state == ENABLE);

    // Enable the rider off state when riders weight is below minimum and we
    // are not in the init state
    assign rider_off = (state == ENABLE && sum_lt_min) || (state == WAIT_ENABLE && sum_lt_min);

endmodule
