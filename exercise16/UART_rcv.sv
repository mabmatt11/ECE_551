module UART_rcv(clk,rst_n,RX,clr_rdy,rx_data,rdy);

input clk,rst_n,RX; //clokc and async reset for flops
					//RX is data being received
input logic clr_rdy; //Input for reseting whether ready for data

output logic rdy; //output for if data is ready to be received
output logic [7:0] rx_data; //received data

logic start,shift,receiving,set_rdy; //internal signals for state machine
logic [3:0] bit_cnt; //internal signal for counting how many bits received
logic [12:0] baud_cnt; //internal signal for tracking baud rate
logic [8:0] rx_shift_reg; //internal signal for parsing received data
logic meta1,meta2,meta_rx; //internal flops for metastability of input

typedef enum reg {IDLE,RECEIVE} state_t; //Set up states for machine
state_t state, nxt_state;

//meta-stability for RX
always_ff @(posedge clk)
  if (!rst_n) begin
    meta1 <= 1'b0;
    meta2 <= 1'b0;
    meta_rx <= 1'b0;
  end
  else begin
    meta1 <= RX;
    meta2 <= meta1;
    meta_rx <= meta2;
  end

//Bit counter
always_ff @(posedge clk)
  if (start)
    bit_cnt <= 4'h0; //defualt to 0
  else if (shift)
    bit_cnt <= bit_cnt + 1; //count up when shift

//baud counter
always_ff @(posedge clk)
  if (start|shift) begin
    if (bit_cnt == 0) begin
      baud_cnt <= 13'h516; //first bit do half baud to get in middle of received data
    end
    else begin
      baud_cnt <= 13'hA2C; //every other bit is full baud rate
    end
  end
  else if (receiving)   
    baud_cnt <= baud_cnt - 1; //count down because of half baud first bit

//TX output logic
always_ff @(posedge clk)
  if (shift)   
    rx_shift_reg <= {meta_rx,rx_shift_reg[8:1]}; //shift received data for output
  else
    rx_shift_reg <= rx_shift_reg;

assign rx_data = rx_shift_reg[7:0]; //output gets shifted data

////////INFER STATE MACHINE FLOP///////////
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n) //default state is IDLE
    state <= IDLE;
  else
    state <= nxt_state;

////////INFER COMBINATIONAL LOGIC//////////
always_comb begin
  //default outputs
  start = 0;
  receiving = 0;
  shift = 0;
  set_rdy = 1;
  nxt_state = IDLE;
   
  case (state) //case statement for State machine
    IDLE : if (RX == 1'b0) begin
             start = 1; //when input goes low we start receiving
             receiving = 1;
             shift = 0;
             set_rdy = 0;
	     nxt_state = RECEIVE;
           end

    RECEIVE : if (baud_cnt == 13'h000) begin //when baud count gets to 0
                 shift = 1;    				 //we're on the next bit 
				 start = 0;
                 receiving = 1;
		 set_rdy = 0;
		 nxt_state = RECEIVE;
                end
                else if (bit_cnt < 4'hA) begin //when our bits arent full keep going
                  start = 0;
                  receiving = 1;
                  shift = 0;
                  set_rdy = 0;
		  nxt_state = RECEIVE;
                end 
                else if (bit_cnt >= 4'hA) begin //when our bits are full stop receiving
                  receiving = 0;
                  start = 0;
                  shift = 0;
                  set_rdy = 1;
		  nxt_state = IDLE;
                end
    default : begin
        //default outputs
        start = 0;
        receiving = 0;
        shift = 0;
        set_rdy = 1;
	nxt_state = IDLE;
     end
  endcase
end

/////////INFER FLIP FLOP/////////
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    rdy <= 1'b0; //default to not ready
  else if (clr_rdy|start)
    rdy <= 1'b0; //when receiving not ready
  else if (set_rdy)
    rdy <= 1'b1;

endmodule

