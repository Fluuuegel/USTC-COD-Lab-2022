module register_file (
    input clk, rst,
    input [4:0] ra0,    //读端口0地址
    output [31:0] rd0,   //读端口0数据

    input [4:0] ra1,    //读端口1地址
    output [31:0] rd1,   //读端口1数据

    input [4:0] ra2,    //读端口2地址
    output [31:0] rd2,  //读端口2数据

    input [4:0] wa, //写端口地址
    input we,   //写使能 高电平有效
    input [31:0] wd //写端口数据
);

reg [31:0] regfile [0:31];
assign rd0 = ra0 ? regfile[ra0] : 32'h0;
assign rd1 = ra1 ? regfile[ra1] : 32'h0;
assign rd2 = ra2 ? regfile[ra2] : 32'h0;
integer i;

always @(posedge clk) begin
    if(rst) begin
        for(i = 0; i <= 31; i = i + 1) begin
            regfile[i] <= 32'b0;
        end
    end
    else if(we) begin
        if(wa == 0) regfile[wa] <= 0;   //r0内容恒为0
        else regfile[wa] <= wd;
    end
end

endmodule