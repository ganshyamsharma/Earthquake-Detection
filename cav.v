`timescale 1ns / 1ps

module cav #(parameter CAV_THRESHOLD = 56'h0001_0000000000, RECORD_TIME = 50)(
	input i_clk, i_accept,
	input [23:0] i_xdata_scaled, i_ydata_scaled, i_zdata_scaled,
	output o_cav_alarm
	);
	
	localparam TIMESCALE = 20'b0000_0000_0100_0001_1001; 
	
	reg r_cav_alarm = 0;
	reg [$clog2(100000)-1 : 0] r_clk_cnt = 0;
	reg [35:0] r_xdata_acc = 0, r_ydata_acc = 0, r_zdata_acc = 0;
	reg [55:0] r_xdata_intg = 0, r_ydata_intg = 0, r_zdata_intg = 0;
	wire w_clk_1k;
	
	assign o_cav_alarm = r_cav_alarm;
	
	clk_1k du0(i_clk, w_clk_1k);
	
	always @(posedge i_clk) begin
		r_xdata_intg <= r_xdata_acc * TIMESCALE;
		r_ydata_intg <= r_ydata_acc * TIMESCALE;
		r_zdata_intg <= r_zdata_acc * TIMESCALE;	
		if((r_xdata_intg > CAV_THRESHOLD) | (r_ydata_intg > CAV_THRESHOLD) | (r_zdata_intg > CAV_THRESHOLD)) begin
			r_cav_alarm <= 1;
		end
		/*
		else if(i_accept) begin
			r_cav_alarm <= 0;
		end
		*/
		else begin
			r_cav_alarm <= 0;
		end
	end
	
	always @(posedge w_clk_1k) begin
		if((r_clk_cnt < (RECORD_TIME*1000))) begin            //& (~r_cav_alarm), FOR ACCEPT BUTTON
			r_xdata_acc <= r_xdata_acc + i_xdata_scaled;
			r_ydata_acc <= r_ydata_acc + i_ydata_scaled;
			r_zdata_acc <= r_zdata_acc + i_zdata_scaled;
			r_clk_cnt <= r_clk_cnt + 1;			
		end
		else begin
			r_xdata_acc <= 0;
			r_ydata_acc <= 0;
			r_zdata_acc <= 0;
			r_clk_cnt <= 0;				
		end
	end
	
endmodule	
/*
module clk_1k(
    input i_clk,
    output o_clk
    );
    
    reg [$clog2(50000)-1 : 0] cnt = 0;
    reg r_clk = 0;
    
    assign o_clk = r_clk;
    
    always @(posedge i_clk) begin
            if(cnt == 49999) begin
                r_clk <= ~r_clk;
                cnt <= 0;
            end
            else begin
                cnt <= cnt + 1;
                r_clk <= r_clk;
            end          
    end
endmodule
*/