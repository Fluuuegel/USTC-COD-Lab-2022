module top(
    input clk,
    input rst,

    //选择CPU工作方式
    input run, 
    input step,

    //输入switch的端口
    input valid,
    input [4:0] in,

    //输出led和seg的端口 
    output [1:0] check,  //led6-5:查看类型
    output [4:0] out0,    //led4-0
    output [2:0] an,     //8个数码管
    output [3:0] seg,
    output ready          //led7

);
wire clk_cpu;

wire [7:0] io_addr;
wire [31:0] io_dout;
wire io_we;
wire [31:0] io_din;

wire [7:0] m_rf_addr;
wire [31:0] rf_data;
wire [31:0] m_data;
wire [31:0] pc_out;

pdu pdu(clk, rst, run, step, clk_cpu, valid, in, check, out0, an, seg, ready, io_addr, io_dout, io_we, io_din, m_rf_addr, rf_data, m_data, pc_out);
cpu cpu(clk_cpu, rst, io_addr, io_dout, io_we, io_din, m_rf_addr, rf_data, m_data, pc_out);

endmodule
