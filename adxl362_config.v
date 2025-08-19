`timescale 1ns / 1ps

module adxl_config(
	input i_clk, i_miso, i_start_config, i_accept,
	input [1:0] i_sel,
	output o_mosi, o_sclk, o_cs_n, o_alarm_pga, o_alarm_wbcav, o_alarm_cav,//o_config_comp
	output reg [23:0] o_leds
	);
	
	localparam [7:0] WR_CMD = 8'h0A;
	localparam [7:0] WR_ADDR = 8'h20;
	localparam [7:0] THRESH_ACT_L = 8'h00;
	localparam [7:0] THRESH_ACT_H = 8'h00;
	localparam [7:0] TIME_ACT = 8'h00;
	localparam [7:0] THRESH_INACT_L = 8'h00;
	localparam [7:0] THRESH_INACT_H = 8'h00;
	localparam [7:0] TIME_INACT_L = 8'h00;
	localparam [7:0] TIME_INACT_H = 8'h00;
	localparam [7:0] ACT_INACT_CTL = 8'h00;
	localparam [7:0] FIFO_CONTROL = 8'h00;
	localparam [7:0] FIFO_SAMPLES = 8'h80;
	localparam [7:0] INTMAP1 = 8'h00;
	localparam [7:0] INTMAP2 = 8'h00;
	localparam [7:0] FILTER_CTL = 8'h17;
	localparam [7:0] POWER_CTL = 8'h22;
	localparam [7:0] RD_CMD = 8'h0B;
	localparam [7:0] RD_ADDR = 8'h0E;
	localparam [127:0] WR_DATA_TOTAL = {WR_CMD, WR_ADDR, THRESH_ACT_L, 
	                                    THRESH_ACT_H, TIME_ACT, 
                                        THRESH_INACT_L, THRESH_INACT_H, 
                                        TIME_INACT_L, TIME_INACT_H, 
                                        ACT_INACT_CTL, FIFO_CONTROL, 
                                        FIFO_SAMPLES, INTMAP1, INTMAP2,
                                        FILTER_CTL, POWER_CTL};                                        
	localparam [15:0] RD_DATA_TOTAL = {RD_CMD, RD_ADDR};
	
	reg r_cs_n = 1, r_mosi = WR_DATA_TOTAL[127], r_config_comp = 0, r_rd_cycle_fin = 0;
	reg [$clog2(100000)-1 : 0] r_clk_cnt = 0, r_clk_cnt_1 = 0;
	reg [$clog2(1000)-1 : 0] r_neged_cnt = 0;
	reg [$clog2(1000)-1 : 0] r_posed_cnt = 0;
	reg [15:0] r_xdata = 0, r_ydata = 0, r_zdata = 0;
	reg [0:79] r_mem;
	wire w_sclk;
	wire [23:0] w_xdata_scaled, w_ydata_scaled, w_zdata_scaled;
	
	assign o_cs_n = r_cs_n;
	assign o_mosi = r_mosi;
	assign o_sclk = w_sclk;
	//assign o_config_comp = r_config_comp;
	
	spi_clk du0(i_clk, r_cs_n, w_sclk);
	scaler 	du1(i_clk, r_xdata, r_ydata, r_zdata, w_xdata_scaled, w_ydata_scaled, w_zdata_scaled);
	pga 	du3(i_clk, i_accept, w_xdata_scaled, w_ydata_scaled, w_zdata_scaled, o_alarm_pga);
	wbcav  	du4(i_clk, i_accept, w_xdata_scaled, w_ydata_scaled, w_zdata_scaled, o_alarm_wbcav);
	cav    	du5(i_clk, i_accept, w_xdata_scaled, w_ydata_scaled, w_zdata_scaled, o_alarm_cav);
    
    always @(*) begin
        case(i_sel)
            2'b00: o_leds = w_xdata_scaled;
            2'b01: o_leds = w_ydata_scaled;
            2'b10: o_leds = w_zdata_scaled;
            default: o_leds = 24'hF0F0F0;
        endcase
    end
    
	always @(posedge i_clk) begin
		if(i_start_config) begin
			if((r_clk_cnt < 12801) & ~(r_config_comp)) begin             //12800
				r_cs_n <= 0;
				r_clk_cnt <= r_clk_cnt + 1;
			end
			else begin
			    r_config_comp <= 1;
			    if(r_clk_cnt_1 < 1000) begin
			        r_clk_cnt_1 <= r_clk_cnt_1 + 1;
				    r_cs_n <= 1;
				end
				else if(r_clk_cnt_1 < 9000) begin
				    r_cs_n <= 0;
				    r_clk_cnt_1 <= r_clk_cnt_1 + 1;
				end
				else begin
				    r_cs_n <= 1;
				    r_clk_cnt_1 <= 0;
				end				
			end				
		end
		else begin
            r_cs_n <= 1;
		end
		if(r_rd_cycle_fin) begin
	       r_xdata <= {r_mem[24:31], r_mem[16:23]};
	       r_ydata <= {r_mem[40:47], r_mem[32:39]};
	       r_zdata <= {r_mem[56:63], r_mem[48:55]};
	    end
	    else begin
	       r_xdata <= r_xdata;
	       r_ydata <= r_ydata;
	       r_zdata <= r_zdata;	       
	    end
	end
	
	always @(posedge w_sclk) begin
	   if(r_config_comp) begin	       
	       if(r_posed_cnt < 79) begin
	           r_mem[r_posed_cnt] <= i_miso;
	           r_posed_cnt <= r_posed_cnt + 1;
	           r_rd_cycle_fin <= 0;
	       end
	       else begin
	           r_posed_cnt <= 0;
	           r_rd_cycle_fin <= 1;
	       end
	   end
	   else begin
	       r_posed_cnt <= 0;
	       r_rd_cycle_fin <= 0;
	   end
	end
	
	always @(negedge w_sclk) begin
		if(~r_config_comp) begin
			if(r_neged_cnt < 127) begin
				r_mosi <= WR_DATA_TOTAL[126-r_neged_cnt];
				r_neged_cnt <= r_neged_cnt + 1;
			end
			else begin
				r_mosi <= RD_DATA_TOTAL[15];
				r_neged_cnt <= 0;
			end
		end
		else begin
            if(r_neged_cnt < 15) begin
                r_mosi <= RD_DATA_TOTAL[14-r_neged_cnt];
                r_neged_cnt <= r_neged_cnt + 1;
            end
            else if(r_neged_cnt < 79) begin
                r_mosi <= 0;
                r_neged_cnt <= r_neged_cnt + 1;
            end
            else begin
                r_neged_cnt <= 0;
            end
		end
	end
endmodule
///////////////////
////////////////////////////////////
///////////////////
module spi_clk(
	input i_clk, input i_cs_n, 
	output o_sclk
	);
	
	reg r_sclk = 0;
	reg [$clog2(50)-1 : 0]r_clk_cnt = 0;
	assign o_sclk = r_sclk;
	
	always @(posedge i_clk) begin
		if(~i_cs_n) begin
			if(r_clk_cnt == 49) begin
				r_clk_cnt <= 0;
				r_sclk <= ~r_sclk;
			end
			else begin
				r_clk_cnt <= r_clk_cnt + 1;
			end
		end
		else begin
			r_sclk <= 0;
			r_clk_cnt <= 0;
		end
	end
endmodule
