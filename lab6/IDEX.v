module IDEX(
    input clk,
    
    input [31:0] IFIDpc,
    input [4:0] Rd, //also part of forwarding unit
    input [31:0] Imm,
    input [31:0] rf_rd0,
    input [31:0] rf_rd1,

    //控制信号
    input rf_wr_en, //WB
    input alu_a_sel, alu_b_sel, //EX
    input [3:0] alu_ctrl,   //EX
    input [2:0] dm_rd_ctrl,   //MEM
    input [1:0] dm_wr_ctrl,   //MEM
    input [1:0] rf_wr_sel,  //WB

    input [2:0] comp_ctrl,  //EX
    input do_branch, do_jump,   //EX

    output reg [31:0] IDEXpc,
    output reg [4:0] IDEXRd,
    output reg [31:0] IDEXImm,
    output reg [31:0] IDEXrf_rd0,
    output reg [31:0] IDEXrf_rd1,

    output reg IDEXrf_wr_en, reg IDEXalu_a_sel,reg IDEXalu_b_sel,
    output reg [3:0] IDEXalu_ctrl,
    output reg [2:0] IDEXdm_rd_ctrl,
    output reg [1:0] IDEXdm_wr_ctrl,
    output reg [1:0] IDEXrf_wr_sel,
    output reg [2:0] IDEXcomp_ctrl,
    output reg IDEXdo_branch, reg IDEXdo_jump,

    //forwarding unit
    input [4:0] IFIDRs1,
    input [4:0] IFIDRs2,
    input eFlush,

    output reg [4:0] IDEXRs1,
    output reg [4:0] IDEXRs2
);

always@(posedge clk) begin
    if(eFlush) begin
        IDEXpc <= 0;
        IDEXRd <= 0;
        IDEXImm <= 0;
        IDEXrf_rd0 <= 0;
        IDEXrf_rd1 <= 0;

        IDEXrf_wr_en <= 0;
        IDEXalu_a_sel <= 0;
        IDEXalu_b_sel <= 0;
        IDEXalu_ctrl <= 0;
        IDEXdm_rd_ctrl <= 0;
        IDEXdm_wr_ctrl <= 0;
        IDEXrf_wr_sel <= 0;
        IDEXcomp_ctrl <= 0;
        IDEXdo_branch <= 0;
        IDEXdo_jump <= 0;

        IDEXRs1 <= 0;
        IDEXRs2 <= 0;
    end
    else begin
        IDEXpc <= IFIDpc;
        IDEXRd <= Rd;
        IDEXImm <= Imm;
        IDEXrf_rd0 <= rf_rd0;
        IDEXrf_rd1 <= rf_rd1;

        IDEXrf_wr_en <= rf_wr_en;
        IDEXalu_a_sel <= alu_a_sel;
        IDEXalu_b_sel <= alu_b_sel;
        IDEXalu_ctrl <= alu_ctrl;
        IDEXdm_rd_ctrl <= dm_rd_ctrl;
        IDEXdm_wr_ctrl <= dm_wr_ctrl;
        IDEXrf_wr_sel <= rf_wr_sel;
        IDEXcomp_ctrl <= comp_ctrl;
        IDEXdo_branch <= do_branch;
        IDEXdo_jump <= do_jump;

        IDEXRs1 <= IFIDRs1;
        IDEXRs2 <= IFIDRs2;
    end
end

endmodule