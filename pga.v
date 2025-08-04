`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2025 16:52:07
// Design Name: 
// Module Name: alarm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alarm1 #(parameter PGA_THRESHOLD = 24'h100000)(
	input i_clk, i_accept,
	input [23:0] i_xdata_scaled, i_ydata_scaled, i_zdata_scaled,
	output o_pga_alarm
	);
	
	reg r_pga_alarm = 0;
	
	assign o_pga_alarm = r_pga_alarm;
	
	always @(posedge i_clk) begin
		if((i_xdata_scaled > PGA_THRESHOLD) | (i_ydata_scaled > PGA_THRESHOLD) | (i_zdata_scaled > PGA_THRESHOLD)) begin
			r_pga_alarm <= 1;
		end
		/*
		else if(i_accept) begin
			r_pga_alarm <= 0;
		end
		*/
		else begin
			r_pga_alarm <= 0;
		end
	end
	
endmodule
