module IFID(
    input clk,
    
    input [31:0]pc_in,
    input [31:0] inst,
    input IFIDWrite,

    output reg [31:0] IFIDpc,
    output reg [31:0] IFIDinst,
    
    //hazard_detection
    input dFlush
);

always@(posedge clk) begin
    if(dFlush) begin
        IFIDpc <= 32'b0;
        IFIDinst <= 32'b0;
    end
    else if(!IFIDWrite) begin
        IFIDpc <= IFIDpc;
        IFIDinst <= IFIDinst;
    end
    else begin
        IFIDpc <= pc_in;
        IFIDinst <= inst;
    end
end

endmodule