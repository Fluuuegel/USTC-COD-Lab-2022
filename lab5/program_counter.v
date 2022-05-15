module program_counter(
    input clk,
    input rst,
    input br,
    input [31:0] alu_out,
    input PCWrite,

    output reg [31:0] pc,
    output reg [31:0] pcin,
    output [31:0] pc_plus4
);


always@(*) begin
    if(!PCWrite) ;
    else if(br) pcin <= alu_out;
    else pcin <= pc_plus4;
end

always@(posedge clk or posedge rst) begin
    if(rst) pc <= 32'h3000;
    else pc <= pcin;
end

// always@(posedge clk or posedge rst) begin
//     if(rst) pc <= 32'h3000;
//     else if(!PCWrite) pc <= pc;
//     else if(br) pc <= alu_out;
//     else pc <= pc_plus4;
//     pcin <= pc;
// end

assign pc_plus4 = pc + 32'h4;

endmodule