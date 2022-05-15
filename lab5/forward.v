module forward(
    input [4:0] IDEXRs1, IDEXRs2, IDEXRd, EXMEMRd, MEMWBRd,
    input EXMEMrf_wr_en, MEMWBrf_wr_en,
    output reg [1:0] ForwardA, ForwardB
);

always@(*) begin
    if(EXMEMrf_wr_en && (EXMEMRd != 0) && EXMEMRd == IDEXRs1) ForwardA = 2'b10;
    else if(MEMWBrf_wr_en && (MEMWBRd != 0) && MEMWBRd == IDEXRs1) ForwardA = 2'b01;
    else ForwardA = 2'b00;

    if(EXMEMrf_wr_en && (EXMEMRd != 0) && EXMEMRd == IDEXRs2) ForwardB = 2'b10;
    else if(MEMWBrf_wr_en && (MEMWBRd != 0) && MEMWBRd == IDEXRs2) ForwardB = 2'b01;
    else ForwardB = 2'b00;
end

endmodule