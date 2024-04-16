`timescale 1ns/1ps
module EXT 
import databus::EXTOPTION;
(
	input EXTOPTION EXTop,
	input [15:0] _16_bit_imm,
	input [31:0] PC,
	output [31:0] EXT_imm
);
	assign EXT_imm = EXTop == databus::EXT_zero ? {16'h0,_16_bit_imm} :
					EXTop == databus::EXT_sig ? {{16{_16_bit_imm[15]}},_16_bit_imm} :
					EXTop == databus::EXT_lui ? {_16_bit_imm,16'h0} :
					'x;
endmodule : EXT