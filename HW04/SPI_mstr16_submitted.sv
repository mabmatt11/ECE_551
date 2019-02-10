module SPI_mstr16_submitted(clk,rst_n,MISO,wrt,cmd,done,rd_data,MOSI,SS_n,SCLK);

input clk,rst_n; //clock and reset 
input MISO,wrt; //wrt tells when beginning transmission, MISO is Master in Slave out
input [15:0] cmd; //data being transmitted

output logic done,SS_n; //signals for transmission, whether done or transmitting
output MOSI,SCLK; //MOSI is Master out Slave in. SCLK is internal clock for transmission
output [15:0] rd_data; //Output data

logic [4:0] sclk_div; //used to create SCLK
logic MISO_sample; //gets next MISO
logic [15:0] shft_reg_in; //used to shift to next MISO
logic [15:0] shft_reg; //flop for rd_data output
logic [3:0] bit_cnt; //used to count how many bits transmitted
logic set_done; 
logic clr_done; //Set and clr for when transmitting or ready to transmit
logic rst_cnt; //used for getting sclk_div set up
logic shft; //internal signal for getting next MISO
logic smpl; //internal signal to sample MISO

typedef enum reg [1:0] {FRONT_PORCH,IDLE,WORKING,BACK_PORCH} state_t;
state_t state, nxt_state;

/////// SCLK COUNTER //////////
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
     sclk_div <= 5'b10111;
  else if (rst_cnt)
     sclk_div <= 5'b10111;
  else
     sclk_div <= sclk_div + 1;

////// SCLK VALUE ////////
assign SCLK = sclk_div[4];

////////// MISO SAMPLER ////////
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
     MISO_sample <= 1'b0;
  else if (smpl)
     MISO_sample <= MISO;


///////// SHIFT SAMPLE /////////
assign shft_reg_in = {shft_reg[14:0], MISO_sample};

////////// SHIFT REGISTER FLOP /////////
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
     shft_reg <= 16'h0000;
  else if (wrt)
     shft_reg <= cmd;
  else if (shft)
     shft_reg <= shft_reg_in; 

//////// assign rd_data output //////
assign rd_data = shft_reg;

//////// MOSI VALUE ///////////
assign MOSI = shft_reg[15];

///////// BIT COUNTER //////////
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
     bit_cnt <= 4'b0000;
  else if (bit_cnt == 15 || state == IDLE)
     bit_cnt <= 4'b0000;
  else if (shft)
     bit_cnt <= bit_cnt + 1;

////////// STATE MACHINE FLOP ////////
always_ff @(posedge clk, negedge rst_n)
  if (~rst_n)
     state <= IDLE;
  else
     state <= nxt_state;

//////// STATE MACHINE LOGIC //////////
always_comb begin
  set_done = 1'b1; //defaults
  smpl = 1'b0;
  shft = 1'b0;
  rst_cnt = 1'b1;
  clr_done = 1'b0;
  nxt_state = IDLE;

  case (state)
    IDLE : if (wrt) begin //going to transmit
	    set_done = 1'b0; //not done, beginning transmission
       rst_cnt = 1'b0; //stop rst_cnt to get SCLK going
       clr_done = 1'b1;
       nxt_state = FRONT_PORCH;
     end

    FRONT_PORCH : if (sclk_div == 5'b01111) begin //SCLK going high
       smpl = 1'b1; // sample first MISO
       set_done = 1'b0; //keep transmission going
       rst_cnt = 1'b0;
       nxt_state = WORKING;
     end
     else begin
       nxt_state = FRONT_PORCH;
       set_done = 1'b0; //keep transmission going
       rst_cnt = 1'b0;
     end
  
     WORKING : if (sclk_div == 5'b01111) begin //SCLK going high
       smpl = 1'b1; //sample MISO
       set_done = 1'b0; //keep transmission going
       rst_cnt = 1'b0;
       nxt_state = WORKING;
     end
     else if (sclk_div == 5'b11111) begin //SCLK going low
       shft = 1'b1; //get next MISO in
       set_done = 1'b0; //keep transmission going
       rst_cnt = 1'b0;
       nxt_state = WORKING;
     end 
     else if (bit_cnt == 15) begin //all bits transmitted
       set_done = 1'b0; //go to BACK PORCH keep transmission for now
       rst_cnt = 1'b0;
       nxt_state = BACK_PORCH;
     end
     else begin
       set_done = 1'b0; //keep transmission going
       rst_cnt = 1'b0;
       nxt_state = WORKING;
     end 

     BACK_PORCH : if (sclk_div == 5'b11111) begin //SCLK going low
       nxt_state = IDLE;
       shft = 1;
     end
     else if (sclk_div == 5'b01111) begin //SCLK going high
       nxt_state = BACK_PORCH;
       smpl = 1;
       set_done = 1'b0;
       rst_cnt = 1'b0;
     end
     else begin
       nxt_state = BACK_PORCH; //keep transmission going until BACK PORCH over
       set_done = 1'b0;
       rst_cnt = 1'b0;
     end

     default : begin //defaults
       set_done = 1'b1;
       smpl = 1'b0;
       shft = 1'b0;
       rst_cnt = 1'b1;
       clr_done = 1'b0;
       nxt_state = IDLE;
     end
  endcase
end

////////// Flops for SS_n and done ////////////
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n) begin
    SS_n <= 1'b1; //async reset ss_n preset, done reset
    done <= 1'b0;
  end
  else if (set_done) begin //when set_done
    SS_n <= 1'b1; //SS_n is high
    done <= 1'b1; //done is high, ready to transmit
  end
  else if (clr_done) begin //when clr_done
    SS_n <= 1'b0; //SS_n low, done low
    done <= 1'b0; //not ready to transmit, beginning transmitting
  end
  else begin
    SS_n <= 1'b0; //State machine defaults set_done to 1
    done <= 1'b0; //When it isn't 1, done/SS_n should be deasserted
    		  //transmitting going on
  end

endmodule       
     
