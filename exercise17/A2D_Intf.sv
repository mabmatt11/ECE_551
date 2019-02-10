module A2D_Intf(clk,rst_n,nxt,lft_ld,rght_ld,batt,SS_n,SCLK,MOSI,MISO);

input clk,rst_n;
input nxt;

output SS_n,SCLK,MOSI;
input MISO;

output logic [11:0] lft_ld,rght_ld,batt;

logic [15:0] cmd,rd_data;
logic done,wrt,update;

logic lft_en,rght_en,batt_en;
logic [1:0] rr_cnt;

typedef enum reg [1:0] {IDLE,SEND1,WAIT,SEND2} state_t;
state_t state, nxt_state;

//////// INSTANTIATE SPI MASTER ///////////
SPI_mstr16 MAST(.clk(clk),.rst_n(rst_n),.wrt(wrt),.done(done),.SS_n(SS_n),
                .rd_data(rd_data),.cmd(cmd),.SCLK(SCLK),.MOSI(MOSI),.MISO(MISO));

//////// STATE MACHINE FLOP ////////
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    state <= IDLE;
  else
    state <= nxt_state;

//////// STATE MACHINE ///////////
always_comb begin
  wrt = 0;
  update = 0;
  nxt_state = IDLE;
  
  case (state)
    IDLE : if (nxt) begin
      wrt = 1;
      update = 0;
      nxt_state = SEND1;
    end

    SEND1 : if (!done) begin
      wrt = 0;
      update = 0;
      nxt_state = SEND1;
    end
    else if (done) begin
      wrt = 0;
      update = 0;
      nxt_state = WAIT;
    end

    WAIT : begin
      nxt_state = SEND2;
      wrt = 1;
      update = 0;
    end

    SEND2 : if (!done) begin
      wrt = 0;
      update = 0;
      nxt_state = SEND2;
    end
    else if (done) begin
      wrt = 0;
      update = 1;
      nxt_state = IDLE;
    end
    
    default : begin
      wrt = 0;
      update = 0;
      nxt_state = IDLE;
    end 
  endcase

end

///////// ROUND ROBIN COUNTER ////////
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    rr_cnt <= 2'b00;
  else if (update && rr_cnt != 2'b10) 
    rr_cnt <= rr_cnt + 1;
  else if (update && rr_cnt == 2'b10)
    rr_cnt <= 2'b00;
  else 
    rr_cnt <= rr_cnt;

//////// ROUND ROBIN ENABLE COMBINATIONAL LOGIC //////////
assign lft_en = (rr_cnt == 2'b00) ? 1'b1 : 1'b0;

assign rght_en = (rr_cnt == 2'b01) ? 1'b1 : 1'b0;

assign batt_en = (rr_cnt == 2'b10) ? 1'b1 : 1'b0;

assign cmd = (rr_cnt == 2'b00) ? 16'h0000 :
             (rr_cnt == 2'b01) ? 16'h2000 :
                                 16'h2800;

///////// LF LOAD FLOP ////////////
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    lft_ld <= 12'h000;
  else if (lft_en)
    lft_ld <= rd_data[11:0];
  else
    lft_ld <= lft_ld;          


///////// RGHT LOAD FLOP ////////////
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    rght_ld <= 12'h000;
  else if (rght_en)
    rght_ld <= rd_data[11:0];
  else
    rght_ld <= rght_ld; 

///////// BATT LOAD FLOP ////////////
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    batt <= 12'h000;
  else if (batt_en)
    batt <= rd_data[11:0];
  else
    batt <= batt; 

endmodule

