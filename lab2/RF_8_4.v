module RF_8_4 (
    input clk, rst,
    input [2:0] ra0,    //读端口0地址
    output [3:0] rd0,   //读端口0数据
    input [2:0] ra1,    //读端口1地址
    output [3:0] rd1,   //读端口1数据
    input [2:0] wa, //写端口地址
    input we,   //写使能 高电平有效
    input [3:0] wd //写端口数据
);

reg [3:0] regfile [0:7];
assign rd0 = regfile[ra0];
assign rd1 = regfile[ra1];
integer i;

always @(posedge clk) begin
    if(rst) begin
        for(i = 0; i <= 7; i = i + 1) begin
            regfile[i] <= 4'b0;
        end
    end
    else if(we) regfile[wa] <= wd;
end

endmodule