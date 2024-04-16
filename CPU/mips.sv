`timescale 1ns/1ps
module mips (
	input clk,                    // 时钟信号
    input reset,                  // 同步复位信号
    input interrupt,              // 外部中断信号
    output [31:0] macroscopic_pc, // 宏观 PC

    output [31:0] i_inst_addr,    // IM 读取地址（取指 PC）
    input  [31:0] i_inst_rdata,   // IM 读取数据

    output [31:0] m_data_addr,    // DM 读写地址
    input  [31:0] m_data_rdata,   // DM 读取数据
    output [31:0] m_data_wdata,   // DM 待写入数据
    output [3 :0] m_data_byteen,  // DM 字节使能信号

    output [31:0] m_int_addr,     // 中断发生器待写入地址
    output [3 :0] m_int_byteen,   // 中断发生器字节使能信号

    output [31:0] m_inst_addr,    // M 级 PC

    output w_grf_we,              // GRF 写使能信号
    output [4 :0] w_grf_addr,     // GRF 待写入寄存器编号
    output [31:0] w_grf_wdata,    // GRF 待写入数据

    output [31:0] w_inst_addr     // W 级 PC
);

	wire [31:0] kernel_m_data_rdata,kernel_m_data_addr,kernel_m_data_wdata;
	wire [3:0] kernel_m_data_byteen;
	wire [31:0] TC0_Addr,TC1_Addr,TC0_Din,TC1_Din,TC0_Dout,TC1_Dout;
	wire TC0_WE,TC1_WE,TC0_IRQ,TC1_IRQ;

	wire [5:0] HWInt = {3'b0,interrupt,TC1_IRQ,TC0_IRQ};//外设中断信号拼接


CPU u_CPU(
	.clk           (clk),
	.HWInt         (HWInt),
	.reset         (reset),

	.m_inst_addr   (m_inst_addr),
	.m_data_addr   (kernel_m_data_addr),
	.m_data_wdata  (kernel_m_data_wdata),
	.m_data_rdata  (kernel_m_data_rdata),
	.m_data_byteen (kernel_m_data_byteen),

	.w_inst_addr   (w_inst_addr),
	.w_grf_we      (w_grf_we),
	.w_grf_addr    (w_grf_addr),
	.w_grf_wdata   (w_grf_wdata),

	.i_inst_addr   (i_inst_addr),
	.i_inst_rdata  (i_inst_rdata),

	.macroscopic_pc(macroscopic_pc)
);

Bridge u_bridge(
	.bridge_m_data_rdata (m_data_rdata),
	.bridge_m_data_addr  (m_data_addr),
	.bridge_m_data_wdata (m_data_wdata),
	.bridge_m_data_byteen(m_data_byteen),

	.kernel_m_data_rdata (kernel_m_data_rdata),
	.kernel_m_data_byteen(kernel_m_data_byteen),
	.kernel_m_data_addr  (kernel_m_data_addr),
	.kernel_m_data_wdata (kernel_m_data_wdata),
	

	.m_int_addr          (m_int_addr),
	.m_int_byteen        (m_int_byteen),

	.TC0_Addr            (TC0_Addr),
	.TC0_WE              (TC0_WE),
	.TC0_Din             (TC0_Din),
	.TC0_Dout            (TC0_Dout),


	.TC1_Addr            (TC1_Addr),
	.TC1_WE              (TC1_WE),
	.TC1_Din             (TC1_Din),
	.TC1_Dout            (TC1_Dout)
);

TC u_TC0(
	.clk  (clk),
	.reset(reset),
	.Addr (TC0_Addr[31:2]),
	.WE   (TC0_WE),
	.Din  (TC0_Din),
	.Dout (TC0_Dout),
	.IRQ  (TC0_IRQ)
);

TC u_TC1(
	.clk  (clk),
	.reset(reset),
	.Addr (TC1_Addr[31:2]),
	.WE   (TC1_WE),
	.Din  (TC1_Din),
	.Dout (TC1_Dout),
	.IRQ  (TC1_IRQ)
);

endmodule : mips