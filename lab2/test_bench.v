module tset_bench ();
reg clk;
reg rst;
reg enq;
reg [3:0] in;
reg deq;
wire [3:0] out;
wire [2:0] an;
wire [3:0] hexplay_data;
wire full;
wire emp;
    
fifo fifo(clk, rst, enq, in, deq, out, an, hexplay_data, full, emp);

initial begin
    clk = 0;
    rst = 0;
    enq = 1;
    deq = 0;
    in = 4'b0;
    forever #1 clk = ~clk;
end

initial begin
    #20 in = 4'b1;
    #20 enq = 0;
    #20 enq = 1; in = 4'b10;
    #20 enq = 0;
    #20 enq = 1; in = 4'b11;
    #20 enq = 0;
    #20 enq = 1; in = 4'b100;
    #20 enq = 0;
    #20 enq = 1; in = 4'b101;
    #20 enq = 0;
    #20 enq = 1; in = 4'b110;
    #20 enq = 0;
    #20 enq = 1; in = 4'b111;
    #20 $finish;
end

endmodule

/*
module test_bench ();
reg [2:0] a;
reg [2:0] b;
wire full;
test test(a, b, full);
initial begin
    a = 3'b111; b = 3'b000;
    #20 $finish;
end
endmodule
*/

/*
module test_bench ();
reg clk, rst; 
reg [2:0] ra0;    //读端口0地址
wire [3:0] rd0;   //读端口0数据
reg [2:0] ra1;    //读端口1地址
wire [3:0] rd1;   //读端口1数据
reg [2:0] wa; //写端口地址
reg we;   //写使能 高电平有效
reg [3:0] wd; //写端口数据
RF_8_4 RF_8_4(clk,rst, ra0, rd0, ra1, rd1, wa, we, wd);

initial begin
    rst = 0;
    clk = 1'b1;
    forever #5 clk = ~clk;
end

initial begin
    we = 1'b1;
    ra0 = 5'b0;
    wa = 5'b0;
    wd = 31'b1010;
    #31 wa = 5'b10; ra1 = 5'b10; wa = 5'b10; wd = 31'b0101;
    #21 we = 1'b0; #20 rst = 1;
    #20 $finish;
end

endmodule
*/

/*
module test_bench ();
reg clka;
reg ena;
reg wea;
reg [3:0] addra;
reg [7:0] dina;
wire [7:0] douta;
blk_mem_gen_0 blk_mem_gen_0(clka, ena, wea, addra, dina, douta);

initial begin
    clka = 1'b1;
    forever #5 clka = ~clka;
end

initial begin
    ena = 1'b1;
    wea = 1'b0;
    addra = 1'b0;
    while (addra < 15) begin
        #10 addra = addra + 1'b1;
    end
    wea = 1'b1;
    addra = 4'hf;
    dina = 8'b0;
    #10 wea = 1'b0; addra = 4'h0; #20 $finish;
end

endmodule

*/

/*
module test_bench ();
reg [3:0] a;    //端口地址
reg [7:0] d;    //端口数据
reg clk;
reg we;
wire [7:0] spo;
dist_mem_gen_0 dist_mem_gen_0(a, d, clk, we, spo);

initial begin
    clk = 1'b1;
    forever #10 clk = ~clk;
end

initial begin
    we = 1'b0;
    a = 1'b0;
    while (a < 15) begin
        #10 a = a + 1'b1;
    end
    we = 1'b1;
    a = 4'hf;
    d = 8'b0;
    #10 we = 1'b0; a = 4'h0; #20 $finish;
end

endmodule
*/

/*
module test_bench #(parameter WIDTH = 32) ();
reg clk; 
reg [4:0] ra0;    //读端口0地址
wire [WIDTH - 1:0] rd0;   //读端口0数据
reg [4:0] ra1;    //读端口1地址
wire [WIDTH - 1:0] rd1;   //读端口1数据
reg [4:0] wa; //写端口地址
reg we;   //写使能 高电平有效
reg [WIDTH - 1:0] wd; //写端口数据
register_file register_file(clk, ra0, rd0, ra1, rd1, wa, we, wd);

initial begin
    clk = 1'b1;
    forever #10 clk = ~clk;
end

initial begin
    we = 1'b1;
    ra0 = 5'b0;
    wa = 5'b0;
    wd = 31'b1010;
    #31 wa = 5'b10; ra1 = 5'b10; wa = 5'b10; wd = 31'b0101;
    #21 we = 1'b0; $finish;
end

endmodule
*/