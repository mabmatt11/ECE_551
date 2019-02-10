module UART_tx(clk,rst_n,trmt,tx_data,TX,tx_done);

input clk,rst_n,trmt;
input [7:0] tx_data;

output logic TX,tx_done;

logic load,shift,transmitting,set_done,clr_done;
logic [3:0] bit_cnt;
logic [12:0] baud_cnt;
logic [8:0] tx_shift_reg;

typedef enum reg {IDLE,TRANSMIT} state_t;
state_t state, nxt_state;

//Bit counter
always_ff @(posedge clk)
  if (load)
    bit_cnt <= 4'h0;
  else if (shift)
    bit_cnt <= bit_cnt + 1;

//baud counter
always_ff @(posedge clk)
  if (load|shift)
    baud_cnt <= 4'h0;
  else if (transmitting)   
    baud_cnt <= baud_cnt + 1;

//TX output logic
always_ff @(posedge clk or negedge rst_n)
  if (!rst_n)
    tx_shift_reg <= 9'h1FF;
  else if (load)   
    tx_shift_reg <= {tx_data,1'b0};
  else if (shift)
    tx_shift_reg <= {1'b1,tx_shift_reg[8:1]};

assign TX = tx_shift_reg[0];

always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    state <= IDLE;
  else
    state <= nxt_state;

always_comb begin
  //default outputs
  load = 0;
  transmitting = 0;
  shift = 0;
  set_done = 0;
  clr_done = 1;
   
  case (state)
    IDLE : if (trmt) begin
             load = 1;
             transmitting = 0;
             shift = 0;
             set_done = 0;
             clr_done = 1;
           end

    TRANSMIT : if (baud_cnt == 13'hA2C) begin
                 shift = 1;
                 load = 0;
                 transmitting = 1;
                end
                else if (bit_cnt < 4'hA) begin
                  load = 0;
                  transmitting = 1;
                  shift = 0;
                end 
                else if (bit_cnt >= 4'hA) begin
                  transmitting = 0;
                  load = 0;
                  shift = 0;
                  set_done = 1;
                  clr_done = 0;
                end
    default : begin
        //default outputs
        load = 0;
        transmitting = 0;
        shift = 0;
        set_done = 0;
        clr_done = 1;
     end
  endcase
end

always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    tx_done <= 1'b0;
  else if (clr_done)
    tx_done <= 1'b0;
  else if (set_done)
    tx_done <= 1'b1;

endmodule

