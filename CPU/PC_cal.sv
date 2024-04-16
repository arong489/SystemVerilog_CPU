`timescale 1ns/1ps
module PC_cal
import databus::PC_cal_Sel_Sig;
(
	input [31:0] PC,
	input [25:0] _26_bit_imm,
	input PC_cal_Sel_Sig PC_cal_Sel,
	output [31:0] iPC
);
	assign iPC =PC_cal_Sel==databus::PCbranch 	? PC + 32'h4 + {{14{_26_bit_imm[15]}},_26_bit_imm[15:0],2'b0} :
				PC_cal_Sel==databus::PCjump		? {PC[31:28],_26_bit_imm,2'b0} :
				'x;

endmodule : PC_cal