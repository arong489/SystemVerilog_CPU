`timescale 1ns/1ps
module CP0
import databus::State_Register,databus::Cause_Register,databus::ExcCode_Define;
(
	input clk,    		// Clock
	input reset,  		// Asynchronous reset active high
	input WE, 			// Write Enable,mtc0
	input EXClr,		//SR.EXL(是否进入内核)复位
	input [4:0] CP0Add,	//CP0写地址,mtc0
	input [31:0] CP0In,	//CP0读入数据,mtc0
	input [31:0] VPC,	//受害PC
	input BDIn,			//是否延迟槽		Cause
	input ExcCode_Define ExcCode,//记录异常类型		Cause
	input [5:0] HWInt,	//6个设备中断信号	Cause
	output [31:0] CP0Out,//CP0读出数据,mfc0
	output [31:0] EPCOut,//EPC
	output Req,			//中断异常请求
	output CU0,
	output EXL
);

	State_Register SR;
	Cause_Register Cause;
	logic[31:0] EPC=0;
	
	//未进入异常才受理中断和异常
	logic IntReq,ExcReq;
	assign IntReq = SR.EXL==0 && SR.IE && (HWInt & SR.IM)!=0;	//中断请求
	assign ExcReq = SR.EXL==0 && ExcCode!=databus::INT;			//异常请求
	assign Req = IntReq | ExcReq;
	assign EXL = SR.EXL;
	assign CU0 = SR.CU0;


	assign EPCOut = Req ? (BDIn ? VPC - 32'h4 : VPC) : EPC;//Req转发为了出请求就能用EPC


	assign CP0Out =	(CP0Add == 12) ? SR :
					(CP0Add == 13) ? Cause :
					(CP0Add == 14) ? EPC :
					0;

	always_ff @(posedge clk) begin : proc_CP0_write_and_func
		if(reset) begin
			SR <= 32'h10000000 ;
			Cause <= 0;
			EPC <= 0;
		end else begin
			Cause.IP <= HWInt;		//中断更新,便于查询
			if (EXClr) SR.EXL <= 0;	//复位异常进入状态
			if (Req) begin
				Cause.ExcCode <= IntReq ? databus::INT : ExcCode;
				Cause.BD <= BDIn;
				EPC <= Req ? (BDIn ? VPC - 32'h4 : VPC) : EPC;
				SR.EXL <= 1'b1;
			end else if (WE) begin
				case (CP0Add)
					12: SR <= CP0In;
					13: Cause <= CP0In;
					14: EPC <= CP0In;
					default : /* default */;
				endcase
			end
		end
	end

endmodule : CP0