/*
module sdu (
    input [3:0]rd1,//read data
    input [7:0]valid,
    input clk,
    output [2:0]ra1,//read address
    output [2:0]an,//segment address
    output [3:0]hexplay_data//segment data
);

reg [23:0] count;
wire [3:0] x0;
//wire [3:0] x1;

assign x0 = 4'h0;
//assign an = (valid[ra1]) ? ra1 : x1;
assign an = ra1;
assign ra1 = count[15:13];

always @(posedge clk) begin
    count <= count + 1;
end

assign hexplay_data = (valid[ra1]) ? rd1 : x0;

endmodule
*/


module sdu (
    input [3:0] rd1, 
    input [7:0] valid, 
    input clk, emp,
    output [2:0] ra1, 
    output reg [2:0] an, 
    output reg [3:0] hexplay_data
);

reg [32:0] hexplay_cnt;
reg [2:0] cnt;

initial begin
    hexplay_cnt <= 0;
    cnt <= 0;
end

always @(*) begin
    if(emp) hexplay_data = 0;
    else hexplay_data = rd1;
end

always@(posedge clk) begin
    if (hexplay_cnt >= (2000000/8)) hexplay_cnt <= 0;
    else hexplay_cnt <= hexplay_cnt + 1;
end

always@(posedge clk) begin
    if (hexplay_cnt == 0) begin
        if(cnt == 7) cnt <= 0;
        else cnt <= cnt + 1;

        if(emp) an <= 0;
        else if(valid[cnt]) an <= cnt;
    end
end

assign ra1 = an;

endmodule
