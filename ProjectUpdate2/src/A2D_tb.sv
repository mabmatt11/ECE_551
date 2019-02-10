module A2D_tb();
 
logic clk,rst_n; //clk and asynch reset
logic nxt; // signal to get next spi reading

logic [11:0] lft_ld,rght_ld,batt; // signals that are being read from spi

logic a2d_SS_n; // input for spi
logic SCLK,MOSI,MISO; // inputs for spi

///////// INSTANTIATE A2D_inft ///////////
A2D_intf iA2D(.clk(clk),.rst_n(rst_n),.nxt(nxt),.lft_ld(lft_ld),
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
  nxt = 0; // defualt readings, start reset
  repeat(10) @(posedge clk);

  rst_n = 1; // stop asynch reset
  repeat(10) @(posedge clk);

  nxt = 1; // send first spi
  @(posedge clk);
  nxt = 0;
  repeat(20000) @(posedge clk);
  
  if (lft_ld != 12'hC00 || rght_ld != 12'hBF4 || batt != 12'hBE5) begin
    $display("Not reading the correct values from SPI, debug!");
	$stop; // self checking values
  end

  nxt = 1;
  @(posedge clk); // send second spi
  nxt = 0;
  repeat(20000) @(posedge clk);

  if (lft_ld != 12'hBD0 || rght_ld != 12'hBC4 || batt != 12'hBB5) begin
    $display("Not reading the correct values from SPI, debug!");
	$stop; // self checking values
  end
  
  nxt = 1;
  @(posedge clk); // send third spi
  nxt = 0;
  repeat(20000) @(posedge clk);

  if (lft_ld != 12'hBA0 || rght_ld != 12'hB94 || batt != 12'hB85) begin
    $display("Not reading the correct values from SPI, debug!");
	$stop; // self checking values
  end
  
  nxt = 1;
  @(posedge clk); // send fourth spi
  nxt = 0;
  repeat(20000) @(posedge clk);

  if (lft_ld != 12'hB70 || rght_ld != 12'hB64 || batt != 12'hB55) begin
    $display("Not reading the correct values from SPI, debug!");
	$stop; // self checking values
  end
  
  $display("All values were correct through the A2D_intf");
  $stop;
end

endmodule


