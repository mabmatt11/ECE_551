`timescale 1ns/1ps
module SPI_mst_16_tb();

	reg clk, rst_n, wrt;
	reg [15:0] cmd;
	wire SS_n, SCLK, MOSI, MISO, done;
	wire [15:0] rd_data;

	// Instantiate DUTS
	SPI_mstr16 master(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO),
						.wrt(wrt), .cmd(cmd), .done(done), .rd_data(rd_data));
	ADC128S conv(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO));

	initial begin
		clk = 0;
		rst_n = 0;
		wrt = 0;
		cmd = 15'd0;
		// Reset initially
		@(posedge clk);
		@(negedge clk) rst_n = 1;
		// Read from 5
		cmd = {2'b00, 3'h5, 11'h000};
		@(posedge clk) wrt = 1;
		@(posedge clk);
		@(negedge clk) wrt = 0;
		@(posedge done) begin
			$display("Channel: 5 Response: %h", rd_data);
			if(rd_data != 16'h0c00) $stop;
		end
		repeat(10) @(posedge clk);
		// Read from 5
		cmd = {2'b00, 3'h5, 11'h000};
		@(posedge clk) wrt = 1;
		@(posedge clk);
		@(negedge clk) wrt = 0;
		@(posedge done) begin
			$display("Channel: 5 Response: %h", rd_data);
			if(rd_data != 16'h0c05) $stop;
		end
		repeat(10) @(posedge clk);
		// Read from 4
		cmd = {2'b00, 3'h4, 11'h000};
		@(posedge clk) wrt = 1;
		@(posedge clk);
		@(negedge clk) wrt = 0;
		@(posedge done) begin
			$display("Channel: 4 Response: %h", rd_data);
			if(rd_data != 16'h0bf5) $stop;
		end
		repeat(10) @(posedge clk);
		// Read from 4
		cmd = {2'b00, 3'h4, 11'h000};
		@(posedge clk) wrt = 1;
		@(posedge clk);
		@(negedge clk) wrt = 0;
		@(posedge done) begin
			$display("Channel: 4 Response: %h", rd_data);
			if(rd_data != 16'h0bf4) $stop;
		end
		repeat(10) @(posedge clk);
		// Read from 5
		cmd = {2'b00, 3'h5, 11'h000};
		@(posedge clk) wrt = 1;
		@(posedge clk);
		@(negedge clk) wrt = 0;
		@(posedge done) begin
			$display("Channel: 5 Response: %h", rd_data);
			if(rd_data != 16'h0be4) $stop;
		end
		repeat(10) @(posedge clk);
		// Read from 4
		cmd = {2'b00, 3'h4, 11'h000};
		@(posedge clk) wrt = 1;
		@(posedge clk);
		@(negedge clk) wrt = 0;
		@(posedge done) begin
			$display("Channel: 4 Response: %h", rd_data);
			if(rd_data != 16'h0be5) $stop;
		end
		$display("All tests passed!");
		$stop;
	end

	always #1 clk = ~clk;

endmodule
