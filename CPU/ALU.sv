`timescale 1ns/1ps
module ALU 
import databus::ALUOPTION;
(
	input ALUOPTION ALUop,
	input [31:0] A,B,
	input [4:0] shamet,
	output logic overflow,
	output reg [31:0] ALU_ans
);
	wire signed [31:0] temp;
	assign equ = A==B;
	assign less = $signed(A) < $signed(B);
	assign greater = $signed(A) > $signed(B);
	assign u_less = $unsigned(A) < $unsigned(B);
	assign u_greater = $unsigned(A) > $unsigned(B);

	assign temp = ALUop == databus::ALU_add ? A + B :
				ALUop == databus::ALU_sub ? A - B : 'x;

	always_comb begin : proc_ALU
		if (ALUop==databus::ALU_add)
			overflow = (!(A[31]^B[31]))&(temp[31]^A[31]);
		else if (ALUop==databus::ALU_sub)
			overflow = (temp[31]^A[31])&(A[31]^B[31]);
		else overflow = 0;

		case (ALUop)
			databus::ALU_sllv:begin
				ALU_ans <= B << A[4:0];
			end
			databus::ALU_srav:begin
				ALU_ans <= $signed(B) >>> A[4:0];
			end
			databus::ALU_srlv:begin
				ALU_ans <= B >> A[4:0];
			end
			databus::ALU_add:begin
				ALU_ans <= A + B;
			end
			databus::ALU_sub:begin
				ALU_ans <= A - B;
			end
			databus::ALU_and:begin
				ALU_ans <= A & B;
			end
			databus::ALU_or:begin
				ALU_ans <= A | B;
			end
			databus::ALU_xor:begin
				ALU_ans <= A ^ B;
			end
			databus::ALU_nor:begin
				ALU_ans <= ~(A|B);
			end
			databus::ALU_slt:begin
				ALU_ans <= less ? 31'h1 : 31'h0;
			end
			databus::ALU_sltu:begin
				ALU_ans <= u_less ? 31'h1 : 31'h0;
			end
			databus::ALU_sll:begin
				ALU_ans <= B << shamet;
			end
			databus::ALU_sra:begin
				ALU_ans <= $signed(B) >>> shamet;
			end
			databus::ALU_srl:begin
				ALU_ans <= B >> shamet;
			end
			default : /* default */;
		endcase
	end
endmodule : ALU