module Auth_blk(clk,rst_n,rx_rdy,rx_data,rider_off,pwr_up,clr_rx_rdy);

input clk,rst_n;
input rx_rdy,rider_off;
input [7:0] rx_data;

output logic pwr_up;
output logic clr_rx_rdy;

localparam G = 8'h67;
localparam S = 8'h73;

//////// STATES IN STATE MACHINE //////////
typedef enum reg[1:0] {OFF,PWR1,PWR2} state_t;
state_t state, nxt_state;

always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    state <= OFF;
  else
    state <= nxt_state;

always_comb begin
  nxt_state = OFF;
  pwr_up = 0;
  clr_rx_rdy = 0;

  case (state)
    OFF : if (rx_data == G) begin
      pwr_up = 1;
      clr_rx_rdy = 1;
      nxt_state = PWR1;
    end

    PWR1 : if (rider_off && rx_rdy && rx_data == S) begin
      pwr_up = 0;
      clr_rx_rdy = 1;
      nxt_state = OFF;
    end 
    else if (!rider_off && rx_rdy && rx_data == S) begin
      pwr_up = 1;
      clr_rx_rdy = 1;
      nxt_state = PWR2;
    end
    else begin
      pwr_up = 1;
      nxt_state = PWR1;
    end

    PWR2 : if (rx_data == G && rx_rdy) begin
      pwr_up = 1;
      clr_rx_rdy = 1;
      nxt_state = PWR1;
    end
    else if (rider_off) begin
      pwr_up = 0;
      nxt_state = OFF;
    end
    else begin
      pwr_up = 1;
      nxt_state = PWR2;
    end

  default : begin
    nxt_state = OFF;
    pwr_up = 0;
    clr_rx_rdy = 0;
  end

  endcase
end

     
endmodule

