
`timescale 1ns / 1ps

module wbcav #(parameter WBCAV_THRESHOLD = 56'h0001_0000000000, WINDOW_SIZE = 16, WINDOW_THRESHOLD = 20'h06666) // Each window of 1s interval
	(
	input i_clk, i_accept,
	input [23:0] i_xdata_scaled, i_ydata_scaled, i_zdata_scaled,
	output o_wbcav_alarm
	);
	
	localparam TIMESCALE = 20'b0000_0000_0100_0001_1001;
	localparam RECORD_TIME = 1;                            
	
	reg r_wbcav_alarm = 0, r_x_win_valid, r_y_win_valid, r_z_win_valid;
	reg [$clog2(1000)-1 : 0] r_clk_cnt = 0;
	reg [35:0] r_xdata_acc_1 = 0, r_ydata_acc_1 = 0, r_zdata_acc_1 = 0;
	reg [35:0] r_xdata_acc [WINDOW_SIZE-1 : 0], r_ydata_acc [WINDOW_SIZE-1 : 0], r_zdata_acc [WINDOW_SIZE-1 : 0];
	reg [35:0] r_xdata_win_sum, r_ydata_win_sum, r_zdata_win_sum; //r_xdata_win_sum_temp, r_ydata_win_sum_temp, r_zdata_win_sum_temp;
	reg [55:0] r_xdata_intg = 0, r_ydata_intg = 0, r_zdata_intg = 0;
	wire w_clk_1k;
	integer i;
	
	assign o_wbcav_alarm = r_wbcav_alarm;
	
	clk_1k du1(i_clk, w_clk_1k);
	
	always @(posedge i_clk) begin
	   // r_xdata_win_sum_temp = 0;
	   // r_ydata_win_sum_temp = 0;
	   // r_zdata_win_sum_temp = 0;	    
		//for (i = 0; i < WINDOW_SIZE; i = i + 1) begin
			r_xdata_win_sum <= r_xdata_acc[0] + r_xdata_acc[1] + r_xdata_acc[2] + r_xdata_acc[3] + r_xdata_acc[4] + r_xdata_acc[5] + r_xdata_acc[6] + r_xdata_acc[7] + r_xdata_acc[8] + r_xdata_acc[9] + r_xdata_acc[10] + r_xdata_acc[11] + r_xdata_acc[12] + r_xdata_acc[13] + r_xdata_acc[14] + r_xdata_acc[15];
			r_ydata_win_sum <= r_ydata_acc[0] + r_ydata_acc[1] + r_ydata_acc[2] + r_ydata_acc[3] + r_ydata_acc[4] + r_ydata_acc[5] + r_ydata_acc[6] + r_ydata_acc[7] + r_ydata_acc[8] + r_ydata_acc[9] + r_ydata_acc[10] + r_ydata_acc[11] + r_ydata_acc[12] + r_ydata_acc[13] + r_ydata_acc[14] + r_ydata_acc[15];
			r_zdata_win_sum <= r_zdata_acc[0] + r_zdata_acc[1] + r_zdata_acc[2] + r_zdata_acc[3] + r_zdata_acc[4] + r_zdata_acc[5] + r_zdata_acc[6] + r_zdata_acc[7] + r_zdata_acc[8] + r_zdata_acc[9] + r_zdata_acc[10] + r_zdata_acc[11] + r_zdata_acc[12] + r_zdata_acc[13] + r_zdata_acc[14] + r_zdata_acc[15];
			//r_xdata_win_sum_temp = r_xdata_win_sum_temp + r_xdata_acc[i];
			//r_ydata_win_sum_temp = r_ydata_win_sum_temp + r_ydata_acc[i];
			//r_zdata_win_sum_temp = r_zdata_win_sum_temp + r_zdata_acc[i];			
		//end
		//r_xdata_win_sum <= r_xdata_win_sum_temp;
		//r_ydata_win_sum <= r_ydata_win_sum_temp;
		//r_zdata_win_sum <= r_zdata_win_sum_temp;
		
		r_xdata_intg <= r_xdata_win_sum * TIMESCALE;
		r_ydata_intg <= r_ydata_win_sum * TIMESCALE;
		r_zdata_intg <= r_zdata_win_sum * TIMESCALE;
		if((r_xdata_intg > WBCAV_THRESHOLD) | (r_ydata_intg > WBCAV_THRESHOLD) | (r_zdata_intg > WBCAV_THRESHOLD)) begin
			r_wbcav_alarm <= 1;
		end
		/*
		else if(i_accept) begin
			r_wbcav_alarm <= 0;
		end
		*/
		
		else begin
			r_wbcav_alarm <= 0;
		end
	end
	
	always @(posedge w_clk_1k) begin
		if(r_clk_cnt < (RECORD_TIME*1000)) begin
			r_xdata_acc_1 <= r_xdata_acc_1 + i_xdata_scaled;
			r_ydata_acc_1 <= r_ydata_acc_1 + i_ydata_scaled;
			r_zdata_acc_1 <= r_zdata_acc_1 + i_zdata_scaled;
			r_clk_cnt <= r_clk_cnt + 1;
			if (i_xdata_scaled > WINDOW_THRESHOLD) begin
				r_x_win_valid <= 1;
			end
			else begin
				r_x_win_valid <= r_x_win_valid;
			end
			if (i_ydata_scaled > WINDOW_THRESHOLD) begin
				r_y_win_valid <= 1;
			end
			else begin
				r_y_win_valid <= r_y_win_valid;
			end
			if (i_zdata_scaled > WINDOW_THRESHOLD) begin
				r_z_win_valid <= 1;
			end
			else begin
				r_z_win_valid <= r_z_win_valid;
			end
		end
		else begin
			r_xdata_acc_1 <= 0;
			r_ydata_acc_1 <= 0;
			r_zdata_acc_1 <= 0;
			r_clk_cnt <= 0;
			if(r_x_win_valid) begin
				for(i = 1; i < WINDOW_SIZE; i = i + 1) begin
					r_xdata_acc[i] <= r_xdata_acc[i-1];
				end
				r_xdata_acc[0] <= r_xdata_acc_1;
				r_x_win_valid <= 0;				
			end
			else begin
				for(i = 1; i < WINDOW_SIZE; i = i + 1) begin
					r_xdata_acc[i] <= r_xdata_acc[i-1];
				end
				r_xdata_acc[0] <= 0;
			end
			if(r_y_win_valid) begin
				for(i = 1; i < WINDOW_SIZE; i = i + 1) begin
					r_ydata_acc[i] <= r_ydata_acc[i-1];
				end
				r_ydata_acc[0] <= r_ydata_acc_1;
				r_y_win_valid <= 0;				
			end
			else begin
				for(i = 1; i < WINDOW_SIZE; i = i + 1) begin
					r_ydata_acc[i] <= r_ydata_acc[i-1];
				end
				r_ydata_acc[0] <= 0;
			end
			if(r_z_win_valid) begin
				for(i = 1; i < WINDOW_SIZE; i = i + 1) begin
					r_zdata_acc[i] <= r_zdata_acc[i-1];
				end
				r_zdata_acc[0] <= r_zdata_acc_1;
				r_z_win_valid <= 0;				
			end
			else begin
				for(i = 1; i < WINDOW_SIZE; i = i + 1) begin
					r_zdata_acc[i] <= r_zdata_acc[i-1];
				end
				r_zdata_acc[0] <= 0;
			end
		end
	end
endmodule

/////////////////////////////////////////////

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
