module register_file (
    input clk, rst,
    input [4:0] ra0,    //读端口0地址
    output reg [31:0] rd0,   //读端口0数据

    input [4:0] ra1,    //读端口1地址
    output reg [31:0] rd1,   //读端口1数据

    input [4:0] ra2,    //读端口2地址
    output reg [31:0] rd2,  //读端口2数据

    input [4:0] wa, //写端口地址
    input we,   //写使能 高电平有效
    input [31:0] wd //写端口数据
);

reg [31:0] regfile [0:31];

always@(*) begin
    if(ra0 == 0) rd0 <= 32'h0;
    else if(we && (wa == ra0)) rd0 <= wd;
    else rd0 <= regfile[ra0];

    if(ra1 == 0) rd1 <= 32'h0;
    else if(we && (wa == ra1)) rd1 <= wd;
    else rd1 <= regfile[ra1];

    if(ra2 == 0) rd2 <= 32'h0;
    else if(we && (wa == ra2)) rd2 <= wd;
    else rd2 <= regfile[ra2];
end

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