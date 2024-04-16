`timescale 1ns/1ps

module Bridge (
    input [31:0] bridge_m_data_rdata,

    input [31:0] kernel_m_data_addr,
    input [31:0] kernel_m_data_wdata,
    input [3:0] kernel_m_data_byteen,

    output [31:0] bridge_m_data_addr,//DM交互
    output [31:0] bridge_m_data_wdata,//
    output [3:0] bridge_m_data_byteen,
    output [31:0] kernel_m_data_rdata,

    output [31:0] m_int_addr,
    output [3:0] m_int_byteen,

    output [31:0] TC0_Addr,
    output TC0_WE,
    output [31:0] TC0_Din,
    input [31:0] TC0_Dout,

    output [31:0] TC1_Addr,
    output TC1_WE,
    output [31:0] TC1_Din,
    input [31:0] TC1_Dout
);
    //外设地址
    assign bridge_m_data_addr = kernel_m_data_addr;
    assign TC0_Addr = kernel_m_data_addr;
    assign TC1_Addr = kernel_m_data_addr;
    assign m_int_addr = kernel_m_data_addr;
    //外设写入数据
    assign TC0_Din = kernel_m_data_wdata;
    assign TC1_Din = kernel_m_data_wdata;
    assign bridge_m_data_wdata = kernel_m_data_wdata;

    //分拣外设
    wire SelTC0 = (kernel_m_data_addr >= `StartAddrTC0) && (kernel_m_data_addr <= `EndAddrTC0);
    wire SelTC1 = (kernel_m_data_addr >= `StartAddrTC1) && (kernel_m_data_addr <= `EndAddrTC1);
    wire IntRes = (kernel_m_data_addr >= `StartAddrIns) && (kernel_m_data_addr <= `EndAddrIns);

    //控制外设使能
    assign TC0_WE = kernel_m_data_byteen!=0 && SelTC0;
    assign TC1_WE = kernel_m_data_byteen!=0 && SelTC1;
    assign m_int_byteen = IntRes ? kernel_m_data_byteen : 0 ;
    assign bridge_m_data_byteen = (SelTC0 || SelTC1 || IntRes ) ? 4'd0 : kernel_m_data_byteen;



    //内核读取数据
    assign kernel_m_data_rdata = (SelTC0) ? TC0_Dout :
                                (SelTC1) ? TC1_Dout :
                                (IntRes) ? 0 ://防错
                                bridge_m_data_rdata;

endmodule : Bridge