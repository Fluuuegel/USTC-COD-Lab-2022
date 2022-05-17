module IFID(
    input clk,
    
    input [31:0]pc_in,
    input [31:0] inst,
    input fStall,

    output reg [31:0] IFIDpc,
    output reg [31:0] IFIDinst,
    
    //hazard_detection
    input dFlush,

    input br_pred_f,
    output reg br_pred_d
);

always@(posedge clk) begin
    if(dFlush) begin
        IFIDpc <= 32'b0;
        IFIDinst <= 32'b0;
        br_pred_d <= 32'b0;
    end
    else if(fStall) begin
        IFIDpc <= IFIDpc;
        IFIDinst <= IFIDinst;
        br_pred_d <= br_pred_d;
    end
    else begin
        IFIDpc <= pc_in;
        IFIDinst <= inst;
        br_pred_d <= br_pred_f;
    end
end

endmodule