`timescale 1ns/1ps
module IF_ID 
import databus::*;
(
	input clk,    // Clock
	input clk_en, // Clock Enable
	input reset,  // Asynchronous reset active high
	input ORDER order_in,
	input [31:0] PC_in,
	input BD_in,
	output logic BD_out,
	input ExcCode_Define EXcCode_in,
	output ExcCode_Define EXcCode_out,
	output ORDER order_out,
	output [31:0] PC_out
);

	ORDER order_reg = 0;
	reg [31:0] PC_reg =0;
	reg BD_reg;
	ExcCode_Define EXcCode_reg;

	assign order_out = order_reg;
	assign PC_out = PC_reg;
	assign EXcCode_out = EXcCode_reg;
	assign BD_out = BD_reg;

	always_ff @(posedge clk) begin : proc_IF_ID
		if(reset) begin
			order_reg <= 0;
			EXcCode_reg <= 0;
			BD_reg <= 0;
			PC_reg <= 32'h3000;
		end else if(clk_en) begin
			order_reg <= order_in;
			PC_reg <= PC_in;
			EXcCode_reg <= EXcCode_in;
			BD_reg <= BD_in;
		end 
	end

endmodule : IF_ID