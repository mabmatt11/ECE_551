module UART_rcv(clk,rst_n,RX,clr_rdy,rx_data,rdy);

input clk,rst_n,RX;
input logic clr_rdy;

output logic rdy;
output logic [7:0] rx_data;

logic start,shift,receiving,set_rdy;
logic [3:0] bit_cnt;
logic [12:0] baud_cnt;
logic [8:0] rx_shift_reg;
logic meta1,meta2,meta_rx;

typedef enum reg {IDLE,RECEIVE} state_t;
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
    bit_cnt <= 4'h0;
  else if (shift)
    bit_cnt <= bit_cnt + 1;

//baud counter
always_ff @(posedge clk)
  if (start|shift) begin
    if (bit_cnt == 0) begin
      baud_cnt <= 13'h516;
    end
    else begin
      baud_cnt <= 13'hA2C;
    end
  end
  else if (receiving)   
    baud_cnt <= baud_cnt - 1;

//TX output logic
always_ff @(posedge clk)
  if (shift)   
    rx_shift_reg <= {meta_rx,rx_shift_reg[8:1]};
  else
    rx_shift_reg <= rx_shift_reg;

assign rx_data = rx_shift_reg[7:0];

always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    state <= IDLE;
  else
    state <= nxt_state;

always_comb begin
  //default outputs
  start = 0;
  receiving = 0;
  shift = 0;
  set_rdy = 1;
  nxt_state = IDLE;
   
  case (state)
    IDLE : if (RX == 1'b0) begin
             start = 1;
             receiving = 1;
             shift = 0;
             set_rdy = 0;
	     nxt_state = RECEIVE;
           end

    RECEIVE : if (baud_cnt == 13'h000) begin
                 shift = 1;
                 start = 0;
                 receiving = 1;
		 set_rdy = 0;
		 nxt_state = RECEIVE;
                end
                else if (bit_cnt < 4'hA) begin
                  start = 0;
                  receiving = 1;
                  shift = 0;
                  set_rdy = 0;
		  nxt_state = RECEIVE;
                end 
                else if (bit_cnt >= 4'hA) begin
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

always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    rdy <= 1'b0;
  else if (clr_rdy|start)
    rdy <= 1'b0;
  else if (set_rdy)
    rdy <= 1'b1;

endmodule

