module br(
    input [31:0] a,
    input [31:0] b,
    input [2:0] comp_ctrl,
    input do_branch,
    input do_jump,
    output branch,
    output jump
);
wire signed [31:0] signed_a;
wire signed [31:0] signed_b;
wire [31:0] unsigned_a;
wire [31:0] unsigned_b;
reg taken;

assign signed_a = a;
assign signed_b = b;
assign unsigned_a = a;
assign unsigned_b = b;

always@(*) begin
    case(comp_ctrl)
    3'h0: taken = (signed_a == signed_b);
    3'h1: taken = ~(signed_a == signed_b);
    3'h2: taken = 1'b0;
    3'h3: taken = 1'b0;
    3'h4: taken = (signed_a < signed_b);
    3'h5: taken = (signed_a >= signed_b);
    3'h6: taken = (unsigned_a < unsigned_b);
    3'h7: taken = (unsigned_a >= unsigned_b);
    default: taken = 0;
    endcase
end

assign branch = taken && do_branch;
assign jump = do_jimp;

endmodule