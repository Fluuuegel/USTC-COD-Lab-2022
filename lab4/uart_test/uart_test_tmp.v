module top(
input clk, rst,
input rx,
output              tx,
output [7:0] led,
input [7:0] sw
);
wire                tx_rd;
wire                rx_vld;
wire                tx_ready;
wire        [7:0]   tx_data;
wire [7:0] rx_data;
reg [7:0] temp_data;

rx                  rx_inst(
.clk                (clk),
.rst                (rst),
.rx                 (rx),
.rx_vld             (rx_vld),
.rx_data            (rx_data)
);   
                  
tx                  tx_inst(
.clk                (clk),
.rst                (rst),
.tx                 (tx ),
.tx_ready           (tx_ready),
.tx_rd              (tx_rd),
.tx_data            (tx_data)
);

assign  tx_ready    = rx_vld;
assign  tx_data     = sw;

always@(posedge clk or posedge rst)
begin
    if(rst)
        temp_data <= 8'h0;
    else if((rx_vld)&&(rx_data!=8'h0a))
        temp_data <= rx_data;  
end

assign led = temp_data;

endmodule