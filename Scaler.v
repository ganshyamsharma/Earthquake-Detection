`timescale 1ns / 1ps

module scaler(
	input i_clk,
	input [15:0] i_xdata, i_ydata, i_zdata,
	output reg [23:0] o_xdata_scaled, o_ydata_scaled, o_zdata_scaled
	);
	
    localparam [19:0] SCALER = 20'b0000_0000_0100_0001_1001;          //Binary of 0.001    
    localparam [15:0] X_OFFS = 16'hffd8;
    localparam [15:0] Y_OFFS = 16'h0000;
    localparam [15:0] Z_OFFS = 16'hfcf0;
                 
	
	reg [15:0] r_xdata_abs, r_ydata_abs, r_zdata_abs;
	wire signed [15:0] w_zdata_offs_corrected, w_ydata_offs_corrected, w_xdata_offs_corrected;
	
	assign w_zdata_offs_corrected = i_zdata - Z_OFFS;
	assign w_ydata_offs_corrected = i_ydata - Y_OFFS;
	assign w_xdata_offs_corrected = i_xdata - X_OFFS;
	
	always @(posedge i_clk) begin
		if(w_xdata_offs_corrected < 0) begin
			r_xdata_abs <= w_xdata_offs_corrected * (-1);
		end
		else begin
			r_xdata_abs <= w_xdata_offs_corrected;
		end
		if(w_ydata_offs_corrected < 0) begin
			r_ydata_abs <= w_ydata_offs_corrected * (-1);
		end
		else begin
			r_ydata_abs <= w_ydata_offs_corrected;
		end	
		if(w_zdata_offs_corrected < 0) begin
			r_zdata_abs <= w_zdata_offs_corrected * (-1);
		end
		else begin
			r_zdata_abs <= w_zdata_offs_corrected;
		end		
	end
	
	always @(posedge i_clk) begin
		o_xdata_scaled <= (r_xdata_abs) * SCALER;
		o_ydata_scaled <= (r_ydata_abs) * SCALER;
		o_zdata_scaled <= (r_zdata_abs) * SCALER;		
	end
	
endmodule
