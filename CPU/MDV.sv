`timescale 1ns/1ps
`define MDV_mt 	(MDVop==databus::MDV_mthi||MDVop==databus::MDV_mtlo)
module MDV 
import databus::MDVOPTION;
(
	input clk,    // Clock
	input reset,
	input start,
	input MDVOPTION MDVop,
	input [31:0] A,B,
	output [31:0] MDVans,
	output logic busy
);

	reg[31:0] hi,lo,temphi,templo;
	reg[3:0] t=0;
	logic write=0;

	assign MDVans = MDVop==databus::MDV_mfhi ? hi :
					MDVop==databus::MDV_mflo ? lo :
					'x;

	assign busy = t>0;

	always_latch begin : proc_DMstore
		if(write)begin
			hi = temphi;
			lo = templo;
		end
	end

	always_ff @(posedge clk) begin : proc_MDV_cal
		write <= 0;
		if(reset) begin
			t <= 0;
			templo <= 0;
			temphi <= 0;
			write <= 1;
		end else if(busy) begin
			t <= t - 1;
			if(t==1)write<=1;
		end

		if(start && !reset) begin
			case (MDVop)
				databus::MDV_mult:begin
					t <= 5;
					{temphi,templo} <= $signed(A)*$signed(B);
				end
				databus::MDV_multu:begin
					t <= 5;
					{temphi,templo} <= A*B;
				end
				databus::MDV_div:begin
					t <= 10;
					templo <= $signed(A)/$signed(B);
					temphi <= $signed(A)%$signed(B);
				end
				databus::MDV_divu:begin
					t <= 10;
					templo <= A/B;
					temphi <= A%B;
				end
				default : /* default */;
			endcase
		end

		if(!reset) begin
			case (MDVop)
				databus::MDV_mthi:begin
					temphi <= A;
					write <= 1;
				end
				databus::MDV_mtlo:begin
					templo <= A;
					write <= 1;
				end
				default : /* default */;
			endcase
		end

	end

endmodule : MDV