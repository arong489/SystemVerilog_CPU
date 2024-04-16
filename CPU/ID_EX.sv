`timescale 1ns/1ps
module ID_EX
import databus::*;
(
	input clk,    // Clock
	input clk_en, // Clock Enable
	input reset,  // Asynchronous reset active high
	input Req,
	input Pause,
	input EXSIGNAL exsignal_in,
	input MEMSIGNAL memsignal_in,
	input WBSIGNAL wbsignal_in,
	input EXDATA exdata_in,
	output EXSIGNAL exsignal_out,
	output MEMSIGNAL memsignal_out,
	output WBSIGNAL wbsignal_out,
	output EXDATA exdata_out
);

	EXSIGNAL exsignal_reg = 0;
	MEMSIGNAL memsignal_reg = 0;
	WBSIGNAL wbsignal_reg = 0;
	EXDATA exdata_reg = 0;

	assign exsignal_out = exsignal_reg;
	assign memsignal_out = memsignal_reg;
	assign wbsignal_out = wbsignal_reg;
	assign exdata_out = exdata_reg;

	always_ff @(posedge clk) begin : proc_ID_EX
		if(reset||Req||Pause) begin
			exsignal_reg <= 0;
			memsignal_reg <= 0;
			memsignal_reg.BD <= reset||Req ? 0 : memsignal_in.BD;
			wbsignal_reg <= 0;
			exdata_reg <= 0;
			exdata_reg.PC <= reset ? 32'h3000 : Req ? 32'h4180 : exdata_in.PC;//暂停读入下一个PC, 优先顺序
		end else if(clk_en) begin
			exsignal_reg <= exsignal_in;
			memsignal_reg <= memsignal_in;
			wbsignal_reg <= wbsignal_in;
			exdata_reg <= exdata_in;
		end
	end

endmodule : ID_EX