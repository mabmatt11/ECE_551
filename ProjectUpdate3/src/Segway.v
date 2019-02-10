module Segway(clk,RST_n,LED,INERT_SS_n,INERT_MOSI,
              INERT_SCLK,INERT_MISO,A2D_SS_n,A2D_MOSI,A2D_SCLK,
			  A2D_MISO,PWM_rev_rght,PWM_frwrd_rght,PWM_rev_lft,
			  PWM_frwrd_lft,piezo_n,piezo,INT,RX);
			  
  input clk,RST_n;
  input INERT_MISO;						// Serial in from inertial sensor
  input A2D_MISO;						// Serial in from A2D
  input INT;							// Interrupt from inertial indicating data ready
  input RX;								// UART input from BLE module

  
  output [7:0] LED;						// These are the 8 LEDs on the DE0, your choice what to do
  output A2D_SS_n, INERT_SS_n;			// Slave selects to A2D and inertial sensor
  output A2D_MOSI, INERT_MOSI;			// MOSI signals to A2D and inertial sensor
  output A2D_SCLK, INERT_SCLK;			// SCLK signals to A2D and inertial sensor
  output PWM_rev_rght, PWM_frwrd_rght;  // right motor speed controls
  output PWM_rev_lft, PWM_frwrd_lft;	// left motor speed controls
  output piezo_n,piezo;					// diff drive to piezo for sound
  
  ////////////////////////////////////////////////////////////////////////
  // fast_sim is asserted to speed up fullchip simulations.  Should be //
  // passed to both balance_cntrl and to steer_en.  Should be set to  //
  // 0 when we map to the DE0-Nano.                                  //
  ////////////////////////////////////////////////////////////////////
  localparam fast_sim = 1;	// asserted to speed up simulations. 
  
  ///////////////////////////////////////////////////////////
  ////// Internal interconnecting sigals defined here //////
  /////////////////////////////////////////////////////////
  wire rst_n;                           // internal global reset that goes to all units

  wire [7:0] rx_data;
  wire clr_rdy, rdy;
  wire rider_off, pwr_up;

  wire [15:0] ptch;
  wire vld;

  wire [11:0] lft_ld, rght_ld, batt;
  wire nxt;

  assign nxt = vld;

  wire [11:0] ld_cell_diff;
  wire [10:0] lft_spd, rght_spd;
  wire lft_rev, rght_rev, too_fast, en_steer;

  //wire PWM_rev_lft, PWM_frwrd_left, PWM_rev_right, PWM_frwrd_rght;

  
  // You will need to declare a bunch more interanl signals to hook up everything
  
  ////////////////////////////////////
   
  
  ///////////////////////////////////////////////////////
  // How you arrange the hierarchy of the top level is up to you.
  //
  // You could make a level of hierarchy called digital core
  // as shown in the block diagram in the spec.
  //
  // Or you could just instantiate all the components of the Segway
  // flat.
  //
  // Just for reference all the needed blocks (in no particular order) would be:
  //   Auth_blk
  //   inert_intf
  //   balance_cntrl
  //   steer_en
  //   mtr_drv
  //   A2D_intf
  //   piezo
  //////////////////////////////////////////////////////
  UART_rcv uart_rcv_inst(.clk(clk), .rst_n(rst_n), .RX(RX), .clr_rdy(clr_rdy), .rx_data(rx_data), .rdy(rdy));
  Auth_blk auth_blk_inst(.clk(clk), .rst_n(rst_n), .rx_rdy(rdy), .rx_data(rx_data), .rider_off(rider_off), .pwr_up(pwr_up), .clr_rx_rdy(clr_rdy));

  inert_intf inert_intf_inst(.clk(clk), .rst_n(rst_n), .SS_n(INERT_SS_n), .SCLK(INERT_SCLK), .MOSI(INERT_MOSI), .MISO(INERT_MISO), .INT(INT), .ptch(ptch), .vld(vld));
  A2D_Intf a2d_intf_inst(.clk(clk), .rst_n(rst_n), .lft_ld(lft_ld), .rght_ld(rght_ld), .batt(batt), .nxt(nxt), .SS_n(A2D_SS_n), .SCLK(A2D_SCLK), .MOSI(A2D_MOSI), .MISO(A2D_MISO));

  balance_cntrl balance_cntrl_inst(.clk(clk), .rst_n(rst_n), .vld(vld), .ptch(ptch), .ld_cell_diff(ld_cell_diff), .lft_spd(lft_spd), .lft_rev(lft_rev), .rght_spd(rght_spd), .rght_rev(rght_rev), .rider_off(rider_off), .en_steer(en_steer), .pwr_up(pwr_up), .too_fast(too_fast));
  steer_en steer_en_inst(.clk(clk), .rst_n(rst_n), .en_steer(en_steer), .rider_off(rider_off), .lft_ld(lft_ld), .rght_ld(rght_ld), .ld_cell_diff(ld_cell_diff));
  mtr_drv mtr_drv_inst(.clk(clk), .rst_n(rst_n), .lft_spd(lft_spd), .lft_rev(lft_rev), .PWM_rev_lft(PWM_rev_lft), .PWM_frwrd_lft(PWM_frwrd_lft), .rght_spd(rght_spd), .rght_rev(rght_rev), .PWM_rev_rght(PWM_rev_rght), .PWM_frwrd_rght(PWM_frwrd_rght));

  /////////////////////////////////////
  // Instantiate reset synchronizer //
  ///////////////////////////////////  
  rst_synch iRST(.clk(clk),.RST_n(RST_n),.rst_n(rst_n));
  
endmodule
