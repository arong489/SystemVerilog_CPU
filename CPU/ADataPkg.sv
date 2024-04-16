`timescale 1ns/1ps

/*------------------------------------------------------------------------------
--  source use register
------------------------------------------------------------------------------*/
`define ID_use_rs(STEP)     (wbSignal_``STEP``.rs!=0&&(\
                                wbSignal_``STEP``.opcode==beq||\
                                wbSignal_``STEP``.opcode==bne||\
(wbSignal_``STEP``.opcode==R_format&&(\
                                wbSignal_``STEP``.func==jalr||\
                                wbSignal_``STEP``.func==jr\
                            ))))

`define ID_use_rt(STEP)     (wbSignal_``STEP``.rt!=0&&(\
                                wbSignal_``STEP``.opcode==bne||\
                                wbSignal_``STEP``.opcode==beq\
                            ))

`define EX_use_rs(STEP)     (wbSignal_``STEP``.rs!=0&&(\
                                wbSignal_``STEP``.opcode==addi||\
                                wbSignal_``STEP``.opcode==ori||\
                                wbSignal_``STEP``.opcode==andi||\
                                wbSignal_``STEP``.opcode==sw||\
                                wbSignal_``STEP``.opcode==lw||\
                                wbSignal_``STEP``.opcode==sh||\
                                wbSignal_``STEP``.opcode==lh||\
                                wbSignal_``STEP``.opcode==sb||\
                                wbSignal_``STEP``.opcode==lb||\
(wbSignal_``STEP``.opcode==R_format&&(\
                                wbSignal_``STEP``.func==add||\
                                wbSignal_``STEP``.func==sub||\
                                wbSignal_``STEP``.func==andv||\
                                wbSignal_``STEP``.func==orv||\
                                wbSignal_``STEP``.func==slt||\
                                wbSignal_``STEP``.func==sltu||\
                                wbSignal_``STEP``.func==multu||\
                                wbSignal_``STEP``.func==mult||\
                                wbSignal_``STEP``.func==divu||\
                                wbSignal_``STEP``.func==div||\
                                wbSignal_``STEP``.func==mthi||\
                                wbSignal_``STEP``.func==mtlo\
                            ))))

`define EX_use_rt(STEP)     (wbSignal_``STEP``.rt!=0&&(\
wbSignal_``STEP``.opcode==R_format&&(\
                                wbSignal_``STEP``.func==add||\
                                wbSignal_``STEP``.func==andv||\
                                wbSignal_``STEP``.func==orv||\
                                wbSignal_``STEP``.func==slt||\
                                wbSignal_``STEP``.func==sltu||\
                                wbSignal_``STEP``.func==sub||\
                                wbSignal_``STEP``.func==multu||\
                                wbSignal_``STEP``.func==mult||\
                                wbSignal_``STEP``.func==divu||\
                                wbSignal_``STEP``.func==div||\
                                wbSignal_``STEP``.func==sll\
                            )))

`define MEM_use_rs(STEP)    (wbSignal_``STEP``.rs!=0&&(\
                                0\
                            ))

`define MEM_use_rt(STEP)    (wbSignal_``STEP``.rt!=0&&(\
                                wbSignal_``STEP``.opcode==sw||\
                                wbSignal_``STEP``.opcode==sb||\
                                wbSignal_``STEP``.opcode==sh||\
                                (wbSignal_``STEP``.ismtc0)\
                            ))

/*------------------------------------------------------------------------------
-- possible source output register 
------------------------------------------------------------------------------*/

`define ID_new_rt(STEP)     (\
                                wbSignal_``STEP``.opcode==lui\
                            )

`define ID_new_rd(STEP)     (\
(wbSignal_``STEP``.opcode==R_format&&(\
                                wbSignal_``STEP``.func==jalr\
                            )))

`define ID_new_ra(STEP)     (\
                                wbSignal_``STEP``.opcode==jal\
                            )

`define EX_new_rt(STEP)     (\
                                wbSignal_``STEP``.opcode==ori||\
                                wbSignal_``STEP``.opcode==andi||\
                                wbSignal_``STEP``.opcode==addi\
                            )

`define EX_new_rd(STEP)     (\
(wbSignal_``STEP``.opcode==R_format&&(\
                                wbSignal_``STEP``.func==add||\
                                wbSignal_``STEP``.func==sub||\
                                wbSignal_``STEP``.func==andv||\
                                wbSignal_``STEP``.func==orv||\
                                wbSignal_``STEP``.func==slt||\
                                wbSignal_``STEP``.func==sltu||\
                                wbSignal_``STEP``.func==mfhi||\
                                wbSignal_``STEP``.func==mflo||\
                                wbSignal_``STEP``.func==sll\
                            )))
/*------------------------------------------------------------------------------
-- 将可能的寄存器写列出，条件写在mem级别写出所有可能用的寄存器 
------------------------------------------------------------------------------*/
`define MEM_new_rs(STEP)    (\
                                0\
                            )

`define MEM_new_rt(STEP)    (\
                                wbSignal_``STEP``.opcode==lw||\
                                wbSignal_``STEP``.opcode==lh||\
                                wbSignal_``STEP``.opcode==lb||\
                                (wbSignal_``STEP``.ismfc0)\
                            )

`define MEM_new_rd(STEP)    (\
                                0\
                            )
`define MEM_new_ra(STEP)    (\
                                0\
                            )


`define MDV_func(STEP)  (wbSignal_``STEP``.opcode==R_format&&(\
                            wbSignal_``STEP``.func==mult||\
                            wbSignal_``STEP``.func==multu||\
                            wbSignal_``STEP``.func==div||\
                            wbSignal_``STEP``.func==divu||\
                            wbSignal_``STEP``.func==mfhi||\
                            wbSignal_``STEP``.func==mflo||\
                            wbSignal_``STEP``.func==mthi||\
                            wbSignal_``STEP``.func==mtlo\
                        ))   


`define EX_done_rt      (`ID_new_rt(EX)&&wbSignal_EX.GRF_WE&&wbSignal_EX.rt!=0)      
`define EX_done_rd      (`ID_new_rd(EX)&&wbSignal_EX.GRF_WE&&wbSignal_EX.rd!=0)
`define EX_done_ra      (`ID_new_ra(EX)&&wbSignal_EX.GRF_WE)

`define MEM_done_rt     ((`EX_new_rt(MEM)||`ID_new_rt(MEM))&&wbSignal_MEM.GRF_WE&&wbSignal_MEM.rt!=0)
`define MEM_done_rd     ((`EX_new_rd(MEM)||`ID_new_rd(MEM))&&wbSignal_MEM.GRF_WE&&wbSignal_MEM.rd!=0)
`define MEM_done_ra     ((`ID_new_ra(MEM)                 )&&wbSignal_MEM.GRF_WE)

`define WB_done_RegDst  (wbSignal_WB.GRF_WE&&RegDst!=0&&(\
                            `ID_new_rt(WB)||`ID_new_rd(WB)||`ID_new_ra(WB)||\
                            `EX_new_rt(WB)||`EX_new_rd(WB)||\
                            `MEM_new_rs(WB)||`MEM_new_rt(WB)||`MEM_new_rd(WB)||`MEM_new_ra(WB)\
                        ))

`define MEM_1_rs     (`MEM_new_rs(MEM)&&wbSignal_MEM.GRF_WE&&wbSignal_MEM.rs!=0)
`define MEM_1_rt     (`MEM_new_rt(MEM)&&wbSignal_MEM.GRF_WE&&wbSignal_MEM.rt!=0)
`define MEM_1_rd     (`MEM_new_rd(MEM)&&wbSignal_MEM.GRF_WE&&wbSignal_MEM.rd!=0)
`define MEM_1_ra     (`MEM_new_ra(MEM)&&wbSignal_MEM.GRF_WE)

`define EX_2_rs     (`MEM_new_rs(EX)&&wbSignal_EX.GRF_WE&&wbSignal_EX.rs!=0)
`define EX_2_rt     (`MEM_new_rt(EX)&&wbSignal_EX.GRF_WE&&wbSignal_EX.rt!=0)
`define EX_2_rd     (`MEM_new_rd(EX)&&wbSignal_EX.GRF_WE&&wbSignal_EX.rd!=0)
`define EX_2_ra     (`MEM_new_ra(EX)&&wbSignal_EX.GRF_WE)

`define EX_1_rt     (`EX_new_rt(EX)&&wbSignal_EX.GRF_WE&&wbSignal_EX.rt!=0)
`define EX_1_rd     (`EX_new_rd(EX)&&wbSignal_EX.GRF_WE&&wbSignal_EX.rd!=0)



package databus;

    typedef enum logic [5:0] {
        R_format= 6'b000000,
        ori     = 6'b001101,
        sw      = 6'b101011,
        lw      = 6'b100011,
        beq     = 6'b000100,
        lui     = 6'b001111,
        j       = 6'b000010,
        jal     = 6'b000011,
        addi    = 6'b001000,
        andi    = 6'b001100,
        lh      = 6'b100001,
        sh      = 6'b101001,
        lb      = 6'b100000,
        sb      = 6'b101000,
        bne     = 6'b000101,
        cop0    = 6'b010000
    } OPCODE;

    typedef enum logic [5:0] {
        add     = 6'b100000,
        sub     = 6'b100010,
        sll     = 6'b000000,
        jalr    = 6'b001001,
        jr      = 6'b001000,
        andv    = 6'b100100,
        orv     = 6'b100101,
        slt     = 6'b101010,
        sltu    = 6'b101011,
        mult    = 6'b011000,
        multu   = 6'b011001,
        div     = 6'b011010,
        divu    = 6'b011011,
        mfhi    = 6'b010000,
        mflo    = 6'b010010,
        mthi    = 6'b010001,
        mtlo    = 6'b010011,
        syscall = 6'b001100
    } FUNC;

    parameter ALUop_Width = 4;
    typedef enum logic [ALUop_Width-1:0] {  
        ALU_sllv,   ALU_srav,   ALU_srlv,   ALU_add,
        ALU_sub,    ALU_and,    ALU_or,     ALU_xor,
        ALU_nor,    ALU_slt,    ALU_sltu,   ALU_sll,
        ALU_sra,    ALU_srl
    } ALUOPTION;

    parameter MDVop_Width = 4;
    typedef enum logic [MDVop_Width-1:0] {
        MDV_mult,   MDV_multu,  MDV_div,    MDV_divu,
        MDV_mfhi,   MDV_mflo,   MDV_mthi,   MDV_mtlo
    } MDVOPTION;

    parameter EXTop_Width = 2;
    typedef enum logic [EXTop_Width-1:0] {
        EXT_zero,   EXT_sig,    EXT_lui
    } EXTOPTION;

    parameter PC_cal_SelWidth = 2;
    typedef enum logic [PC_cal_SelWidth-1:0] {
        PCbranch,   PCjump
    } PC_cal_Sel_Sig;

    parameter PCSrc_SelWidth = 2;
    typedef enum logic [PCSrc_SelWidth-1:0] {
        PC4,    iPC,    jrPC,   ePC4
    } PCSrc_Sel_Sig;

    parameter RegDst_SelWidth = 2;
    typedef enum logic [RegDst_SelWidth-1:0] {
        rs,     rt,     rd,     ra
    } RegDst_Sel_Sig;

    parameter ALUsrc_SelWidth = 1;
    typedef enum logic [ALUsrc_SelWidth-1:0] {
        R_rt,   Imm
    } ALUsrc_Sel_Sig;

    parameter toReg_SelWidth = 2;
    typedef enum logic [toReg_SelWidth-1:0] {
        wEXans,     wMEMans,     wImm,    wPC8
    } toReg_Sel_Sig;

    typedef enum logic [4:0] {
        INT     = 0,    //中断类型
        AdEL    = 4,
        AdES    = 5,
        Syscall = 8,
        RI      = 10,
        Ov      = 12
    } ExcCode_Define;

    typedef struct packed {
        OPCODE opcode;
        logic [4:0] rs,rt,rd,shamet;
        FUNC func;
        logic [25:0] _26_bit_imm;
    } ORDER;

    typedef struct packed {
        EXTOPTION EXTop;
        PCSrc_Sel_Sig PCSrc_Sel;
        PC_cal_Sel_Sig PC_cal_Sel;
        logic eret;
    } IDSIGNAL;



    typedef struct packed {
        ALUsrc_Sel_Sig ALUsrc_Sel;
        ALUOPTION ALUop;
        MDVOPTION MDVop;
        logic EX_ans_Sel;
        logic start;
    } EXSIGNAL;

    typedef struct packed {
        logic [31:0] R_rs,R_rt,Imm,PC;
        logic [4:0] shamet;
        ExcCode_Define ExcCode;
    } EXDATA;



    typedef struct packed {
        logic CPO_WE;
        logic MEM_ans_Sel;
        logic BD;
    } MEMSIGNAL;

    typedef struct packed {
        logic [31:0] EX_ans,R_rt,Imm,PC;
        logic overflow;
        ExcCode_Define ExcCode;
    } MEMDATA;

    
    typedef struct packed {
        OPCODE opcode;
        logic [4:0] rs,rt,rd;
        FUNC func;
        toReg_Sel_Sig toReg_Sel;
        RegDst_Sel_Sig RegDst_Sel;
        logic GRF_WE;
        logic ismfc0;
        logic ismtc0;
        logic [31:0] ins;
    } WBSIGNAL;

    typedef struct packed {
        logic [31:0] EX_ans,MEM_ans,Imm,PC;
        logic clear;
    } WBDATA;

    typedef struct packed {
        logic [2:0] forfuture1;
        logic CU0;
        logic [11:0] forfuture2;
        logic [5:0] IM;   //分别对应六个外部中断，相应位置 1 表示允许中断，置 0 表示禁止中断。这是一个被动的功能，只能通过 mtc0 这个指令修改，通过修改这个功能域，我们可以屏蔽一些中断
        logic [7:0] forfuture3;
        logic EXL;      //任何异常发生时置位，这会强制进入核心态（也就是进入异常处理程序）并禁止中断。
        logic IE;       //全局中断使能，该位置 1 表示允许中断，置 0 表示禁止中断。
    } State_Register;

    typedef struct packed {
        logic BD;       //当该位置 1 的时候，EPC 指向当前指令的前一条指令（一定为跳转），否则指向当前指令
        logic [14:0] forfuture1;
        logic [5:0] IP;//为 6 位待决的中断位，分别对应 6 个外部中断，相应位置 1 表示有中断，置 0 表示无中断，将会每个周期被修改一次，修改的内容来自计时器和外部中断
        logic [2:0] forfuture2;
        ExcCode_Define ExcCode;//异常编码，记录当前发生的是什么异常
        logic [1:0] forfuture3;
    } Cause_Register;

endpackage