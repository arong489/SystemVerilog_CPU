`timescale 1ns/1ps
module Pause_Ctrl
import databus::*;
( 
	input WBSIGNAL wbSignal_ID,wbSignal_EX,wbSignal_MEM,
	input busy,
	input eret,
	output Pause
);

	wire id_rs_Pause,id_rt_Rause,ex_rs_Pause,ex_rt_Pause,MDV_Pause;

	assign id_rs_Pause = `ID_use_rs(ID)&&(	(`MEM_1_rs&&wbSignal_MEM.rs==wbSignal_ID.rs) || (`MEM_1_rt&&wbSignal_MEM.rt==wbSignal_ID.rs) || (`MEM_1_rd&&wbSignal_MEM.rd==wbSignal_ID.rs)|| (`MEM_1_ra&&5'h1f==wbSignal_ID.rs)||
											(`EX_2_rs&&wbSignal_EX.rs==wbSignal_ID.rs) || ((`EX_1_rt||`EX_2_rt)&&wbSignal_EX.rt==wbSignal_ID.rs) || ((`EX_1_rd||`EX_2_rd)&&wbSignal_EX.rd==wbSignal_ID.rs) || (`EX_2_ra&&5'h1f==wbSignal_ID.rs));
	
	assign id_rt_Rause = `ID_use_rt(ID)&&(  (`MEM_1_rs&&wbSignal_MEM.rs==wbSignal_ID.rt) || (`MEM_1_rt&&wbSignal_MEM.rt==wbSignal_ID.rt) || (`MEM_1_rd&&wbSignal_MEM.rd==wbSignal_ID.rt)|| (`MEM_1_ra&&5'h1f==wbSignal_ID.rt)||
											(`EX_2_rs&&wbSignal_EX.rs==wbSignal_ID.rt) || ((`EX_1_rt||`EX_2_rt)&&wbSignal_EX.rt==wbSignal_ID.rt) || ((`EX_1_rd||`EX_2_rd)&&wbSignal_EX.rd==wbSignal_ID.rt) || (`EX_2_ra&&5'h1f==wbSignal_ID.rt));

	assign ex_rs_Pause = `EX_use_rs(ID)&&((`EX_2_rs&&wbSignal_EX.rs==wbSignal_ID.rs) || (`EX_2_rt&&wbSignal_EX.rt==wbSignal_ID.rs) || (`EX_2_rd&&wbSignal_EX.rd==wbSignal_ID.rs) || (`EX_2_ra&&5'h1f==wbSignal_ID.rs));

	assign ex_rt_Pause = `EX_use_rt(ID)&&((`EX_2_rs&&wbSignal_EX.rs==wbSignal_ID.rt) || (`EX_2_rt&&wbSignal_EX.rt==wbSignal_ID.rt) || (`EX_2_rd&&wbSignal_EX.rd==wbSignal_ID.rt) || (`EX_2_ra&&5'h1f==wbSignal_ID.rt));

	assign MDV_Pause = `MDV_func(ID) && busy;

	wire CP0_Pause = (eret && ((wbSignal_EX.ismtc0&&wbSignal_EX.rd==5'd14)||(wbSignal_MEM.ismtc0&&wbSignal_MEM.rd==5'd14)))||
						(wbSignal_ID.ismfc0&&((wbSignal_EX.ismtc0&&wbSignal_ID.rd==wbSignal_EX.rd)||(wbSignal_MEM.ismtc0&&wbSignal_ID.rd==wbSignal_MEM.rd)));

	assign Pause = id_rs_Pause | id_rt_Rause | ex_rs_Pause | ex_rt_Pause | MDV_Pause | CP0_Pause;

endmodule : Pause_Ctrl