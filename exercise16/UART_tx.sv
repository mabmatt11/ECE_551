module UART_tx(clk,rst_n,trmt,tx_data,TX,tx_done);

input clk,rst_n,trmt; //clock and async reset for flops. trmt tells when data is transmit ready
input [7:0] tx_data; //The data to be transmitted

output logic TX,tx_done; //The output of the data transmitted

//Internal signals
logic load,shift,transmitting,set_done,clr_done; //load asserted when trmt asserted
						 //shift asserted during
						 //transmission
						 //transmitting asserted
						 //during transmission
						 //set_done asserted after
						 //transmission
						 //clr_done asserted before
						 //transmission starts
						
logic [3:0] bit_cnt;	//Counts the bits that have been transmitted
logic [12:0] baud_cnt; //Keeps track of baudrate for when next bit should be sent
logic [8:0] tx_shift_reg; //The shifted output data for transmission

typedef enum reg {IDLE,TRANSMIT} state_t; //Set up states for state machine
state_t state, nxt_state;

//Bit counter Flop //
always_ff @(posedge clk)
  if (load) //Reset counter when load begins
    bit_cnt <= 4'h0;
  else if (shift) //When shift happens add to count
    bit_cnt <= bit_cnt + 1;

//baud counter Flop //
always_ff @(posedge clk)
  if (load|shift) //Reset baud count when load or shift happens
    baud_cnt <= 13'h000;
  else if (transmitting)  //Count when transmitting
    baud_cnt <= baud_cnt + 1;

//TX output logic Combinational logic //
always_ff @(posedge clk or negedge rst_n)
  if (!rst_n) //async preset to all ones
    tx_shift_reg <= 9'h1FF;
  else if (load)   //When load, set up tx shift for transmission
    tx_shift_reg <= {tx_data,1'b0};
  else if (shift) //When shift, shift tx shift for transmission
    tx_shift_reg <= {1'b1,tx_shift_reg[8:1]};

    //output is set to lsb of tx shift
assign TX = tx_shift_reg[0];

//////INFER FLOP FOR STATE MACHINE/////
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n) //async reset to IDLE
    state <= IDLE;
  else
    state <= nxt_state;

//////INFER COMBINATIONAL LOGIC FOR STATE MACHINE /////
always_comb begin
  //default outputs
  load = 0;
  transmitting = 0;
  shift = 0;
  set_done = 1;
  clr_done = 0;
  nxt_state = IDLE;
   
  //CASE STATEMENTS FOR STATES
  case (state)
    IDLE : if (trmt) begin //When trmt asserted
             load = 1; //load will happen
             transmitting = 0; //not transmitting yet
             shift = 0; //not shifting
             set_done = 0;
             clr_done = 1; //clear done for transmission
	     nxt_state = TRANSMIT; //Move to state for transmitting
           end
	//Remain in IDLE unless trmt asserted

    TRANSMIT : if (baud_cnt == 13'hA2C) begin //When we reach baud rate
                 shift = 1; //shift transmission output
                 load = 0; 
                 transmitting = 1; //transmission happening
		 set_done = 0;
		 clr_done = 1;
		 nxt_state = TRANSMIT; //stay in state
                end
                else if (bit_cnt < 4'hA) begin //When bit count below # of bits
                  load = 0;
                  transmitting = 1; //continue transmitting
                  shift = 0;
		  set_done = 0;
		  clr_done = 1;
		  nxt_state = TRANSMIT; //stay in state
                end 
                else if (bit_cnt >= 4'hA) begin //When bit count above # of bits
                  transmitting = 0; //stop transmission
                  load = 0; //not loading
                  shift = 0; //no more shifts
                  set_done = 1; //set done asserted
                  clr_done = 0;
		  nxt_state = IDLE; //leave state
                end
    default : begin
        //default outputs
        load = 0;
        transmitting = 0;
        shift = 0;
        set_done = 1;
        clr_done = 0;
	nxt_state = IDLE;
     end
  endcase
end

//////INFER FLIP FLOP FOR OUTPUT DONE OR NOT//////////////
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n) //Async reset sets to 0
    tx_done <= 1'b0; 
  else if (clr_done) //When clearing done set to 0
    tx_done <= 1'b0; 
  else if (set_done) //When setting done flop set to 1
    tx_done <= 1'b1;

endmodule

