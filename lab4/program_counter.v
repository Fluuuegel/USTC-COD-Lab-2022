module program_counter(
    input clk,
    input rst,
    input br,
    input [31:0] alu_out,
    output reg [31:0] pc,
    output [31:0] pc_plus4
);

always@(posedge clk or posedge rst) begin
    if(rst) pc <= 32'h3000;
    else if(br) pc <= alu_out;
    else pc <= pc_plus4;
end

assign pc_plus4 = pc + 32'h4;

endmodule