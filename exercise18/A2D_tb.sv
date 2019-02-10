module A2D_tb();
 
logic clk,rst_n;
logic nxt;

logic [11:0] lft_ld,rght_ld,batt;

logic a2d_SS_n;
logic SCLK,MOSI,MISO;

///////// INSTANTIATE A2D_inft ///////////
A2D_Intf iA2D(.clk(clk),.rst_n(rst_n),.nxt(nxt),.lft_ld(lft_ld),
              .rght_ld(rght_ld),.batt(batt),.SS_n(a2d_SS_n),
              .SCLK(SCLK),.MISO(MISO),.MOSI(MOSI));

///////// INSTANTIATE ADC128S ////////////
ADC128S iADC(.clk(clk),.rst_n(rst_n),.SS_n(a2d_SS_n),.SCLK(SCLK),
             .MOSI(MOSI),.MISO(MISO));

///// CREATE CLOCK /////
initial begin
  clk = 0;
  forever begin
    #5;
    clk = ~clk;
  end
end

///// ACTUAL TEST ///////
initial begin
  rst_n = 0;
  nxt = 0;
  repeat(10) @(posedge clk);

  rst_n = 1;
  repeat(10) @(posedge clk);

  nxt = 1;
  @(posedge clk);
  nxt = 0;
  repeat(20000) @(posedge clk);

  nxt = 1;
  @(posedge clk);
  nxt = 0;
  repeat(20000) @(posedge clk);

  nxt = 1;
  @(posedge clk);
  nxt = 0;
  repeat(20000) @(posedge clk);

  nxt = 1;
  @(posedge clk);
  nxt = 0;
  repeat(20000) @(posedge clk);

  $stop;
end

endmodule


