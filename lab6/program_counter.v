module program_counter(
    input clk,
    input rst,
    input br,
    input jump,
    input [31:0] alu_out,
    input PCWrite,

    output reg [31:0] pc,
    output reg [31:0] pcin,
    output [31:0] pc_plus4
);


always@(*) begin
    if(br || jump) pcin <= alu_out;
    else if(PCWrite) pcin <= pc_plus4;
    else pcin <= pc;
end

always@(posedge clk or posedge rst) begin
    if(rst) pc <= 32'h3000;
    else pc <= pcin;
end

assign pc_plus4 = pc + 32'h4;

endmodule