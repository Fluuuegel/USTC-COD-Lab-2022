module fifo (
    input clk, rst, enq,    //时钟（上升沿有效） 同步复位（高电平有效） 入队列使能（高电平有效）
    input [3:0] in, //入队列数据
    input deq,  //出队列使能（高电平有效）
    output [3:0] out,   //出队列数据
    output [2:0] an,    //数码管选择
    output [3:0] hexplay_data,    //数码管数据
    output full, emp
);

wire [2:0] ra0; wire [2:0] ra1;
wire [3:0] rd0; wire [3:0] rd1;
wire [2:0] wa; wire we; wire [3:0] wd; wire [7:0] valid;

lcu lcu(in, enq, deq, clk, rst, rd0, out, full, emp, ra0, wa, we, wd, valid);
RF_8_4 RF_8_4(clk, rst, ra0, rd0, ra1, rd1, wa, we, wd);
sdu sdu(rd1, valid, clk, emp, ra1, an, hexplay_data);

endmodule