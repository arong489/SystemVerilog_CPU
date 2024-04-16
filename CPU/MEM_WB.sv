`timescale 1ns/1ps
module MEM_WB
import databus::*;
(
	input clk,    // Clock
	input clk_en, // Clock Enable
	input reset,  // Asynchronous reset active low
	input WBSIGNAL wbsignal_in,
	input WBDATA wbdata_in,
	output WBSIGNAL wbsignal_out,
	output WBDATA wbdata_out
);
	WBSIGNAL wbsignal_reg = 0;
	WBDATA wbdata_reg = 0;

	assign wbsignal_out = wbsignal_reg;
	assign wbdata_out = wbdata_reg;

	always_ff @(posedge clk) begin : proc_MEM_WB
		if(reset) begin
			wbsignal_reg <= 0;
			wbdata_reg <= 0;
		end else if(clk_en) begin
			wbsignal_reg <= wbsignal_in;
			wbdata_reg <= wbdata_in;
		end
	end

endmodule : MEM_WB