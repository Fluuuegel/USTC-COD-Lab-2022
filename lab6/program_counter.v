module program_counter(
    input clk,
    input rst,
    input br,

    //branch prediction signals
    input br_pred_e,
    input br_pred_f,
    input [31:0] br_pred_pc,
    input jump,

    input [31:0] alu_out,
    input fStall,

    input [31:0] pce,
    output reg [31:0] pc,
    output reg [31:0] pcin,
    output [31:0] pc_plus4
);


always@(*) begin
    if(jump) pcin <= alu_out;
    else if(br && ~br_pred_e) pcin <= alu_out;  //预测不跳转但实际跳转
    else if(~br && br_pred_e) pcin <= pce + 4; //预测跳转但实际不跳转
    else if(br_pred_f) pcin <= br_pred_pc;    
    else if(fStall) pcin <= pc;  //idk if branch prediction has conflict with data hazard
    else pcin <= pc_plus4;
end

always@(posedge clk or posedge rst) begin
    if(rst) pc <= 32'h3000;
    else pc <= pcin;
end

assign pc_plus4 = pc + 32'h4;

endmodule