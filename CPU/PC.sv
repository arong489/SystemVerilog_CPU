`timescale 1ns/1ps
module IFPC
import databus::ORDER;
(
	input clk,    // Clock
	input clk_en, // Clock Enable
	input reset,  // Asynchronous reset active high
	input [31:0] nPC,
	input Req,
	output [31:0] PC
);
	reg [31:0] _PC = 32'h00003000;
	assign PC = Req&&!reset ? 32'h4180 : _PC;//reset优先序最高

	always_ff @(posedge clk) begin
		if(reset) begin
			_PC <= 32'h00003000;
		end else if(Req||clk_en!=0) begin
			_PC <= nPC;
		end
	end
endmodule : IFPC