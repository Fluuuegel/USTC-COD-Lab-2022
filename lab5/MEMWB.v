module MEMWB(
    input clk,

    input EXMEMrf_wr_en,
    input [1:0] EXMEMrf_wr_sel,
    input [31:0] dm_dout,
    input [31:0] EXMEMalu_out,
    input [4:0] EXMEMRd,
    input [31:0] EXMEMpc,

    output reg MEMWBrf_wr_en,
    output reg [1:0] MEMWBrf_wr_sel,
    output reg [31:0] MEMWBdm_dout,
    output reg [31:0] MEMWBalu_out,
    output reg [4:0] MEMWBRd,
    output reg [31:0] MEMWBpc
);

always@(posedge clk) begin
    MEMWBrf_wr_en <= EXMEMrf_wr_en;
    MEMWBrf_wr_sel <= EXMEMrf_wr_sel;
    MEMWBdm_dout <= dm_dout;
    MEMWBalu_out <= EXMEMalu_out;
    MEMWBRd <= EXMEMRd;
    MEMWBpc <= EXMEMpc;
end

endmodule