module hazard_detection(
    input [2:0] IDEXdm_rd_ctrl,
    input [4:0] IDEXRd,
    input [4:0] IFIDRs1,
    input [4:0] IFIDRs2,
    output fStall,
    output dStall,

    //br_pred
    input branch,
    input br_pred_e,
    input jump,
    output dFlush, eFlush
);

assign fStall = (IDEXdm_rd_ctrl && ((IDEXRd == IFIDRs1) || (IDEXRd == IFIDRs2))) ? 1'b1 : 1'b0;
assign dStall = (IDEXdm_rd_ctrl && ((IDEXRd == IFIDRs1) || (IDEXRd == IFIDRs2))) ? 1'b1 : 1'b0;
assign dFlush = ((branch ^ br_pred_e) || jump) ? 1'b1 : 1'b0;
assign eFlush = ((branch ^ br_pred_e) || jump || fStall) ? 1'b1 : 1'b0;

endmodule
