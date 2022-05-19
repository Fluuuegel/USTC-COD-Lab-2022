module top(
input clk, rst,
input rx,
output [7:0] led,
input [7:0] sw
);

wire rx_vld;
wire [7:0] rx_data;
reg [7:0] temp_data;

initial begin
    temp_data = 8'b11111111;     
end

rx                  rx_inst(
.clk                (clk),
.rst                (rst),
.rx                 (rx),
.rx_vld             (rx_vld),
.rx_data            (rx_data)
);

always@(posedge clk or posedge rst)
begin
    if(rst)
        temp_data <= 8'h0;
    else if((rx_vld)&&(rx_data!=8'h0a))
        temp_data <= rx_data - 8'h30;  
end

assign led = temp_data;

endmodule