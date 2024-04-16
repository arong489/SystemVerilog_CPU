`timescale 1ns/1ps
module Forwarding_Ctrl
import databus::*;
(
	input WBSIGNAL wbSignal_ID,wbSignal_EX,wbSignal_MEM,wbSignal_WB,
	input [4:0] RegDst,
	output [1:0] ForwardingRSD,ForwardingRTD,ForwardingRSE,ForwardingRTE,
	output ForwardingRTM
);

	assign ForwardingRSD = `ID_use_rs(ID)?(
								(`EX_done_rt&&wbSignal_EX.rt==wbSignal_ID.rs)||(`EX_done_rd&&wbSignal_EX.rd==wbSignal_ID.rs)||(`EX_done_ra&&5'h1f==wbSignal_ID.rs) ? 1 :
								(`MEM_done_rt&&wbSignal_MEM.rt==wbSignal_ID.rs)||(`MEM_done_rd&&wbSignal_MEM.rd==wbSignal_ID.rs)||(`MEM_done_ra&&5'h1f==wbSignal_ID.rs) ? 2 : 0
							) : 0;

	assign ForwardingRTD = `ID_use_rt(ID)?(
								(`EX_done_rt&&wbSignal_EX.rt==wbSignal_ID.rt)||(`EX_done_rd&&wbSignal_EX.rd==wbSignal_ID.rt)||(`EX_done_ra&&5'h1f==wbSignal_ID.rt) ? 1 :
								(`MEM_done_rt&&wbSignal_MEM.rt==wbSignal_ID.rt)||(`MEM_done_rd&&wbSignal_MEM.rd==wbSignal_ID.rt)||(`MEM_done_ra&&5'h1f==wbSignal_ID.rt) ? 2 : 0
							) : 0;

	assign ForwardingRSE = `EX_use_rs(EX)?(
								(`MEM_done_rt&&wbSignal_MEM.rt==wbSignal_EX.rs)||(`MEM_done_rd&&wbSignal_MEM.rd==wbSignal_EX.rs)||(`MEM_done_ra&&5'h1f==wbSignal_EX.rs) ? 1 :
								`WB_done_RegDst&&(RegDst==wbSignal_EX.rs) ? 2 : 0
							) : 0;

	assign ForwardingRTE = (`EX_use_rt(EX)||`MEM_use_rt(EX))?(//提前转发
								(`MEM_done_rt&&wbSignal_MEM.rt==wbSignal_EX.rt)||(`MEM_done_rd&&wbSignal_MEM.rd==wbSignal_EX.rt)||(`MEM_done_ra&&5'h1f==wbSignal_EX.rt) ? 1 :
								`WB_done_RegDst&&(RegDst==wbSignal_EX.rt) ? 2 : 0
							) : 0;

	assign ForwardingRTM = `MEM_use_rt(MEM)?(
								`WB_done_RegDst&&(RegDst==wbSignal_MEM.rt) ? 1 : 0
							) : 0;

endmodule : Forwarding_Ctrl