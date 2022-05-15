module EXMEM (
    input clk,

    input [31:0] alu_out,
    input [31:0] IDEXrf_rd1,
    input [4:0] IDEXRd,
    input [31:0] IDEXpc,

    input IDEXrf_wr_en,
    input [2:0] IDEXdm_rd_ctrl,
    input [1:0] IDEXdm_wr_ctrl,
    input [1:0] IDEXrf_wr_sel,

    output reg [31:0] EXMEMalu_out,
    output reg [31:0] EXMEMrf_rd1,
    output reg [4:0] EXMEMRd,
    output reg [31:0] EXMEMpc,

    output reg EXMEMrf_wr_en,
    output reg [2:0] EXMEMdm_rd_ctrl, //MEM
    output reg [1:0] EXMEMdm_wr_ctrl, //MEM
    output reg [1:0] EXMEMrf_wr_sel
);

always@(posedge clk) begin
    EXMEMalu_out <= alu_out;
    EXMEMrf_rd1 <= IDEXrf_rd1;
    EXMEMRd <= IDEXRd;
    EXMEMpc <= IDEXpc;
    
    EXMEMrf_wr_en <= IDEXrf_wr_en;
    EXMEMdm_rd_ctrl <= IDEXdm_rd_ctrl;
    EXMEMdm_wr_ctrl <= IDEXdm_wr_ctrl;
    EXMEMrf_wr_sel <= IDEXrf_wr_sel;
end

endmodule