`timescale 1ns/1ps
module DE 
import databus::*;
(
	input [31:0] Addr,
	input [31:0] DM_Rdata,
	input WBSIGNAL wbSignal_MEM,
	input overflow,
	output logic[31:0] Load_Data,
	output logic excAdEL
);
	//未对齐
	logic AlignErr;
	//访问范围错误
	logic RangeErr;
	assign RangeErr=!(( (Addr >= `StartAddrDM) && (Addr <= `EndAddrDM) )||
					( (Addr >= `StartAddrTC1) && (Addr <= `EndAddrTC1) )||
					( (Addr >= `StartAddrTC0) && (Addr <= `EndAddrTC0) )||
					( (Addr >= `StartAddrIns) && (Addr <= `EndAddrIns) ));
	//非整字节访问timer
	logic TimerErr;
	logic Load;
	
	logic [15:0] hwdata;
	logic [7:0] bytedata;
	assign hwdata = Addr[1] ? DM_Rdata[31-:16] : DM_Rdata[15-:16];
	assign bytedata = Addr[1:0]==0 ? DM_Rdata[0+:8] :
						Addr[1:0]==1 ? DM_Rdata[8+:8] :
						Addr[1:0]==2 ? DM_Rdata[16+:8] :
						DM_Rdata[24+:8];

	always_comb begin : proc_DE
		Load = 1;
		case (wbSignal_MEM.opcode)
			lw:begin
				Load_Data = DM_Rdata;
				AlignErr = Addr[1:0]!=0;
				TimerErr = 0;
			end
			lh:begin
				Load_Data = {{16{hwdata[15]}},hwdata};
				AlignErr = Addr[0];
				TimerErr = ( (Addr >= `StartAddrTC1) && (Addr <= `EndAddrTC1) )||
							( (Addr >= `StartAddrTC0) && (Addr <= `EndAddrTC0) );
			end
			// lhu:begin
			// 	Load_Data = {16'h0,hwdata};
			// 	AlignErr = Addr[1];
			// 	TimerErr = ( (Addr >= `StartAddrTC1) && (Addr <= `EndAddrTC1) )||
			// 				( (Addr >= `StartAddrTC0) && (Addr <= `EndAddrTC0) );
			// end
			lb:begin
				Load_Data = {{24{bytedata[7]}},bytedata};
				AlignErr = 0;
				TimerErr = ( (Addr >= `StartAddrTC1) && (Addr <= `EndAddrTC1) )||
							( (Addr >= `StartAddrTC0) && (Addr <= `EndAddrTC0) );
			end
			// lbu:begin
			// 	Load_Data = {24'h0,bytedata};
			// 	TimerErr = ( (Addr >= `StartAddrTC1) && (Addr <= `EndAddrTC1) )||
			// 				( (Addr >= `StartAddrTC0) && (Addr <= `EndAddrTC0) );
			// end
			default :begin
				Load = 0;
				AlignErr = 0;
				TimerErr = 0;
			end
		endcase
		if(Load) excAdEL = AlignErr | RangeErr | TimerErr | overflow ;
		else excAdEL = 0;
	end

endmodule : DE