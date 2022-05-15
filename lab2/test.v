module test (
    input [2:0] a,
    input [2:0] b,
    output reg full
);
always@(*) begin
    full <= (a + 1'b1 == b) ? 1'b1 : 1'b0;
end

endmodule