module inert_intf_tb();

logic clk,rst_n; //clk and async reset

logic strt_cal; //possibly unneeded

logic PWM_rev_lft,PWM_frwrd_lft,PWM_rev_rght,PWM_frwrd_rght; //inputs to segwaymodel
logic signed [15:0] rider_lean; //all of the segway model inputs will be set to 0

logic vld; //output from inert_intf for if signal is valid
logic [15:0] ptch; //output from inert_intf for ptch of segway

logic INT,SS_n,SCLK,MOSI,MISO; //signals passed between inert_intf and segwaymodel for spi

wire [3:0] state;

//////////// INSTANTIATE BLOCKS /////////////
inert_intf iDUT(.clk(clk),.rst_n(rst_n),.INT(INT),.SS_n(SS_n),.SCLK(SCLK),.MOSI(MOSI),.MISO(MISO),.vld(vld),.ptch(ptch));

assign state = iDUT.state;

////////// INSTANTIATE SEGWAY MODEL PHYSICS ///////
SegwayModel model(.PWM_rev_lft(PWM_rev_lft),.PWM_frwrd_lft(PWM_frwrd_lft),.PWM_rev_rght(PWM_rev_rght),.PWM_frwrd_rght(PWM_frwrd_rght),.clk(clk),
                  .RST_n(rst_n),.rider_lean(rider_lean),.INT(INT),.SS_n(SS_n),.SCLK(SCLK),.MOSI(MOSI),.MISO(MISO));


/////// make a clk ////////
initial begin
  clk = 0;
  forever begin
    #10;
    clk = ~clk;
  end
end

///////// set async reset and let it run ///////////
initial begin
  PWM_rev_lft = 0;
  PWM_frwrd_lft = 0;
  PWM_rev_rght = 0;
  PWM_frwrd_rght = 0;
  rider_lean = 16'h0100;
  rst_n = 0;
  repeat(10) @(posedge clk);
  repeat(1) @(negedge clk);
  rst_n = 1;
  repeat(500000) @(posedge clk);

  //////// NEMO_SETUP should be high when registers set correctly ///////////
  if (inert_intf_tb.model.NEMO_setup == 1'b0)
    $display("NEMO_setup is not high, registers not set correctly!");
  else
    $display("NEMO_setup is set high, registers set correctly! :)");

  $stop;
end



endmodule