`timescale 1ns/1ps
module CPU 
import databus::*;
(
	input clk,    // Clock
	input reset,  // Asynchronous reset active high
//IM
    output logic [31:0] i_inst_addr,
	input [31:0] i_inst_rdata,
//DM
    output [31:0] m_data_addr,
    output [3 :0] m_data_byteen,
    output [31:0] m_data_wdata,
    input [31:0] m_data_rdata,
    output [31:0] m_inst_addr,
//GRF
    output w_grf_we,
    output [4:0] w_grf_addr,
    output logic [31:0] w_grf_wdata,
    output [31:0] w_inst_addr,

    output [31:0] macroscopic_pc, // 宏观 PC
	input [5:0] HWInt
);
IDSIGNAL idSignal;
EXSIGNAL exSignal_ID,exSignal;
MEMSIGNAL memSignal_ID,memSignal_EX,memSignal;
WBSIGNAL wbSignal_ID,wbSignal_EX,wbSignal_MEM,wbSignal;

EXDATA exdata;
MEMDATA memdata;
WBDATA wbdata;


ORDER order_IF,order;
wire [31:0] PC;
wire clk_en=1,eq;
wire [31:0] iPC,nPC;

wire [31:0] EXT_imm,R_rs,R_rt,idR_rs,idR_rt,MDVans;
wire busy;
wire [4:0] RegDst;
RegDst_Sel_Sig RegDst_Sel;
toReg_Sel_Sig toReg_Sel;
wire [31:0] toReg,exForward,memForward;

wire [1:0] ForwardingRSD,ForwardingRTD,ForwardingRSE,ForwardingRTE;
wire ForwardingRTM;
wire Pause;
wire [31:0] EX_ans;
wire [31:0] EPC;
ExcCode_Define IFexc,IDexc,preIDexc,MEMexc;
wire Req;

MUX #(PCSrc_SelWidth) u_PCSrc(
	.Select(idSignal.PCSrc_Sel),
	.Inputs('{0:i_inst_addr+32'h4,1:iPC,2:idR_rs,3:EPC+4}),
	.Output(nPC)
);
wire [31:0] temp_IF_PC;
logic Pause_clk_en; 

IFPC u_getPC(
	.clk   (clk),
	.reset (reset),
	.clk_en(Pause_clk_en),
	.Req   (Req),
	.nPC   (nPC),
	.PC    (temp_IF_PC)
);

always_comb begin
	if(idSignal.eret) i_inst_addr = EPC;//eret强制跳转
	else i_inst_addr = temp_IF_PC;
	if (Pause) Pause_clk_en = 0;
	else Pause_clk_en = 1; 
end

//IFexcADEL可能需要判eret但是强制跳转不需要？
// wire IFexcAdEL = (i_inst_addr[1:0]!=0 || i_inst_addr<32'h3000 || i_inst_addr>32'h6ffc) && !idSignal.eret;
wire IFexcAdEL = (i_inst_addr[1:0]!=0 || i_inst_addr<32'h3000 || i_inst_addr>32'h6ffc) ;

assign order_IF = IFexcAdEL ? 0 : {i_inst_rdata,i_inst_rdata[25:0]};//异常气泡

assign IFexc = IFexcAdEL ? AdEL : INT;

/*------------------------------------------------------------------------------
-- IF/ID  
------------------------------------------------------------------------------*/
wire BD_in,BD_out;
IF_ID u_if_id(
	.clk      (clk),
	.reset    (reset),
	.clk_en   (Pause_clk_en|Req),
	.order_in (order_IF),
	.order_out(order),
	// .Req        (Req),
	.BD_in      (BD_in),
	.BD_out     (BD_out),
	.EXcCode_in (IFexc),
	.EXcCode_out(preIDexc),
	.PC_in    (i_inst_addr),
	.PC_out   (PC)
);

Pause_Ctrl u_Pause_Ctrl(
	.wbSignal_EX (wbSignal_EX),
	.wbSignal_MEM(wbSignal_MEM),
	.wbSignal_ID (wbSignal_ID),
	.eret        (idSignal.eret),
	.busy        (busy|exSignal.start),
	.Pause     	 (Pause)
);

Forwarding_Ctrl u_Forwarding_Ctrl(
	.wbSignal_ID  (wbSignal_ID),
	.wbSignal_MEM (wbSignal_MEM),
	.wbSignal_EX  (wbSignal_EX),
	.wbSignal_WB  (wbSignal),
	.RegDst       (RegDst),
	.ForwardingRSD(ForwardingRSD),
	.ForwardingRSE(ForwardingRSE),
	.ForwardingRTD(ForwardingRTD),
	.ForwardingRTE(ForwardingRTE),
	.ForwardingRTM(ForwardingRTM)
);

assign eq = idR_rs==idR_rt;
wire IDexcRI,IDSYSCALL;

wire CU0,EXL;

Ctrl u_ctrl(
	.order    (order),
	.eq       (eq),
	.BD         (BD_in),
	.idSignal (idSignal),
	.exSignal (exSignal_ID),
	.memSignal(memSignal_ID),
	.wbSignal (wbSignal_ID),
	.wbSignal_WB(wbSignal),
	.RegDst_Sel (RegDst_Sel),
	.toReg_Sel  (toReg_Sel),
	.Req        (Req),
	.RI         (IDexcRI),
	.BD_ex      (BD_out),
	.SYSCALL    (IDSYSCALL),
	.CU0        (CU0),
	.EXL        (EXL)
);

GRF u_grf(
	.clk   (clk),
	.reset (reset),
	// .PC    (wbdata.PC),
	.Radds ('{order.rs,order.rt}),
	.Rdatas('{R_rs,R_rt}),
	.GRF_WE(wbSignal.GRF_WE&!wbdata.clear),
	.Wadds ('{RegDst}),
	.Wdatas('{toReg})
);

assign w_grf_we = wbSignal.GRF_WE&!wbdata.clear;
assign w_grf_addr = RegDst;
assign w_grf_wdata = toReg;
assign w_inst_addr = wbdata.PC;

// wire [31:0] ins;
// assign ins = {wbSignal.func,wbSignal.rs,wbSignal.rt,wbSignal.rd,wbSignal.rs,wbSignal.func};
// assign w_grf_wdata = ( memdata.PC==32'h301c ) ? wbSignal.ins : toReg ;
// assign w_grf_we = ( memdata.PC==32'h301c ) ? 1 : wbSignal.GRF_WE&!wbdata.clear ;

MUX #(2) MFRSD(
	.Select(ForwardingRSD),
	.Inputs('{0:R_rs,1:exForward,2:memForward,3:'x}),
	.Output(idR_rs)
);
MUX #(2) MFRTD(
	.Select(ForwardingRTD),
	.Inputs('{0:R_rt,1:exForward,2:memForward,3:'x}),
	.Output(idR_rt)
);

EXT u_ext(
	.PC         (PC),
	._16_bit_imm(order._26_bit_imm[15:0]),
	.EXTop      (idSignal.EXTop),
	.EXT_imm    (EXT_imm)
);

PC_cal u_PC_cal(
	.PC         (PC),
	._26_bit_imm(order._26_bit_imm),
	.PC_cal_Sel (idSignal.PC_cal_Sel),
	.iPC        (iPC)
);

assign IDexc = preIDexc == INT ? (IDexcRI? RI : IDSYSCALL ? Syscall : INT) : preIDexc;

/*------------------------------------------------------------------------------
-- ID/EX 
------------------------------------------------------------------------------*/

// assign exdata_1='{idR_rs,idR_rt,EXT_imm,PC,order.shamet,RegDst};
ID_EX u_id_ex(
	.clk          (clk),
	.clk_en       (clk_en),
	.reset        (reset),
	.Pause        (!Pause_clk_en),
	.Req          (Req),
	.exsignal_in  (exSignal_ID),
	.memsignal_in (memSignal_ID),
	.wbsignal_in  (wbSignal_ID),
	.exdata_in    ('{idR_rs,idR_rt,EXT_imm,PC,order.shamet,IDexc}),
	.exdata_out   (exdata),
	.exsignal_out (exSignal),
	.memsignal_out(memSignal_EX),
	.wbsignal_out (wbSignal_EX)
);

wire [31:0] exR_rs;
wire [31:0] exR_rt;
wire [31:0] B;

MUX #(2) MFRSE(
	.Select(ForwardingRSE),
	.Inputs('{0:exdata.R_rs,1:memForward,2:toReg,3:'x}),
	.Output(exR_rs)
);

MUX #(2) MFRTE(
	.Select(ForwardingRTE),
	.Inputs('{0:exdata.R_rt,1:memForward,2:toReg,3:'x}),
	.Output(exR_rt)
);

MUX #(ALUsrc_SelWidth) u_ALUSrc(
	.Select(exSignal.ALUsrc_Sel),
	.Inputs('{0:exR_rt,1:exdata.Imm}),
	.Output(B)
);

wire overflow;
wire [31:0] ALU_ans;
ALU u_ALU(
	.ALUop    (exSignal.ALUop),
	.A        (exR_rs),
	.B        (B),
	.shamet   (exdata.shamet),
	.overflow(overflow),
	.ALU_ans  (ALU_ans)
);

MDV	u_MDV(
	.clk   (clk),
	.reset (reset),
	.A     (exR_rs),
	.B     (B),
	.start (exSignal.start&!Req),
	.MDVop (exSignal.MDVop),
	.MDVans(MDVans),
	.busy  (busy)
);


MUX #(toReg_SelWidth) u_exForward(
	.Select(wbSignal_EX.toReg_Sel),
	.Inputs('{0:'x,1:'x,2:exdata.Imm,3:exdata.PC+32'h8}),//wALUans,wDM,wImm,wPC8
	.Output(exForward)
);


MUX #(1) u_EX_ans_Sel(
	.Select(exSignal.EX_ans_Sel),
	.Inputs('{0:ALU_ans,1:MDVans}),
	.Output(EX_ans)
);

wire RI_plus;
assign RI_plus = (wbSignal_EX.ismfc0||wbSignal_EX.ismtc0)&&!CU0&&!EXL;
ExcCode_Define exExcCode;
assign exExcCode = RI_plus ? RI : exdata.ExcCode;

/*------------------------------------------------------------------------------
--  EX/MEM
------------------------------------------------------------------------------*/

// assign memdata_1='{ALU_ans,exR_rt,exdata.Imm,exdata.PC,exdata.RegDst};
wire MEMexcAdES,MEMexcAdEL;
EX_MEM u_ex_mem(
	.clk          (clk),
	.reset        (reset),
	.Req          (Req),
	.clk_en       (clk_en),
	.memsignal_in (memSignal_EX),
	.wbsignal_in  (wbSignal_EX),
	.memdata_in   ('{EX_ans,exR_rt,exdata.Imm,exdata.PC,overflow,exExcCode}),
	.memsignal_out(memSignal),
	.wbsignal_out (wbSignal_MEM),
	.memdata_out  (memdata)
);

wire [31:0] memR_rt;

MUX MFRTM(
	.Select(ForwardingRTM),
	.Inputs('{0:memdata.R_rt,1:toReg}),
	.Output(memR_rt)
); 

assign MEMexc = memdata.ExcCode == INT ? (MEMexcAdEL ? AdEL : MEMexcAdES ? AdES : memdata.overflow ? Ov : INT) : memdata.ExcCode;

wire [31:0] DM_Rdata;
wire [31:0] CP0Out;

CP0	u_CP0(
	.clk    (clk),
	.reset  (reset),
	.WE     (memSignal.CPO_WE&&!Req),
	.CP0Add (wbSignal_MEM.rd),
	.CP0In  (memR_rt),
	.CP0Out (CP0Out),
	.Req    (Req),
	.ExcCode(MEMexc),
	.VPC    (memdata.PC),
	.BDIn   (memSignal.BD),
	.HWInt  (HWInt),
	.EPCOut (EPC),
	.EXClr  (idSignal.eret),
	.CU0    (CU0),
	.EXL    (EXL)
);

assign m_data_addr = memdata.EX_ans;
assign m_inst_addr =memdata.PC;
assign macroscopic_pc=memdata.PC;

logic [3:0] tempbyteen;

BE u_BE(
	.wbSignal_MEM(wbSignal_MEM),
	.Addr    	 (memdata.EX_ans),
	.memR_rt     (memR_rt),
	.byteen      (tempbyteen),
	.DMwdata     (m_data_wdata),
	.overflow    (memdata.overflow),
	.excAdES     (MEMexcAdES)
);

assign m_data_byteen = Req ? 0 : tempbyteen;

DE u_DE(
	.Addr 		(memdata.EX_ans),
	.DM_Rdata 	(m_data_rdata),
	.Load_Data	(DM_Rdata),
	.wbSignal_MEM(wbSignal_MEM),
	.overflow    (memdata.overflow),
	.excAdEL     (MEMexcAdEL)
);

wire [31:0] MEM_ans;
MUX #(1) u_MEM_ans_Sel(
	.Select(memSignal.MEM_ans_Sel),
	.Inputs('{0:DM_Rdata,1:CP0Out}),
	.Output(MEM_ans)
);


MUX #(toReg_SelWidth) u_memForward(
	.Select(wbSignal_MEM.toReg_Sel),
	.Inputs('{0:memdata.EX_ans,1:'x,2:memdata.Imm,3:memdata.PC+32'h8}),//wALUans,wDM,wImm,wPC8
	.Output(memForward)
);

/*------------------------------------------------------------------------------
-- MEM/WB 
------------------------------------------------------------------------------*/

// assign wbdata_1='{memdata.Addr,MEM_ans,memdata.Imm,memdata.PC+32'h4,memdata.RegDst};

MEM_WB u_mem_wb(
	.clk         (clk),
	.reset       (reset),
	.clk_en      (clk_en),
	.wbsignal_in (wbSignal_MEM),
	.wbdata_in   ('{memdata.EX_ans,MEM_ans,memdata.Imm,memdata.PC,Req}),
	.wbsignal_out(wbSignal),
	.wbdata_out  (wbdata)
);

MUX #(toReg_SelWidth) u_toReg(
	.Select(toReg_Sel),
	.Inputs('{0:wbdata.EX_ans,1:wbdata.MEM_ans,2:wbdata.Imm,3:wbdata.PC+32'h8}),//wALUans,wDM,wImm,wPC8
	.Output(toReg)
);

MUX #(RegDst_SelWidth,5) u_RegDst(
	.Select(RegDst_Sel),
	.Inputs('{5'h1f,wbSignal.rd,wbSignal.rt,wbSignal.rs}),
	.Output(RegDst)
);

endmodule : CPU