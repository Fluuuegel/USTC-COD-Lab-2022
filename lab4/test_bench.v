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

cpu cpu(clk, rst, io_addr, io_dout, io_we, io_din, m_rf_addr, rf_data, m_data, pc_out);

initial begin 
    rst = 1; m_rf_addr = 0; 
    clk = 0;#5
    rst = 0;
    
    forever #5 clk = ~clk;
end

initial begin
    #800 $finish;
end

endmodule