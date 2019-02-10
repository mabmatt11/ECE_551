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

  input diff_gt_1_4;		// asserted if load cell difference exceeds 1/8 sum (rider not situated)
  input diff_gt_15_16;		// asserted if load cell difference is great (rider stepping off)
  output clr_tmr;			// clears the 1.3sec timer
  output logic en_steer;	// enables steering (goes to balance_cntrl)
  output rider_off;			// pulses high for one clock on transition back to initial state
  
  // You fill out the rest...use good SM coding practices ///

  typedef enum reg [1:0] {IDLE,WAIT,STEER_EN} state_t; //Set up the states in the State machine
                          state_t state, nxt_state;

  /////////// infer state flop ///////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
      state <= IDLE; //Defualt state is IDLE
    else
      state <= nxt_state; //Move to next state on clock edge

  ////////// Combinational Logic for State Transitions ///////////
  always_comb begin
    en_steer = 1'b0; //set defaults to avoid flops
    nxt_state = IDLE; 

	//case statements on switching states
    case (state)
      IDLE : if (sum_gt_min)  //When in idle only leave if weight is enough
        nxt_state = WAIT;
      else
        nxt_state = IDLE;
      WAIT : if (!sum_gt_min) begin //In wait, go to idle if weight gets too low 
        nxt_state = IDLE;
      end
      else if (diff_gt_1_4) begin //If unbalanced stay in wait, tmr also clears below
        nxt_state = WAIT;
      end
      else if (tmr_full) begin	//When balanced enable steering/transition to steer state
        en_steer = 1'b1;		
        nxt_state = STEER_EN;
      end
      else if (!diff_gt_1_4)  //If balanced stay in wait until timer full
        nxt_state = WAIT;
      STEER_EN : if (!sum_gt_min) begin //In steer, when user gets off go to IDLE
        nxt_state = IDLE;		//rider_off also changes below on this condition
      end
      else if (diff_gt_15_16) begin     //rider is stepping off, return to Wait state
        nxt_state = WAIT;
      end
      else if (!diff_gt_15_16) begin
        en_steer = 1'b1;		//While rider is on successfully keep steering 
        nxt_state = STEER_EN;		//enabled and state in enabled state
      end
      default : begin
        nxt_state = IDLE;		//defaults to avoid not changing states and 
        en_steer = 1'b0;		//to avoid latches
      end
    endcase
  end

		//clr_tmr asserted when user is getting on in idle state,
                //when  user is balanced in wait state, and when user  
                //transitions from steer to wait 
  assign clr_tmr = (sum_gt_min && state == IDLE) ? 1'b1 :
                   (diff_gt_1_4 && state == WAIT) ? 1'b1 :
                   (diff_gt_15_16 && state == STEER_EN) ? 1'b1 :
                   1'b0; 

		//rider_off is asserted when user is unbalanced after steering
                //and the machine is going to transition to IDLE, or when user
                //transitions from steering straight to idle (clotheslined)
  assign rider_off = (diff_gt_15_16 && nxt_state == IDLE) ? 1'b1 :
                     (!sum_gt_min && state == STEER_EN) ? 1'b1 :
                     1'b0;
endmodule