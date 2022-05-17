module test_bench();
reg clk;
reg rst;

wire [31:0] io_addr;
wire [31:0] io_dout;
wire io_we;
reg [31:0] io_din;

reg [7:0] m_rf_addr;
wire [31:0] rf_data;
wire [31:0] m_data;
wire [31:0] pc_out;
wire [31:0] pcd;
wire [31:0] ir;
wire [31:0] pcin;

//ID/EX
wire [31:0] pce;
wire [31:0] a;
wire [31:0] b;
wire [31:0] imm_debug;
wire [4:0] rd;
wire [31:0] ctrl;

//EX/MEM
wire [31:0] y;
wire [31:0] bm;
wire [4:0] rdm;
wire [31:0] ctrlm;

//MEM/WB
wire [31:0] ym;
wire [31:0] mdr;
wire [4:0] rdw;
wire [31:0] ctrlw;

cpu_pl cpu_pl(clk, rst, io_addr, io_dout, io_we, io_din, m_rf_addr, rf_data, m_data, pc_out, pcd, ir, pcin, pce, a, b, imm_debug, rd, ctrl, y, bm, rdm, ctrlm, ym, mdr, rdw, ctrlw);

initial begin 
    io_din = 0;
    rst = 1; m_rf_addr = 0; 
    clk = 1;#5
    clk = 0;
    rst = 0;
    
    forever #5 clk = ~clk;
end

initial begin
    #12000 $finish;
end

endmodule