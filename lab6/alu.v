module alu(
    input [31:0] a,b,
    input [3:0] alu_ctrl,
    output reg [31:0] alu_out
);

wire signed [31:0] signed_a;
wire signed [31:0] signed_b;
assign signed_a = a;
assign signed_b = b;

always@(*) begin
    case(alu_ctrl)
    4'h1: alu_out = a + b;
    4'h2: alu_out = a - b;
    4'h3: alu_out = b;
    4'h4: alu_out = (signed_a < signed_b) ? 32'b1 : 32'b0;
    4'h5: alu_out = (a < b) ? 32'b1 : 32'b0;
    4'h6: alu_out = a ^ b;
    4'h7: alu_out = a | b;
    4'h8: alu_out = a & b;
    4'h9: alu_out = a << b[4:0];
    4'ha: alu_out = a >> b[4:0];
    4'hb: alu_out = ({{31{a[31]}}, 1'b0} << (~b[4:0])) | (a >> b[4:0]);
    default: alu_out = 32'h0;
    endcase
end

endmodule