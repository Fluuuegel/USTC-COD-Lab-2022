module alu(
    input [31:0] a,b,
    input [1:0] alu_ctrl,
    output reg [31:0] alu_out
);

always@(*) begin
    case(alu_ctrl)
    4'h0: alu_out = a + b;
    4'h1: alu_out = a - b;
    default: alu_out = 32'h0;
    endcase
end

endmodule