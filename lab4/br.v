module br(
    input [31:0] a,
    input [31:0] b,
    input [2:0] comp_ctrl,
    input do_branch,
    input do_jump,
    output branch
);
reg taken;

always@(*) begin
    case(comp_ctrl)
    3'h0: taken = (a == b);
    3'h4: taken = (a < b);
    default: taken = 0;
    endcase
end

assign branch = (taken && do_branch) || do_jump;

endmodule