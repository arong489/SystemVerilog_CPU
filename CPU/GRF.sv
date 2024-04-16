`timescale 1ns/1ps
module GRF #(
	parameter Read_Num = 2,
			Write_Num = 1
) (
	// input [31:0] PC,


	input clk,    // Clock
	input GRF_WE, // Clock Enable
	input reset,  // Asynchronous reset active high
	input [4:0] Radds [Read_Num-1:0],
	input [4:0] Wadds [Write_Num-1:0],
	input [31:0] Wdatas [Write_Num-1:0],
	output reg [31:0] Rdatas [Read_Num-1:0]
);
	reg [31:0] regs [31:0] = '{default:0};


	reg [31:0] disAddr;

	//read,内部转发
	always_comb begin : proc_regs_read
		for (int i = 0; i < Read_Num; i++) begin
			Rdatas[i] <= regs [Radds[i]];
			if(GRF_WE)
			for (int j = 0; j < Write_Num; j++) begin
				if (Radds[i]!=0 && Radds[i]==Wadds[j]) Rdatas[i] <= Wdatas[j];//internal forwarding and check zero
			end
		end
	end

	// write,同步复位    异步复位请食用"@(posedge clk or posedge reset)"
	always_ff @(posedge clk) begin : proc_regs_write
		if(reset) begin
			regs <= '{default:0};
		end else begin
			if(GRF_WE) begin
				for (int i = 0; i < Write_Num; i++) begin
					regs[Wadds[i]] <= (Wadds[i]!=0) ? Wdatas[i] : 0;
					// disAddr = Wadds[i];
					// if(disAddr!=0)$display("%d@%h: $%d <= %h",$time,PC,disAddr,Wdatas[i]*(Wadds[i]!=0));
				end
				regs[0] <= 0;
			end
		end
	end
endmodule : GRF