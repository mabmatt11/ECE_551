module piezo(clk, rst_n, en_steer, ovr_spd, batt_low, drive, drive_n);

	input en_steer, ovr_spd, batt_low, clk, rst_n;
	output drive, drive_n;
	
	// 400MHz clk 
	reg[31:0] cnt;
	
	wire steer, ovr, batt, sec;
	
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			cnt <= 32'd0;
		else
			cnt <= cnt + 1;
	end
	
	assign steer = cnt[15]; // ~750Hz 18
	assign ovr = cnt[12]; // ~6.1kHz 15
	assign batt = cnt[14]; // ~1.5kHz 17
	assign sec = cnt[25]; // ~1.5 seconds 28
	
	assign drive_n = ~drive;
	assign drive = sec ? en_steer ? steer : batt_low & ovr_spd ? batt ^ ovr : 
					batt_low ? batt : ovr_spd ? ovr : 0 : 0;

endmodule