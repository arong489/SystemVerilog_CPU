`timescale 1ns/1ps
module Ctrl
import databus::*;
(
	input ORDER order,
	input logic eq,
	input WBSIGNAL wbSignal_WB,
	input Req,
	output IDSIGNAL idSignal,
	output EXSIGNAL exSignal,
	output MEMSIGNAL memSignal,
	output WBSIGNAL wbSignal,
	output RegDst_Sel_Sig RegDst_Sel,
	output toReg_Sel_Sig toReg_Sel,
	output logic RI,
	output logic SYSCALL,
	output logic BD,
	input BD_ex,
	input CU0,
	input EXL
);

	wire isori  = ori ==order.opcode;
    wire issw   = sw  ==order.opcode;
    wire islw   = lw  ==order.opcode;
    wire isbeq  = beq ==order.opcode;
    wire islui  = lui ==order.opcode;
    wire isj    = j   ==order.opcode;
    wire isjal  = jal ==order.opcode;
    wire isaddi = addi==order.opcode;
    wire isandi = andi==order.opcode;
    wire islh   = lh  ==order.opcode;
    wire issh   = sh  ==order.opcode;
    wire islb   = lb  ==order.opcode;
    wire issb   = sb  ==order.opcode;
    wire isbne  = bne ==order.opcode;

	wire isadd  = R_format==order.opcode&&add  ==order.func;
	wire issub  = R_format==order.opcode&&sub  ==order.func;
	wire issll  = R_format==order.opcode&&sll  ==order.func;
	wire isjalr = R_format==order.opcode&&jalr ==order.func;
	wire isjr   = R_format==order.opcode&&jr   ==order.func;
	wire isandv = R_format==order.opcode&&andv ==order.func;
	wire isorv  = R_format==order.opcode&&orv  ==order.func;
	wire isslt  = R_format==order.opcode&&slt  ==order.func;
	wire issltu = R_format==order.opcode&&sltu ==order.func;
	wire ismult = R_format==order.opcode&&mult ==order.func;
	wire ismultu= R_format==order.opcode&&multu==order.func;
	wire isdiv  = R_format==order.opcode&&div  ==order.func;
	wire isdivu = R_format==order.opcode&&divu ==order.func;
	wire ismfhi = R_format==order.opcode&&mfhi ==order.func;
	wire ismflo = R_format==order.opcode&&mflo ==order.func;
	wire ismthi = R_format==order.opcode&&mthi ==order.func;
	wire ismtlo = R_format==order.opcode&&mtlo ==order.func;
	wire issysc = R_format==order.opcode&&syscall==order.func;

	wire ismtc0 = order.opcode==cop0&&order._26_bit_imm[10:0]==0&&order.rs==5'b00100;
	wire ismfc0 = order.opcode==cop0&&order._26_bit_imm[10:0]==0&&order.rs==5'b00000;
	wire iseret = order.opcode==cop0&&order.func==mult;

	assign RI = !CU0&&!EXL&&(ismfc0||ismtc0) ? 1 :
				 !(	isori | issw  | islw  | isbeq | islui | isj   | 
					isjal | isaddi| isandi| islh  | issh  | islb  | 
					issb  | isbne | isadd | issub | issll | isjalr| 
					isjr  | isandv| isorv | isslt | issltu| ismult| 
				   ismultu| isdiv | isdivu| ismfhi| ismflo| ismthi| 
					ismtlo| issysc| ismtc0| ismfc0| iseret);
	assign SYSCALL = issysc;
/*------------------------------------------------------------------------------
--  
------------------------------------------------------------------------------*/

	assign idSignal.EXTop = order.opcode==lui 															? EXT_lui :
							(order.opcode==sw||order.opcode==lw||order.opcode==sh||order.opcode==lh||
							order.opcode==sb||order.opcode==lb||order.opcode==beq||order.opcode==bne||
							order.opcode==addi)															? EXT_sig :
																										EXT_zero;

	assign idSignal.PCSrc_Sel = Req ? PC4 :
								iseret ? ePC4 :
								(order.opcode==R_format&&(order.func==jr||order.func==jalr))? jrPC :
								(order.opcode==j||order.opcode==jal||
								(order.opcode==beq&&eq)||(order.opcode==bne&&!eq))			? iPC :
																							PC4;


	assign idSignal.PC_cal_Sel = (order.opcode==beq&&eq)||(order.opcode==bne&&!eq)	? PCbranch :
								(order.opcode==j||order.opcode==jal)				? PCjump :
																					'x;

	assign idSignal.eret = iseret;


	assign exSignal.ALUsrc_Sel = (order.opcode==ori||order.opcode==lw||order.opcode==sw||order.opcode==addi||
								order.opcode==lb||order.opcode==lh||order.opcode==sh||order.opcode==sb||
								order.opcode==andi) ? Imm :
													R_rt;

	assign exSignal.ALUop = (order.opcode==lw||order.opcode==sw||order.opcode==addi||order.opcode==lh||
							order.opcode==sh||order.opcode==sb||order.opcode==lb||
							(order.opcode==R_format&&order.func==add))						? ALU_add :
							(order.opcode==ori||(order.opcode==R_format&&order.func==orv))	? ALU_or :
							(order.opcode==R_format&&order.func==sub)						? ALU_sub :
							(order.opcode==R_format&&order.func==sll)						? ALU_sll :
							(order.opcode==andi||(order.opcode==R_format&&order.func==andv))? ALU_and :
							(order.opcode==R_format&&order.func==slt)						? ALU_slt :
							(order.opcode==R_format&&order.func==sltu)						? ALU_sltu :
																							'x;
	assign exSignal.MDVop = order.opcode==R_format&&order.func==mult 	? MDV_mult :
							order.opcode==R_format&&order.func==multu 	? MDV_multu :
							order.opcode==R_format&&order.func==div 	? MDV_div :
							order.opcode==R_format&&order.func==divu 	? MDV_divu :
							order.opcode==R_format&&order.func==mthi 	? MDV_mthi :
							order.opcode==R_format&&order.func==mtlo 	? MDV_mtlo :
							order.opcode==R_format&&order.func==mfhi 	? MDV_mfhi :
							order.opcode==R_format&&order.func==mflo 	? MDV_mflo :
																		'x;

	assign exSignal.EX_ans_Sel = order.opcode==R_format&(order.func==mfhi|order.func==mflo);

	assign exSignal.start = order.opcode==R_format&(order.func==mult|order.func==multu|order.func==divu|order.func==div);

	assign memSignal.CPO_WE = ismtc0;

	assign memSignal.MEM_ans_Sel = ismfc0;

	assign memSignal.BD = BD_ex;

	always_comb begin
		if (order.opcode==beq||order.opcode==bne||order.opcode==jal||order.opcode==j||(order.opcode==R_format&&(order.func==jr||order.func==jalr))) BD = 1;
		else BD = 0;
	end

	assign wbSignal.GRF_WE = order.opcode==ori | order.opcode==lui | order.opcode==addi | order.opcode==lw | 
							order.opcode==jal | order.opcode==lb | order.opcode==lh | order.opcode==andi |
							(order.opcode==R_format&(
								order.func==jalr|order.func==add|order.func==sub|order.func==sll|
								order.func==orv|order.func==slt|order.func==sltu|order.func==andv|
								order.func==mfhi|order.func==mflo))|
							ismfc0;

	assign wbSignal.toReg_Sel = (order.opcode==jal|(order.opcode==R_format&&order.func==jalr))	? wPC8 :
								order.opcode==lui 												? wImm :
								order.opcode==lw||order.opcode==lh||order.opcode==lb||ismfc0	? wMEMans :
																								wEXans;

	assign wbSignal.RegDst_Sel = order.opcode==jal ? ra :
								(order.opcode==R_format&&(
									order.func==jalr||order.func==add||order.func==sub||
									order.func==sll||order.func==andv||order.func==orv||
									order.func==slt||order.func==sltu||order.func==mflo||
									order.func==mfhi)) 									? rd :
																						rt;																		

	assign wbSignal.opcode = order.opcode;
	assign wbSignal.rs = order.rs;
	assign wbSignal.rt = order.rt;
	assign wbSignal.rd = order.rd;
	assign wbSignal.func = order.func;
	assign wbSignal.ismfc0= ismfc0;
	assign wbSignal.ismtc0= ismtc0;
	assign wbSignal.ins = {order.opcode,order._26_bit_imm};



	assign RegDst_Sel = wbSignal_WB.RegDst_Sel;
	assign toReg_Sel = wbSignal_WB.toReg_Sel;

endmodule : Ctrl