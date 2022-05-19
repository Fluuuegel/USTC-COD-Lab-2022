module top(
    input clk,
    input rst,  //sw7

    //选择CPU工作方式
    input run,  //sw6
    input step, //button

    //输入switch的端口
    input valid,    //sw5
    input [4:0] in, //sw4-0

    //输出led和seg的端口 
    // output [1:0] check,  //led6-5:查看类型
    // output [4:0] out0,    //led4-0
    output [2:0] an,     //8个数码管
    output [3:0] seg,
    //output ready          //led7

    input rx,
    output tx,
    output reg [7:0] led
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

wire [7:0] sw;
wire [1:0] check;
wire [4:0] out0;
wire ready;
assign sw = 0;

//uart
wire tx_r;
wire [7:0] tx_d;
wire [7:0] rx_d;
wire rx_vld;
wire tx_rd;

rx rx1(
    .clk (clk),
    .rst (rst),
    .rx (rx),
    .rx_vld (rx_vld),
    .rx_data (rx_d)
);

tx tx1(
    .clk (clk),
    .rst (rst),
    .tx (tx),
    .tx_ready (tx_r),
    .tx_rd (tx_rd),
    .tx_data (tx_d)
);

reg [7:0] tx_data_r;
assign tx_r = clk_cpu;
always@(posedge clk) begin
    if(io_addr == 8'h8) tx_data_r <= io_dout + 8'h30;
    else tx_data_r <= tx_data_r;
end

always@(posedge clk or posedge rst) begin
    if(rst) led <= 8'h0;
    else if(rx_vld && (rx_d != 8'h0a)) led <= rx_d - 8'h30;
end

pdu pdu(.clk (clk),
        .rst (rst),
        .run (run),
        .step (step),
        .clk_cpu (clk_cpu),
        .valid (valid),
        .in (led[4:0]),
        // .in (in),
        .check (check),
        .out0 (out0),
        .an (an),
        .seg (seg),
        .ready (ready),
        .io_addr (io_addr),
        .io_dout (io_dout),
        .io_we (io_we),
        .io_din (io_din),
        .m_rf_addr (m_rf_addr),
        .rf_data (rf_data),
        .m_data (m_data),
        .pc (pc_out)
);

cpu cpu(.clk (clk_cpu),
        .rst (rst),
        .io_addr (io_addr),
        .io_dout (io_dout),
        .io_we (io_we),
        .io_din (io_din),
        .m_rf_addr (m_rf_addr),
        .rf_data (rf_data),
        .m_data (m_data),
        .pc_out (pc_out)
);


endmodule
