`define StartAddrDM         32'h0000_0000
`define EndAddrDM           32'h0000_2fff
`define StartAddrTC0        32'h0000_7f00
`define EndAddrTC0          32'h0000_7f0b
`define StartAddrTC1        32'h0000_7f10
`define EndAddrTC1          32'h0000_7f1b
`define StartAddrIns		32'h0000_7F20
`define EndAddrIns			32'h0000_7F23

module BE
import databus::*;
(
	input WBSIGNAL wbSignal_MEM,
	input [31:0] Addr,
	input [31:0] memR_rt,
	input overflow,
	output logic[3:0] byteen,
	output logic[31:0] DMwdata,
	output logic excAdES
);
	//未对齐
	logic AlignErr;
	//访问范围错误
	logic RangeErr;
	assign RangeErr=!(( (Addr >= `StartAddrDM) && (Addr <= `EndAddrDM) )||
					( (Addr >= `StartAddrTC0) && (Addr <= `EndAddrTC0) )||
					( (Addr >= `StartAddrTC1) && (Addr <= `EndAddrTC1) )||
					( (Addr >= `StartAddrIns) && (Addr <= `EndAddrIns) ));
	//非整字节访问timer
	logic TimerErr;
	//非法Timer写入
	logic TimerStoreErr;
	assign TimerStoreErr = (Addr >= 32'h0000_7f08 && Addr <= 32'h0000_7f0b)||(Addr >= 32'h0000_7f18 && Addr <= 32'h0000_7f1b);

	always_comb begin : proc_DMAdddrTran
		case (wbSignal_MEM.opcode)
			sw:begin
				byteen = 4'b1111;
				AlignErr = Addr[1:0]!=0;
				TimerErr = 0;
				DMwdata = memR_rt;
			end
			sh:begin
				byteen = Addr[1] ? 4'b1100 : 4'b0011;
				AlignErr = Addr[0];
				TimerErr = ( (Addr >= `StartAddrTC0) && (Addr <= `EndAddrTC0) )||
							( (Addr >= `StartAddrTC1) && (Addr <= `EndAddrTC1) );
				DMwdata = memR_rt << (Addr[1]*16);
			end
			sb:begin
				byteen = 4'b0001 << Addr[1:0];
				AlignErr = 0;
				TimerErr = ( (Addr >= `StartAddrTC0) && (Addr <= `EndAddrTC0) )||
							( (Addr >= `StartAddrTC1) && (Addr <= `EndAddrTC1) );
				DMwdata = memR_rt << (Addr[1:0]*8);
			end
			default :begin
				TimerErr = 0;
				byteen = 4'b0;
				AlignErr = 0;
			end
		endcase
	end


	assign excAdES = byteen!=0 & (AlignErr|TimerErr|TimerStoreErr|RangeErr|overflow);//除去计算溢出的store异常

endmodule : BE