module SPI_mstr_16_tb();

/////// Inputs to SPI master /////////
logic clk,rst_n;
logic [15:0] cmd;
logic wrt;
logic MISO;

/////// Outputs from SPI master ///////
logic [15:0] rd_data;
logic MOSI,SCLK,SS_n;

///////// Instantiate master /////////////
SPI_mstr16 MSTR(.clk(clk),.rst_n(rst_n),.wrt(wrt),.cmd(cmd),.MISO(MISO),
                 .rd_data(rd_data),.MOSI(MOSI),.SCLK(SCLK),.SS_n(SS_n));

////////// Instantiate ADC ////////////
ADC128S ADC(.clk(clk),.rst_n(rst_n),.SS_n(SS_n),.SCLK(SCLK),.MISO(MISO),.MOSI(MOSI));

initial begin //get clock going
  clk = 0;
  forever
    #5 clk = ~clk;
end

initial begin

rst_n = 0; wrt = 0; cmd = 16'h0000;
repeat(10) @(posedge clk);
rst_n = 1;
repeat(10) @(posedge clk);

cmd = 16'h2800;
wrt = 1;
@(posedge clk);
wrt = 0;
repeat(550) @(posedge clk);
if (rd_data != 16'h0C00) begin
  $display("Data did not transmit correctly! Expected: %h Received: %h",16'h0C00,rd_data);
  $stop;
end
wrt = 1;
@(posedge clk);
wrt = 0;
repeat(550) @(posedge clk);
if (rd_data != 16'h0C05) begin
  $display("Data did not transmit correctly! Expected: %h Received %h",16'h0C05,rd_data);
  $stop;
end
cmd = 16'h2000;
wrt = 1;
@(posedge clk);
wrt = 0;
repeat(550) @(posedge clk);
if (rd_data != 16'h0BF5) begin
  $display("Data did not transmit correctly! Expected: %h Received %h",16'h0BF5,rd_data);
  $stop;
end
wrt = 1;
@(posedge clk);
wrt = 0;
repeat(1024) @(posedge clk);
if (rd_data != 16'h0BF4) begin
  $display("Data did not transmit correctly! Expected: %h Received %h",16'h0BF4,rd_data);
  $stop;
end
$display("CORRECTLY TRANSMITTED AND RECEIVED DATA! LAST RECIEVED: %h",rd_data);
$stop;

end

endmodule

