`timescale 1ns/1ps
module EX_MEM
import databus::*;
(
	input clk,    // Clock
	input clk_en, // Clock Enable
	input reset,  // Asynchronous reset active high
	input Req,
	input MEMSIGNAL memsignal_in,
	input WBSIGNAL wbsignal_in,
	input MEMDATA memdata_in,
	output MEMSIGNAL memsignal_out,
	output WBSIGNAL wbsignal_out,
	output MEMDATA memdata_out
);

	MEMSIGNAL memsignal_reg = 0;
	WBSIGNAL wbsignal_reg = 0;
	MEMDATA memdata_reg = 0;

	assign memsignal_out = memsignal_reg;
	assign wbsignal_out = wbsignal_reg;
	assign memdata_out = memdata_reg;

	always_ff @(posedge clk) begin : proc_EX_MEM
		if(reset||Req) begin
			memsignal_reg <= 0;
			wbsignal_reg <= 0;
			memdata_reg <= 0;
			memdata_reg.PC <= reset ? 32'h3000 : 32'h4180;
		end else if(clk_en) begin
			memsignal_reg <= memsignal_in;
			wbsignal_reg <= wbsignal_in;
			memdata_reg <= memdata_in;
		end
	end

endmodule : EX_MEM